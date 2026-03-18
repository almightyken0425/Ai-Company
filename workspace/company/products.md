# Products

## 使用說明
每個產品有自己獨立的文件目錄，所有產品細節（技術棧、設計哲學、股權帳本）
都記錄在該目錄下，不集中在此處。
此文件只做索引，記錄「去哪裡找」，不記錄「內容是什麼」。

---

## 進行中

### Hatsuon
- 狀態：開發中
- 規格文件：`workspace/specs/HatsuonSpec/`
- 程式碼：`code/HatsuonApp/`

### SuSuGiGi
- 狀態：開發中
- 規格文件：`workspace/specs/SuSuGiGiSpec/`
- 程式碼：`code/SuSuGiGiApp/`

### LiquidGlassHeaderTemplate
- 狀態：已發布（OSS 模板）
- 規格文件：（無獨立 Spec，直接看程式碼）
- 程式碼：`code/LiquidGlassHeaderTemplate/`

---

## 規劃中

### UndergroundRemake
- 狀態：規劃中
- 規格文件：`workspace/specs/UndergroundRemakeSpec/`
- 程式碼：尚未建立

---

## 產品模板

```
### [產品名稱]
- 狀態：[構想 / 規劃中 / 開發中 / 已上線]
- 規格文件：`workspace/specs/[ProductNameSpec]/`
- 程式碼：`code/[ProductNameApp]/`
```

每個產品 Spec 理論目錄採用以下結構，以編號前綴 `noN_` 控制閱讀順序：

```
workspace/specs/[ProductNameSpec]/
│
├── CLAUDE.md                          ← 此 Spec 庫的 agent 工作指引，Chief of Staff 建立，所有 agent 須優先閱讀
├── home.html                          ← 視覺化導覽頁（選用），Chief of Staff 或 Experience Designer 建立
│
├── no1_product_initiation/            ← 產品定位，Product Planner 主責建立與維護
│   ├── no1_app_value_proposition.md   ← 產品核心價值主張與目標用戶
│   ├── no2_product_philosophy.md      ← 設計哲學與產品原則
│   ├── no3_product_definition.md      ← 功能範疇定義與邊界
│   ├── no4_business_model.md          ← 商業模式與收費策略
│   └── no5_app_naming_discussion.md   ← 命名討論與品牌決策記錄
│
├── no2_equity_model/                  ← 股權模型，Equity Accountant 主責建立與維護
│   ├── no1_foundation/                ← 基礎設定
│   │   ├── no1_equity_principles.md   ← 股權分配核心原則
│   │   ├── no2_role_definition.md     ← 貢獻者角色定義
│   │   ├── no3_scope_value_ledger.md  ← 工作範疇與積分估算帳本
│   │   ├── no4_1_module_role_points.csv        ← 模組 × 角色積分原始表
│   │   ├── no4_2_generate_equity_csvs.py       ← 積分計算腳本
│   │   ├── no4_3_equity_summary_by_role.csv    ← 按角色彙整的股權摘要
│   │   ├── no4_4_equity_summary_by_module.csv  ← 按模組彙整的股權摘要
│   │   ├── no4_5_equity_consistency_analysis.csv ← 一致性驗證分析
│   │   └── no5_equity_distribution_policy.md  ← 股權分配政策與觸發條件
│   └── no2_operation/                 ← 股權操作管理
│       └── no1_operation_management_design.md ← 積分結算流程與操作規範
│
├── no3_module_specs/                  ← 功能模組規格，各 agent 依職責分工
│   ├── no0_policy/                    ← 跨模組共用政策，Solution Architect 與 Experience Designer 共同建立
│   │   ├── no1_ui_design_policy.md    ← UI 設計規範（Experience Designer）
│   │   ├── no2_i18n_policy.md         ← 國際化政策（Solution Architect）
│   │   ├── no3_error_handling.md      ← 錯誤處理規範（Solution Architect）
│   │   └── no4_error_code_definition.md ← 錯誤碼定義表（Solution Architect）
│   ├── no1_interaction_flows/         ← 整體互動流程，Experience Designer 主責
│   │   └── no1_interaction_flow.md    ← 跨畫面互動流程圖與說明
│   └── no[N]_[module_name]/           ← 每個功能模組一個子目錄，依產品實際模組新增
│       ├── no1_module_architecture/   ← 模組架構，Solution Architect 主責
│       │   ├── no1_module_conclusion.md    ← 架構決策結論
│       │   └── no2_architecture_tradeoffs.md ← 技術選型取捨分析
│       ├── no2_screens/               ← 畫面規格，Experience Designer 主責
│       │   └── no[N]_[screen_name]_screen.md ← 各畫面的 UI 規格與互動說明
│       ├── no3_logics/                ← 業務邏輯規格，Solution Architect 或 Full-Stack Engineer 主責
│       │   └── no[N]_[logic_name].md  ← 各邏輯流程的詳細規格
│       ├── no4_data_models/           ← 資料模型，Solution Architect 主責
│       │   └── no1_data_models.md     ← 資料結構定義與關聯說明
│       └── no5_design_system/         ← 設計系統，Experience Designer 主責
│           └── no[N]_[token_name].md  ← 設計 token、主題、格式政策
│
├── no4_dev_management/                ← 開發管理，Full-Stack Engineer 與 Release Manager 共同維護
│   ├── no0_policy/                    ← 開發政策
│   │   ├── no1_git_workflow_policy.md ← Git 分支與 commit 規範
│   │   ├── no2_coding_style_policy.md ← 程式碼風格規範
│   │   ├── no3_testing_policy.md      ← 測試規範（Quality Engineer 協作）
│   │   └── no4_release_policy.md      ← 發布流程規範（Release Manager 主責）
│   └── no1_mvp_planning/              ← MVP 規劃，Product Planner 主責
│       ├── no1_mvp.md                 ← MVP 功能範疇與優先順序
│       ├── no2_file_plan.md           ← 程式碼檔案結構規劃
│       └── no3_development_plan.md    ← 開發里程碑與任務拆解
│
├── no5_marketing_strategy/            ← 行銷策略，GTM Strategist 主責
│   └── no1_geo_strategy.md            ← 地區市場推廣策略
│
└── no99_archive/                      ← 已完成或封存的一次性文件，Chief of Staff 管理
    └── [封存文件與資料夾]              ← 不再更新但需保留的歷史文件
```

