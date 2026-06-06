# SuSuGiGi 原生機制健檢報告

日期 2026-06-05。唯讀健檢，未改任何檔。
212 個 agent。9 路 × 二輪 + 3 視角反駁 + 漏檢稽核。

## 統計

- 原始發現 77 條
- 進反駁驗證 45 條
- 確認 57 條（broken 12 / drift 45 / 其他 0）
- 待複查 0 條
- 衛生類 35 條（未個別驗）
- 註：需驗發現 55 條超過上限 45，broken 優先，其餘標 unverified

## 總評

這套設定的「散文規範」與「實際機制」大面積對不上，治理護欄基本是空的。最嚴重的三件事：一、四支以路徑為錨的 hook（含兩支會 exit 2 硬擋的 design 對齊與 spec 越界 guard）在規範唯一允許的 worktree 路徑下全部 NO MATCH，等於安全網在合法工作流裡形同拆除。二、push main／刪 remote／force-push／`cat > 任意路徑` 全在 `Bash(git:*)`＋`cat > *` allow＋`defaultMode:auto`＋四檔零 deny/ask 之下無提示直接執行，與 CLAUDE.md 列為最高風險、需明示授權的規則方向相反。三、`Edit/Write(~/.claude/**)` 被 auto 放行，正面推翻「禁 Claude 自改設定/hook」禁令，且該禁令連 hook 兜底都沒有。其次是 products_registry.md 整份是另一台 Windows 機的絕對路徑（`C:\Users\ken.chio\...`），auditor 拿去跑 git -C 會全 fatal，盤點 agent 在本機等同失效。再來是 project CLAUDE.md「產品路徑」段 6 條全指向不存在的 `*App/*Spec` 目錄、是 Claude 找檔的第一參照卻整段死路。建議優先序：先補機制護欄（worktree-aware hook ＋ push/redirect guard ＋ 收窄 self-mod 授權），再修 registry 路徑可移植化，最後清 CLAUDE.md 與 skill 的路徑/編號漂移。

## 最該先修（topRisks）

### 1. [broken] 四個 path-keyed hook 在強制 worktree 工作流下全部 NO MATCH，design 對齊與 spec 越界兩道 exit-2 護欄形同關閉

