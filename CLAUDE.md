# AI Company — Claude Code 全局設定

## 動作前 5 秒自檢

執行下列動作前先停一拍確認授權範圍。每條都對應重複踩過的雷。

- push main / merge to main — 需使用者明說 `merge` 或 `push main`，或走 `/game-stop`（該 command 即配對 commit + push + merge + cleanup 全程授權）；單獨的 `ok`、`commit`、`完成了` 都不算
- 刪 remote feat branch — 需使用者明說「刪 remote」，或 `/game-stop`、`/game-clear`（帶 `--keep-remote` 除外）
- worktree 內啟 Metro — 不行，symlinked node_modules 在 worktree 跑 Metro 必爆；Metro 只跑主 git path。見「Port 協作規範」
- `git stash` 使用者既有的 uncommitted 改動 — 不行；改 wip commit 或停下問
- worktree 內 `npm ci` / `npm install` / 複製 node_modules — 不行，symlink 才合規；唯一例外是主題本身動 `package.json`。見「Worktree 使用慣例」
- Edit `~/.claude/settings.json` / `hooks/*.sh` / `commands/*.md` — 預設不行。唯一例外：正式 plan mode 流程（plan 檔在 `~/.claude/plans/`、ExitPlanMode 走過、使用者明示 ok）且 plan 明列該檔；commit 加 `self-modification` 標籤
- 主 git 路徑下 Edit / Write `product/<產品>/no[34567]_*` 任一檔 — 不行，必須先在 worktree 內；`no1`、`no2`、`no99` 屬頂層 Product git，hook 不機械攔截但仍守全員 worktree。見「Worktree 使用慣例」
- Edit impl UI 檔（`src/screens/**`、`src/components/**`、`src/constants/theme.ts`）— 必須先 Read 對應 design 檔，hook 會擋。見「Design-Impl 對齊」
- `/game-over` / `/game-clear` dry-run / 跨 git 盤點 / 多 worktree 清理 — 不分批給結果。見「盤點任務協作節奏」

完整規則見全域「跨機 git 協作規範」「修改流程規範」與本檔「多產品多層 git 協作規範」「動工前置」「Worktree 使用慣例」「Port 協作規範」。本段只是濃縮自檢。

## 頂層目錄結構
```
ai-company/
├── company/     公司層級定位與產品索引
├── product/     所有產品（App 程式碼 + Spec 文件）
├── project/     各產品專案管理文件
└── finance/     公司層級股權與財務管理
```

## 公司文件路徑
- 公司 context：`company/context.md`
- 產品索引：`company/products.md`

## 產品路徑

各產品採決策框架 noN 分層、依 module 拆分（spec `no3_product_specs/`、design `no4_product_designs/`、impl `no5_product_development/`、quality `no6_product_quality/`、release `no7_product_release/`，各層下接 `<module>/`）。層模型唯一真相是 `layer_manifest.yaml`；配對與屬性（remote、private、空殼、sub_mapping）權威在 `~/.claude/skills/decision_framework_router/products_registry.md`，本節只列路由入口。

- SuSuGiGi：`product/SuSuGiGi/`——`no2_accounting_app`（spec + design + impl + quality + release 五層全）、`no1_user_management`（僅 spec，plan-only）、`no3_cloud_functions`（spec + impl，後端無 UI）、`no4_support_site`（僅 impl，內容即真相）
- Hatsuon：`product/Hatsuon/`——`no1_pronunciation_app`（spec + impl）
- LiquidGlassHeaderTemplate：`product/LiquidGlassHeaderTemplate/`——`no1_liquid_glass_header`（spec 空殼 + impl）
- UndergroundRemake：`product/UndergroundRemake/`——`no1_concept`（僅 spec，概念階段）

## 財務路徑
- 股權原則：`finance/no1_principles/`
- 各產品貢獻帳本：`finance/no2_ledgers/<ProductName>/`
- 公司股權操作管理：`finance/no3_operation/`

## 多產品多層 git 協作規範

骨架不變式（branch 同名、commit 同 subject+body、各層各自 `--no-ff` merge）與「Branch 涉及範圍」判準持在全域 CLAUDE.md 同名節；本節承載其餘細則。

- **git 拆分結構：** 每產品拆為頂層 Product git 與依 module 拆分的各層 git。層的編號、目錄名、git 邊界只在 `layer_manifest.yaml` 宣告；實例配對在 `products_registry.md`；兩者與衍生物的一致性由 `~/.claude/hooks/tests/layer-manifest-test.sh` 檢核
- **頂層 Product git 承載：** 提案層、需求層、整合層 Product Map、Roadmap；專案管理文件在 ai-company 根 git 的 `project/<產品名>/`；另追蹤 `no99_archive/` 歸檔層，收納工作追蹤筆記、規格衝突報告、已廢案 spec 等非決策框架核心層檔案
- **新增產品 / 新增 module SOP：** 依 `products_registry.md` 末段變更 SOP 走檢核器迴圈——改宣告、跑 `layer-manifest-test.sh`、照 FAIL 清單補實體與文件、再檢核至全綠
- **Spec 層職責邊界：** spec 文件的 MVC 分層政策與跨層禁止項由 spec_writer skill（含 `cross_layer_boundary_policy.md`）承載；各 spec module git 的 CLAUDE.md 為入口
- **已知邊界：** 本機 hook 僅提示層，無法保證遠端 merge 真的配對發生；要硬保證走 CI 或遠端 pre-merge 檢查

