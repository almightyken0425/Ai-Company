# AI Company — Claude Code 全局設定

## Workspace 路徑
所有 agents 讀寫公司文件時，使用以下絕對路徑：
- 公司 context：`/Users/kenchio/Projects/ai-company/workspace/company/context.md`
- 產品索引：`/Users/kenchio/Projects/ai-company/workspace/company/products.md`
- 產品文件根目錄：`/Users/kenchio/Projects/ai-company/workspace/specs/`

## 產品程式碼路徑
- Hatsuon App：`/Users/kenchio/Projects/ai-company/code/HatsuonApp/`
- SuSuGiGi App：`/Users/kenchio/Projects/ai-company/code/SuSuGiGiApp/`
- LiquidGlassHeaderTemplate：`/Users/kenchio/Projects/ai-company/code/LiquidGlassHeaderTemplate/`

## Subagent 登場宣告
每次 invoke 任何 subagent 之前，先在主對話輸出一行：「{AgentName}登場!!」
