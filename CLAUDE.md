# AI Company — Claude Code 全局設定

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
- `directory`：worktree 的絕對路徑
- `port`：design canvas 用的 HTTP server port（base 8765，每新 worktree +1）
- `metroPort`：Metro bundler port（base 8081，每新 worktree +1）；若該 worktree 不跑 RN app 可省略

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

**重量 server（Metro bundler、iOS Simulator）：Claude 永遠不主動啟、不主動切。**

理由：低 RAM 環境並行 Metro 會把系統壓死；simulator 一次只能跑一個 app。這兩個資源**完全由使用者手動管理**——使用者決定 simulator 現在要看哪個 worktree。

launch.json 仍為每個 worktree 預先分配 metroPort，作用是**避免 hardcode 衝突**：無論 Metro 何時被啟動，它對應的 port 由 launch.json 決定，app build 時拿到的 bundler URL 就會對應到該 port。這讓使用者切 worktree 時 metroPort 是穩定的、不會隨機。

### Metro 切換流程：Claude 提醒、使用者裁示

當 Claude 完成改動、預期使用者可能想在 simulator 上看時，回報訊息必含「驗證位置」段帶 Metro 狀態（見全域 CLAUDE.md「驗證回報規範」內「回報訊息：simulator 切換用提醒 + 詢問」）。

使用者打「切 Metro」/「切過去」之後，Claude 才執行：

1. `lsof -i :8081-:8090 | grep node` 找現有 Metro 的 port
2. `kill <PID>` 停掉既有 Metro
3. `cd <本 worktree>` 後 `npx react-native start --port <本 worktree 的 metroPort>`
4. 提醒使用者：「在 simulator 上 dev menu → Configure Bundler 切到 port X，或 force quit app 重 build」

使用者沒打就**不動**。即使本 session 是「改完 push 完待 merge」狀態，Metro 也不主動切。

### Metro 與 app build 必須對應同一 port

iOS app build 時的 bundler URL 必須對應當前活著的 Metro 的 metroPort。不允許 app hardcode 8081 但 Metro 跑在 8082——這是並行 session 撞牆的核心場景。切換流程由使用者觸發（見上一條）。

### 收工時的硬規則

`git worktree remove` 之後必須**同步移除** launch.json 對應 entry，避免註冊表累積殘留。`/game-stop` 收尾指令會自動處理；手動 remove 時自己記得。

### 與「驗證回報規範」的銜接

「驗證位置」段提到 server URL 時，必須對齊 launch.json 的 entry port，不允許說「server 已起在 8000」這種無對應的 port。