## 動工前置

凡動註冊產品的 spec / design / impl / quality / release 路徑，第一個 Edit / Write 之前四步全做完：

1. **跑 decision_framework_router 答上游四問**（屬哪個產品 / 哪一層 / 哪個 module / 需求根因與 Product Map 對應項存在嗎）
2. **依四問結果確認要動的層**——單層或跨多層都明確列出
3. **每個要動的層 git 各自 `git worktree add` 建同名 feat branch**——名稱沿用 plan 內已定的（全域「Plan 產出規範」）；跨層完全一致、同步建立，不允許「只開 impl、之後再補」
4. **動工前最後檢查 cwd**——`pwd` 在 `~/Doc/ai-company-worktrees/<topic>/<layer>-<module>` 下、`git branch --show-current` 是 `feat/<topic>` 不是 main

「已知道要改哪個檔」「只是小改」「先動再說」都不是跳步理由；跳過事後必須 `git reset --hard` 重開，不如一開始做對。框架的價值是確認層沒選錯；同名同步建立的價值是 commit 配對與 merge 才能對齊。

## Worktree 使用慣例

主 git 永遠停在乾淨 main。任何主題改動一律 `git worktree add` 隔離，不在主 git 開 feat branch，無例外（含 hot-fix、一次性小改、無並行時）。理由：並行 session 動同產品時，任一 session 在主 git 開 branch，另一 session 的 merge 就撞牆；worktree 是秒級操作、代價極低。

### 目錄與命名

- worktree 集中在 `~/Doc/ai-company-worktrees/<topic>/`，末層目錄名兩形：module 層 git 用 `<layer>-<module>`（如 `spec-no2_accounting_app`）；頂層 Product git 用 `product-<產品名小寫>`（如 `product-susugigi`）
- 末層目錄名是 hook 反查產品與層級的唯一錨點，改名須同步 `multi-tier-sync-guard.sh` 與 `branch-pairing-guard.sh` 的反查正則
- 同主題跨多層 git 用完全相同的 branch 名稱
- 開新 worktree 後、啟 server 前，為它 append launch.json entry（見「Port 協作規範」），否則 verify 看到的是原 git 內容

### node_modules 一律 symlink

需要 node_modules 的 worktree 強制 symlink 主 git 那份（`ln -s <主 git node_modules 絕對路徑> ./node_modules`），禁止各自 `npm ci` / `npm install`——單份約 1.9 GB，多 worktree 各一份會爆硬碟；worktree 與主 git 本來就是共用精神。**唯一例外：** 主題本身要動 `package.json` / lock 檔——動工前先說明、獨立 npm ci、收工立刻刪那份 node_modules 並 recreate symlink。

### 動作層面流程

**開工**——對每個要動的層 git，各層同步建立、branch 名相同：

```
git -C <該層主 git> worktree add ~/Doc/ai-company-worktrees/<topic>/<layer>-<module> -b feat/<topic> main
```

**改檔 + 靜態檢查**（lint / tsc / spec-term-audit）全在 worktree 內。

**commit + push：** `cd <worktree>` → `git add` + `git commit` + `git push -u origin feat/<topic>`；各層各自 commit，subject + body 完全相同（見「多產品多層 git 協作規範」）。

**merge to main**——各層各自配對執行，主 git 全程停在 main、無 checkout：

1. 確認 worktree 已 push feat——這一步是「remote 是唯一真相」的安全點
2. `git -C <該層主 git> merge --no-ff feat/<topic>`（worktree 與主 git 共享 `.git/refs`，local feat 與 origin/feat 同 hash，免 fetch）
3. `git -C <該層主 git> push`

**收尾：** `git -C <主 git> worktree remove <worktree 路徑>` + `git -C <主 git> branch -d feat/<topic>`。

### 唯一例外（極窄）

純歷史性檔案整理（修 `.gitignore`、錯字單 commit），且此刻無其他 session 動同產品——可在主 git 直接動。除此無例外。

## Design-Impl 對齊

凡有 design git 的產品，impl 寫 UI 時 token、component、screen layout 必須對齊 design——不擅自設值，先查 design 對應 token 與 component 結構再對應到 impl。目前只有 SuSuGiGi `no2_accounting_app` 有 design git；未來任何產品建 design git 後，本規則與 hook 自動套用。

