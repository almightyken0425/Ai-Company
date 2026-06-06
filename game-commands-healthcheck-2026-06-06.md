# game-* command 健康檢查報告

- 日期：2026-06-06
- 範圍：`game-start` / `game-review` / `game-over` / `game-stop` / `game-clear`（位於 `~/.claude/commands/`）
- 方法：workflow 6 維度平行掃描，每個發現再派獨立 agent adversarial 驗證（共 28 agent、約 46 分鐘）
- 維度：內部一致性 / 跨 command 一致性 / CLAUDE.md 規則對齊 / 引用與環境存在性 / 流程缺口 / 危險操作護欄
- 結果：22 發現 → **確認 13、駁回 9**
- 嚴重度分布：high 6、medium 5、low 2
- 集中點：破壞性最強的 `game-stop` 與 `game-clear`

確認問題分兩類：

- **純文件對齊**（低風險，改 .md 措辭/編號）：#1 #2 #3 #4 #5 #6 #13
- **行為 / SOP 變更**（需設計決策）：#7 #8 #9 #10 #11 #12

---

## 摘要表

| # | 嚴重度 | 檔案 | 類別 | 一句話 |
|---|--------|------|------|--------|
| 12 | high | game-clear | 行為 | reflog 救回是空頭支票，worktree 內 commit 砍掉後查不到 |
| 7 | high | game-stop | 行為 | merge 前不 sync main，跨機 push 被拒會留半成品，錯誤表沒這列 |
| 8 | high | 家族 | SOP | wip-push 的中間態主題無跨機 resume 命令，生命週期缺一角 |
| 9 | high | game-stop/clear | 行為 | 已 merge 但 cleanup 中斷的殘留 worktree，兩命令都不收 |
| 1 | high | game-stop | 文件 | dry-run 漏列 rmdir 父目錄，違反「列出所有動作」宣稱 |
| 2 | high | game-clear | 文件 | dry-run 漏列 rmdir 父目錄（同型） |
| 3 | medium | game-stop/over | 文件 | 引用「step 7.6」但 Step 7 用 1.~6.、無此標籤 |
| 4 | medium | game-stop | 文件 | 散文「step 2 的 worktree remove」指錯步（實際在 Step 7） |
| 5 | medium | game-clear | 文件 | 同型 step 2 指錯（實際在 Step 5） |
| 10 | medium | game-clear | 行為 | 刪 local feat 前不查未 push commit，跨機進度可能靜默遺失 |
| 11 | medium | game-over | 文件 | 空殼掃描只掃一根，與「三根都掃」規範不閉合 |
| 6 | low | game-clear | 文件 | 同檔兩表 merge 措辭不一（merge to main vs merge） |
| 13 | low | game-clear | 文件 | merge 偵測 grep 未跳脫 topic、依賴輸出格式 |

---

## 確認問題（13）

### High（6）

#### [12] game-clear：reflog 救回聲明對 worktree 內 commit 失效（誤導性安全聲明）

- 位置：Step 4 dry-run L107-109、Step 6 總結 L176、安全邊界 L202、執行前提 L20
- 問題：四處保證「local commit 30 天內可從 reflog 救回」，作為丟棄的最後安全網。但在 worktree 內 commit 的內容，經 Step 5 `worktree remove --force`（連 worktree 的 `logs/HEAD` reflog 一起刪）再 `branch -D`（刪 feat ref）後，該 commit 不在主 git HEAD reflog、也無任何 reflog 指向，`git reflog` 根本查不到。預設模式又同時 `push origin --delete` 砍 remote，於是 working tree、local branch、local reflog、remote 四處同時消失。比「救不回但講清楚」更危險——使用者是「相信可救回」才敢按 ok。
- 修法（二選一，建議 B）：
  - **A 限縮聲明**：四處改成「只有曾被主 git HEAD 指向過的 commit 才在 reflog；純 worktree 內 commit 經 `worktree remove --force` 後 reflog 不保證留存」。
  - **B 給真安全網**：Step 5 砍 worktree 前，對每層主 git 先 `git tag clear-backup/<topic> feat/<topic>`（或記下 `feat/<topic>` 的 SHA 寫進總結）。tag reachable，`git checkout` 救得回，承諾才成真。總結改印實際 backup ref 讓使用者照抄。

