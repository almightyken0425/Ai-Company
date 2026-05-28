# AI Company — Claude Code 全局設定

## 動作前 5 秒自檢

執行下列動作前先停一拍，對照規則確認授權範圍。每條都對應一個我已重複踩過的雷。

- `git push origin main` / 任何對 main 的 push — 需使用者明說 `merge` 或 `push main`；`ok`、`commit`、`完成了`、`/game-stop` 都不算授權
- 在 worktree 內啟 Metro / `react-native start` — 不行，Metro 只能跑在主 git path；symlinked `node_modules` 在 worktree 跑 Metro 必爆。詳見「Port 協作規範」
- `git stash` 使用者既有的 uncommitted 改動 — 不行；改用 wip commit 或停下問
- `cp -r .../node_modules` / `npm ci` / `npm install` 在 worktree — 不行，symlink 才合規。唯一例外是該主題本身要動 `package.json`。詳見「Worktree 使用慣例」
- Edit `~/.claude/settings.json` / `~/.claude/hooks/*.sh` — 不行，self-modification 是 hard block，使用者授權也無法解
- Edit / Write 主 git 路徑下 `product/<產品>/no[346]_*` 任一檔 — 不行，必須先在 worktree 內。詳見「Worktree 使用慣例」

完整規則散在「跨機 git 協作規範」（全域）、「修改流程規範」（全域）、「動工前置」「Worktree 使用慣例」「Port 協作規範」（本檔）各節。本段只是濃縮版自檢清單。

## 頂層目錄結構
```
ai-company/
├── company/     公司層級定位與產品索引
├── product/     所有產品（App 程式碼 + Spec 文件）
└── finance/     公司層級股權與財務管理
```

## 公司文件路徑
- 公司 context：`company/context.md`
- 產品索引：`company/products.md`

## 產品路徑
- Hatsuon App：`product/Hatsuon/HatsuonApp/`
- Hatsuon Spec：`product/Hatsuon/HatsuonSpec/`
- SuSuGiGi App：`product/SuSuGiGi/SuSuGiGiApp/`
- SuSuGiGi Spec：`product/SuSuGiGi/SuSuGiGiSpec/`
- LiquidGlassHeaderTemplate：`product/LiquidGlassHeaderTemplate/LiquidGlassHeaderTemplate/`
- UndergroundRemake Spec：`product/UndergroundRemake/UndergroundRemakeSpec/`（程式碼尚未建立）

## 財務路徑
- 股權原則：`finance/no1_principles/`
- 各產品貢獻帳本：`finance/no2_ledgers/<ProductName>/`
- 公司股權操作管理：`finance/no3_operation/`

## 動工前置

凡牽涉 SuSuGiGi、Hatsuon、LiquidGlassHeaderTemplate、UndergroundRemake 或未來註冊產品的 spec / design / impl 路徑改動，在第一個 Edit / Write 之前必須完成下列四步，全做完才能動工：

1. **跑 decision_framework_router skill 答上游四問**（屬哪個產品 / 哪一層 / 哪個 module / 需求根因與 Product Map 對應項存在嗎）

2. **依四問結果確認要動的層**（design / spec / impl 一層或多層；單層、跨兩層、跨三層都明確列出）

3. **在每個要動的層 git 各自用 `git worktree add` 建立同名 feat branch**
    - branch 名稱跨層必須**完全一致**，含前綴、連字號、大小寫
    - **強制用 worktree**（不在主 git 開 branch；詳見下一節「Worktree 使用慣例」）
    - 跨層同步建立——不允許「只開 impl 一層、之後再補」

4. **動工前最後檢查 cwd 在 worktree 內**
    - 跑 `pwd` 確認在 `~/Doc/ai-company-worktrees/<topic>/<layer>-<module>` 路徑下
    - 跑 `git branch --show-current` 確認是 `feat/<topic>`，不是 main

「我已經知道要改哪個檔案」「只是小改」「先動再說」都不是跳過任何一步的理由。跳過任何一步事後一定要回頭補（`git reset --hard` → 重開），不如一開始做對。

框架的價值是確認你想動的那一層不是錯的層；branch 同步建立的價值是後續 commit 配對與 merge 才有可能對齊。