建議：worktree 路徑 ~/Doc/ai-company-worktrees/<topic>/<layer>-<module>/ 無 noN_product_* 段。讓四 matcher 改認 worktree 形錨點：impl 認 /<topic>/impl-<module>/.../src/(screens|components)、spec 認 /spec-<module>/ 內層 no2_screens、design 認 /design-<module>/project/(10_foundations|20_components|30_screens)、multi-tier 產品偵測補 ai-company-worktrees 並從 <layer>-<module> 前綴解出 layer/module。design-impl-alignment-guard 的 transcript-grep（line 97）與 design_base 推導（line 62）也須一併支援 worktree 形，否則修了 file-matcher 會從『從不觸發』翻成『從不放行』。補一組以真實 worktree 路徑為輸入的 hook 測試鎖約定。走正式 plan mode（動 ~/.claude/hooks/* 受 self-modification 規則約束）。

### 2. [broken] push main／刪 remote／force-push／cat > 任意路徑零機械攔截，且被 permission 主動放行，撞 CLAUDE.md 最高風險授權門

建議：已實測：唯一提到 git push 的 hook 是 stash-guard 的 heredoc 文字，無一支真擋；cat > * 在 project settings.local.json line 99 被 allow，配 Bash(git:*)＋defaultMode auto＋四檔零 deny/ask = 無提示直接跑。建議：(a) 移除 settings.local.json:99 的 Bash(cat > *)（旁邊唯讀 cat .prettierrc 才是當初需要的）；(b) 在全域 settings.json 加 permissions.deny 涵蓋 Bash(git push origin main)、Bash(git push origin --delete:*)、含 --force/-f 打 main 者、Bash(git stash:*)；(c) 更治本補一支 PreToolUse Bash guard，解析 git push 目標與 >/>>/tee 的 redirect target，套 worktree-only 的 no[346]_ 主 git 判定後 exit 2。deny/glob 對 git push 的實際比對要實測。

### 3. [broken] Edit/Write(~/.claude/**) 被 auto 放行，正面推翻 self-modification 禁令，且該禁令零 hook 兜底

建議：settings.json line 51-52 萬用授權 + line 54 auto + line 161 skipAutoPermissionPrompt，讓 Claude 可零提示覆寫自己的 settings/hook/command/skill，與 project CLAUDE.md 自檢#6『預設不行』180 度相反；其他五條自檢至少有一層機械把關，唯獨此條雙層皆空。二擇一：(a) 移除 line 51-52、回到 plan mode 才放行（permission 預設 ask 兜底）；(b) 加 permissions.deny 明列 Edit/Write(~/.claude/settings*.json|hooks/**|commands/**)（deny 優先於 allow），只留 skills/agents/plans 等真要開放的子路徑。可選補一支 self-mod-guard hook，命中敏感路徑時除非 ~/.claude/plans/ 有對應 plan 否則 exit 2。順帶 line 37 Edit(~/.claude/skills/decision_framework_router/**) 已被 line 51 完全涵蓋、為死規則。

### 4. [broken] products_registry.md 全部 path 欄位是 Windows 絕對路徑＋錯誤使用者名 ken.chio，auditor 用它跑 git -C 在本機全 fatal

建議：13 個 path 欄全是 C:\Users\ken.chio\...（host 是 macOS /Users/kenchio，ken.chio 多一點且不存在）。registry 自述為四層 git 權威來源、是 hook 與 auditor 的資料源；multi-tier-alignment-auditor 讀它後對每個 repo 跑 git -C，本機 13 條全 No such file，盤點 agent 等同失效。改成可移植寫法：以 ~/Doc/ai-company 為根的相對路徑（與 launch.json directory 同慣例）由消費端拼，或至少改 ~ 錨點並校正 ken.chio→kenchio。同時違反全域 CLAUDE.md 禁 OS 絕對路徑（但路徑在 yaml code block 內、踩不到 linter）。改前對齊 auditor 取用方式。

### 5. [broken] project CLAUDE.md「產品路徑」段 6 條全指向不存在的 *App/*Spec 扁平目錄

建議：實測 product/SuSuGiGi/SuSuGiGiApp、SuSuGiGiSpec、Hatsuon/HatsuonApp、HatsuonSpec 等全 No such file；真實是 no4_product_specs/<module>/、no6_product_development/<module>/、no3_product_designs/<module>/ 兩層編號結構。這是 Claude 找檔的第一參照、卻整段死路，且與同檔『動工前置』『Design-Impl 對齊』『block-worktree-ios-build hook 提示』用的 no6_product_development 自相矛盾。改寫成實際 module 化結構並列現存 module；L260『如 product/SuSuGiGi/SuSuGiGiApp/』改 no6_product_development/no2_accounting_app/。block-worktree-ios-build.sh L22 的 product/<產品>App 提示一併修。依 .md 修改四步整份讀過。

### 6. [drift] spec-guard.sh 的 PreToolUse 阻擋分支是死碼，只掛 PostToolUse，cross-layer 越界永遠只 warn 不擋

建議：已實測 settings.json 只在 PostToolUse 掛 spec-guard，PreToolUse 三支不含它；script line 48 `if event != PreToolUse then exit 0` 讓 line 47-86 的 exit-2 阻擋路徑永不執行，script 開頭註解卻自稱 PreToolUse blocks。二擇一：(a) 要硬擋則在 PreToolUse Edit|Write 增掛 spec-guard.sh（script 已支援雙 event）；(b) 刻意只 warn 則刪 line 47-86 死碼並改註解。注意若採 (a)，spec-guard 的 file-matcher（line 30 no4_product_specs）同樣有上述 worktree NO MATCH 問題，要一併改認 spec-<module> 形。另 auditor 把 hex 色值列為越界但 spec-guard high/mid pattern 都不含 hex，report 與 enforce 兩端不一致。

### 7. [drift] skill 路徑與層級編號多處漂移：integration_layer 用舊 no3/no5、SKILL.md 整合層漏前綴、spec_writer 斷鏈、product-planner 輸出全死路

建議：逐條：integration_layer.md L68 no3_product_specs/no5_product_development 應為 no4/no6（同檔 L64 自己用對 no2/no2）；SKILL.md L59/L67 no2_product_map/ 應補 no2_product_planning/ 前綴（與自家 integration_layer.md L64、registry 對齊）；spec_writer/SKILL.md L42 指 universal_writing_linter/spec_writing_policy.md 但實際檔名是 universal_writing_policy.md（已實測 MISSING）；product-planner.md L269/L271 輸出至 no3_module_specs/no4_dev_management（已實測兩目錄全不存在）應改 no4_product_specs/<module>、no5_project_management。全部對齊 registry 的 decision_framework_layout 權威命名。

### 8. [drift] registry 狀態語意（TEMPLATE_OK/CONCEPT_ONLY 以 product_repo==null 為閘）與資料區實況矛盾，auditor Step3 狀態判定會落空；多條 product_map_paths 指向空目錄

建議：已實測 LGHT 與 UR 的 product_repo.path 皆非 null，但 registry L266-272 與 auditor L140-141 用 product_repo==null 當 TEMPLATE_OK/CONCEPT_ONLY 的閘 → 兩產品永遠 match 不到、fall through 到錯狀態。校正判據：TEMPLATE_OK 對齊模板實況（repo 非 null、Spec 空殼），CONCEPT_ONLY = product_repo 非 null＋僅 spec_repo＋impl_repo null。同步：accounting/user_management/pronunciation 三個 product_map_paths 都指向不存在子目錄（map 子目錄是 app/ 等平台視角、非 module-id 同名），multi-tier-sync-guard.sh:73 硬編 no2_product_map/${module}/ 的假設對多數 module 不成立，會把 runtime hint 導向空目錄；Hatsuon 該條建議改空陣列並於 status_note 註明待補。

## 同根因分組

### 根因：permission 設定與規範方向相反，加上零 deny/ask 與無對應 hook，使 CLAUDE.md 列為最高風險的治理禁令在執行層全部空轉

- push main／刪 remote／force-push 零機械攔截，且被 Bash(git:*)＋auto 主動放行
- Bash(cat > *) 自動放行任意路徑寫入，繞過三支 Edit/Write 守門 hook
- 全域 settings.json line 51-52 auto-allow Edit/Write(~/.claude/**)，推翻 self-modification 禁令
- self-modification 禁令零 hook 防線：無任何 Edit/Write hook 守 ~/.claude/**
- 四個 settings 檔零 deny/ask，defense-in-depth 完全缺席
- push main／刪 remote／stash 三條高風險禁令只有 advisory hook，無 deny 也無 hard-block
- 動作前 5 秒自檢前兩條（push main／刪 remote）無機械防線，措辭像有閘門
- settings.json line 37 Edit(~/.claude/skills/decision_framework_router/**) 為死規則，被 line 51 完全涵蓋

### 根因：hook matcher 與規範強制的工作流形狀（worktree 路徑、PreToolUse 時機、cwd 偵測）系統性錯位，導致 hook 在最該守的場景下靜默跳過或誤判

- 四個 path-keyed hook 在強制 worktree 工作流下全部 NO MATCH（design 對齊安全網形同關閉）
- design-impl-alignment-guard 第二層 transcript-grep 對 worktree 形 design Read 同樣 miss
- design-impl-alignment-guard.sh line 45 註解與 line 46 邏輯矛盾（聲稱接受 worktree 實際只認主 git）
- spec-guard.sh PreToolUse 阻擋分支是死碼，只掛 PostToolUse，越界永遠只 warn
- branch-pairing-guard 用 pwd 認產品，但 worktree add 流程 cwd 不含產品名，主推流程下基本沉默
- design-impl-alignment-guard 的 transcript-grep 會被自己的拒絕訊息污染，正向有效但反向自解
- markdown-stitch-guard 只攔 Edit、放掉 Write 對 .md 的整檔覆寫
- 三支 hook 硬寫四產品清單，新產品 SOP 未列『擴充 hook』，加第五產品時靜默失效

### 根因：整套設定從 Windows ken.chio 機搬到 macOS kenchio 機後未在地化，留下大量 Windows 絕對路徑、錯誤 username、舊機殘留目錄與 inert 授權

- products_registry.md 全部 path 欄位是 Windows 絕對路徑＋使用者名 ken.chio，auditor 跑 git -C 全 fatal
- self-review 的 find_project_dir 用 max(mtime) 選目錄，候選含 0-transcript 的 Windows 殘留與 SuSuGiGi 子目錄，會選錯目錄回空報告
- claude-code-self-review/SKILL.md 的 project slug 範例是 Windows 殘留且 username 拼錯
- universal_writing_linter/SKILL.md lint 指令標 powershell＋裸 python＋引號內 ~ 不展開，本機照打必失敗
- 全域 settings.local.json 帶 4 條 Windows-only allow entry（robocopy/powershell/gh.exe，用 ken.chio）
- 殘留 Windows 風格 project 目錄 C--Users-ken-chio-Doc-ai-company
- settings.local.json 曾被 git 追蹤並 commit，是跨機污染的傳播途徑
- ai-company 各 repo 無 .gitattributes，eol=lf 統一聲明未落地（跨 Windows/Mac 行尾風險）

### 根因：目錄做過 renumber（specs no3→no4、project_mgmt no4→no5、dev no5→no6）與 token/screen 重構，filesystem 與部分權威檔已跟進，但多份文件/設定/registry 的舊編號與舊檔名沒一起 migrate

- project CLAUDE.md「產品路徑」與「iOS 自驗策略」指向不存在的 *App/*Spec 扁平目錄
- integration_layer.md 仍用舊編號 no3_product_specs/no5_product_development
- decision_framework_router/SKILL.md 整合層路徑漏 no2_product_planning/ 前綴
- product-planner 輸出路徑全部指向不存在的 no3_module_specs/no4_dev_management
- 全域 settings.json 三條 mkdir -p 用 renumber 前的舊目錄（no3_product_specs/no4_project_management/no5_product_development）
- block-worktree-ios-build.sh fallback 提示寫了壞路徑 product/<產品>App
- registry sub_mapping 的 design_glob 指向已被重構掉的 .jsx 檔（data.jsx/foundations.jsx/screens.jsx）
- spec accounting CLAUDE.md 把 token 權威指向不存在的 data.jsx
- 全域 allow list 殘留 cp -r __TRACKED_VAR__ 與 _partb-github-ops.sh 等永不匹配/不存在條目

### 根因：registry 自稱權威配對來源，但 product_map_paths 與狀態語意未與實際 Product Map 佈局對齊，且錯誤經 multi-tier-sync-guard hint 外溢成 runtime 誤導

- registry 與 auditor 的 TEMPLATE_OK/CONCEPT_ONLY 以 product_repo==null 為閘，與模板/概念產品實況矛盾
- registry no2_accounting_app 的 product_map_paths 指向不存在目錄（實際散在 app/）
- registry Hatsuon no1_pronunciation_app 的 product_map_paths 指向空殼目錄
- registry 宣稱的 no2_accounting_app Product Map 子路徑不存在於 filesystem
- UndergroundRemake 磁碟有 no5_project_management 但 registry layout 未列

### 根因：launch.json 落後於實際 worktree 集合，且 spec 的 port 欄位模型未涵蓋 impl-only/純文字 worktree，違反『每新 worktree 必 append、port 最大+1』硬規則

- 8 個 active feat worktree 只登 4 條，import-wizard/paywall 的 impl+spec 共 4 層沒 entry
- 獨立 impl entry 帶 design-canvas port 8769 但該 worktree 無 project/ 可服務
- design port 8766 與 metroPort 8082 跳號，源自 explore-transfer-editor 收工後未回填
- hook 的 metroPort 豁免區間只有 8081-8090，補完未登記 impl 後逼近上限

### 根因：全域 CLAUDE.md 與相關 hook 對 branch 命名 shape 各說各話（feat/r-id-slug vs feat/topic），且 r-id/slug 無定義、guard 無法仲裁

- 全域 CLAUDE.md 修改流程規範用 feat/r-id-slug，其餘權威（plan/worktree/game-* commands）全用 feat/topic
- branch 命名 token r-id 與 slug 全工作區無定義
- exit-plan-branch-guard.sh 只把關 feat/ 前綴，無法仲裁兩種 branch shape 衝突
- exit-plan-branch-guard 的 plan 來源 fallback 取最新 mtime 的 plan 檔，並行 session 下會驗到別人的 plan（目前 dead path）

### 根因：盤點規範列的 worktree 路徑集合與實際命令/檔案系統三方不一致，殘留舊佈局假設

- 盤點段要求掃的 .worktrees 與 _worktrees 兩路徑不存在、game-over/game-clear 也不掃
- git-sync exclude_regex 漏掉盤點規範列的 .worktrees 與 _worktrees 兩個 worktree 家目錄
- /sync-gits 排除清單的 *-worktrees/ 萬用寫法在 agent regex 裡其實只精確列三個固定字串

### 根因：paywall-compliance-notes 主題收尾不乾淨：唯一未 commit 內容未推 remote，且近重名雙主題＋偏離命名慣例帶來混淆風險

- paywall-compliance-notes worktree 帶唯一未 commit 內容、未推任何 remote，force-cleanup 會永久遺失
- paywall-compliance-notes 與合法 paywall-compliance 為易混淆近重名雙主題，且用 <topic>/product/ 偏離 <topic>/<layer>-<module> 慣例
- ai-company-worktrees 有未註冊殘留目錄 + 主 impl git 停在 detached HEAD
- git-sync detached HEAD dirty miss（主 impl git 目前 detached，dirty 不報告）

### 根因：auto-memory 與其引用的機制檔一同 drift，計數/位置/wikilink 落後於現況

- feedback_design_canvas_subnav 的『22 個 screen group』已過時，現為 26（memory 與 design CLAUDE.md 一同落後 code）
- redeem memory 列的殘留位置不全，只寫 payment.md，漏 structure.md 與 index.md
- wikilink 普查少算一條並錯置一條歸屬（連字號形 vs 底線形）

### 根因：審查/盤點類 agent 的守門邏輯與本 repo 的 global-only agent 佈局衝突，使其在最該服務的 repo 自我癱瘓或無法執行轉派

- agent-workflow-manager 把 project agents 設成執行前提，本 repo 無 project agents 故必觸發 hard-stop
- product-planner 引用 5 個生態系內不存在的 sibling agent 與 Chief of Staff
- multi-tier-alignment-auditor 與 spec-guard 對 hex 色值等邊界政策 report 與 enforce 兩端不一致

## 確認 · 壞掉 broken（12）

### 1. [skills] products_registry.md 全部 path 欄位是 Windows 絕對路徑、使用者名也錯（ken.chio vs kenchio），auditor 用它跑 git -C 會全失敗

- 證據：~/.claude/skills/decision_framework_router/products_registry.md 全部 path: 欄位，如 line 21 `path: C:\Users\ken.chio\Doc\ai-company\product\SuSuGiGi`、line 37/39/42 等。實機是 macOS、家目錄 /Users/kenchio/（無 dot、無 C 槽）。消費端 ~/.claude/agents/multi-tier-alignment-auditor.md line 8 + Step 1（line 42/45/48）明文『讀取 products_registry.md』後對『其所有已註冊 git』跑 `git -C <repo> log/diff/branch`，repo 即取自 path: 欄位 — 這些路徑在本機不存在，auditor 每個 git -C 都會失敗。另全域 ~/.claude/CLAUDE.md『路徑引用規則』明文禁止 .md 內文出現 C:\ 與 /Users/username 絕對路徑，本檔整份違反。
- 為何是問題：registry 是四層 git 配對的『權威來源』（檔頭自述）、是 hook 與 auditor 的資料源。path 欄位是跨機遷移殘留（從 Windows ken.chio 機搬到 macOS kenchio 機沒更新），對 auditor 是功能性 broken，對規範是 OS 絕對路徑違規。
- 建議：把所有 path: 改成以產品根可重組的相對表示（如僅留 product 目錄相對路徑，由 ~/Doc/ai-company 拼），或至少更新成本機正確家目錄並去掉 C 槽；同時校正 ken.chio→kenchio。改前整份讀過、與 auditor 取用方式對齊。

### 2. [skills] spec_writer/SKILL.md 指向 universal_writing_linter/spec_writing_policy.md，但實際檔名是 universal_writing_policy.md（broken 連結）

- 證據：~/.claude/skills/spec_writer/SKILL.md line 42 表格列『通用格式，所有層級 | `~/.claude/skills/universal_writing_linter/spec_writing_policy.md`』。實際 ls universal_writing_linter/ 只有 universal_writing_policy.md，無 spec_writing_policy.md（test -f 確認 MISSING）。全 repo grep 此錯名僅此一處。
- 為何是問題：spec_writer 是 SuSuGiGi 主線 skill，這條是它指向通用格式政策的唯一連結。檔名不符 → 任何人/agent 照此路徑開檔會落空，通用格式規則形同斷鏈。
- 建議：把 line 42 的 spec_writing_policy.md 改為 universal_writing_policy.md（或反向把檔案改名並更新所有引用，但目前只有此處引用，改 SKILL.md 較省）。

### 3. [claudemd-global] multi-tier-alignment-auditor reads registry Windows paths as authoritative; on this Mac all resolve-fail so it audits nothing

- 證據：auditor.md L14 reads registry; Step1 L37-60 runs git -C <repo> per tier where repo=registry path field; L216 path authoritative, L217 skip if missing. Every path is Windows C: ken.chio; host home /Users/kenchio. The auditor is the only real consumer of the path field (guard builds from $HOME).
- 為何是問題：Round 1 rated drift, betting it breaks only if a future tool reads path. The auditor reads path NOW, every git -C fails, it skips all gits. Round 1 never read how the auditor uses path.
- 建議：Make registry path portable, or have the auditor build paths from decision_framework_layout + $HOME.

### 4. [claudemd-project] 產品路徑段六條全部指向不存在的路徑

- 證據：~/Doc/ai-company/CLAUDE.md L31-37「產品路徑」段。實際 ls：product/SuSuGiGi/SuSuGiGiApp/、SuSuGiGiSpec/、product/Hatsuon/HatsuonApp/、HatsuonSpec/、product/LiquidGlassHeaderTemplate/LiquidGlassHeaderTemplate/、product/UndergroundRemake/UndergroundRemakeSpec/ 全部 No such file or directory。實際結構是 product/SuSuGiGi/no6_product_development/no2_accounting_app/（impl）、no4_product_specs/no2_accounting_app/（spec）、no3_product_designs/no2_accounting_app/（design），即 no[1-6]_*/<module>/ 兩層編號結構。
- 為何是問題：這段是 project CLAUDE.md 唯一明列各產品具體路徑的地方，是 Claude 動工找檔的第一參照。六條全錯會直接把人導到不存在的路徑；與本檔自己其他段（動工前置、Worktree、Design-Impl、hook 註解）一致使用的 no6_product_development/<module> 結構自相矛盾。products_registry.md 也用 noN_ 結構，可見此段是早期 *App/*Spec 命名遺留、整片沒跟著 migrate。
- 建議：把六條改寫成實際結構，建議直接對齊 products_registry 的 module 寫法，例如 SuSuGiGi impl = product/SuSuGiGi/no6_product_development/no2_accounting_app/、SuSuGiGi spec = no4_product_specs/no2_accounting_app/、design = no3_product_designs/no2_accounting_app/；Hatsuon/LiquidGlass/UndergroundRemake 同理改 noN_ 結構。不要保留 *App/*Spec 別名。

### 5. [claudemd-project] 自我修改防線（自檢#6）無 hook 把關，且 permission 反向 auto-allow

- 證據：~/Doc/ai-company/CLAUDE.md L12 自檢#6 稱 Edit ~/.claude/settings.json / hooks/*.sh / commands/*.md「預設不行（防 Claude 自主修改自己的設定 / hook / command）」，只有正式 plan mode 例外。實測：grep ~/.claude/hooks/*.sh 無任何 hook body 攔截 .claude/settings|hooks|commands 的 Edit/Write。同時 ~/.claude/settings.json permissions.allow 含 'Edit(~/.claude/**)' 與 'Write(~/.claude/**)'，且 defaultMode='auto'、deny 與 ask 皆 NONE。
- 為何是問題：聲稱的是硬防線（防 Claude 自主改自己的 config/hook/command），但機制上：(a) 沒有 PreToolUse hook 擋這類路徑；(b) permission 設定不只沒擋、還把整個 ~/.claude/** 樹的 Edit/Write 列入 allow 並 auto 模式，等於免確認放行——與「預設不行」正好相反。plan-mode 例外的基礎設施（~/.claude/plans/ 存在、exit-plan-branch-guard 存在）有，但那只在 ExitPlanMode 檢查 branch name，完全不 gate 這些檔的編輯。結果是規範以為有閘門、實際全開。
- 建議：二擇一收斂：要嘛補一支 PreToolUse Edit|Write hook，偵測 target 命中 ~/.claude/settings.json|hooks/*.sh|commands/*.md 時 exit 2 擋下（並認 plan mode 例外，如比對 ~/.claude/plans/ 最新檔有列該路徑才放行，與 exit-plan-branch-guard 同套讀法）；要嘛把 settings.json allow 內的 'Edit(~/.claude/**)'、'Write(~/.claude/**)' 收窄或移到 ask，至少別 auto 放行整棵樹。在補強前，自檢#6 的『hook 把關』語感與現況不符，宜先把該條措辭改成純自律提醒。

### 6. [claudemd-project] products_registry.md 所有路徑欄位是 Windows 絕對路徑，本機（macOS）失效

- 證據：~/.claude/skills/decision_framework_router/products_registry.md L21-173：product_repo.path、各 module 的 design_repo/spec_repo/impl_repo.path 全部是 'C:\Users\ken.chio\Doc\ai-company\...'。本機是 macOS（env Platform darwin、家目錄 /Users/kenchio/）。此檔被 ~/.claude/hooks/multi-tier-sync-guard.sh L45、L73 明確要求 Claude 反查（『請對照 products_registry.md 反查受影響的 module』）。project CLAUDE.md 多處（動工前置 L48、Design-Impl L168、Worktree、四層 git 規範）把它指為權威配對表。
- 為何是問題：這是被 hook 與 CLAUDE.md 同時當『權威配對來源』的檔，但每個 path 欄位都指向另一台 Windows 機的磁碟路徑。在本機任何依 path 欄位做事的流程（auditor 反查、跨層路徑解析）都會落空。同時違反全域 CLAUDE.md L3-11『禁止 OS 絕對路徑』（C:\ 開頭明列為禁止格式）。remote 欄位是對的，壞的是 path 欄位——典型跨機搬遷後沒更新本機路徑。
- 建議：把所有 path 欄位從 Windows 絕對路徑改為可移植寫法。最穩是改成相對於 ai-company 根的相對路徑（如 product/SuSuGiGi/no6_product_development/no2_accounting_app），與 launch.json 的 directory 同慣例；若消費端需要絕對路徑，至少改成 ~ 錨點。順帶確認 multi-tier-sync-guard / multi-tier-alignment-auditor 讀此檔時對路徑欄位的預期格式。

### 7. [commands] products_registry.md 全部 repo path 是 Windows 路徑且使用者名也不對，auditor agent 拿來 git -C 在本機直接 fatal

- 證據：products_registry.md 13 個 path 欄全是 `C:\Users\ken.chio\Doc\ai-company\...`（如 line 21、37、40、43、92）。本機家目錄是 /Users/kenchio，`ls -d /Users/ken.chio` 不存在（`ken.chio` 多一個點，與 Mac 的 `kenchio` 不同）。檔頭 line 5-8 宣告本檔為「四層 git 的路徑查詢」「hook 與 auditor 的資料源」。multi-tier-alignment-auditor.md line 14 讀此 registry、line 42/45/48 對每個 repo 跑 `git -C <repo> ...`，全文 grep 無任何 Windows→mac 路徑轉換指引。實測 `git -C 'C:\Users\ken.chio\Doc\ai-company\product\SuSuGiGi' status` 回 `fatal: cannot change to ...: No such file or directory`。
- 為何是問題：registry 被宣告為 auditor/hook 的權威路徑源，但每條路徑都指向另一台 Windows 機、且連使用者名都錯，本機完全無法解析。multi-tier-alignment-auditor 照字面執行 git -C 會 13 條全 fatal，等於這個盤點 agent 在本機形同失效，得逐條人腦翻譯路徑（且 naive C:\→/ 替換還會落在不存在的 ken.chio 家目錄）。這些路徑在 yaml code block 內，踩不到 CLAUDE.md 路徑 linter（程式碼區塊例外），所以無 hook 攔得到，純靠人工發現。
- 建議：把 13 個 path 欄改成可移植寫法（以 ~/.claude 或專案相對根錨定，如 `~/Doc/ai-company/product/SuSuGiGi`），或在 auditor 內加一步把 registry path 正規化到本機 $HOME 再餵 git -C。順帶修 `ken.chio`→`kenchio`。不在本次修改。

### 8. [補掃] 四個 path-keyed hook 在強制 worktree 工作流下全部失效（核心 design 對齊安全網形同關閉）

- 證據：CLAUDE.md 強制所有產品改動在 worktree 內進行，命名 `~/Doc/ai-company-worktrees/<topic>/<layer>-<module>/`（磁碟實證：`git -C .../no6_product_development/no2_accounting_app worktree list` 列出 `import-wizard-redesign/impl-no2_accounting_app` 等）。worktree 路徑不含任何 `noN_product_*` 段。用真實 worktree 路徑跑四 hook 原始 matcher，全部 NO MATCH 並提早 exit 0：
1) design-impl-alignment-guard.sh line 46 `grep -qE '/product/[^/]+/no6_product_development/[^/]+/'` → impl worktree 檔 `.../impl-no2_accounting_app/src/screens/Settings/DataManagementScreen.tsx` NO MATCH → line 47 exit 0。此 hook 是 PreToolUse exit-2 BLOCKER，CLAUDE.md line 14、172-174 明文宣稱「hook 會擋未讀過 design 的修改」「在 PreToolUse 階段攔截」——但在唯一允許的 worktree 路徑下它從不觸發。
2) spec-guard.sh line 30 `grep -qE 'no4_product_specs/.*\.md$'` → spec worktree md `.../spec-no2_accounting_app/no2_screens/*.md` NO MATCH（worktree 內層是 `no2_screens/`，無 `no4_product_specs` 段）→ exit 0。這也是 exit-2 跨層越界 BLOCKER，等同關閉。
3) verification-report-guard.sh line 16-21 case（`*/no6_product_development/*.tsx`、`*/no3_product_designs/*.jsx`）→ impl 與 design worktree 路徑 hit=0，驗證三件套提醒不注入。
4) multi-tier-sync-guard.sh 產品偵測（line 22-28 `*SuSuGiGi*`，worktree 路徑無此字面）與 layer 偵測（line 38-94 `*/noN_product_*/*`）兩段皆 NO MATCH → exit 0，四層配對提醒不出。
對照組 worktree-only-guard.sh line 29 對 worktree 路徑同樣 NO MATCH 但這對它正確（放行 worktree、line 29 對主 git 路徑 exit 2 BLOCK 正常）。
- 為何是問題：這四條規則的整個價值是在 mandated workflow 裡攔下錯誤——design 對齊（exit 2 擋未讀 design 的 UI 改）、spec 跨層越界（exit 2 擋 token/SF Symbol/RN API 寫進 spec）、四層同步提醒、瀏覽器可預覽改動的驗證提醒。但 CLAUDE.md 同時又強制所有改動只能在 worktree 內。兩條規則互斥：照規範在 worktree 改 = 四 hook 全部靜默跳過。最嚴重的是 design-impl-alignment-guard 與 spec-guard 是 exit-2 真正會阻擋的 guard，使用者與 CLAUDE.md 都以為它們在守門，實際在唯一合法路徑下從不執行，安全網形同拆除。9 路前掃報「works, exit 2 when triggered」是因為餵的是主 git 形 path（hook 測試夾具 `~/.claude/hooks/tests/` 也只有主 git 形、零 worktree 引用），從沒測過 worktree path 形狀。
- 建議：讓四個 matcher 同時認得 worktree 路徑形狀。worktree 路徑無 `noN_product_*` 段，需改用其他錨點：(a) impl 認 `/ai-company-worktrees/[^/]+/impl-[^/]+/` 或泛化成 `(no6_product_development|impl)-?[^/]*/.*src/(screens|components)`；(b) spec 認 `/spec-[^/]+/` 且內層走 `no2_screens` 等；(c) design 認 `/design-[^/]+/project/(10_foundations|20_components|30_screens)`；(d) multi-tier 產品偵測補 `*ai-company-worktrees*` 並從 `<layer>-<module>` 前綴解出 layer 與 module。同時 design-impl-alignment-guard 的 transcript-grep（見下一條）與 design_base 推導路徑也要一併支援 worktree 形。建議補一組以真實 worktree 路徑為輸入的 hook 測試，鎖住此約定，避免再次回歸。此為唯一最高價值缺口，建議走正式 plan mode 動 `~/.claude/hooks/*` 與 `~/.claude/settings.json` 範圍外的修補（hook script 修改受 self-modification 規則約束）。

### 9. [補掃] design-impl-alignment-guard 第二層也壞：transcript-grep 對 worktree 形 design Read 同樣 miss

- 證據：design-impl-alignment-guard.sh line 97 `design_pattern="product/$product/no3_product_designs/$module/project/(10_foundations|20_components|30_screens)"`，line 99 用它 grep transcript 判斷「是否讀過對應 design」。但 worktree 工作流下使用者 Read 的 design 檔路徑是 `.../design-no2_accounting_app/project/10_foundations/...`（無 `no3_product_designs` 段）。實測：把一條 worktree 形 design Read 字串餵這個 pattern → NO MATCH。design_base 推導（line 62 `$HOME/Doc/ai-company/product/$product/no3_product_designs/$module/project`）也固定指主 git。
- 為何是問題：這是同一支 hook 的第二個獨立失效點。即使把上一條的 file-matcher（line 46）修好讓 hook 對 worktree impl 檔觸發，line 97 的 transcript-grep 仍會因為使用者在 worktree 形路徑下讀 design 而 NO MATCH，於是 hook 會誤判「沒讀過 design」並 exit 2 擋下——把「靜默放行」變成「永遠誤擋」，同樣不可用。兩個失效點必須一起修，只修 file-matcher 會讓 guard 從不執行翻轉成從不放行。
- 建議：line 97 的 design_pattern 與 line 62 的 design_base 都要支援 worktree 形：pattern 放寬成同時匹配 `no3_product_designs/<module>/project/...` 與 `design-<module>/project/...`；design_base 在偵測到當前改的是 worktree 檔時，對應去找同 worktree 的 `design-<module>/project` 而非主 git。與上一條合併在同一次修補處理。

### 10. [補掃] git push origin main / 刪 remote / force-push 零機械攔截，且被 permission 設定主動放行——撞 CLAUDE.md 兩條最高風險授權門

- 證據：全域 ~/.claude/settings.json line 7 `"Bash(git:*)"` + line 54 `"defaultMode": "auto"` + line 161 `"skipAutoPermissionPrompt": true`：`Bash(git:*)` 是 prefix allow，吃下 `git push origin main`、`git push origin --delete <branch>`、`git push --force`，全部自動跑、零 prompt。四層 settings 皆無 deny/ask：grep `deny` 於兩份 tracked settings.json 均 exit 1；兩份 settings.local.json（~/.claude 與 ~/Doc/ai-company/.claude）只有 allow。五支 Bash PreToolUse hook 無一攔 push——safe-ops-guard.sh:20 只配 rm/robocopy、branch-pairing-guard.sh:27-33 只配 branch 建立且 line 91 恆 exit 0、stash-guard.sh:32 只配 git stash 且 line 46 恆 exit 0、server-launchjson-guard.sh:41-45 只配 server port、project block-worktree-ios-build.sh:12 只配 iOS build。跨 hook grep `git push|origin main|--delete|--force` 唯一命中是 stash-guard.sh:39 的 heredoc 文字。main-on-clean-main-guard.sh:23 是 Stop hook 恆 exit 0（push 已發生後才印警告）。對照 ~/Doc/ai-company/CLAUDE.md line 7-8：『git push origin main…需使用者明說 merge 或 push main』『git push origin --delete…需使用者明說刪 remote』——明文列為兩條最高風險、需顯式授權的操作。
- 為何是問題：規範把這兩件事定為全檔最高風險、最需要授權確認的操作（『動作前 5 秒自檢』第 1、2 條），但實際機制不只是沒攔，是 permission 設定主動把它們設為 auto-run 無 prompt。授權門純靠散文自律，而自律對象（Claude）正是被 skipAutoPermissionPrompt + Bash(git:*) 解除摩擦的那一方。一句 `commit and push`、一次 context compact 後的誤判、或把 feat 的 push 誤打成 main，都能零阻力推上 main 或刪掉 remote branch，且 force-push 對 main 在規範裡是絕對禁止（全域 CLAUDE.md『--force-with-lease 絕不可對 main 使用』）卻同樣無攔截。這是 broken：規範聲稱的安全邊界與實際機制方向相反。
- 建議：加一支 PreToolUse Bash guard（例如 push-main-delete-guard.sh），對 `git push` 目標為 main/master、`git push * --delete`、以及任何 `--force`/`-f` 打 main 的命令 exit 2 攔截，僅在偵測到授權訊號時放行（如環境變數由 /game-stop、/game-clear 設置，或命令本身來自這些 command 流程）。或最小成本：在 settings.json 加 `permissions.ask` 規則涵蓋 `Bash(git push:*)` 與 `Bash(git push origin --delete:*)`，把這兩類從 auto 降為每次詢問。注意 ask/deny 的 git push 樣式比對需驗證實際生效（prefix 比對對 `git push origin main` 的匹配行為要實測）。本 finding 只報問題、不代為修改。

### 11. [補掃] 全域 settings.json line 51-52 auto-allow `Edit/Write(~/.claude/**)`，直接推翻 self-modification 禁令

- 證據：`~/.claude/settings.json` line 51 `"Edit(~/.claude/**)"`、line 52 `"Write(~/.claude/**)"`，搭配 line 54 `"defaultMode": "auto"`。對照 project `CLAUDE.md` line 12 自檢#6：`Edit ~/.claude/settings.json / hooks/*.sh / commands/*.md 預設不行（防 Claude 自主修改自己的設定 / hook / command）`，唯一例外是正式 plan mode 流程。permissions 區塊無 deny／ask（grep 三個 settings 檔零命中）。
- 為何是問題：規範白紙黑字說預設禁止改自己的 settings／hooks／commands／skills，理由明寫『防 Claude 自主修改自己的設定 / hook / command』；但 permission 層用 `~/.claude/**` 萬用授權 + auto 模式，讓 Claude 可在零 prompt 下覆寫自己的 hook、settings、command、skill——正是規則要防的事。規範與機制 180 度對撞，且這條授權使整個 self-mod 防線形同虛設。這是治理型 broken：聲稱的禁令在執行層被反向打開。
- 建議：二擇一收斂，使其與自檢#6 一致：(a) 直接移除 line 51-52 兩條 `~/.claude/**` 授權，回到『預設不行、走 plan mode 才放行』；或 (b) 若確實要保留部分自助能力，改用 `deny` 區塊把 `Edit/Write(~/.claude/settings.json)`、`Edit/Write(~/.claude/hooks/**)`、`Edit/Write(~/.claude/commands/**)` 明列封鎖（deny 優先於 allow），只留真正想開放的子路徑。注意 plan-mode 例外無法靠 permission 表達，仍需人工守。不在此次修改。

### 12. [補掃] Bash(cat > *) 自動放行任意路徑寫入，完全繞過三支 Edit/Write 守門 hook

- 證據：授權來源 ~/Doc/ai-company/.claude/settings.local.json:99 `"Bash(cat > *)"`。配合 ~/.claude/settings.json:54 `"defaultMode": "auto"`，且 4 個 settings 檔皆無 deny/ask 清單（grep 'deny'|'ask' 零命中）→ `cat > <任意路徑>` 無提示直接執行。三支該擋的守門 hook 全失效：(1) worktree-only-guard.sh 只讀 `tool_input.get('file_path')`（hook 內 python，第 38 行附近）且在 settings.json 掛 `Edit|Write` matcher，Bash 呼叫的 payload 只有 `tool_input.command`、沒有 `file_path`，hook 拿到空字串第一個 `if [ -z "$file" ]; then exit 0` 直接放行——何況 matcher 是 Edit|Write 根本不對 Bash 觸發；(2) design-impl-alignment-guard.sh 同樣只讀 file_path、同掛 Edit|Write；(3) markdown-stitch-guard.sh 同掛 Edit|Write。Bash matcher 下的 5 支 hook（safe-ops / branch-pairing / stash / server-launchjson / block-worktree-ios-build）逐支讀過，全部只比對特定指令前綴（rm -rf、git stash、git checkout -b、http.server、xcodebuild 等），沒有一支檢查 redirection 寫入目標。
- 為何是問題：整套 ai-company 強規則的地基是「產品 no[346]_ 路徑的寫入一律走 worktree、且 impl UI 必先讀 design」，而這個地基完全建立在 Edit/Write 會被攔截的假設上。`cat > ~/Doc/ai-company/product/SuSuGiGi/no6_product_development/.../theme.ts` 可在 defaultMode:auto 下無提示寫進主 git、跳過 worktree 隔離、跳過 design 對齊檢查。CLAUDE.md 動作前 5 秒自檢明列「Edit/Write 主 git 路徑下 product/<產品>/no[346]_* 任一檔 — 不行，必須先在 worktree 內」「Edit/Write 任何產品 impl UI 檔 — 必須先 Read 對應 design」，但這兩條的機械把關只攔 Edit/Write 工具、攔不到 Bash heredoc。同時 Bash 工具規約（CLAUDE.md 提示優先用專用工具、避免 cat/echo）只是文字自律、無機制兜底。等於主 git 防護有一條後門大開。
- 建議：建議移除 settings.local.json:99 的 `Bash(cat > *)`（這是過去某次 session 自動學習累積的過寬授權，旁邊 90-94 行的 `cat .prettierrc` 等唯讀 entry 才是當初真正需要的）。若確有「用 shell 寫檔」需求，改為窄授權（限定具體檔名/目錄）而非 `> *`。更根本的兜底：在 Bash matcher 增一支 redirect-target guard，解析 command 內 `>`/`>>`/`tee` 的目標路徑，套用與 worktree-only-guard 相同的 no[346]_ 主 git 判定。皆為建議，不在本次執行。

## 確認 · 漂移 drift（45）

### 1. [hooks] spec-guard.sh 的 PreToolUse 阻擋分支是死碼——只掛 PostToolUse，cross-layer 越界永遠擋不住只會 warn

- 證據：~/.claude/settings.json 只在 PostToolUse(matcher Write|Edit) 掛 spec-guard.sh，PreToolUse 沒掛（python 列舉確認：spec-guard 僅出現於 PostToolUse）。但 ~/.claude/hooks/spec-guard.sh 第 47-86 行是完整 PreToolUse 阻擋分支：`if [ "$event" != "PreToolUse" ]; then exit 0; fi` 之後對 high_pattern（如 *_TOKENS:、SF Symbols、react-native-* 等）命中時 `exit 2`。script 開頭註解第 4 行明寫『PreToolUse: blocks new high-signal cross-layer violations』。因為 hook event 永遠是 PostToolUse，這整段阻擋路徑從不執行。
- 為何是問題：規範（script 自述 + spec_writer/cross_layer_boundary_policy.md 的精神）聲稱 Spec 高信號越界會被『阻擋寫入』，實際機制只在寫入後印 stderr backstop 提醒、檔案照寫進去。聲稱的硬攔截不存在，Spec 越界靠自律。這是『規範聲稱 vs 實際機制』的典型對不上。
- 建議：二擇一：(a) 若要硬擋，在 ~/.claude/settings.json 的 PreToolUse 增掛 matcher Edit|Write -> spec-guard.sh（script 已支援雙 event，無需改碼）；(b) 若刻意只 warn，刪掉 spec-guard.sh 第 47-86 行死碼並改掉開頭註解，讓 script 自述與實際掛載一致。不要兩者並存造成『讀 script 以為會擋、其實不會』。

### 2. [hooks] 三支 hook 硬寫四產品清單，但『新產品 SOP』與全域 CLAUDE.md 都沒列『擴充 hook』——加第五個產品時三支 guard 靜默失效

- 證據：硬寫產品清單的三支：~/.claude/hooks/worktree-only-guard.sh 第 29 行 grep '(SuSuGiGi|Hatsuon|LiquidGlassHeaderTemplate|UndergroundRemake)'、branch-pairing-guard.sh 第 41-58 行 case、multi-tier-sync-guard.sh 第 22-28 行 case，三者對未列產品都 fall-through `exit 0`。products_registry.md『### 新產品』(第 279-285 行) 只要求更新 products 清單與建目錄；全域 ~/.claude/CLAUDE.md『新增產品 SOP』只說『同步更新三處——註冊表、實體目錄、對應 repo 的 CLAUDE.md』。兩處都沒提這三支 hook。
- 為何是問題：SOP 漏了一個必改點。第五個產品註冊後，worktree 強制、branch 配對提醒、跨層同步提醒會對它全部靜默無效，使用者以為有護欄其實沒有，且不會有任何報錯提示。這是擴充時才引爆的潛在 broken，現在記為 drift。
- 建議：在 products_registry.md『### 新產品』與全域 CLAUDE.md『新增產品 SOP』各補一條：新增產品需同步把 product_id 加進 worktree-only-guard.sh、branch-pairing-guard.sh、multi-tier-sync-guard.sh 三支的產品清單。或更治本——讓三支改從 products_registry.md 動態讀產品清單，消除硬寫。

### 3. [hooks] permission allowlist 開了 Edit/Write(~/.claude/**)，正面廢掉 CLAUDE.md「禁 Claude 自改設定/hook/command」的護欄

- 證據：全域 ~/.claude/settings.json 第 51-52 行 allow 清單含 `Edit(~/.claude/**)` 與 `Write(~/.claude/**)`，且第 54 行 defaultMode 為 `auto`。但 project ~/Doc/ai-company/CLAUDE.md 第 12 行「動作前 5 秒自檢」硬規則寫明：Edit `~/.claude/settings.json` / `~/.claude/hooks/*.sh` / `~/.claude/commands/*.md`『預設不行（防 Claude 自主修改自己的設定 / hook / command）』，唯一例外是正式 plan mode 流程。auto + allow 萬用字元等於對這些路徑的所有 Edit/Write 自動放行，連 permission prompt 的摩擦都拿掉。
- 為何是問題：典型『規範聲稱 vs 實際機制對不上』。CLAUDE.md 聲稱有一道防自改護欄，但那條純靠自律（無 hook 強制），而 settings.json 的 permission 又主動把唯一會讓 Claude 停手的 prompt 摩擦移除。`~/.claude/**` 比 CLAUDE.md 列的三類更寬，連 agents、skills、plans 一併放行。結果是『該擋的剛好被 auto 放行』，護欄形同虛設。
- 建議：三擇一，由使用者定調：(a) 若真要防自改，把第 51-52 行兩條 allow 收窄或移除，讓對 settings/hooks/commands 的 Edit 回到需 prompt；(b) 若信任自律、刻意放行，刪掉或改寫 CLAUDE.md 第 12 行那條規則，別讓文件聲稱一個機制不提供的保護；(c) 折衷——allow 只保留非敏感子路徑（如 ~/.claude/plans/**），settings/hooks/commands 排除在外。不要 allow 全放、CLAUDE.md 又寫禁止，兩者打架。

### 4. [hooks] branch-pairing-guard 用 pwd 認產品，但 CLAUDE.md 主推的 git -C <主git> worktree add 從 ai-company 根跑、cwd 不含產品名，實測 56/98 次靜默跳過配對檢查

- 證據：~/.claude/hooks/branch-pairing-guard.sh 第 38 行 `pwd_str=$(pwd)`，第 41-58 行用 cwd 是否含 SuSuGiGi/Hatsuon/... 來認產品，第 58 行 `*) exit 0` 對不含產品名的 cwd 直接放行。但 ~/Doc/ai-company/CLAUDE.md 第 104 行的 canonical 開工指令是 `git -C <該層主 git> worktree add ~/Doc/ai-company-worktrees/... -b feat/<topic> main`——產品在 `-C` 參數與 worktree 路徑裡、不在 cwd。對全部 transcript 比對：worktree-add -b 共 98 次，cwd 不含產品名 63 次，其中 56 次命令本體確實指向真實產品層 git（如 `git -C ~/Doc/ai-company/product/SuSuGiGi/no4_product_specs/...`），這 56 次 guard 全部 exit 0 沒檢查。
- 為何是問題：guard 自述目的是『建 branch 時若配對 repo 缺同名 branch 就提醒』，但它認產品的方式（cwd）與規範強制的開工方式（從根 cd、用 -C 指主 git）系統性錯位。結果是在 CLAUDE.md 最主推的全員 worktree 流程裡，配對提醒幾乎不觸發。warn-only（exit 0）故非阻塞，但設計的安全價值大半落空——第一輪把它列入『matcher vs 邏輯 OK』、未測實際 cwd。
- 建議：改認產品的來源：除了 cwd，再從命令字串解析 `-C <path>` 的值與 worktree 目標路徑，任一含產品名就據以定位 product_root。或更穩——對 worktree-add 分支，直接從 `-C` 後的路徑 git rev-parse 出 toplevel 再比對。現行純靠 pwd 在主推流程下基本沉默。

### 5. [hooks] design-impl-alignment-guard 的 transcript-grep 會被自己的拒絕訊息污染——第一輪「實測有效」信心過高

- 證據：~/.claude/hooks/design-impl-alignment-guard.sh 第 97 行 grep pattern 為 `product/$product/no3_product_designs/$module/project/(10_foundations|20_components|30_screens)`，掃整份 transcript 命中即放行。但同檔第 104-122 行的拒絕訊息把 `${design_base}/10_foundations/` 等列出，展開後正是 `.../no3_product_designs/no2_accounting_app/project/10_foundations/`——本機模擬確認該訊息自身就 match 第 97 行 pattern。對 transcript 比對：真正 runtime 觸發 6 次，6 次拒絕訊息全部落進 transcript 且全部自我滿足 grep（其一 b3cf0b03 經查：觸發前無任何真實 design Read，但觸發紀錄本身已含 grep-able 路徑）。意即 guard 一旦擋一次、Claude 後續任一訊息又提到該 design 路徑（極常見），同檔的下一次 Edit 就會因 transcript 已含路徑而放行，無需真的讀過 design。
- 為何是問題：放行判據是『transcript 內出現過該 design 路徑字串』，但 guard 的拒絕輸出、Claude 覆述、使用者貼路徑都會讓字串出現，與『真的 Read 過 design 檔』不等價。grep 不分『誰寫的、是不是 file_path』。第一輪明確說此機制『實測有效』且列為高信心 OK，但只驗了正向（讀過會放行），沒驗反向（被擋後訊息回灌是否反而自解）。這是信心過高的判斷。當前 transcript 未見『擋後同檔重試』被實際走到，故記 medium 而非 high。
- 建議：收緊判據，二擇一：(a) grep 只認 Read 工具的 file_path 欄位含 design 路徑（解析 transcript 的 tool_use/tool_result 結構，而非整檔字串 grep）；(b) 拒絕訊息別把可被 grep 的完整 design 路徑原樣印出，改用主題描述或拆散路徑，避免自我滿足。同時把這條從『OK』改記為已知弱點。

### 6. [skills] decision_framework_router/SKILL.md 整合層路徑漏 no2_product_planning/ 前綴，與自家 integration_layer.md 及 registry 矛盾

- 證據：~/.claude/skills/decision_framework_router/SKILL.md line 59 寫整合層 = Product git 的 `no2_product_map/<module_id>/`。但同 skill 的 integration_layer.md line 64 寫 `no2_product_planning/no2_product_map/`，registry line 26/46 也是 `no2_product_planning/no2_product_map/`。實機 ls 確認：SuSuGiGi 無頂層 no2_product_map/，真實路徑在 no2_product_planning/no2_product_map/。同檔 line 67-68 四層配對段也用 `no2_product_map/<module_id>/` 同樣漏前綴。
- 為何是問題：SKILL.md 是路由總表、最常被讀。它把整合層指到一個不存在的頂層目錄，與自家 sub-file 和權威 registry 不一致，照它判斷會找錯層。
- 建議：SKILL.md line 59 與 line 67 的 `no2_product_map/` 補成 `no2_product_planning/no2_product_map/`，與 integration_layer.md line 64 對齊。

### 7. [skills] integration_layer.md 用 no3_product_specs/ 與 no5_product_development/，編號錯（應為 no4 / no6）

- 證據：~/.claude/skills/decision_framework_router/integration_layer.md line 68：『目錄名與 `no3_product_specs/<module_id>/` 及 `no5_product_development/<module_id>/` 逐字一致』。但 registry（line 29-31）與實機目錄都是 no4_product_specs/ 與 no6_product_development/（ls 確認 SuSuGiGi 有 no4_product_specs、no6_product_development，無 no3_product_specs/no5_product_development）。同檔 line 64 自己用對 no2/no2 卻在 line 68 用錯 no3/no5。
- 為何是問題：spec/impl 層編號是四層 git 協作的硬骨架，整份規範與 hook 都用 no4/no6。這裡 no3/no5 是過時編號殘留，會誤導讀者以為 spec 在 no3、impl 在 no5。
- 建議：integration_layer.md line 68 改成 no4_product_specs/ 與 no6_product_development/。

### 8. [skills] registry 宣稱的 no2_accounting_app Product Map 子路徑不存在於 filesystem

- 證據：~/.claude/skills/decision_framework_router/products_registry.md line 45-46 宣告 no2_accounting_app 的 product_map_paths 為 `no2_product_planning/no2_product_map/no2_accounting_app/`。實機 ls no2_product_planning/no2_product_map/ 內容是 app/ cloud_service/ external_service/ firebase/ web_console/ structure.md — 無 no2_accounting_app/ 子目錄（test -d 確認 MISSING）。對照 no1_user_management 宣告的 firebase/authentication.md 則 test -f 存在。
- 為何是問題：registry 自述是『hook 與 auditor 的資料源』。auditor Step 2（agent line 88）會檢查 product_map_paths 變動是否被跟進；指向不存在的子目錄會讓該檢查永遠對不上或誤判。
- 建議：核對 accounting app 在 Product Map 的真實落點（看來是散在 app/ 等平台視角子目錄，而非 module-id 子目錄），把 line 46 改成實際存在的子路徑清單。

### 9. [skills] universal_writing_linter/SKILL.md 的 lint 指令在本機無法照打：powershell 標籤 + 裸 python + 引號內 ~ 不展開

- 證據：~/.claude/skills/universal_writing_linter/SKILL.md line 17-19 code block 標 ```powershell，內容 `python "~/.claude/skills/universal_writing_linter/scripts/lint_spec.py" <檔案路徑>`。實機驗：(a) 標 powershell 但 env 是 zsh/macOS；(b) command -v python → MISSING，只有 python3；(c) `ls "~/.claude/.../lint_spec.py"` → No such file（引號內 ~ 不展開）。三者任一都讓此指令 verbatim 失敗。對照 claude-code-self-review/SKILL.md line 33 正確寫 `python3 ~/...`（不加引號、用 python3）。
- 為何是問題：這是 skill 唯一給的執行手段，照抄會 command not found 或 file not found。是跨機（Windows→macOS）遷移殘留。
- 建議：改成 `python3 ~/.claude/skills/universal_writing_linter/scripts/lint_spec.py <檔案路徑>`（bash 標籤、python3、不用引號包 ~），與 self-review skill 的寫法一致。

### 10. [skills] claude-code-self-review/SKILL.md 的 project slug 範例是 Windows 殘留且使用者名拼錯

- 證據：~/.claude/skills/claude-code-self-review/SKILL.md line 16 舉例『ai-company 專案的 slug 是 `C--Users-ken-chio-Doc-ai-company`』。實機 ls ~/.claude/projects/ 的活躍 slug 是 `-Users-kenchio-Doc-ai-company`（無 C- 前綴、kenchio 無 dot）；那個 C--Users-ken-chio 目錄確實還在但是舊機殘留。腳本 find_project_dir 用子字串 fuzzy 比對 'ai-company'，所以實際執行仍能命中，影響僅限說明文字誤導。
- 為何是問題：範例 slug 形如 Windows 路徑（C- 前綴、ken-chio），與本機 macOS 命名規則不符，讀者照此理解會找錯目錄；屬跨機遷移未更新的文件漂移。
- 建議：把範例 slug 改為 `-Users-kenchio-Doc-ai-company`，並把『把絕對路徑分隔符換成連字號』的說明對齊 macOS（開頭即為 / 換成 -，無磁碟機代號）。

### 11. [skills] self-review 的 find_project_dir 用 max(mtime) 選目錄，候選不只一個會選錯——第一輪「fuzzy match 仍能命中、只影響說明文字」判斷過樂觀

- 證據：~/.claude/skills/claude-code-self-review/scripts/extract_signals.py line 74-84：find_project_dir 用 `project_hint.lower() in d.name.lower()` 子字串比對，命中後 line 84 `return max(candidates, key=lambda d: d.stat().st_mtime)`。SKILL.md line 33 預設 `--project ai-company`。實機 ls ~/.claude/projects/ 有三個含 'ai-company' 的目錄：`-Users-kenchio-Doc-ai-company`（82 個 jsonl，真的那個，mtime 06-05 15:38）、`-Users-kenchio-Doc-ai-company-product-SuSuGiGi`（0 個 jsonl，mtime 06-05 13:33）、`C--Users-ken-chio-Doc-ai-company`（0 個 jsonl，Windows 殘留，mtime 06-01）。三者都進 candidates，靠 mtime 決勝。當下真目錄剛好最新故命中，但只領先 SuSuGiGi 那個約 2 小時。
- 為何是問題：第一輪 finding #7 明寫『腳本 find_project_dir 用子字串 fuzzy 比對，所以實際執行仍能命中，影響僅限說明文字誤導』，把這當純文件漂移。實際是 latent 正確性 bug：選擇靠 mtime 而非 transcript 多寡，候選集本身就有歧義。任何一次 cwd 在 SuSuGiGi 子產品、或不慎 touch 到 Windows 殘留目錄，max(mtime) 就翻向 0-transcript 目錄，self-review 會靜默掃到 0 個 session（extract_signals 不會報錯、只回 sessions_scanned:0），使用者拿到空報告卻不知選錯目錄。
- 建議：find_project_dir 的 tie-break 改為偏好 jsonl 數量最多的候選（或候選>1 時印出全部候選要求 disambiguate），不要單純 max(mtime)；並把 SKILL.md line 33 範例改成更精確的 hint。順帶把 line 16 的 slug 範例 C--Users-ken-chio-Doc-ai-company 改成 -Users-kenchio-Doc-ai-company（此點第一輪已提，本 finding 補的是『選錯目錄』的功能性風險）。

### 12. [skills] registry 與 auditor 的『狀態語意』把 TEMPLATE_OK / CONCEPT_ONLY 定義成 product_repo 為 null，但實機模板/概念產品 product_repo 都非 null——自相矛盾，第一輪整段沒查

- 證據：~/.claude/skills/decision_framework_router/products_registry.md line 266-267『模板 module：product_repo 與 spec_repo 皆為 null，auditor 回 TEMPLATE_OK』、line 269-272『概念 module：product_repo 為 null、impl_repo 為 null、僅 spec_repo，auditor 回 CONCEPT_ONLY』。但同檔資料區：LiquidGlassHeaderTemplate（唯一模板產品）line 127-128 product_repo.path 非 null、line 142-145 spec_repo 非 null；UndergroundRemake（唯一概念產品）line 153-154 product_repo.path 非 null。實機 ls 也確認兩產品根都有 .git 目錄（LGHT、UR 各有 no1~no5/no6 結構）。auditor 端 ~/.claude/agents/multi-tier-alignment-auditor.md line 140『TEMPLATE_OK：product_repo 與 spec_repo 皆為 null』、line 141『CONCEPT_ONLY：product_repo 與 impl_repo 皆為 null』照抄同樣的 null 條件。另 line 254-257 把 spec-only 無 design 的 no1_user_management（design_repo null、spec_repo 非 null、impl_repo null）標為『純設計階段 / PLAN_ONLY_DESIGN』，名稱與實情（有 spec 無 design）相反。
- 為何是問題：第一輪 coverage 只查了 registry 的 path 欄位與 product_map 子路徑，完全沒檢『狀態語意』block 與資料區的一致性。這段是 auditor Step 3 狀態判定的依據：若 auditor 照字面用『product_repo == null』當 TEMPLATE_OK / CONCEPT_ONLY 的閘，LGHT 與 UR 永遠 match 不到該狀態，會 fall through 到錯狀態（PLAN_ONLY 之類甚至 FAIL），盤點結論失真。PLAN_ONLY_DESIGN 命名與 spec-only module 實情相反則會誤導讀者判層。
- 建議：校正『狀態語意』：TEMPLATE_OK 的判據應對齊模板產品實況（product_repo 與 spec_repo 皆非 null、Spec 為空殼、變動多屬 REFACTOR_EXEMPT，如 LGHT 的 status_note 所述）；CONCEPT_ONLY 應為『product_repo 非 null、僅 spec_repo、impl_repo null』（如 UR）。registry line 266-272 與 auditor line 140-141 兩處同步改。並重新命名或重述 PLAN_ONLY_DESIGN，使其涵蓋 spec-only 無 design 的 Plan-only module。

### 13. [agents] product-planner 輸出路徑全部指向不存在的目錄

- 證據：~/.claude/agents/product-planner.md L267-272「輸出位置」：功能規格輸出至 no3_module_specs/、開發計畫輸出至 no4_dev_management/no1_mvp_planning/。實測這三個目錄名在整個 ai-company 下都不存在（find 全空）。權威結構（products_registry.md L29、L31 與 ai-company CLAUDE.md）是 specs_root: no4_product_specs/、project_management: no5_project_management/。SuSuGiGi 實際只有 no4_product_specs/ 與 no5_project_management/。
- 為何是問題：product-planner 是註冊產品的規劃 agent，但它寫出的所有交付物落點都是死路徑。若照它寫的去產出 spec / 開發計畫，會建到錯目錄，繞過四層 git 結構與 decision_framework_router 的對應，事後得回頭搬。這是規範聲稱與實際機制對不上的典型 drift。
- 建議：把 L269 的 no3_module_specs/ 改成 no4_product_specs/<module_id>/、L271 的 no4_dev_management/no1_mvp_planning/ 改成 no5_project_management/ 對應子目錄；對齊 products_registry.md 的 decision_framework_layout 權威命名。建議不執行，列入待修。

### 14. [agents] product-planner 引用 5 個生態系內不存在的 sibling agent

- 證據：~/.claude/agents/product-planner.md L281-285「職責邊界」把工作轉派給 solution-architect、experience-designer、equity-accountant、quality-engineer；L22 啟動流程又說「從 Chief of Staff 取得當前產品名稱」。實測 ~/.claude/agents/ 只有 4 個 .md，這 5 個 agent 全部 MISSING。
- 為何是問題：職責邊界寫了轉派對象，但轉派目標不存在，等於邊界規則無法執行——遇到技術選型 / 視覺設計 / 點數記錄 / 測試時，product-planner 指向空氣。啟動流程依賴的「Chief of Staff」也不存在，情況 A 的「取得產品名稱與路徑」這一步沒有上游可問。agent 描述的協作網與實際生態系對不上。
- 建議：二擇一：要嘛補齊這些 agent，要嘛把 product-planner 的轉派邊界與 Chief of Staff 依賴改寫成現況可執行的描述（如改為由使用者直接提供產品路徑、移除不存在的轉派指向）。建議不執行，需使用者定奪生態系該補還是該收斂。

### 15. [agents] agent-workflow-manager 會在本 repo 直接 hard-stop，永遠掃不到那 4 個 global agent

- 證據：~/.claude/agents/agent-workflow-manager.md L43-50：Step1 規定「Project agents 是必要條件，若 .claude/agents/ 不存在或為空，輸出警告後停止，不產出分析報告」。實測 ~/Doc/ai-company/.claude/agents/ 不存在（ai-company/.claude 下只有 hooks、launch.json、settings.json、settings.local.json）。
- 為何是問題：這套設定服務 SuSuGiGi，所有 agent 都掛在 global（~/.claude/agents/），project 層刻意沒放 agent。但 agent-workflow-manager 把 project agents 設成執行前提，在這個 repo 跑必定觸發停止分支，連 global 的 4 個 agent 都不會分析。等於這個審查 agent 在它最該服務的 repo 上自我癱瘓——規範意圖（審查 agent 生態）與守門邏輯（要求 project agents 存在）互相矛盾。
- 建議：放寬 Step1：project agents 為空時改為「僅掃 global、標注 project 層無 agent」繼續分析，而非 hard-stop；或在本 repo 建立 project agents。建議不執行，先確認使用者要的是 global-only 審查還是強制 project 層。

### 16. [agents] products_registry.md 全用 Windows 絕對路徑，跨機在 macOS 上無法解析

- 證據：~/.claude/skills/decision_framework_router/products_registry.md 所有 repo path 寫死成 C:\Users\ken.chio\Doc\... （L21、L37、L43、L92 等全部條目）。本機是 macOS（實際路徑 /Users/kenchio/Doc/...）。multi-tier-alignment-auditor L216「registry 所載路徑為權威來源」、L37-50 直接拿這些 path 去跑 git -C <repo>。
- 為何是問題：auditor 把 registry path 當權威餵給 git -C，但這些 C:\ 路徑在當前 macOS 機器上不存在，auditor 一跑就會對每層 git 報「路徑不存在、跳過」，盤點實質失效。這是 agent 引用的路徑漂移——agent 本身邏輯對，但它信任的資料源指向錯的 OS。跨機協作（Windows + Mac 輪流）情境下這份註冊表只對 Windows 那台有效。
- 建議：registry path 改用可跨機解析的寫法（相對 ~/Doc 的相對路徑，或約定由 product_id + decision_framework_layout 組路徑、不存絕對 path）。auditor 端對應改成從 product_repo 相對路徑解析。建議不執行，屬跨機 git 協作的結構修正，需使用者拍板路徑方案。

### 17. [agents] git-sync detached HEAD dirty miss

- 證據：git-sync.md lines 64 to 96 only check dirty inside the branch equals head_branch block; when detached head_branch is literal HEAD and matches no real branch so dirty never reports; worktree loop skips the main entry. SuSuGiGi impl main git is currently detached.
- 為何是問題：git-sync backs game-over which catches uncommitted work before leaving a machine; a detached dirty main checkout is missed.
- 建議：add a detached check reporting DETACHED_DIRTY. do not execute.

### 18. [claudemd-global] project CLAUDE.md「產品路徑」與「iOS 自驗策略」指向不存在的 <Product>App / <Product>Spec 扁平目錄

- 證據：~/Doc/ai-company/CLAUDE.md L32-37「Hatsuon App：`product/Hatsuon/HatsuonApp/`」「SuSuGiGi App：`product/SuSuGiGi/SuSuGiGiApp/`」「SuSuGiGi Spec：`product/SuSuGiGi/SuSuGiGiSpec/`」等；L260「主 git（如 `product/SuSuGiGi/SuSuGiGiApp/`）」。實測 `ls product/SuSuGiGi/SuSuGiGiApp` 與 `SuSuGiGiSpec`、`Hatsuon/HatsuonApp`、`HatsuonSpec` 皆 No such file or directory。實體為 `no4_product_specs/<module>/` 與 `no6_product_development/<module>/`（accounting impl 真在 no6_product_development/no2_accounting_app/，內含 App.tsx/ios/android）。
- 為何是問題：這是 CLAUDE.md 的導航段，等於給 Claude 與使用者一張錯的地圖。同一份 project CLAUDE.md 的「Design-Impl 對齊」「動作前 5 秒自檢」卻用正確的 no6_product_development，自我矛盾。新 session 照「產品路徑」找檔會撲空，或誤以為該建立扁平目錄。
- 建議：把 L31-37 產品路徑改寫為實際的 module 化結構（Spec=no4_product_specs/<module>/、Impl=no6_product_development/<module>/、Design=no3_product_designs/<module>/），並列出現存 module；L260「如 product/SuSuGiGi/SuSuGiGiApp/」改為 no6_product_development/no2_accounting_app/。改前依全域「Markdown 修改規範」四步整份讀過、查與既有正確段落的重複。

### 19. [claudemd-global] integration_layer.md 仍用舊編號 no3_product_specs / no5_product_development

- 證據：~/.claude/skills/decision_framework_router/integration_layer.md L68「目錄名與 `no3_product_specs/<module_id>/` 及 `no5_product_development/<module_id>/` 逐字一致」。同 skill 的 SKILL.md L66-67、delivery_layer.md、products_registry.md、實體目錄全用 no4_product_specs / no6_product_development。grep 全 ~/.claude 只有此檔殘留舊編號（settings.json 的 mkdir 權限另計）。
- 為何是問題：integration_layer 是 decision_framework_router 的權威擴充檔之一，被上游 review 流程引用。舊編號會讓「整合層→落地層」的路徑連鎖指錯，與同 skill 其他檔自相矛盾。
- 建議：L68 兩處改為 no4_product_specs / no6_product_development，與 registry、delivery_layer、SKILL.md 對齊。

### 20. [claudemd-global] block-worktree-ios-build.sh 的 fallback 提示寫了壞路徑 product/<產品>App

- 證據：~/Doc/ai-company/.claude/hooks/block-worktree-ios-build.sh L22「或 cd 到對應主 git（product/<產品>App）後再執行」。該扁平路徑不存在；主 git 實為 product/<產品>/no6_product_development/<module>/。
- 為何是問題：hook 攔截成功後給的引導指向不存在的目錄，使用者照做會 cd 失敗。hook 攔截邏輯本身正確（測試外的純訊息問題），但提示誤導。
- 建議：把提示改為 cd 到 product/<產品>/no6_product_development/<module>/，或直接只引導打 /sim-review（與 L20-21 一致）。

### 21. [claudemd-global] products_registry.md 內嵌 Windows 絕對路徑且用了另一台機的使用者名 ken.chio

- 證據：~/.claude/skills/decision_framework_router/products_registry.md 全檔 path 欄位皆為 `C:\Users\ken.chio\Doc\ai-company\product\...`（如 L21、L37、L43、L92、L117）。本機家目錄為 /Users/kenchio（無點，darwin）。全域 ~/.claude/CLAUDE.md「路徑引用規則」明令 .md 內文禁止 OS 絕對路徑（含 macOS `/Users/username/` 與 Windows `C:\` 開頭）。
- 為何是問題：registry 是 hook 與 auditor 的資料源、且跨機共享。路徑對本機完全失效（盤地不同、磁碟機格式不同、username 不同），任何依 path 欄位解析的消費端在本機都會抓空。username ken.chio vs kenchio 顯示這份是從另一台 Windows 機帶過來未在地化，正是跨機路徑漂移。
- 建議：把 path 欄位改為主題/相對引用（如以產品根 + 註冊表既有的 decision_framework_layout 推導），或至少改成可移植的 `~/Doc/ai-company/...` 錨點；remote 欄位保留即可。實際上 design-impl-alignment-guard 等消費端都用 $HOME 自行組路徑、未讀 registry 的 path，故先記 drift；若未來有工具改讀 path 欄位會升級為 broken。

### 22. [claudemd-global] spec-guard.sh PreToolUse blocking branch is dead code (wired only to PostToolUse)

- 證據：spec-guard.sh header L2-6 claims PreToolUse blocks high-signal violations; L47-86 is a real exit-2 blocking branch. settings.json wires it ONLY in PostToolUse (L117-134); PreToolUse block (L90-106) omits it. event is always PostToolUse so L48 makes L47-86 unreachable.
- 為何是問題：Advertised write-time block never happens; only the non-blocking PostToolUse stderr backstop runs. Round 1 missed the never-invoked Pre branch.
- 建議：Add spec-guard.sh to PreToolUse Write|Edit block, or delete the Pre branch and mark header PostToolUse-only.

### 23. [claudemd-global] design-impl-alignment-guard prints export CLAUDE_SKIP_DESIGN_GUARD=1 escape hatch, which does not work via Bash

- 證據：design-impl-alignment-guard.sh L117-119 prints export CLAUDE_SKIP_DESIGN_GUARD=1 as remedy. auto-memory reference_design_guard_bypass.md L14: via Bash ineffective (subprocess env never reaches main process); L15: reliable path is Read a design file into the transcript. Hook L24 reads the var but Claude cannot set it.
- 為何是問題：Hook teaches an unworkable remedy first; user memory already logs this landmine. Claude exports, assumes unblocked, next Edit still blocks. Round 1 verified the bypass vs spec but did not cross-check the memory.
- 建議：Make Read-a-design-file the first remedy; demote the env var noting it must be set before launch.

### 24. [claudemd-project] 盤點段要求掃的兩個 worktree 路徑不存在、實際命令也不掃

- 證據：~/Doc/ai-company/CLAUDE.md L289-292『盤點任務協作節奏』列掃描範圍『三個路徑都要含』：~/Doc/.worktrees/、~/Doc/_worktrees/、~/Doc/ai-company-worktrees/。實測前兩者 ls 皆 No such file or directory，只有第三個存在。實際命令 grep：game-over.md 僅掃 ~/Doc/ai-company-worktrees/（L35、L43-45），game-clear.md 也只認 ~/Doc/ai-company-worktrees/<topic>/<layer>-<module>/，兩者完全沒提 .worktrees / _worktrees。
- 為何是問題：規範把『三個路徑都要含』寫成硬要求（『不允許先看 A 等等再看 B』語境下的最少範圍），但 (a) 其中兩個路徑本機不存在、(b) 真正執行盤點的 game-over/game-clear 命令根本不掃那兩個。規範與實作、規範與檔案系統三方不一致。多出來的兩條像舊 worktree 佈局遺留。風險：誤導讀者以為有兩處 worktree 巢需要顧，或讓人懷疑命令漏掃。
- 建議：確認 .worktrees / _worktrees 是否仍是任何 repo 的 worktree 慣用位置（看來不是）。若已棄用，盤點段刪掉這兩條、只留 ~/Doc/ai-company-worktrees/，與 game-over/game-clear 對齊；若仍要保留為防御性掃描，則改寫成『存在才掃』語氣，並回頭把 game-over/game-clear 補上對這兩路徑的掃描，否則規範自我矛盾。

### 25. [claudemd-project] ai-company 各 repo 無 .gitattributes，eol=lf 統一聲明未落地（跨 Windows/Mac 行尾風險）

- 證據：全域 CLAUDE.md「Git config baseline」末條：『repo 應在 .gitattributes 中聲明 `* text=auto eol=lf` 統一行尾』。實測 /Users/kenchio/Doc/ai-company/.gitattributes 與 impl repo no6_product_development/no2_accounting_app/.gitattributes 皆 No such file or directory。
- 為何是問題：products_registry 顯示這套 workspace 是 Windows（C:\Users\ken.chio）與本機 macOS 跨機協作。沒有 eol=lf 聲明時，兩機 checkout 行尾不一致會造成整檔 diff、配對 commit 失準——正是規範這條要預防的根因。措辭是『應』屬軟要求，但它是被明列的 baseline，且跨機情境下風險具體存在。confidence high 指『檔案確實不存在』；是否每個 module repo 都該補可由執行者定。
- 建議：至少在 ai-company 根 repo 與各 module impl/spec/design repo 補 .gitattributes 含 `* text=auto eol=lf`。一次性動作，與上一條 baseline 一起收。

### 26. [claudemd-project] branch-pairing-guard 在標準 worktree 流程下不會觸發（靠 pwd 含產品名偵測，worktree 路徑無產品名）

- 證據：~/.claude/hooks/branch-pairing-guard.sh L38-58 用 `pwd_str=$(pwd)` 配 `case ... */SuSuGiGi*)` 偵測產品，非產品名則 L58 `*) exit 0`。但實際 worktree 路徑是 ~/Doc/ai-company-worktrees/<topic>/<layer>-no2_accounting_app（實測 ls 確認），不含 'SuSuGiGi' 等產品名。模擬：對 paywall-compliance/impl-no2_accounting_app 跑 case → NO-PRODUCT-MATCH，guard 提早 exit。且 CLAUDE.md「Worktree 使用慣例」開 branch 的正規指令是 `git -C <主 git> worktree add ...`，執行時 cwd 通常在 ai-company 根或別處，一樣不含產品名。
- 為何是問題：branch-pairing-guard 的用途是『開 branch 時提醒配對 git 缺同名 branch』。但全員 worktree 是本專案硬規則（無例外），開 branch 幾乎都發生在 worktree add；而 worktree add 的 pwd 與 worktree 路徑都不含產品名，guard 在最常見的開 branch 路徑上靜默不發。等於規範自檢#（跨層 branch 配對）背後的這支 hook 實質空轉。註：guard 內部檢查 main repo refs/heads 的邏輯本身正確（worktree 與主 git 共享 refs，實測主 spec repo 看得到 feat/paywall-compliance），所以一旦觸發是有效的——問題純在觸發條件。屬提醒型 hook（恆 exit 0），不致命故列 drift。
- 建議：把產品偵測從 pwd 改成同時看『被建立的 branch 名 / -C 目標路徑 / pwd』三者任一含產品根，或直接用 `git rev-parse --show-toplevel` 反推所屬產品（已是主 git path）。讓 worktree add 場景也能觸發配對檢查。

### 27. [claudemd-project] launch.json：5 個在用 worktree 缺 entry，且 port 分配跳號，與『每新 worktree +1、必 append』硬規則不符

- 證據：~/Doc/ai-company/.claude/launch.json 只有 4 條 entry（susugigi-design、+import-wizard-redesign design、+paywall-compliance design、+fix-google-signin impl）。實測 on-disk worktree leaf 有 8 個：import-wizard-redesign 與 paywall-compliance 各有 design+spec+impl 三層、fix-google-signin impl、paywall-compliance-notes/product。缺 entry 的含 import-wizard-redesign/{spec,impl}、paywall-compliance/{spec,impl} 等。又 design port 序列 8765,8767,8768,8769 跳過 8766；metroPort 8081,8083,8084,8085 跳過 8082。CLAUDE.md「Port 協作規範」：『git worktree add 完成後、啟 server 前必須 append 一條 entry』『design port = 現有最大+1（8765 起）、metroPort = 最大+1（8081 起）』。
- 為何是問題：第一輪只驗了『欄位格式正確、directory 無絕對路徑』，沒比對 entry 集合與磁碟 worktree 集合、也沒看 port 連號。實況是註冊表落後於實際 worktree：多個在用 worktree 無 entry，違反『必 append』；port 跳號代表中途有 worktree 收掉但分配規則被當成單調遞增（或手動跳），與『最大+1』描述有出入。風險：未登記 worktree 若起 design server，server-launchjson-guard 找不到 entry 會擋；或人工 hardcode 撞到別人。屬規範與實況 drift。
- 建議：用 /game-over 對齊：為每個仍在用、需起 server 的 worktree 補 entry（spec 層純文字可省 port，但 design/impl 該有）；收掉的 worktree entry 清掉。順帶確認 port 規則要的是『最大+1』還是『補洞用最小空位』，讓文件與實際分配一致。

### 28. [registry] project CLAUDE.md「產品路徑」段全是不存在的虛構路徑

- 證據：~/Doc/ai-company/CLAUDE.md:32-37 寫 `product/SuSuGiGi/SuSuGiGiApp/`、`product/SuSuGiGi/SuSuGiGiSpec/`、`product/Hatsuon/HatsuonApp/`、`product/Hatsuon/HatsuonSpec/`、`product/UndergroundRemake/UndergroundRemakeSpec/`。實際 `ls product/SuSuGiGi/SuSuGiGiApp` → No such file or directory；`SuSuGiGiSpec` 同樣不存在。真實結構是 registry 定義的 no4_product_specs/no2_accounting_app、no6_product_development/no2_accounting_app。
- 為何是問題：這是 project 規範裡最常被當作入口的路徑索引段，卻整段指向不存在的目錄。任何照 CLAUDE.md 找 SuSuGiGi 程式碼或 spec 的人（含 Claude）會撲空，再繞回 registry 才找到真路徑。CLAUDE.md 與 registry 兩份 source 對同一產品給出互斥路徑。
- 建議：把「產品路徑」段改寫成 registry 的四層結構（no3_product_designs / no4_product_specs / no6_product_development 加 module_id），或直接刪掉這段、改指 products_registry.md 為單一真相。需使用者授權後在 worktree 內改 project CLAUDE.md。

### 29. [registry] registry sub_mapping 的 design_glob 指向已被重構掉的 .jsx 檔

- 證據：products_registry.md:59 `design_glob: project/10_foundations/data.jsx, project/10_foundations/foundations.jsx`；:70 `design_glob: project/30_screens/screens.jsx`。實際 ls：10_foundations 下無 data.jsx、無 foundations.jsx（已拆成 no1_atomic_tokens.jsx、no2_canvas_tokens.jsx … no6_icon_library.jsx + component_tokens/）；30_screens 下無 screens.jsx（已拆成 no1_home_screen/ … no26_localization_settings_screen/ 等 per-screen 子目錄）。20_components 的 components.jsx、components-showcase.jsx 仍存在、那條 OK。
- 為何是問題：registry 自稱是 hook 與 auditor 的資料源、四層 git 的路徑查詢權威。sub_mapping 描述 design 變動如何牽動下游，但 design 層做過 token 拆分與 screen 拆目錄的重構，registry 沒跟上。任何將來照 design_glob 自動比對「動到哪個 design 檔該通知哪層」的工具會比對到不存在的檔名而漏判。
- 建議：更新這兩條 design_glob 對齊現況：foundations 指 `project/10_foundations/*.jsx`（或列出 no1~no6 + component_tokens/），screens 指 `project/30_screens/**`。需使用者授權後動 registry。

### 30. [registry] spec accounting CLAUDE.md 把 token 權威指向不存在的 data.jsx

- 證據：product/SuSuGiGi/no4_product_specs/no2_accounting_app/CLAUDE.md:46 `視覺 token 具體值權威：no3_product_designs/no2_accounting_app/project/10_foundations/data.jsx`。該檔不存在（同上條，已重構為 no1_atomic_tokens.jsx 等）。
- 為何是問題：spec 層 CLAUDE.md 明確把「視覺 token 具體值的權威來源」釘在一個已消失的檔。讀 spec 想回查 token 定案值的人會找不到檔，且與 registry 同步出錯，屬同一次 design 重構沒回頭修的遺留。
- 建議：改指向重構後的 token 檔（如 10_foundations/no1_atomic_tokens.jsx 或整個 10_foundations/ 目錄）。需使用者授權後在 worktree 內動該 spec git 的 CLAUDE.md。

### 31. [registry] registry no2_accounting_app 的 product_map_paths 指向不存在目錄

- 證據：products_registry.md:45-46 `product_map_paths: - no2_product_planning/no2_product_map/no2_accounting_app/`。實際 ls no2_product_map/ 下子目錄為 app/、cloud_service/、external_service/、firebase/、web_console/，無 no2_accounting_app/。structure.md:124-130 顯示 accounting 相關功能掛在 app/（app/auth.md、app/recording_core.md、app/home_dashboard.md 等）。
- 為何是問題：registry 把 accounting module 的 Product Map 對應釘在不存在的子目錄。更糟的是 multi-tier-sync-guard.sh:73,82 的提示文字也會叫使用者去檢查 `no2_product_map/${module}/`（即 no2_product_map/no2_accounting_app/），同樣指向空目錄。registry 錯誤已外溢成 runtime hint 的錯誤導引。上游需求變動反查受影響 module 時會斷鏈。
- 建議：把 product_map_paths 改成實際路徑（指 no2_product_map/app/ 或列出 app/ 下相關 .md），或在 registry 註明 accounting 對應的是 app/ 而非同名子目錄。連帶評估 multi-tier-sync-guard.sh 的 module→product_map 推導假設（它假設 map 子目錄名 == module_id，此假設對 accounting 不成立）。需使用者授權後動 registry。

### 32. [registry] registry Hatsuon module 的 product_map_paths 指向不存在的空目錄

- 證據：products_registry.md:122-123 Hatsuon no1_pronunciation_app `product_map_paths: - no2_product_planning/no2_product_map/no1_pronunciation_app/`。實際 `ls product/Hatsuon/no2_product_planning/no2_product_map/` 只有 `.gitkeep`，無 no1_pronunciation_app/ 子目錄；整個 Hatsuon no2_product_planning/（requirements、product_map、roadmap）皆為 .gitkeep 空殼。對照該 module status_note(:124)『Spec + Impl 已就位』、磁碟上 spec(no4)與 impl(no6/App.tsx 等)確實都有實碼。
- 為何是問題：與第一輪 finding #4 同型（registry product_map_paths 指向不存在目錄），但發生在第一輪 coverage 明文未查的 Hatsuon——第一輪只驗了 SuSuGiGi 兩個 module 的 product_map_paths。Hatsuon 此 module 依 registry 自身狀態語意屬『正常 module』（spec+impl 皆非 null，期待三層配對），上游 Product Map 錨點卻是空殼。runtime 外溢與 #4 相同：multi-tier-sync-guard.sh:73 編輯 Hatsuon spec 時會提示去檢查 `no2_product_map/no1_pronunciation_app/`，把使用者導向空目錄。上游需求反查受影響 module 時斷鏈。
- 建議：二擇一——若 Hatsuon Product Map 尚未動工，把此條改成空陣列 `product_map_paths: []`（對齊 Liquid 的處理），並在 status_note 註明 Product Map 待補；若已有對應內容散在他處，改指實際路徑。連帶此案再次印證 multi-tier-sync-guard.sh:73,82 硬編 `no2_product_map/${module}/` 的假設對多數 module 不成立（accounting、user_management、pronunciation 三者皆不符）。需使用者授權後在 worktree 內動 registry。

### 33. [launchjson] 5 個 active feat worktree 只登記了 4 個，import-wizard 與 paywall-compliance 的 impl worktree 漏登 launch.json

- 證據：git worktree list (impl git product/SuSuGiGi/no6_product_development/no2_accounting_app) 列出 3 個 feat worktree：fix-google-signin-web-client-id/impl（feat/fix-google-signin-web-client-id）、import-wizard-redesign/impl（feat/import-wizard-redesign）、paywall-compliance/impl（feat/paywall-compliance）。但 launch.json 4 個 entry 的 directory 只含 fix-google-signin-web-client-id/impl-no2_accounting_app 這一個 impl，另兩個 impl worktree（~/Doc/ai-company-worktrees/import-wizard-redesign/impl-no2_accounting_app、~/Doc/ai-company-worktrees/paywall-compliance/impl-no2_accounting_app，皆實際存在且為 RN app、package.json 含 react-native）完全沒有 entry。
- 為何是問題：project CLAUDE.md「開新 worktree 時的硬規則」明寫『git worktree add 動作完成後、啟任何 server 之前，必須 append 一條 entry 到 launch.json』，且 metroPort 欄位的作用是『保留為佔位，避免日後手動 hardcode 衝突』。兩個 impl worktree 沒登記，等於 metroPort 佔位機制對它們失效；若日後對這兩個 impl 啟 server 或手動指定 port，可能撞到既有 8083/8084/8085。這是規範聲稱（每個 worktree 必登記）與實際狀態（漏 2 個）對不上的 drift。
- 建議：為 import-wizard-redesign/impl-no2_accounting_app 與 paywall-compliance/impl-no2_accounting_app 各補一條 entry，port 取現有最大+1（8770、8771），metroPort 取現有最大+1（8086、8087），name 比照 susugigi-impl-<topic> 命名。或若確認這兩個 impl 短期不啟 server，至少在收工盤點時一併決定登記或不需要。不在本次健檢執行。

### 34. [launchjson] 未登記的 worktree 比第一輪說的多：8 個 active feat worktree 只登 4 條，import-wizard / paywall 的 design+spec+impl 共 6 層裡有 4 層沒 entry

- 證據：三層 git worktree list 實況：design git 有 import-wizard-redesign/design、paywall-compliance/design 兩個 feat worktree；spec git 有 import-wizard-redesign/spec、paywall-compliance/spec 兩個；impl git 有 fix-google-signin/impl、import-wizard-redesign/impl、paywall-compliance/impl 三個。合計 8 個 active feat worktree（ls ~/Doc/ai-company-worktrees/ 也看得到 import-wizard-redesign/ 與 paywall-compliance/ 各含 design+impl+spec 三個子目錄）。launch.json 只有 4 條 entry（grep directory：susugigi-design 主 git、import-wizard design、paywall design、fix-google-signin impl）。第一輪只掃了 impl git，得出『5 個 active、漏 2 個 impl』；真實是 8 個 active、漏 4 個（import-wizard 的 impl+spec、paywall 的 impl+spec；design 兩個已登）。
- 為何是問題：project CLAUDE.md:208『git worktree add 動作完成後、啟任何 server 之前，必須 append 一條 entry』。spec 也說 design canvas 多 instance 可並行、每個 worktree 跑各自 http.server——import-wizard/spec 與 paywall/spec 是純 markdown（無 project/、無 package.json），確實不跑 server，登不登記是判斷題；但兩個 impl worktree 是 RN app，metroPort 佔位機制對它們失效（與第一輪 finding 同因，但第一輪把母數算錯，掩蓋了『規範要求每個 worktree 登記』與實況的落差規模）。把 spec 層算進來，6 個該被規範涵蓋的非主git worktree（2 design + 2 impl + 2 spec）有 4 個沒 entry。
- 建議：兩個 impl worktree 補 metroPort entry（如第一輪建議 8086/8087，仍在 hook 豁免範圍 8081-8090 內）。兩個 spec worktree 屬判斷題：spec 純文字不跑 server，可在 Port 協作規範補一句『純文字 spec worktree 免登記』澄清，或一律登記以對齊『每個 worktree 必登』的字面規則——兩者擇一、消除歧義。不在本次健檢執行。

### 35. [launchjson] 獨立 impl entry 帶了 design-canvas port 8769，但該 worktree 無 project/ 可服務；第一輪建議照抄此 pattern 給新 impl 配 8770/8771 會傳播無用欄位

- 證據：launch.json 第 28-33 行 susugigi-impl-fix-google-signin entry 帶 `port: 8769` 與 `metroPort: 8085`，但無 `runtimeArgs`。該 worktree（~/Doc/ai-company-worktrees/fix-google-signin-web-client-id/impl-no2_accounting_app）ls 顯示是 RN app（App.tsx、android/、package.json 含 react-native），無 `project/` 子目錄。spec CLAUDE.md:201 定義 `port` 為『design canvas 用的 HTTP server http.server port』——impl-only worktree 沒有 design canvas，8769 指向一個沒東西可服務的 worktree。對比同 entry 沒給 runtimeArgs（正確地反映它不開 canvas），卻仍佔了一個 design port 號，自相矛盾。第一輪 finding 1 的 suggestion 直接說『為兩個 impl worktree 各補 port 8770/8771』，等於把這個無用 port 欄位再複製兩份。
- 為何是問題：spec line 197『欄位至少包含 name/directory/port/metroPort』把 port 寫成必備、只允許 metroPort 對非 RN worktree 省略，沒處理『impl-only worktree 的 design port 該不該省』的反向情形。結果是資料層出現一個語意上用不到的 port 號（占用 8769、且第一輪會再占 8770/8771），雖不會撞 server（沒人真的拿它起 canvas），但讓 port 號與『實際有 canvas 的 worktree 數』脫鉤，盤點時誤導；也讓 hook 的 8765-8800 design 區間被 impl entry 無謂消耗。第一輪對自己的 remediation 信心過高，沒察覺是在沿用一個有問題的 pattern。
- 建議：釐清 spec 的欄位模型：明訂『impl-only worktree 可省略 design `port`、只填 metroPort』（與『非 RN 可省 metroPort』對稱）。據此，獨立 impl entry 的 `port: 8769` 可移除；第一輪要補的兩個 impl entry 只給 metroPort（8086/8087）、不配 design port。屬規範與資料模型對不齊的 drift，非 server 會壞。不在本次健檢執行。

### 36. [補掃] design-impl-alignment-guard.sh line 45 註解與 line 46 邏輯矛盾（聲稱接受 worktree，實際只認主 git）

- 證據：design-impl-alignment-guard.sh line 45 註解：`# 偵測是否屬於任一產品的 impl 範圍（主 git 或 worktree 都接受）`，緊接 line 46 `if ! echo "$file" | grep -qE '/product/[^/]+/no6_product_development/[^/]+/'`。實測真實 worktree impl 路徑對此 regex NO MATCH——worktree 路徑既無 `/product/` 也無 `no6_product_development` 段。註解宣稱的「worktree 都接受」與程式碼行為相反。
- 為何是問題：這行假註解正是讓此缺口長期沒被抓到的原因之一：任何讀 hook 的人（含前 9 路掃描）看到註解寫「主 git 或 worktree 都接受」，會直接相信 worktree 已被涵蓋而不去實測。註解把一個 broken 行為偽裝成 intended，誤導維護者。
- 建議：修 matcher 真正支援 worktree 後，此註解才成真；在修 matcher 的同一次改動裡確保註解與行為一致。若分階段，至少先把註解改成誠實描述（目前只認主 git）以免繼續誤導。歸進前述 hook 修補 plan。

### 37. [補掃] self-modification 禁令零 hook 防線：無任何 Edit/Write hook 守 `~/.claude/**`

- 證據：全域三支 Edit|Write PreToolUse hook 中，`worktree-only-guard.sh` 偵測範圍只命中 `/ai-company/product/(SuSuGiGi|Hatsuon|...)/no[346]_`（見該檔 line 29），`~/.claude` 完全在範圍外；`design-impl-alignment-guard.sh`、`markdown-stitch-guard.sh` grep `.claude` 路徑守衛皆零命中。全 16 支 hook grep `self-mod／commands/*／settings.json` 保護字樣零命中。對比同檔其他禁令多有 hook 兜底：worktree 禁令有 worktree-only-guard、stash 禁令有 stash-guard、branch 配對有 branch-pairing-guard。
- 為何是問題：自檢#6 是 CLAUDE.md 自檢清單六條硬規之一，但唯獨它**既無 permission 防線（被 line 51-52 反向打開）、也無 hook 防線**。其他五條自檢項至少一層機械把關，這條完全靠 LLM 自律。漏檢稽核只點出 permission 反向，沒注意到 hook 層同樣空缺，故實際比『permission 反向』更嚴重——是雙層皆無。
- 建議：若採上一條的 (a) 移除授權路線，hook 層空缺尚可接受（permission 預設 ask 會兜）；但若想硬保證，可新增一支 PreToolUse Edit|Write self-mod-guard hook，命中 `~/.claude/settings*.json`、`~/.claude/hooks/`、`~/.claude/commands/`、`~/.claude/skills/`、`~/.claude/agents/` 時 exit 2 擋下，僅在偵測到對應 plan 檔存在於 `~/.claude/plans/` 時放行，與自檢#6 的 plan-mode 例外對齊。不在此次修改。

### 38. [補掃] 全域 allow list 三條 mkdir -p 用 renumber 前的舊目錄佈局

- 證據：~/.claude/settings.json 第 34-36 行："Bash(mkdir -p no3_product_specs)"、"mkdir -p no4_project_management"、"mkdir -p no5_product_development"。`ls` 三者全 ABSENT。現行佈局 `ls -d product/SuSuGiGi/*/` → no4_product_specs／no5_project_management／no6_product_development。權威表 products_registry.md 第 29-31 行：specs_root no4_product_specs／project_management no5_project_management／development_root no6_product_development。
- 為何是問題：目錄做過 renumber（specs no3→no4、project_mgmt no4→no5、dev no5→no6），規範與 filesystem 都已跟進，唯獨這三條 allow 仍寫舊號碼。屬規範漂移：條目本身仍能匹配（mkdir 相對路徑），但建出來的會是舊命名的孤兒目錄，與現行佈局衝突。第 32-33 行的 no1_product_initiation／no2_product_planning 未改號、仍正確。
- 建議：若這三條 mkdir 仍是某個初始化流程需要的，更新號碼為 no4_product_specs／no5_project_management／no6_product_development；若初始化已不靠這些手動 allow，整批移除。建議連同第 30-31 行一起清。不在本次健檢執行修改。

### 39. [補掃] 同一 allow 區塊用 Edit/Write(~/.claude/**) 全面放行，與 project CLAUDE.md「預設不行」自檢規則直接衝突

- 證據：~/.claude/settings.json 第 51-52 行："Edit(~/.claude/**)"、"Write(~/.claude/**)"。project CLAUDE.md「動作前 5 秒自檢」明寫：Edit ~/.claude/settings.json／hooks/*.sh／commands/*.md「預設不行（防 Claude 自主修改自己的設定 / hook / command）。唯一例外：經正式 plan mode 流程…才放行」。
- 為何是問題：自檢規則的意圖是預設擋下 Claude 自改自己的 settings／hook／command，只在 plan mode 例外放行。但 allow list 用 `~/.claude/**` 萬用字元把整個 ~/.claude 樹的 Edit/Write 永久放行，等於規則想守的那道門被機制層面常開。這是規範聲稱與實際機制對不上的典型 drift，且比前三項殘留嚴重——它實際擴大了授權面，不是無害 cruft。本路在審同一 allow 區塊時順帶撞見，平權列出。
- 建議：釐清意圖後二擇一：若確實要讓 Claude 自由改自己的 config，刪掉自檢規則那段、讓規範對齊機制；若要守住「預設不行、plan 例外」，收掉第 51-52 行的萬用放行、改為窄範圍或完全移除、靠 plan 流程逐次授權。需使用者決定方向，不在本次健檢執行修改。

### 40. [補掃] 全域 CLAUDE.md branch 命名 shape 自相矛盾：修改流程規範用 feat/r-id-slug，其餘權威全用 feat/topic

- 證據：~/.claude/CLAUDE.md:222 寫 `從目標 git 的 main 開 feat/<r-id>-<slug> branch`，line 231 配套 `wip: <r-id>-<slug>`。對照同檔 line 210 Plan 產出規範寫 `feat/<topic>`、line 72/88 段落收工兩版型寫 `branch：feat/<topic>`。再對照 ~/Doc/ai-company/CLAUDE.md:60、104、113、122、133、141 全為 `feat/<topic>`，以及 ~/.claude/commands/game-stop.md:50/131/165 與 game-clear.md:48/58/142 全為 `feat/<topic>`。
- 為何是問題：同一份全域 CLAUDE.md 對 branch 名稱給出兩種互斥 shape。更尖銳的是 line 210 自稱命名規則沿用修改流程規範，但它指向的 line 222 shape 與它自己寫的 feat/topic 不同，交叉引用本身打架。讀者照修改流程規範動工會產出 r-id-slug 形狀，與 worktree/plan/game-stop/game-clear 全鏈期待的 topic 形狀不一致。四層 git 配對要求跨層 branch 名稱逐字一致，命名 shape 漂移直接威脅配對與 merge 對齊。
- 建議：把 ~/.claude/CLAUDE.md:222 與 231 的 r-id-slug 統一改為 topic，與 line 210、段落收工版型、project CLAUDE.md、game-* commands 對齊。改檔走 .md 修改四步：整份讀過、確認無別處仍引用 r-id-slug、決定 topic 勝出後一次改掉兩處。

### 41. [補掃] markdown-stitch-guard 只攔 Edit、放掉 Write 對 .md 的整檔覆寫

- 證據：~/.claude/hooks/markdown-stitch-guard.sh 第 22 行 `if d.get('tool_name') != 'Edit': sys.exit(0)`。但此 hook 在 settings.json 掛的 matcher 是 `Edit|Write`（與 worktree-only、design-impl 並列同一 block）。意即 Write 工具會觸發 hook、但 hook 進去後因 tool_name 是 'Write' 不等於 'Edit' 立刻 exit 0。對照同 block 另兩支：worktree-only-guard 與 design-impl-alignment-guard 都不分 Edit/Write、只看 file_path，所以 Write 照擋。唯獨 stitch guard 自己把 Write 排除。
- 為何是問題：全域 CLAUDE.md「Markdown 修改規範」要求動任何 .md 走四步、禁止縫合插入，stitch guard 是這條的機械兜底。但用 Write 整檔覆寫一個既有 .md（例如重貼一份 spec / 角色定義）時，正是最容易發生「整段搬移、heading 層級錯亂、概念重複」的場景，卻完全不過 stitch 檢查。這是與「cat > *」同一家族的破口：真正該防的寫入路徑（這裡是 Write 工具）沒被覆蓋，防護只蓋住 Edit。屬規範意圖與實作覆蓋面不符的 drift，非完全失效（Edit 仍受保護），故列 drift 不列 broken。
- 建議：建議把第 22 行改成接受 Edit 與 Write 兩種 tool_name；Write 情境下以 new_string 等價的整檔內容做同樣的 heading 重複/搬移檢查（Write 無 old_string，可退化為只查新內容內部的 heading 衝突）。或在 hook 註解明確聲明「僅管 Edit、Write 不在範圍」並回填到 CLAUDE.md，讓規範與實作對齊。建議性質，不在本次執行。

### 42. [補掃] settings 允許 Edit/Write `~/.claude/**`，與 CLAUDE.md「改自己設定預設不行」正面矛盾

- 證據：全域 `~/.claude/settings.json` allow 清單第 51-52 行：`"Edit(~/.claude/**)"`、`"Write(~/.claude/**)"`，搭配第 54 行 `defaultMode: auto`、第 161 行 `skipAutoPermissionPrompt: true`。project CLAUDE.md「動作前 5 秒自檢」明寫：`Edit ~/.claude/settings.json / ~/.claude/hooks/*.sh / ~/.claude/commands/*.md — 預設不行（防 Claude 自主修改自己的設定 / hook / command）`，唯一例外是走完整 plan mode。掃 wired 的 Edit|Write PreToolUse hook（worktree-only-guard、design-impl-alignment-guard、markdown-stitch-guard）皆無任何 `~/.claude/settings|hooks|commands` 的 self-protection 參照（grep 全部回 no self-protection reference）。
- 為何是問題：這是 prose 與 config 方向完全相反的一條，不是單純缺底線。規範要求自我修改預設擋下、只有 plan mode 放行；但 config 用最寬的 `~/.claude/**` 萬用字元 allow 了 Edit 與 Write，且 auto 模式不跳 prompt、又沒有任何 hook 攔截自我修改路徑。等於規範說預設禁、機制說一律放行。允許自主修改自己 settings/hook 正是 CLAUDE.md 列為高風險的雷。
- 建議：在全域 settings.json 加 `permissions.deny`，把 `Edit(~/.claude/settings.json)`、`Edit(~/.claude/settings.local.json)`、`Edit(~/.claude/hooks/**)`、`Edit(~/.claude/commands/**)` 與對應 `Write(...)` 列入 deny（deny 優先序高於 allow，可硬擋）。plan mode 例外改由人工在當次 session 暫解，或另設專屬 bypass，不要靠萬用 allow 常開。同時收窄 allow 的 `Edit(~/.claude/**)`/`Write(~/.claude/**)`，縮到實際需要的子目錄（如 skills、agents）。

### 43. [補掃] push main / 刪 remote / stash 三條高風險禁令只有 advisory hook，無 deny 也無 hard-block

- 證據：project CLAUDE.md 自檢前三條把 `git push origin main`、`git push origin --delete <branch>`、`git stash` 既有改動列為需明示授權或「不行」。但：(1) 四檔 deny 全空，Python 檢查 `deny entries mentioning git/push: NONE`；(2) 全域 allow 第 7 行 `Bash(git:*)` 把所有 git 子命令一律放行；(3) defaultMode auto；(4) 對應 hook 全是 advisory：safe-ops-guard.sh 只在 `rm -rf`/robocopy 警告且最後 `exit 0`（第 32 行），完全不碰 git push/delete；stash-guard.sh 註解明寫「警告但不阻擋（exit 0）」（第 8 行）並只 `exit 0`；branch-pairing-guard.sh 所有路徑都 `exit 0`（第 91 行為唯一收尾）。逐 hook 判定結果：safe-ops-guard、branch-pairing-guard、stash-guard 皆 advisory only。
- 為何是問題：這三條是 CLAUDE.md 開宗明義列的「我已重複踩過的雷」，授權門檻寫得最重（單獨 ok/commit 都不算）。但機制層對它們是零硬底線：allow 全放、deny 沒用、hook 只印字不擋。auto 模式下 `git push origin main` 會無 prompt 直接執行，唯一阻力是 Claude 自願讀 prose。一旦 prose 注意力衰減（這正是 brevity hook 想防的衰減），最高風險動作沒有任何機械攔截。
- 建議：在全域 settings.json `permissions.deny` 加可硬擋的條目，例如 `Bash(git push origin main)`、`Bash(git push origin --delete:*)`、`Bash(git push * main)` 與 `Bash(git stash:*)`(保留 list/show/pop 等用 allow 細列)。注意 deny 是字串前綴/glob 比對，`Bash(git:*)` 這種寬 allow 配 deny 才有 defense-in-depth。`/game-stop` 等授權路徑需要時再走 Claude 互動或暫時放寬，不要靠常開 allow。

### 44. [補掃] paywall-compliance-notes worktree 帶唯一未 commit 內容、且未推任何 remote，force-cleanup 會永久遺失

- 證據：`git -C ~/Doc/ai-company-worktrees/paywall-compliance-notes/product status` 顯示 modified: no99_archive/2026-06-03_subscription_ios_revenuecat_gap_audit.md。`git diff` 為約 25 行新增段「Paywall 合規決策與 URL 待辦」（含 Apple EULA URL、隱私政策托管待辦）。`git show main:no99_archive/2026-06-03_subscription_ios_revenuecat_gap_audit.md | grep -c` 該標題 = 0（main 不含）。branch -r 無 paywall-compliance-notes，branch -vv 標 `+ feat/paywall-compliance-notes`（無 upstream）。目錄 mtime 2026-06-04 18:26，閒置約 1.5 天。
- 為何是問題：這段是唯一、只存在於此 worktree working tree 的內容，沒 commit、沒推 remote。違反跨機 git 協作規範『未 commit 改動若可能跨機繼續，改用 wip commit + push』。在硬碟接近上限的環境、或日後對此 topic 誤跑 /game-clear（step 2 以 topic 找 paired、step 8 force-remove，--force 連 dirty 葉節點一起刪），這段 Paywall 合規 URL 待辦會永久消失。注意：branch 的所有 committed 內容已併入 main，真正有風險的只有這個 working-tree 修改。
- 建議：到該 worktree 跑 `git commit -m "wip: paywall 合規決策與 URL 待辦"` 後 `git push -u origin feat/paywall-compliance-notes`，把這段唯一內容落到 remote；或若判定該段已被別處取代而不要了，明確 `git checkout -- <file>` 後再走收尾。先存再決定，不要直接 force-remove。

### 45. [補掃] paywall-compliance-notes 與合法 paywall-compliance 為易混淆的近重名雙主題，且結構偏離 <topic>/<layer>-<module> 慣例

- 證據：worktree 根目錄並列：`paywall-compliance/`（design-no2_accounting_app + spec- + impl- 三層，皆 feat/paywall-compliance，gitdir 各指向 design/spec/impl module git，launch.json port 8768 有 entry）與 `paywall-compliance-notes/`（只有 product/ 一層，feat/paywall-compliance-notes，gitdir 指向 product/SuSuGiGi Product git，launch.json 無 entry）。後者用 `<topic>/product/` 而非規範的 `<topic>/<layer>-<module>/`（CLAUDE.md『Worktree 使用慣例 — 目錄與命名慣例』）。
- 為何是問題：兩個只差 `-notes` 的 topic 名並存，一個三層齊備有 server entry、一個單層無 entry，極易在未來 `git worktree add` 或 /sim-review、/game-stop 推 topic 時張冠李戴。這正是補掃缺口擔心的『confusing future worktree-add』。雖然 git 本身認得、/game-over 不會誤刪，但人為與 Claude 推斷層面的混淆風險真實存在。
- 建議：釐清 paywall-compliance-notes 是否仍為活躍主題。若是，考慮更名為語意明確、不與 paywall-compliance 撞首碼的 topic（避免 `-notes` 這種看似手滑變體）；若 committed 內容已併 main、只剩那段 working-tree 待辦要處置，處理完該段後對 Product 層走 `git worktree remove` + `branch -d feat/paywall-compliance-notes` 收掉，讓 worktrees 根目錄回到一 topic 一目錄的乾淨狀態。

## 待複查（驗證無定論）


## 衛生類（未個別驗，建議順手清）

- [hooks] verification-report-guard 與 multi-tier-sync 仍用舊註解口徑 no5_project_management，與 multi-tier-sync 自身 case 對得上但需留意一處註解描述範圍　證據：~/.claude/hooks/multi-tier-sync-guard.sh 第 87 行 case 寫 `*/no5_project_management/*`，與實體目錄 no5_project_management 一致、正確。但同檔第 1-6 行頂註與 verification-report-guard.sh 第 4-6 行頂註描述偵測範圍時，措辭較舊。verification-report-guard 命中規則註解只列 no3_product_designs 與 no6_product_development，與其 case(第 16-21 行)一致，無功能問題。此為註解與實作雖一致、但散落多版措辭的記載衛生。
- [hooks] exit-plan-branch-guard 的 plan 來源 fallback 取『最新 mtime 的 plan 檔』，並行 session 下會驗到別人的 plan——目前是 dead path 但屬潛在地雷　證據：~/.claude/hooks/exit-plan-branch-guard.sh 第 35-38 行：tool_input.plan 為空時 `latest=$(ls -t "$HOME/.claude/plans"/*.md | head -1)` 取最近修改的單一 plan 檔當受檢內容。~/.claude/plans/ 現有 83 個 .md。對最近 40 個 transcript 比對 ExitPlanMode 共 78 次，tool_input.plan 全部非空（78/78），意即現行 harness 永不走這條 fallback——它是 dead path。但 CLAUDE.md 全篇強調多 session 並行；若哪天 harness 改成不傳 plan，fallback 會在跨 session 下挑到別的 session 剛寫的 plan，據以判 branch name，要嘛誤放（別人的 plan 剛好有 feat/）要嘛誤擋。
- [skills] auditor 越界掃描列了 hex 色值 #[0-9a-fA-F]{3,8}，但實際攔截的 spec-guard.sh hook 完全沒有此 pattern——report 與 enforce 兩端對同一條政策不一致　證據：~/.claude/agents/multi-tier-alignment-auditor.md line 108『色值定義：rgba?\(、#[0-9a-fA-F]{3,8}』把 hex 色值列為類型2越界。cross_layer_boundary_policy.md line 22 也明文禁 `#xxxxxx`。但 ~/.claude/hooks/spec-guard.sh line 73 high_pattern 與 line 89 mid_pattern 都不含 hex：grep '0-9a-fA-F' spec-guard.sh 回 NOT FOUND；mid_pattern 只有 `\b[0-9]+ms\b|opacity:\s*[0-9.]+|theme\.[a-z_.]+|rgba?\(`。即 Spec 寫入 `#aabbcc` 時 auditor 事後會標違規、但 PreToolUse 的 spec-guard hook 既不 block（high）也不 warn（mid），放行。
- [agents] git-sync exclude_regex 漏掉盤點規範列的 .worktrees 與 _worktrees 兩個 worktree 家目錄　證據：~/.claude/agents/git-sync.md L30 exclude_regex 只排 /(worktrees|tmp-worktrees|ai-company-worktrees)/。ai-company CLAUDE.md「盤點任務協作節奏」明列 worktree 三路徑：~/Doc/.worktrees/、~/Doc/_worktrees/、~/Doc/ai-company-worktrees/。實測 .worktrees 與 _worktrees 目前不存在（只有 ai-company-worktrees 在），且 _worktrees 不含 -backup-/-work- 後綴故 backup pattern 也不攔。
- [agents] settings.json allow-list stale numbering　證據：settings.json lines 30 to 36 reference no3_product_specs and no4_project_management and no5_product_development which do not exist; current is no4 and no5 and no6.
- [agents] auditor duplicates boundary patterns　證據：auditor.md line 102 names policy file as source but lines 104 to 114 embed patterns also in spec-guard.sh; tokens match today.
- [claudemd-global] cross_layer_boundary_policy.md 引用 delivery_layer 的「層級邊界規則」章節，該標題不存在　證據：~/.claude/skills/spec_writer/cross_layer_boundary_policy.md L7「三層職責切分由 ...delivery_layer.md 的「層級邊界規則」章節定義」。grep delivery_layer.md 無「層級邊界規則」標題；對應內容實際在「承載內容 / 跨層承載內容」段（delivery_layer.md L90、L115、L145）。全域 ~/.claude/CLAUDE.md L129 也把同一規則來源寫成「三層承載清單與模糊邊界處理規則由 delivery_layer.md 定義」（用詞不同但指同處）。
- [claudemd-global] 全域路徑規則的範例檔 ~/.claude/agents/qa-agent.md 不存在　證據：~/.claude/CLAUDE.md L9「必須寫路徑時，以 `~/.claude/` 為錨點起寫（如 `~/.claude/agents/qa-agent.md`）」。實際 agents/ 只有 agent-workflow-manager.md、git-sync.md、multi-tier-alignment-auditor.md、product-planner.md，無 qa-agent.md。
- [claudemd-global] 全域 settings.json 殘留舊編號的一次性 mkdir 權限　證據：~/.claude/settings.json permissions.allow L35「Bash(mkdir -p no4_project_management)」、L36「Bash(mkdir -p no5_product_development)」。現行編號為 no5_project_management / no6_product_development（見實體目錄與 registry）。另 L30-31 的 cp 權限帶 __TRACKED_VAR__ 佔位與 no3_product_specs 舊路徑。
- [claudemd-project] 動作前 5 秒自檢前兩條（push main / 刪 remote）無機械防線，措辭像有閘門　證據：~/Doc/ai-company/CLAUDE.md L7-8 自檢#1（git push origin main 需明示授權）、#2（push origin --delete 刪 remote feat 需明示授權）。settings.json PreToolUse Bash hook 鏈為 safe-ops-guard、branch-pairing-guard、stash-guard、server-launchjson-guard。實讀 safe-ops-guard.sh：只對 rm -rf / Remove-Item -Recurse -Force / robocopy /MOVE 警告，完全不碰 git push。其餘三支也不擋 push main 或 delete remote。
- [claudemd-project] ai-company-worktrees 有未註冊殘留目錄 + 主 impl git 停在 detached HEAD　證據：ls ~/Doc/ai-company-worktrees/ 有 paywall-compliance-notes/（內含 product/ 子目錄），但它不在任一 repo 的 git worktree list（design/spec/impl 三層 worktree list 只見 import-wizard-redesign 與 paywall-compliance，無 -notes）；launch.json 也無對應 entry。另 git -C product/SuSuGiGi/no6_product_development/no2_accounting_app worktree list 顯示主 git 本體在『084d8e2 (detached HEAD)』。
- [claudemd-project] self-check#3『worktree 內啟 Metro 不行』無 hook 攔截，與同段有 hook 撐的條目混列易誤判　證據：~/Doc/ai-company/CLAUDE.md L9 self-check#3：『在 worktree 內啟 Metro / `react-native start` — 不行…symlinked node_modules 在 worktree 跑 Metro 必爆』。實測：block-worktree-ios-build.sh L12 regex 為 `(xcodebuild|pod install|react-native run-ios|npm run ios|yarn ios)`，不含 `react-native start` / `metro start`。grep 全 hooks 目錄，唯一 match `react-native start` 的是 server-launchjson-guard，但它只在帶 `--port` 時抓 port 做『有沒有登記』檢查，無 `--port` 直接 exit 0，且完全不判 worktree vs 主 git。
- [claudemd-project] project settings.json permissions.allow 殘留舊編號路徑（no3_product_specs / no4_project_management / no5_product_development）　證據：~/.claude/settings.json（全域，服務本 project）L30-31 `cp -r ... '~/Doc/ai-company/product/SuSuGiGi/no3_product_specs/no2_accounting_app'` 與 .../no3_product_specs/no1_user_management；L34-36 `mkdir -p no3_product_specs` / `no4_project_management` / `no5_product_development`。實測 no3_product_specs No such file or directory（specs 已遷 no4_product_specs，no3 現為 no3_product_designs）；實際結構是 no4_product_specs / no5_project_management / no6_product_development。
- [registry] UndergroundRemake 磁碟有 no5_project_management 但 registry layout 未列　證據：products_registry.md:155-162 UndergroundRemake 的 decision_framework_layout 只列 proposal/requirements/product_map/roadmap/designs_root/specs_root，無 project_management 欄。實際 `ls product/UndergroundRemake/` 有 no5_project_management 目錄。對照 SuSuGiGi(:31) 與 Hatsuon(:111) 的 layout 都含 project_management。
- [launchjson] design port 8766 與 metroPort 8082 有跳號，源自 explore-transfer-editor 收工後未回填　證據：port 排序為 [8765, 8767, 8768, 8769]，缺 8766；metro 排序 [8081, 8083, 8084, 8085]，缺 8082。git log -p 顯示 8766 曾屬於 susugigi-design-explore-transfer-editor entry（commit f78bcd5 加入、後續移除），對應 worktree ~/Doc/ai-company-worktrees/explore-transfer-editor 現已不存在（ls: No such file or directory）。
- [launchjson] hook 的 metroPort 豁免區間只有 8081-8090（10 槽），扣掉已用剩 6 槽；補完未登記 impl 後逼近上限，再開主題會撞 hook 邊界　證據：server-launchjson-guard.sh 第 59 行：`if (( port < 8081 || (port > 8090 && port < 8765) || port > 8800 ))` 則放行（不檢查）。即 metroPort 受管區間是 8081-8090，共 10 個號。目前已用 8081/8083/8084/8085（4 個），加上跳號空洞 8082，實際可分配剩 8086-8090（5 個）。補完第一輪要補的兩個 impl（8086/8087）後只剩 8088/8089/8090 三槽。design 區間 8765-8800（36 槽）相對寬鬆、目前用到 8769，短期無虞。
- [memory] redeem memory 列的殘留位置不全——只寫 payment.md，漏了 structure.md 與 index.md　證據：project_susugigi_redeem_code_dropped.md:14 只點名「Product Map payment.md 仍殘留定義（功能清單一句『序號兌換介面』+ L35 起 RedeemCodeScreen 整段）」。實查 Product Map：RedeemCodeScreen / 序號兌換 還同時出現在 structure.md:70（Payment 樹節點）與 :130（摘要列）、app/index.md:11（摘要列），不只 payment.md。今天 2026-06-05 的 no99_archive/2026-06-05_no2_accounting_app_four_layer_audit.md:322 已完整列出全部 4 處（structure.md:70/:130、payment.md:5/:35-47、index.md:11）。
- [memory] 一輪 wikilink 普查少算一條（5 應為 6）並錯置一條歸屬　證據：實際 grep memory 全目錄得 6 條 wikilink，非一輪所稱 5 條：feedback_concise_chinese_dialogue.md:14 [[feedback_restate_user_intent_before_acting]]、feedback_content_additions_not_spec.md:14 [[feedback_explorations_stay_in_design]]、feedback_derive_dont_hardcode_with_guard.md:14 [[feedback_restate_user_intent_before_acting]]、feedback_ios_build_in_main_git_only.md:28 [[feedback-worktree-for-parallel-themes]]、feedback_restate_user_intent_before_acting.md:22 [[feedback-no-repeat-after-authorization]]、reference_design_guard_bypass.md:17 [[feedback_ios_build_in_main_git_only]]。一輪 finding #2 把 reference_design_guard_bypass.md:17 與 feedback_ios_build_in_main_git_only.md 都記成指向 [[feedback_ios_build_in_main_git_only]]，但 feedback_ios_build_in_main_git_only.md:28 實際指向的是 [[feedback-worktree-for-parallel-themes]]（連字號形）。
- [memory] feedback_design_canvas_subnav 的「22 個 screen group」已過時，現為 26　證據：feedback_design_canvas_subnav.md:14（檔齡 17 天，帶『may be outdated』reminder）稱『Screens tab ... 22 個 screen group 走 sub-navigation』。實查機制檔 no3_product_designs/no2_accounting_app/project/90_workbench/app.jsx 的 `SCREEN_GROUPS` array 為 26 個 group（home/home-filter/search/.../merge-editor），非 22。值得注意：design git 自身的 CLAUDE.md「內容概覽」也仍寫『Screens — 22 個畫面群組』，即 memory 與該 CLAUDE.md 當初一致、之後一同 drift 到落後 code。
- [commands] 殘留 Windows 風格 project 目錄 C--Users-ken-chio-Doc-ai-company　證據：`ls -d ~/.claude/projects/*ai-company*` 列出 `/Users/kenchio/.claude/projects/C--Users-ken-chio-Doc-ai-company`，與 active 的 `-Users-kenchio-Doc-ai-company` 並存。名稱是 Windows `C:` + `ken-chio` 舊家目錄格式，明顯是別台機 / 舊路徑遺留的 transcript 目錄。
- [commands] /sync-gits 排除清單列舉與 git-sync agent 實際 regex 用語不完全對應　證據：`~/.claude/commands/sync-gits.md`「排除目錄」段列 `_*-backup-*/`、`_*-work-*/`、`*-worktrees/`、`worktrees/`、`tmp-worktrees/`、`node_modules/`、`.claude/plugins/marketplaces/`。實際執行的 `git-sync` agent regex（agent line 30/41）是 `_[^/]+-(backup|work)-|/(worktrees|tmp-worktrees|ai-company-worktrees)/|/node_modules/|/\.claude/plugins/marketplaces/`。差異：agent 明列 `ai-company-worktrees`（doc 用萬用的 `*-worktrees/` 涵蓋，勉強對得上），但 doc 的 `*-worktrees/` 萬用寫法在 regex 裡其實只精確列了 `worktrees|tmp-worktrees|ai-company-worktrees` 三個固定字串，並非真正萬用 — 任何其他 `xxx-worktrees/` 不會被排除。
- [commands] 全域 settings.json 殘留舊編號的 mkdir 權限（no4_project_management / no5_product_development）　證據：~/.claude/settings.json line 35 `Bash(mkdir -p no4_project_management)`、line 36 `Bash(mkdir -p no5_product_development)`。但 disk 與 registry 一致用 `no5_project_management`、`no6_product_development`（SuSuGiGi disk `ls` 確認、registry line 30/31 確認），即這兩條 allow 的目錄編號比現行 layout 少 1，是遷移前的舊 SOP 殘留。同檔 line 32-34 的 mkdir（no1_product_initiation / no2_product_planning/... / no3_product_specs）也是舊 specs_root 編號（現行 specs 在 no4_product_specs）。
- [補掃] 全域 settings.json line 37 `Edit(~/.claude/skills/decision_framework_router/**)` 為死規則，被 line 51 完全涵蓋　證據：`~/.claude/settings.json` line 37 `"Edit(~/.claude/skills/decision_framework_router/**)"` 與 line 51 `"Edit(~/.claude/**)"`。glob `**` 比對任意深度，故 `~/.claude/**` 嚴格包含 `~/.claude/skills/decision_framework_router/**`，兩者同為 Edit 軸，line 37 無任何 line 51 涵蓋不到的情形。
- [補掃] 全域 allow list 殘留兩條永不匹配的 cp -r 條目（placeholder 未代換 + 目標目錄不存在）　證據：~/.claude/settings.json 第 30-31 行："Bash(cp -r __TRACKED_VAR__/accounting-spec '~/Doc/.../no3_product_specs/no2_accounting_app')" 與 usermgmt 版。`env | grep TRACKED` 無此變數（exit 1），`__TRACKED_VAR__` 是未代換的字面 placeholder；`ls product/SuSuGiGi/no3_product_specs` → No such file（實際為 no4_product_specs，見第 30 行同檔證據）。來源 accounting-spec／usermgmt-spec 在 ~/Doc 下 find 不到。
- [補掃] 全域 allow list 兩條 bash 指向已不存在的 _partb-github-ops 腳本　證據：~/.claude/settings.json 第 38-39 行："Bash(bash ~/Doc/_partb-github-ops.sh)" 與 "...-2.sh"。`ls ~/Doc/_partb-github-ops*.sh` → no matches found；`find ~/Doc -maxdepth 2 -name '_partb*'` 無結果；`ls ~/Doc/*.sh` → no matches。兩腳本在 ~/Doc 下任何深度都不存在。
- [補掃] settings.local.json 殘留 7 個已消失 worktree 的 16 條絕對路徑 allow entry，且無任何清理機制　證據：~/Doc/ai-company/.claude/settings.local.json 共 103 條 allow，其中 16 條寫死 7 個已 GONE 的 worktree 絕對路徑。逐條(line:內容)：line 42 `Bash(WT=/Users/kenchio/Doc/ai-company-worktrees/period-expand-height-clip/...)`、line 43 該 worktree 的 .bin/eslint、line 45 該 worktree 的 .bin/tsc、line 46 `rmdir .../period-expand-height-clip`、line 47 `Read(//...period-expand-height-clip/**)`、line 51 `Read(//...add-currency-icon/**)`、line 52 `Read(//...category-account-editor-ui-fix/**)`、line 53 `Read(//...self-built-date-picker/**)`、line 59 grep self-built-date-picker 的 theme.ts、line 77 `Read(//...list-card-hug-content/...)`、line 83-84 remove-merge-warning-banner 的 DW/IW、line 85 `Read(//...remove-merge-warning-banner/...)`、line 88 ln -s 到 pref-selection-frozen-order、line 89 `Read(//...pref-selection-frozen-order/...)`。實測 7 個路徑 [ -d ] 全 GONE，ls ~/Doc/ai-company-worktrees/ 只剩 fix-google-signin-web-client-id、import-wizard-redesign、paywall-compliance、paywall-compliance-notes；git worktree list --porcelain 也無這 7 個。grep `settings.local.json` 跨 hooks/commands/skills/agents = 零引用。
- [補掃] settings.local.json 累積大量一次性死碼 entry（特定 PID、已刪 /tmp 路徑、寫死 URL），無收斂步驟　證據：同檔 ~/Doc/ai-company/.claude/settings.local.json：line 10 `Bash(kill 81591)`、line 11 `Bash(kill 81594)` 為一次性 PID(早已無意義)；line 17 `Bash(cp -r /tmp/anthropic-skills-r3qEyi/skills/frontend-design ...)`、line 18 同源 theme-factory，而 /tmp/anthropic-skills-r3qEyi 實測已不存在；line 9 `Bash('/Applications/Google Chrome.app/.../Google Chrome' --new-window --auto-open-devtools-for-tabs 'http://localhost:8765/SuSuGiGi.html#all')` 寫死單一 URL+port。全檔 23 條 entry 硬編 SuSuGiGi/worktree 絕對路徑(grep -c 命中)。整份檔案無任何機制做收斂或泛化。
- [補掃] branch 命名 token r-id 與 slug 全工作區無定義　證據：grep r-id / slug / requirement id / R[0-9] 掃 ~/.claude/CLAUDE.md、~/Doc/ai-company/CLAUDE.md、~/.claude/skills/decision_framework_router/products_registry.md，命中僅 ~/.claude/CLAUDE.md:222 與 231 兩處使用，無任何一處定義 r-id（需求編號？）或 slug 的產生規則。products_registry.md 與 decision_framework_router 也無需求編號慣例。
- [補掃] exit-plan-branch-guard.sh 只把關 feat/ 前綴、無法仲裁 branch shape 衝突　證據：~/.claude/hooks/exit-plan-branch-guard.sh:47 `if printf '%s' "$plan" | grep -qE 'feat/[a-z0-9]'; then exit 0; fi`。regex 僅要求 feat/ 後接一個英數字元即放行，對 feat/r-id-slug 與 feat/topic 兩種 shape 同樣通過。
- [補掃] 全域 settings.local.json 帶 4 條 Windows-only allow entry，用的是另一台機 username ken.chio　證據：~/.claude/settings.local.json:10-13 — `Bash(robocopy "C:\\Users\\ken.chio\\OneDrive - 勝和科技有限公司\\文件\\Repository\\KnowledgeVault" ...)`、`Bash(cmd /c robocopy ...)`、`Bash(powershell:*)`、`Bash(/c/Program Files/GitHub CLI/gh.exe auth *)`。本機 whoami=kenchio、$HOME=/Users/kenchio（非 ken.chio）。實測 `/c/Program Files/GitHub CLI/` 不存在、`C:\Users\ken.chio` 不存在、`powershell`/`pwsh` not found——4 條全 inert，permission pattern 在 macOS 永不命中。
- [補掃] settings.local.json 曾被 git 追蹤並 commit，是跨機污染的傳播途徑（根因鏈）　證據：`git log --diff-filter=A -- settings.local.json` → c596f15 新增；`git show --stat` 顯示 60e7abc、39b0ced 也改過其內容（含 repo-root 與 .claude/ 巢狀兩個路徑）；c5ca1d9 才 untrack+gitignore（commit msg：『untrack 1 existing jsonl + settings.local.json』）。`git show c596f15:.claude/settings.local.json` 當時內容含 `git -C "C:/Users/ken.chio/.claude" remote -v` 等 Windows 路徑 entry。
- [補掃] 四個 settings 檔零 `deny`/`ask`，defense-in-depth 完全缺席　證據：Python `json.load` 四檔結果：GLOBAL settings `deny=False ask=False allow_n=49 defaultMode=auto`；GLOBAL settings.local `deny=False ask=False allow_n=11`；PROJECT settings `deny=False ask=False allow_n=0`(只有 hooks 區塊、無 permissions)；PROJECT settings.local `deny=False ask=False allow_n=103`。彙總 `ANY deny anywhere? False / ANY ask anywhere? False`。對照 CLAUDE.md 兩處祈使禁令密度：自檢段 9 條；全 CLAUDE.md `不行/需使用者明說/禁止/不得/絕不可/預設不行` token 數 global 11、project 13。
- [補掃] brevity stash 在 session 無後續 prompt 時洩漏，無 SessionEnd 清理　證據：`~/.claude/hooks/brevity-meter.sh:92-96` 在合格長報告時寫 stash 檔 `${TMPDIR}/claude-brevity-<session_id>`；清理只有兩處——meter 自己下一次非觸發 Stop 的 `clear()`（L35/63/85），與 `~/.claude/hooks/brevity-refresh.sh:34` 的 `os.remove(stash)`（下一輪 UserPromptSubmit）。`grep -rn SessionEnd ~/.claude/settings.json ~/Doc/ai-company/.claude/settings.json` 回 (no SessionEnd/SessionStart hooks)。實測：若 session 在長報告後結束、無下一個 prompt，stash 留在 TMPDIR 直到 OS prune。本機 TMPDIR=`/tmp/claude-501` 不被即時清（同目錄有 5/30、6/4 的 RN codegen 殘留 dir 仍在）。
- [補掃] meter→refresh 注入依賴 harness 跨事件給同一 TMPDIR，屬未記載的隱性耦合　證據：`brevity-meter.sh:25` 與 `brevity-refresh.sh:26` 都用 `os.environ.get("TMPDIR", "/tmp")` 組 stash 路徑。本機 TMPDIR 是 sandbox 自訂值 `/tmp/claude-501`（非 macOS 預設 `/var/folders/jm/.../T/`），且 `grep TMPDIR ~/.zshrc ~/.zprofile ...` 回「未在 shell profile 設」=繼承自啟動行程。測試 `tests/brevity-test.sh:11-12` 用 `mktemp -d` 自建 TMPDIR 並 export，所以測試恆過、繞開了 production 的真實依賴。實測本環境 round-trip 正常（meter 寫 `/tmp/claude-501/...`、refresh 從同路徑讀到並刪），代表 Stop 與 UserPromptSubmit 目前拿到同一 TMPDIR。
- [補掃] sourcekit-lsp 對 SuSuGiGi 這種 xcodeproj-based RN app 只能跑 fallback 模式，無專案級符號解析　證據：iOS 專案根 no6_product_development/no2_accounting_app/ios/ 是 xcworkspace + xcodeproj 結構，無 Package.swift（`find ... -name 'Package.swift' | grep -v Pods` 空）、無 compile_commands.json、無 buildServer.json（`ls` 三者皆 No such file）。marketplace.json 的 lspServers 只給 `command: "sourcekit-lsp"`、無 args、無 root marker hint。sourcekit-lsp 缺這三類 build context 時退回 global-module fallback。

## 各路覆蓋

- Hook 完整性（hooks）：發現 8 條
- Skill 健康（skills）：發現 10 條
- Agent 一致（agents）：發現 8 條
- CLAUDE.md global 對帳（claudemd-global）：發現 10 條
- CLAUDE.md project 對帳（claudemd-project）：發現 12 條
- registry 對目錄（registry）：發現 7 條
- launch.json port（launchjson）：發現 5 條
- Memory stale（memory）：發現 8 條
- command 對 skill（commands）：發現 9 條