#### [7] game-stop：Step 6.1 merge 前不 sync main，push 被拒留半成品

- 位置：Step 6.1（L160-166）+ 錯誤處理摘要
- 問題：每層主 git 直接 `merge --no-ff feat/<topic>` 然後 `push origin main`，merge 前無任何 `fetch` / `pull --ff-only`。跨機下另一台機可能已推進 main，本機 `push origin main` 被 rejected——此時本機 main 已被 merge commit 推進、卻推不上 remote。多層各自 merge 還可能 layer1 成功、layer2 被拒，四層 main 不一致。違反全域「remote 是唯一真相、ff-only 失敗是跨機警報」。錯誤表沒有「push main rejected / main 落後」這列。
- 修法：
  - Step 6.1 merge 前加 `git fetch origin main` + 落後則 `pull --ff-only`，失敗就停（不自動 rebase / non-ff）；`push origin main` rejected 也停，後續層與 cleanup 全跳過。
  - 錯誤處理表補兩列：「merge 前 main 落後且無法 ff」、「push main rejected」。
  - 可選：dry-run 第 2 項註明「merge 前會先 fetch + pull --ff-only 跟齊」。

#### [8] 家族缺口：wip-push 的中間態主題無跨機 resume 命令

- 位置：game-over 行為段 WT_DIRTY / DIRTY 建議（L18-26）
- 問題：game-over 對 dirty worktree 建議 `wip commit + push` 到 feat 後離機（全域「離機前置」也這樣要求）。但整個 game-* 家族沒有命令負責在另一台機把這個 wip-pushed 主題接回來續做。`game-start`（=sync-gits）只對有 upstream 的 local branch 做 ff，且 git-sync 明確 exclude `ai-company-worktrees/`，機器 B 上該 worktree 根本不存在。主題既沒 game-stop（沒改完）、也沒 game-clear（不放棄），只能臨場手打 `worktree add` 補。「收—棄」之間的暫存續做是生命週期真實缺口。
- 修法（文件補洞，非必開新命令）：
  - 在全域 `~/.claude/CLAUDE.md`「跨機 git 協作規範」的「上機後置」段補一條 worktree resume：對每層 git `git worktree add ~/Doc/ai-company-worktrees/<topic>/<layer>-<module> feat/<topic>`（checkout 既有 branch、不加 `-b`），node_modules symlink、補 launch.json entry。
  - 可選：game-over 的 DIRTY 建議行尾指回此 resume 步驟。

#### [9] game-stop/clear：已 merge 但 cleanup 中斷的殘留 worktree 無命令可收

- 位置：game-clear Step 3 安全檢查 + 安全邊界
- 問題：game-stop 的 cleanup（Step 7）在 merge 成功「之後」才跑 worktree remove，且對 dirty 層「跳過該層 cleanup」。若 merge 成功但某層 worktree 因 dirty 被跳過、或 `push --delete` 失敗，這主題已 merge to main、worktree 卻還在硬碟。想補清：game-clear Step 3.1 第一件事 `branch --merged main` 偵測到已 merge 就「報錯停下、叫你去 revert」，直接拒收；game-stop 重跑又撞 `nothing to commit`。等於兩個收尾命令都不收，只能全手動。
- 修法（建議方案一）：game-clear 加 `--cleanup-only` flag。偵測到已 merge 時，帶此 flag 則跳過 `branch -D` 與 `push --delete`，只做 history-neutral 清理（worktree remove --force + launch.json + rmdir 父目錄），總結把 branch 欄標 `kept (merged)`。同步更新用法區、錯誤表、安全邊界。

