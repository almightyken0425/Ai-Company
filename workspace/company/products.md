# Products

## 使用說明
每個產品有自己獨立的文件目錄，所有產品細節（技術棧、設計哲學、股權帳本）
都記錄在該目錄下，不集中在此處。
此文件只做索引，記錄「去哪裡找」，不記錄「內容是什麼」。

---

## 進行中

### Hatsuon
- 狀態：開發中
- 規格文件：`/Users/kenchio/Projects/ai-company/workspace/specs/HatsuonSpec/`
- 程式碼：`/Users/kenchio/Projects/ai-company/code/HatsuonApp/`

### SuSuGiGi
- 狀態：開發中
- 規格文件：`/Users/kenchio/Projects/ai-company/workspace/specs/SuSuGiGiSpec/`
- 程式碼：`/Users/kenchio/Projects/ai-company/code/SuSuGiGiApp/`

### LiquidGlassHeaderTemplate
- 狀態：已發布（OSS 模板）
- 規格文件：（無獨立 Spec，直接看程式碼）
- 程式碼：`/Users/kenchio/Projects/ai-company/code/LiquidGlassHeaderTemplate/`

---

## 規劃中

### UndergroundRemake
- 狀態：規劃中
- 規格文件：`/Users/kenchio/Projects/ai-company/workspace/specs/UndergroundRemakeSpec/`
- 程式碼：尚未建立

---

## 新增產品模板
新立項時，複製以下格式並建立對應目錄：

```
### [產品名稱]
- 狀態：[構想 / 開發中 / 已上線]
- 規格文件：`/Users/kenchio/Projects/ai-company/workspace/specs/[ProductSpec]/`
- 程式碼：`/Users/kenchio/Projects/ai-company/code/[Product]/`
```

每個產品 Spec 目錄建議結構：
```
workspace/specs/[ProductSpec]/
├── product-context.md     ← 技術棧、設計哲學、商業模式
├── equity/                ← 股權帳本（Equity Accountant 建立）
├── user-stories/          ← Product Planner 產出
├── design/                ← Experience Designer 產出
├── architecture/          ← Solution Architect 產出
├── qa/                    ← Quality Engineer 產出
└── gtm/                   ← GTM Strategist 產出
```