各目錄的 agent 負責人摘要：

| 目錄                                                       | 主責 agent                               | 說明                                       |
| ---------------------------------------------------------- | ---------------------------------------- | ------------------------------------------ |
| `CLAUDE.md`                                                | Chief of Staff                           | 建立時一次性產出，記錄此 Spec 庫的使用規範 |
| `no1_product_initiation/`                                  | Product Planner                          | 產品立項初期建立，後續有重大策略調整時更新 |
| `no2_equity_model/`                                        | Equity Accountant                        | 隨每次股權事件觸發後更新                   |
| `no3_module_specs/no0_policy/`                             | Solution Architect + Experience Designer | 各自負責技術與設計政策                     |
| `no3_module_specs/no1_interaction_flows/`                  | Experience Designer                      | UX 流程確定後建立                          |
| `no3_module_specs/no[N]_[module]/no1_module_architecture/` | Solution Architect                       | 模組架構設計階段建立                       |
| `no3_module_specs/no[N]_[module]/no2_screens/`             | Experience Designer                      | 畫面設計階段建立                           |
| `no3_module_specs/no[N]_[module]/no3_logics/`              | Solution Architect / Full-Stack Engineer | 邏輯設計與實作過程中建立                   |
| `no3_module_specs/no[N]_[module]/no4_data_models/`         | Solution Architect                       | 資料模型設計階段建立                       |
| `no3_module_specs/no[N]_[module]/no5_design_system/`       | Experience Designer                      | 設計系統確立後建立                         |
| `no4_dev_management/`                                      | Full-Stack Engineer + Release Manager    | 開發啟動前建立政策，過程中持續更新         |
| `no5_marketing_strategy/`                                  | GTM Strategist                           | GTM 規劃階段建立                           |
| `no99_archive/`                                            | Chief of Staff                           | 按需封存                                   |

---

## 新產品立項核心問題模板

每個新產品立項時，以下問題必須被回答。每個節點都標注前置依賴與完成標準，只有前置節點達到完成標準，才能解鎖下一個節點。

---

### [no1] 產品立項

主責：Product Planner、GTM Strategist