#### [1] game-stop：dry-run 漏列 rmdir 父目錄

- 位置：Step 4（L89-117）vs Step 7 item 6（L180）
- 問題：L91 宣稱「把後續所有動作列成清單給使用者看」、L116「打 ok 執行」（=批准這份清單）。但 dry-run 的 Cleanup 只列 5 項，獨缺 Step 7 item 6 的「rmdir 空的 topic 父目錄」——這正是該檔自己強調「過去明明 game-stop 了卻沒清乾淨」要修的動作，卻沒進使用者實際批准的 dry-run。
- 修法：dry-run 的 `3. Cleanup:` 在 launch.json 那行後補一行 `- rmdir 空的 <topic> 父目錄（worktree 全 remove 後，僅在父目錄為空時）`。

#### [2] game-clear：dry-run 漏列 rmdir 父目錄（同型）

- 位置：Step 4 dry-run（L103-106）vs Step 5 item 6（L151）
- 問題：同 #1。Step 5 item 6 會 `rmdir` 父目錄（動到硬碟），但 dry-run 的 Cleanup 只列 kill Metro 與 launch.json 兩項。
- 修法：dry-run `4. Cleanup` 補一行 `- rmdir 空的 topic 父目錄 …（僅當 ls -A 判空；絕不 rm -rf）`。

### Medium（5）

#### [3] game-stop / game-over：引用不存在的「step 7.6」標籤

- 位置：game-stop L208（×2）、game-over L30
- 問題：Step 7 子項是純數字列表 1.~6.，全檔無「7.N」記法（對比 6.0/6.1 是用 `####` 標題寫出的）。但三處寫「step 7.6」，照字面搜尋找不到；跨檔（game-over→game-stop）導引更放大此問題。
- 修法：三處「step 7.6」改成「Step 7 第 6 項（rmdir 空 topic 父目錄）」。（或反向：把 Step 7 子項升格為 `#### 7.1`~`#### 7.6` 標題，與 Step 6 一致——改動較大，不建議。）

#### [4] game-stop：散文「step 2 的 worktree remove」指錯步

- 位置：L180、L186、L189
- 問題：文件層級 Step 2 是「掃 paired worktrees」（只跑 `worktree list`），實際 `worktree remove` 在 Step 7 item 2。三處用「step 2」指 remove 動作與其 dirty-skip。因該段本身在 Step 7 編號列表內、item 2 恰是 remove，可勉強讀作「本列表第 2 項」，屬命名不嚴謹。
- 修法：三處改「Step 7 第 2 項的 `git worktree remove`」。

#### [5] game-clear：散文「step 2 的 worktree remove」指錯步（同型）

- 位置：L151
- 問題：同 #4。文件層級 Step 2 不跑 remove，實際 `worktree remove --force` 在 Step 5 item 2。
- 修法：L151 改「Step 5 item 2 的 `git worktree remove --force`」。

#### [10] game-clear：刪 local feat 前不查未 push commit，跨機進度可能靜默遺失

- 位置：Step 3.2 + Step 5.3 branch -D
- 問題：Step 3.2 只用 ls-remote 偵測 remote feat 存不存在，不比對 local 是否 ahead。Step 5.3 直接 `branch -D`。若本機 feat 有 commit 但沒 push，dry-run 只泛說「reflog 30 天可救回」，沒有「此 branch 有 N 個 commit 只在本機」的明確警示。跨機視角等同遺失。
- 修法：Step 3 偵測加 `git rev-list --count feat/<topic> --not --remotes=origin` 算未 push 數 UNPUSHED_N；dry-run 對 UNPUSHED_N>0 的層加明確 ⚠ 行。不改命令行為，只把遺失點從靜默變可見。

#### [11] game-over：空殼掃描只掃一根，與「三根都掃」規範不閉合