- **範圍：** impl 的 `src/screens/**`、`src/components/**`、`src/constants/theme.ts`（任何產品都套）；對應同 module design 的 `project/10_foundations/`（tokens）、`20_components/`（元件）、`30_screens/`（layout）。仲裁配對權威在 `products_registry.md`：design 仲裁、impl 跟進
- **動作層面：** 動 impl UI 前必須先 Read 同 module 對應 design 範圍任一檔。`~/.claude/hooks/design-impl-alignment-guard.sh` 在 PreToolUse 攔截：同 session 已讀過放行；沒讀過擋下並明示要讀哪些路徑；design 目錄不存在自動放行
- **例外（極窄）：** 純邏輯修補不動視覺（useEffect、data fetching、handler 邏輯），設 `export CLAUDE_SKIP_DESIGN_GUARD=1` 繞過，該 session 後續全放行；判斷由執行者擔責、濫用會回到沒對齊的爆氣循環
- **impeccable skill 接口：** 註冊產品的設計工作一律走 decision_framework_router 與該 module 的 design git，不用 impeccable；impeccable 只用於非註冊產品的 web / artifact 場景

## Port 協作規範

多 worktree 並行跑 server 會撞 port。解法：集中註冊表 `~/Doc/ai-company/.claude/launch.json`，所有 server 啟動前必查表、不自選 port。

### 註冊表與硬規則

每個 worktree 一條 entry，欄位：`name`（人類可讀標籤）、`directory`（相對 ai-company 根目錄；`directory` 與 `runtimeArgs` 內任何路徑都**禁止絕對路徑**——launch.json 跨機共享，絕對路徑只對單機有效，混入會讓另一台機看到無法解析的路徑）、`port`（design canvas 用，base 8765 遞增）、`metroPort`（base 8081 遞增；純佔位防手動 hardcode 衝突，`/sim-review` 不讀它、統一跑 8081——app 嵌入的 bundler URL 即 8081，切 worktree = 換 Metro 來源、不換 port）。

- `git worktree add` 完成後、啟任何 server 前，**必須** append entry；未加不許啟 server。分配 port = 現有最大 +1
- `git worktree remove` 後**同步移除** entry；`/game-stop` 自動處理，手動 remove 自己記得
- 回報訊息「驗證位置」的 server URL 必須對齊 entry port（銜接全域「驗證回報規範」），不允許報無對應的 port

### 輕量 server（design canvas）

每 instance 約 10 MB，可多 instance 並行；每個 worktree 用自己 entry 的 port 跑 `python3 -m http.server <port>`。

### 重量資源（Metro / iOS Simulator）：一律走 /sim-review

原獨立節「iOS 自驗策略」已併入本節，hook 訊息引該名時指的就是這裡。

- simulator 驗證一律 `/sim-review` 一鍵全自動：判別只動 JS 或動到原生、切 Metro、build、還原，流程細節與排隊規則見 `~/.claude/skills/sim-review/SKILL.md`
- `/sim-review` 觸發以外，Claude 不主動啟、不主動切 Metro、不動 simulator——低 RAM 環境並行 Metro 會壓死系統；這兩個資源平時由使用者手動管理
- **禁止 worktree 內 build**（`npm run ios`、`xcodebuild`、`pod install`）——各自 build 會在 DerivedData 累積 cache 爆磁碟；build 集中主 git、由 `/sim-review` 觸發。`.claude/hooks/block-worktree-ios-build.sh` PreToolUse 機械攔截
- 完成改動、預期使用者想上 simulator 看時，回報「驗證位置」段引導打 `/sim-review`（見全域「驗證回報規範」內「回報訊息：simulator 走 /sim-review」）

## 盤點任務協作節奏

涵蓋 `/game-over`、`/game-start`、跨 git 盤點、多 worktree 清理等掃整片任務。

**第一輪必須掃完整，不分批。** 範圍最少含：

- 所有頂層 git（`~/Doc/ai-company` 與底下產品 git）與所有 module 子 git（五層）
- 所有 worktree。活躍根唯一：`~/Doc/ai-company-worktrees/`（兩層 `<topic>/<末層名>` 慣例，末層名依「Worktree 使用慣例」兩形；空殼 rmdir 只認此根）；遺留根 `~/Doc/.worktrees/`、`~/Doc/_worktrees/` 存在才順手掃。dirty 偵測靠 `git worktree list` 自報、與根路徑無關

**請示節奏：** 全部訊號收齊、建議列完，才集中請示一次，不邊掃邊問；不可逆操作（worktree remove、branch delete、merge to main）歸入請示清單而非當下執行。

回報結構——三件套、禁止降級指代、精簡可掃描——沿用全域 `~/.claude/CLAUDE.md`「對話回報訊息規範」，不在此重述；唯逐欄比對更清楚時可用表格。