#### no1_1 產品存在論（前置：無）

必答問題：
- 這個產品解決的核心問題是什麼？使用者在沒有這個產品前，用什麼替代方案解決？替代方案有哪些根本性限制？
- 護城河是什麼？為什麼大型平台或現有競品有結構性的理由無法完美解決這個問題（利益衝突、技術壁壘、資料主權、行為習慣）？
- 即使技術環境或市場格局改變，這個需求為何不會消失？（識別恆常不變的人類動機，而非依賴特定技術）

完成標準：任何人讀完能清楚解釋「競品有結構性理由無法解決這個問題」，且理由不是「我們做得比較好」。

#### no1_2 產品哲學（前置：no1_1）

必答問題：
- 目標使用者的核心心理動因是什麼？表面需求（功能）與深層動機（情感、身份認同、控制感）分別是什麼？
- 使用者旅程七節點，每個節點的使用者心態與產品策略各是什麼：
  - 獲取：為什麼第一次安裝或試用？
  - 啟動：為什麼完成 Onboarding？
  - 留存：為什麼第 30 天還在用？
  - 中期價值：為什麼付費？
  - 核心價值：什麼時候感受到「這個產品缺不了我」？
  - 進階價值：什麼場景讓使用者升級到更高 Tier？
  - 推薦：什麼時候主動告訴別人？
- 一句話洞察：「所有競品都假設使用者是 X，但我們發現其實是 Y」
- 產品的「不能做」清單（至少 3 條禁令，定義產品個性的邊界）

完成標準：有第一人稱語氣的使用者旅程描述。任何 agent 設計功能時，都能拿這份文件判斷「這個功能是否符合我們的哲學」。

#### no1_3 產品定義（前置：no1_1、no1_2）

必答問題：
- 這個產品由哪些模組組成？每個模組的定位是什麼（基礎設施、核心功能、進階功能、B 端服務）？
- 每個模組的 User Stories，格式：「作為 [角色]，我想要 [行為]，以便 [目的]」
- 哪些功能被明確排除？排除理由是什麼（使用者習慣門檻、產品複雜度、架構衝突、低使用率）？
- 術語表：「Product」、「Module」及其他核心名詞的定義

注意：User Story 的付費/免費標注採兩輪作業。第一輪只列出所有 User Stories，不標 Tier。第二輪在 no1_4 Tier 草案完成後，回頭補標每個 User Story 的 Tier 歸屬。

完成標準：有模組清單、User Stories、排除功能清單、術語表。所有 agents 後續撰寫文件時使用一致的名詞。

#### no1_4 商業模式（前置：no1_3 模組清單完成）

必答問題：
- 核心商業邏輯類型是什麼（Freemium、SaaS 訂閱、一次性付費、B2B 授權、廣告、資料變現、混合模式）？
- Tier 結構：每個 Tier 的內部名稱、包含功能、定價各是什麼？
- 每個 Tier 的升級觸發點是什麼？使用者在哪個 no1_2 旅程節點感受到升級的必要性？
- 飛輪效應：各 Tier 如何互相強化？B 端與 C 端如何互利（若有）？

完成標準：Tier 結構與 no1_2 使用者旅程有明確對應。每個 Tier 的功能邊界清晰到工程師可直接實作付費牆邏輯。

#### no1_5 命名與品牌（前置：no1_2）

必答問題：
- 品牌原型是什麼（管家、副手、守護者、教練、工匠、探索者）？
- 命名的評估標準是什麼（可發音性、記憶點、跨語言友好性、App Store 搜尋能見度）？
- 哪些命名候選被考慮了？每個候選的優勢與排除理由？
- 最終命名決策及理由？

完成標準：有明確命名決策，附帶理由，且記錄所有被排除的候選名稱（避免未來重複討論同樣被排除的選項）。

#### 建議新增文件（可選）

- `no1_0_user_research.md`：Persona 定義、調研方法、驗證核心假設的指標。是 no1_2 產品哲學的信念基礎。
- `no1_6_competitive_analysis.md`：主要競品功能矩陣、定價策略、App Store Review 高頻抱怨分析，讓 no1_1 的護城河論述有分析依據而非推論。

---

### [no2] 股權模型

主責：Equity Accountant
前置：no1_3 完成（必須先知道有哪些模組，才能建立模組維度的貢獻帳本）