- 位置：空殼 worktree 目錄掃描段（L30-52）
- 問題：專案 CLAUDE.md「盤點任務協作節奏」要求掃描含 `~/Doc/.worktrees/`、`~/Doc/_worktrees/`、`~/Doc/ai-company-worktrees/` 三根。但 game-over 的 rmdir 迴圈只 `for d in ~/Doc/ai-company-worktrees/*/`；game-stop/clear 的 rmdir 也只認此根。承諾 vs 實作有落差。
- 修法（建議文件側）：把專案 CLAUDE.md 收斂成「以 `ai-company-worktrees` 為唯一活躍根；另兩根為遺留/防禦條目，存在才掃」。理由：dirty 偵測靠 `git worktree list` 自報、與根路徑無關，已天然覆蓋三根；空殼 rmdir 寫死單根是合理的（沒命令會在另兩根產空殼）。收緊文件即閉合落差，且不引入清理不存在目錄的死碼。

### Low（2）

#### [6] game-clear：同檔兩表 merge 措辭不一

- 位置：L28 差別表「merge to main」 vs L209 對位表「merge」
- 問題：同檔兩表對 /game-stop 的 merge 動作措辭不齊，雖同義但並列時應對齊。
- 修法：L209 改「merge to main」，對齊 L28 與框架句 L5。

#### [13] game-clear：merge 偵測 grep 未跳脫 topic、依賴輸出格式

- 位置：Step 3 第 1 項（L55-57）
- 問題：`branch --merged main | grep -qE "^[* ]+feat/<topic>$"` 把 `<topic>` 直接內插進 regex 未跳脫（含 `.`、`+` 會誤配），且綁死 `git branch` 兩空格前綴輸出格式。這是「拒絕清理已 merge 主題」護欄的執行手段，不該靠命名慣例兜底。
- 修法：改 `git merge-base --is-ancestor "feat/<topic>" main`（退出 0 = 已 merge = 停下）。branch 名以 literal ref 傳入，不再被當 regex，也不依賴輸出格式。

---

## 駁回（9，查過已排除）

verifier 重讀原文後判定不是真問題，多數是 finder 把「示例性括號清單」「刻意設計」「跨檔一致設計」當缺陷。

| # | 維度 | 駁回標題 | 核心理由 |
|---|------|----------|----------|
| R1 | cross-command | sync-gits 三名稱「同一流程」與 game-start 對稱定位牴觸 | 別名只指 game-start，game-over 是「成對」非別名；設計刻意且一致 |
| R2 | cross-command | 三表「何時」欄描述不一致 | 措辭差異是同義濃縮，非缺陷 |
| R3 | cross-command | push --delete 失敗護欄 stop/clear 不一致 | 括號內是示例清單非窮舉條件，operative 行為都是「警告但繼續」 |
| R4 | claudemd-align | 空殼掃描只含 1 路徑、規範要 3 | 可辯護的設計窄化（與 #11 同題，#11 取文件收緊角度才成立） |
| R5 | flow-gaps | Step 5 push rejected 留半 commit、重跑撞已 commit | 機械讀法對，但屬刻意設計（停下交使用者接） |
| R6 | flow-gaps | 錯誤表漏列 6.0 detached 還原等 | 自動還原成功非「失敗」，不屬錯誤表；dry-run 已可見 |
| R7 | flow-gaps | 多主題並行收尾誤 kill 另一活躍 Metro | 誤讀 port 規則：metroPort 分配排除 8081，sim-review 才用 8081 |
| R8 | flow-gaps | clear 5.0 與 stop 6.0 detached 失敗語意相反未交代 | 事實對，但兩者語意差異是設計（清理盡量做完 vs 收尾要嚴謹） |
| R9 | danger | 裸 ok 預設落在不可逆刪 remote | 治理層（專案 CLAUDE.md L8）明文預設，command 忠實實作、非失誤 |

---

## 後續

修法多落在受保護檔：`~/.claude/commands/game-*.md`、`~/.claude/CLAUDE.md`、`~/Doc/ai-company/CLAUDE.md`。改這些受 self-modification hook 保護，須走 plan mode + 切 acceptEdits。