## Worktree 使用慣例

主 git 永遠停在乾淨 main 上。任何主題改動一律用 `git worktree add` 隔離，不在主 git 上開 feat branch。這條規則無例外——包括 hot-fix、一次性小改、單一 git 單一主題情境。

### 為什麼全員 worktree

兩個並行 session 動同一個產品時，若任一 session 直接在主 git 開 branch，另一個 session 想 merge 時主 git 不在 main，會撞牆要等對方收尾。「全員 worktree」消除這個風險，並且代價極低（`git worktree add` 是秒級操作）。

「我只改一行」「我等等就 merge」「現在沒並行」都不是跳過 worktree 的理由。未來自己也可能開第二個 session，現在預先用 worktree 就讓未來自己不必煩惱。

### 目錄與命名慣例

- worktree 集中放到 `~/Doc/ai-company-worktrees/<topic>/<layer>-<module>/`
- 同主題跨四層 git 用**完全相同的 branch 名稱**（含前綴、連字號、大小寫）
- Preview server / `launch.json` 為新 worktree 路徑新增條目，否則 verify 看到的是原 git 內容而非 worktree 改動

### node_modules 一律 symlink，禁止各自 npm ci

worktree 開好之後，需要 node_modules 才能跑（例如 RN impl 層）的話，**強制** symlink 主 git 那份：

```
cd <worktree>
ln -s <主 git 的 node_modules 絕對路徑> ./node_modules
```

不允許跑 `npm ci` / `npm install` 讓 worktree 自己有一份。理由：

- 單一 impl 的 node_modules 約 1.9 GB；三個並行主題 worktree 各一份 = 5.7 GB
- 對硬碟接近上限的環境會直接爆
- worktree 與主 git 共享 .git，本來就是「共用為主」精神

**唯一例外：** 該主題本身就要動 `package.json` / `package-lock.json`、需要 commit 依賴變動。這種情況：(a) 動工前先說明、(b) 用獨立 npm ci、(c) 主題收工立刻 recreate symlink 並 `rm -rf` 那份 worktree 自己的 node_modules。

### 動作層面流程

**開工：** 對每個要動的層 git，跑

```
git -C <該層主 git> worktree add ~/Doc/ai-company-worktrees/<topic>/<layer>-<module> -b feat/<topic> main
```

四層同步建立、branch 名稱完全相同。

**改檔 + 跑靜態檢查：** 全在 worktree 內進行（lint / tsc / spec-term-audit）。

**commit + push：**

- `cd <worktree>` 然後 `git add` + `git commit` + `git push -u origin feat/<topic>`
- 四層各自 commit，subject + body 完全相同（全域 CLAUDE.md「多產品四層 git 協作規範」）

**merge to main：** worktree 已 push feat 之後，直接用主 git 的 local feat branch ref 來 merge（worktree 與主 git 共享 `.git/refs`，主 git 看得到 worktree commit 出來的 feat branch）：

1. 確認 worktree 已 push feat（保留「remote 是唯一真相」的安全點）
2. 主 git 直接用 local feat branch ref 來 merge：

```
git -C <該層主 git> merge --no-ff feat/<topic>
```

3. push main：

```
git -C <該層主 git> push
```

四層各自跑、配對執行。主 git 全程停在 main、無 checkout 動作。

**為什麼用 local feat 而不是 origin/feat：** worktree push 完之後，本機的 `.git/refs/heads/feat/<topic>` 與 `.git/refs/remotes/origin/feat/<topic>` 指向同一個 commit hash（兩個 ref 在同一個 .git 裡）。主 git merge local feat 與 merge origin/feat 結果完全相同，但跳過了多餘的 `git fetch`。

**「remote 是唯一真相」如何維持：** 安全點在「worktree push feat」那一步——這保證了 feat 的 commit 確實在 remote 上有備份。主 git merge 之後 push main 也會把 feat 的 commit 帶上去（git 推 main 時會把所有 reachable commit 推齊）。跨機協作時另一台 Mac 看得到 feat 的 commit history。

**收尾：**

```
git -C <主 git> worktree remove ~/Doc/ai-company-worktrees/<topic>/<layer>-<module>
git -C <主 git> branch -d feat/<topic>
```

