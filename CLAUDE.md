# AI Company — Claude Code 全局設定

## Workspace 路徑
所有 agents 讀寫公司文件時，使用以下相對路徑（相對於專案根目錄）：
- 公司 context：`workspace/company/context.md`
- 產品索引：`workspace/company/products.md`
- 產品文件根目錄：`workspace/specs/`

## 產品程式碼路徑
- Hatsuon App：`code/HatsuonApp/`
- SuSuGiGi App：`code/SuSuGiGiApp/`
- LiquidGlassHeaderTemplate：`code/LiquidGlassHeaderTemplate/`

## Subagent 登場宣告
每次 invoke 任何 subagent 之前，先在主對話輸出一行：「{AgentName}登場!!」

## Chief of Staff 模式（當用戶說「chief of staff」時觸發）

這是你（main Claude）直接執行的路由協議，**不要啟動任何名為 chief-of-staff 的 subagent**。

### 步驟
1. Read `workspace/company/products.md`（只讀這一個檔案，不讀其他任何東西）
2. 根據下方路由表和用戶的任務，決定需要哪些 specialist
3. 輸出路由計畫，等待用戶確認
4. 確認後：輸出「{AgentName}登場!!」並用 Agent tool invoke specialist

### 路由表
| 用戶說的關鍵字 | invoke |
|---|---|
| UX / UI / 外觀 / 設計 / 視覺 / 原型 / 介面 / 使用者流程 | experience-designer |
| 市場 / 競品 / 功能規劃 / PRD / User Story / 問題定義 | product-planner |
| 定價 / GTM / 行銷 / 上市 / 成長 | gtm-strategist |
| 架構 / 技術選型 / 系統設計 / 資料模型 | solution-architect |
| 寫程式 / 實作 / 開發 / bug / 功能 | full-stack-engineer |
| 測試 / 驗收 / QA / 品質 | quality-engineer |
| 上架 / 部署 / 發布 / 上線 | release-manager |
| 股權 / 點數 / 估點 / 帳本 / 貢獻 | equity-accountant |

### 上下文傳遞規則
invoke specialist 時，傳入：
- 用戶的原始任務描述
- 產品名稱（從 products.md 取得）
- 該產品的文件目錄路徑（從 products.md 取得）
