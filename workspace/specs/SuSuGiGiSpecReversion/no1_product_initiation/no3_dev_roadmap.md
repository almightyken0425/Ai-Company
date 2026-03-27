# Development Roadmap

## 外部因素篩選

**公司政策與策略方向**
SuSuGiGi 由小型共同創辦人團隊啟動，初期無外部資金壓力，優先以最小可上架範疇驗證付費意願，再以 Tier 收入支撐後續模組開發。

**客戶重要性**
MVP 階段無付費客戶，以 App Store 自然流量為市場驗證代理指標。早期目標使用者是有隱私意識且財務結構趨於複雜的成年人，集中在 iOS 平台。付費轉化率與 Tier 1 訂閱數是第一個可觀測的商業信號。

**市場時機**
個人財務管理工具市場需求穩定，無強烈季節性窗口。Local-First 隱私定位在隱私法規趨嚴的市場有中期優勢。無競品即時壓力，但若 AI 自動記帳類產品出現，必須在 Delivery 3 完成前評估邏輯引擎的差異化能否抵禦。

**資源限制**
初期工程資源有限，架構以 Expo/React Native 為核心，採 Firebase Auth 加 Firestore，無後端自建。所有交付單元的範疇切分以現有團隊在不新增外部依賴的前提下可完成為上限。

Construction Points 加總來自 `no2_equity_model/no1_foundation/no4_1_module_role_points.csv`，以各交付單元包含的 User Story × 全 Role 的 Construction Points 加總，反映建設複雜度。

---

## Delivery 1：Accounting App 核心 + 會員管理

**範疇內容：** User Management 全部（登入、登出、首次登入初始化、多語言、多幣別、主題偏好）加 Accounting App Tier 0（支出管理、收入管理、轉帳管理、帳戶管理、類別管理、預設資料、離線支援、首頁儀表板、搜尋功能、多語言、主題系統）加序號驗證與兌換。排除定期交易、多幣別支援、雲端同步、資料匯入、邏輯引擎。

**總 Construction Points：** 約 11,800

**依存條件：** 無

**上線後可感知商業價值：** App Store 上架、自然下載量可觀測、序號兌換啟動初步付費意願驗證。

---

## Delivery 2：雲端同步 + Tier 1 Premium 功能

**範疇內容：** 雲端同步（批次引擎加衝突解決）、解除帳戶與類別數量限制、多幣別支援（外幣帳戶、跨幣別轉帳、匯率管理）、定期交易、資料匯入（CSV）。排除即時同步、直接銀行 API 對接。

**總 Construction Points：** 約 10,250

**依存條件：** Delivery 1

**上線後可感知商業價值：** Tier 1 訂閱付費牆啟動，可觀測月訂閱數與 Tier 0 → Tier 1 轉化率。

---

## Delivery 3：邏輯引擎與規則中心

**範疇內容：** 規則中心介面、填空式規則編輯、規則開關控制、時光機回溯（非破壞性歷史重算）。Tier 2 付費牆在此啟動。排除 AI 輔助規則建議（屬 Delivery 5）。

**總 Construction Points：** 無數據，CSV 未獨立追蹤此模組

**依存條件：** Delivery 2（需要多幣別與交易資料結構穩定後再建構規則引擎）

**上線後可感知商業價值：** Tier 2 訂閱啟動，ARPU 提升，可觀測 Tier 1 → Tier 2 升級率。

---

## Delivery 4：Web Console

**範疇內容：** 桌面版表格視圖、進階匯出、JQL 查詢介面、視圖儲存、自訂維度報表、報表匯出。排除即時協作、手機版 Web Console。

**總 Construction Points：** 約 16,000

**依存條件：** Delivery 3（邏輯引擎資料結構為 Web Console 查詢的核心資料源）

**上線後可感知商業價值：** 桌面使用者可存取進階管理功能，Tier 2 留存率提升，可觀測 Web Console 月活。

---

## Delivery 5：AI Advisor

**範疇內容：** 現金流預測模型、財務健康評分、自然語言 AI 對話問答介面。Tier 3 付費牆在此啟動。排除主動推播通知。

**總 Construction Points：** 約 9,800

**依存條件：** Delivery 4（需要足夠的歷史交易資料與使用者留存基礎）

**上線後可感知商業價值：** Tier 3 訂閱啟動，可觀測 AI 對話互動率與 Tier 3 轉化率。

---

## Delivery 6：Macro Data Service

**範疇內容：** 市場情資儀表板（B 端）、競品趨勢分析、總經 API 輸出、K-Anonymity 隱私合規處理。Tier B 企業版定價。排除個人資料直接出售。

**總 Construction Points：** 約 17,600

**依存條件：** Delivery 5（需要足夠的 C 端使用者數量才能提供有統計意義的聚合數據）

**上線後可感知商業價值：** B 端企業訂閱收入啟動，飛輪形成：C 端數據量 → B 端收入 → C 端研發資金。