### 唯一例外（極窄）

純粹的歷史性檔案整理（rebase `.gitignore`、修補錯字到單一 commit），且整個 ai-company workspace 此刻無其他 session 在動同產品——可在主 git 直接動。除此之外無例外。

## Port 協作規範

多個 worktree 同時跑 HTTP server / Metro bundler 會撞 port。設定的解法是集中的 port 註冊表，所有 server 啟動前必查表、不自選 port。

### 註冊表位置

`~/Doc/ai-company/.claude/launch.json`

每個 worktree 一條 entry，欄位至少包含：

- `name`：人類可讀標籤（如 `susugigi-design-editor-v2`）
- `directory`：worktree 相對於 ai-company 根目錄的路徑（例如 `../ai-company-worktrees/<topic>/<layer>-<module>`）
- `port`：design canvas 用的 HTTP server port（base 8765，每新 worktree +1）
- `metroPort`：Metro bundler port（base 8081，每新 worktree +1）；若該 worktree 不跑 RN app 可省略

**路徑欄位禁止絕對路徑：** `directory` 與 `runtimeArgs` 內任何路徑（如 `--directory` 後的值）都必須是相對於 ai-company 根目錄的路徑，禁止絕對路徑（`/Users/.../...`）。理由：launch.json 是跨機共享的 port 規範表，絕對路徑只對單一機器有效——混入會讓另一台機看到「無法解析的路徑」，並可能誤判此檔「該追蹤還是該 ignore」（這正是 launch.json 跨機打架的根因）。

### 開新 worktree 時的硬規則

`git worktree add` 動作完成後、啟任何 server 之前，**必須** append 一條 entry 到 launch.json。分配 port 規則：

- design port = 現有最大 port + 1（從 8765 起算）
- metroPort = 現有最大 metroPort + 1（從 8081 起算）

未加 entry → 不允許啟 server。

### 啟 server 時的硬規則：輕量 vs 重量分流

**輕量 server（design canvas，每 instance ~10 MB RAM）：** 可多 instance 並行。每個 worktree 跑各自的 python http.server：

```
cd <worktree>
python3 -m http.server <port from entry>
```

不允許自選 port，必讀 launch.json 找該 worktree 的 entry。

**重量 server（Metro bundler、iOS Simulator）：Claude 平時不主動啟、不主動切；唯一例外是使用者打 `/sim-review` 觸發後，由該 skill 自動處理 kill Metro / 啟 Metro / `xcrun simctl terminate/launch` / 主 git `git checkout` / `npm run ios`。**

理由：低 RAM 環境並行 Metro 會把系統壓死；simulator 一次只能跑一個 app。這兩個資源**平時由使用者手動管理**——使用者決定 simulator 現在要看哪個 worktree。`/sim-review` 是使用者明確授權的自動化路徑。

launch.json 仍為每個 worktree 預先分配 metroPort 欄位，作用是**保留為佔位**，避免日後手動 hardcode 衝突。但 `/sim-review` 自動化流程**不讀此 metroPort，統一跑在 port 8081**（主 git base app 嵌入的 bundler URL）——所有 worktree review 都共用 8081 上的 Metro，切 worktree = 換 Metro 來源，不換 port。

### Metro 切換：走 `/sim-review`

當 Claude 完成改動、預期使用者可能想在 simulator 上看時，回報訊息必含「驗證位置」段（見全域 CLAUDE.md「驗證回報規範」內「回報訊息：simulator 走 /sim-review」），主動引導使用者打 `/sim-review`。

使用者打 `/sim-review` 之後，Claude 在該 skill 內自動處理 kill Metro、cd worktree、啟 Metro on port 8081、`xcrun simctl terminate/launch` 重啟 app 等動作。含原生改動分支則自動 cd 主 git、checkout feat、`npm run ios`、review 完還原 main。完整流程見 `~/.claude/skills/sim-review/SKILL.md`。

`/sim-review` 觸發以外的場景，Claude 仍守「不主動啟、不主動切 Metro」（見「啟 server 時的硬規則」段）。

### Metro 與 app build 對應 port