#### no2_1 股權基礎原則

必答問題：
- 股權計算的基礎假設是什麼（例如：若無團隊，創辦人獨自完成所有事項所需的時間總值等於 100%）？
- 工時換算單位如何定義（1 點等於幾分鐘、1 人日等於幾點）？
- 所有角色的時間是否等值？若否，差異化依據是什麼？
- 是否允許現金貢獻換算股權？換算規則是什麼？

完成標準：新成員能根據這份文件自行計算「投入 X 小時，股權比例為 Y%」。

#### no2_2 角色定義（前置：no2_1）

必答問題：
- 這個產品需要哪些角色？每個角色的職責邊界是什麼（避免重疊，確保每項工作只有一個主責角色）？
- 哪些角色是必要的（沒有就無法推進），哪些是增值的（有了更好但沒有也能運作）？

完成標準：角色清單可直接對應 no2_3 的工作分類，無遺漏、無重疊。

#### no2_3 工作估點帳本（前置：no1_3 模組清單、no2_2）

必答問題：
- 工作如何分類（施工類、維運類、策略類、一次性）？
- 每個模組的各項工作估計需要多少點數？

注意：採兩版作業。v0 版在 no1_3 完成後建立粗估框架；v1 版在 no3 主要模組規格完成後精算。股權邀請合約只能基於 v1 版進行。

---

### [no3] 模組規格

主責：Solution Architect（架構、邏輯、資料模型）、Experience Designer（設計政策、互動流程、畫面、設計系統）
前置：no1_3 完成

#### no3_0 跨模組政策（前置：no1_2 產品哲學、no1_3 模組清單、no1_5 品牌決策）

重要：no3_0 是所有其他模組規格的前置，必須最先建立。

UI 設計政策必答問題：
- 設計語言的核心原則是什麼（一致性的具體定義、簡潔性的具體定義）？
- 顏色系統、字體排版系統、間距 Token 如何結構化命名？
- 哪些設計決策是明確禁止的（最容易出錯的清單）？

工程政策必答問題：
- 國際化政策：支援哪些語言、文字方向、日期格式如何處理？
- 錯誤處理的通用策略（錯誤分級、使用者可見錯誤 vs 系統內部錯誤）？
- 錯誤碼如何命名和分類？

完成標準：任何 agent 在設計具體模組時，能直接從這份文件找到判斷依據。

建議新增文件：
- `no0_tech_stack_decision.md`：全局技術棧選型及排除替代方案的理由
- `no5_privacy_compliance.md`：資料收集範疇、儲存位置、使用目的、刪除政策、適用法規（GDPR、CCPA 或地區法規）

#### no3_1 整體互動流程（前置：no3_0）

必答問題：
- 使用者的主要路徑（Happy Path）是什麼？從第一次開啟到完成核心任務，經過哪些畫面？
- 各模組之間如何銜接？有哪些跨模組的共用畫面或元件（如付費牆）？
- 認證流程如何與主功能流程整合？

#### no3_N 各功能模組（前置：no3_0、no3_1；相依模組架構先完成）

每個模組包含五個子節點：

`no1_module_architecture`（Solution Architect）
- 架構結論（一段話描述核心設計）
- 關鍵技術選型、替代方案與排除理由
- 與其他模組的依賴關係
- 已知的技術風險或 Tradeoff

`no2_screens`（Experience Designer）
- 每個畫面：進入點、離開點、元件清單
- 每個元件的狀態（預設、載入中、空、錯誤）
- 邊緣情境（資料為空、超出限制、無網路、無權限）

`no3_logics`（Solution Architect / Full-Stack Engineer）
- 每個邏輯流程：觸發條件、輸入/輸出、Happy Path、異常情境處理
- 非同步操作的失敗回退策略

`no4_data_models`（Solution Architect）
- 所有實體：欄位定義、型別、是否必填、預設值
- 實體間的關聯關係（一對一、一對多、多對多）
- 資料生命週期（創建、更新、刪除、是否軟刪除）

`no5_design_system`（Experience Designer）
- Design Tokens（顏色、間距、字體變數）
- 多主題之間的差異
- 日期格式、貨幣格式、數字格式的顯示規則
- 文字輸入欄位的長度限制

---