iOS app build 時嵌入的 bundler URL 是 `http://localhost:8081/`（RN 預設）。`/sim-review` 自動化下所有 Metro 都跑 8081，永遠對得上，不會出現「app hardcode 8081 但 Metro 跑在 8082」這種撞牆。

並行多個 review 時，simulator 只有一個，誰先打 `/sim-review` 誰佔用 Metro on 8081。下一個 worktree review 等前一個結束（「只動 JS」review 切換很快、不嚴重阻擋）。

### 收工時的硬規則

`git worktree remove` 之後必須**同步移除** launch.json 對應 entry，避免註冊表累積殘留。`/game-stop` 收尾指令會自動處理；手動 remove 時自己記得。

### 與「驗證回報規範」的銜接

「驗證位置」段提到 server URL 時，必須對齊 launch.json 的 entry port，不允許說「server 已起在 8000」這種無對應的 port。

## iOS 自驗策略

RN app 在 simulator 上的驗證一律走 `/sim-review`，一鍵全自動。

### 一次性 setup

主 git（如 `product/SuSuGiGi/SuSuGiGiApp/`）的 main 版本跑過一次 `npm run ios`，build 出 base app on simulator。之後 base app 長期留著，所有「只動 JS」review 共用這份。

### `/sim-review` 自動處理

在 worktree 內打 `/sim-review`，Claude 會：

1. 跑 `git diff main --name-only` 判別本次屬於「只動 JS」還是「動到原生」
2. **只動 JS**：kill 現有 Metro、cd 本 worktree 啟新 Metro on port 8081、`xcrun simctl terminate/launch` 重啟模擬器 app → 約 30 秒，新內容上場
3. **動到原生**：kill Metro、cd 主 git、checkout 該 feat branch、`npm run ios`（4~6 分鐘 build）→ review 完使用者打「review 結束」→ 自動 `git checkout main` 並再 build 一次 main 還原模擬器

使用者唯一手動：在模擬器上看與驗證；含原生情況加打一句「review 結束」收尾。完整流程見 `~/.claude/skills/sim-review/SKILL.md`。

### 絕對禁止：worktree 內 build

不得在 worktree 內跑 `npm run ios`、`xcodebuild`、`pod install`。理由：每個 worktree 各自 build 會在 `~/Library/Developer/Xcode/DerivedData/` 累積獨立 cache，磁碟很快爆。所有 build / pod 動作都集中在主 git 跑，由 `/sim-review` 自動觸發。

ai-company `.claude/settings.json` 的 PreToolUse hook 會機械攔截 worktree 內的此類指令（hook script 位於 `.claude/hooks/block-worktree-ios-build.sh`）。

### 多 worktree 並行 review

simulator 只有一個。誰先打 `/sim-review` 誰就佔用模擬器；下一個 worktree review 等前一個結束。「只動 JS」review 因為不換 app、只換 Metro，切換很快（30 秒），不嚴重阻擋；「動到原生」review 較重（4~6 分鐘 build + review + 還原 build），建議多個 native session 等手上的批次集滿再依序跑。

## 盤點任務協作節奏

涵蓋 `/game-over`、`/game-start`、跨 git 盤點、多 worktree 清理等「掃整片」任務。

**第一輪必須掃完整。** 不允許「先看 A 等等再看 B」分批。掃描範圍最少包含：

- 所有頂層 git（`~/Doc/ai-company` 與底下產品 git）
- 所有 worktree，**三個路徑都要含**：
    - `~/Doc/.worktrees/`
    - `~/Doc/_worktrees/`
    - `~/Doc/ai-company-worktrees/`
- 所有 module 子 git（design / spec / impl 三層）

**對每一項給「現況 / 我的判斷 / 建議動作」3 件套**，缺一不可。表格形式比條列清楚時就用表格。

**禁止用語：** 報告中不得出現「順便」「另外」「補一下」這類降級指代——每個議題都需明確決定，不分輕重。

**請示節奏：** 全部訊號收齊、所有建議列完，才向使用者集中請示一次；不要邊掃邊問。掃描過程中若需要動到不可逆操作（worktree remove、branch delete、merge to main 等），歸入請示清單而非當下執行。

對話回報訊息的通用規範（不限本節）見全域 `~/.claude/CLAUDE.md`「對話回報訊息規範」。