### [no4] 開發管理

主責：Full-Stack Engineer（政策）、Product Planner（MVP 規劃）

#### no4_0 開發政策（前置：no3_0 工程政策）

必答問題：
- Git 工作流程：分支策略、Commit message 格式、合併策略、版本號定義
- Coding Style：Linter 與 Formatter、命名慣例、目錄結構原則
- 測試政策：測試範疇、測試框架、覆蓋率目標
- 發布政策：發布流程步驟、Beta 測試策略、App Store 材料清單、Rollback 策略

#### no4_1 MVP 規劃（前置：no1_4 Tier 結構）

必答問題（MVP 範疇）：
- MVP 成功標準是什麼（驗證什麼假設，不是「做完所有功能」）？
- 哪些 User Stories 在 MVP 內，哪些在 MVP 後？
- 有意識的技術負債有哪些（知道這樣做不完美但暫時可接受，記錄未來要改的項目）？

注意：MVP 範疇可以在 no1_4 完成後即開始規劃，但以下兩份文件必須等 MVP 範疇內所有模組架構決策完成後才能撰寫：
- `no2_file_plan.md`（程式碼檔案結構規劃）
- `no3_development_plan.md`（開發順序與 Definition of Done）

---

### [no5] 行銷策略

主責：GTM Strategist
前置：no1_1 護城河、no1_4 Tier 結構完成

#### no5_1 GEO 與獲客策略

必答問題：
- 目標市場的地理分佈是什麼？首要市場和次要市場分別在哪裡？理由是什麼？
- AI 搜尋引擎推薦策略（GEO）：希望 AI 用哪些關鍵字描述這個產品（品牌核心詞、功能關聯詞、使用者情境詞）？
- 官網以外的內容生態系渠道策略（技術部落格、社群論壇、GitHub、影片）？
- Building in Public 策略：在產品上線前，如何透過公開開發累積初期流量和信任？

完成標準：有「上線前 30 天內容計劃」，清楚說明要建立哪些內容資產。

建議新增：`no5_2_post_launch_feedback.md`，定義上線後的反饋收集機制（App Store Review 監測、功能使用率追蹤、NPS）、指標監測儀表板，以及觸發產品迭代決策的門檻。

---

## 邏輯衝突與解法

以下四個已知的相依衝突，在立項時必須主動管理：

衝突 A — no1_3 User Story Tier 標注的循環依賴
no1_3 的 User Story 需要標注付費/免費，但這需要 no1_4 的 Tier 草案才能決定。
解法：no1_3 採兩輪作業。第一輪列出所有 User Stories（不標 Tier），第二輪在 no1_4 完成後補標。

衝突 B — no2_3 估點早於 no3 模組規格
no2_3 的精確估點依賴 no3 的模組規格，但 no2 在目錄順序上排在 no3 之前。
解法：no2_3 分 v0（no1_3 完成後的粗估框架）與 v1（no3 主要規格完成後的精算版），股權邀請合約只能基於 v1。

衝突 C — no3_0 UI 政策依賴 no1_5 品牌決策
no3_0 的設計語言選擇必然受品牌個性影響，但 no1_5 的命名決策也屬於 no1 的範疇，兩者的完成時間可能不同步。
解法：明確標注 no3_0 的前置依賴包含 no1_2（產品哲學）和 no1_5（品牌決策），在兩者都完成前不啟動 no3_0。

衝突 D — no4_1 開發計劃早於模組架構決策
no4_1 的檔案結構計畫與開發順序依賴各模組的架構決策，但 MVP 規劃往往在架構完成前就被要求產出。
解法：no4_1 拆為兩部分。MVP 功能範疇（no1_mvp.md）可以在 no1_4 完成後即開始；檔案計畫與開發計劃（no2_file_plan.md、no3_development_plan.md）必須等 MVP 範疇內所有模組架構決策完成後才能撰寫。

---

## Single Source of Truth 聲明

以下資訊有唯一正本，其他文件只能引用，不能另立：

- 使用者旅程：正本在 no1_2。no5_1 的 GEO 關鍵字必須直接引用 no1_2 的旅程節點，不可重新定義目標使用者。
- 角色定義：正本在 no2_2。所有文件標注的「主責 agent」只是引用，不在各自文件中重複定義角色職責。
