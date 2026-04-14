# 角色職責定義

## 核心目標

- 本文件定義執行範疇與價值帳本所需的所有關鍵角色
- 每個角色都必須有明確的職責範圍, 即其負責的概念範疇
- 這是股權分配總表中分配任務的人員基礎

---

## 組織架構與角色職責

- **領導與策略, CEO**
    - 定義公司最終願景與方向
    - 對外尋找資源、融資或合作夥伴
    - 承擔最終的法律與財務責任
- **營運長, COO**
    - **行銷與成長, Marketing**
        - 使用者獲取策略, UA
        - 應用商店優化, ASO
        - 社群媒體經營與品牌曝光
        - 使用者社群經營與客服
    - **財務與法務, Operations**
        - 公司實體設立, 若有需求
        - 管理實際金流、稅務申報
        - 草擬與審核所有法律合約, 例如股東協議、使用者條款
        - 團隊招募、勞力合約
        - 貢獻點數的結算與追蹤
- **產品長, CPO**
    - **產品管理, PDM**
        - 維護所有規格文件
        - 功能開發優先排序
        - 定義產品願景與使用者故事
    - **UX 設計, UX Designer**
        - 使用者流程 User Flow 與資訊架構 IA
        - 低保真線框圖 Wireframe 與原型 Prototype
        - 使用者研究與易用性測試
        - 規格邏輯驗證與邊緣案例定義 Edge Cases
    - **UI 設計, UI Designer**
        - App 的視覺風格、Logo、品牌形象
        - 高保真視覺稿 Mockup 與互動設計
        - 維護設計系統 Design System 與元件庫
        - 輸出切圖與標註 Assets 與 Handoff
- **技術長, CTO**
    - **專案管理, PJM**
        - 專案時程規劃與管理
        - 開發進度追蹤
        - 跨職能溝通與資源協調
    - **App 開發, App RD**
        - React Native 應用程式的架構與實作
        - 將 UI/UX 設計稿轉換為可互動的 App 畫面
        - 串接所有本地資料庫 SQLite/WatermelonDB
    - **Web 開發, Web RD**
        - Web Console 與 B2B Dashboard 的架構與實作
        - 複雜報表與圖表的網頁端呈現
        - 響應式網頁設計 RWD
    - **後端開發, Backend RD**
        - Firebase 服務架構，包含 Firestore 與 Auth 的設計與安全規則
        - 實作同步邏輯與 Cloud Functions
        - 串接 Apple StoreKit 與 Google Play Billing 訂閱機制
        - 維護 CI/CD 流程
    - **品質保證, QA**
        - 撰寫測試案例
        - 手動回歸測試所有功能
        - 自動化測試的導入
        - App 上架前的最終驗收
    - **AI 工程師, AI Engineer**
        - 訓練異常偵測與預測模型
        - 整合 LLM API 與 Prompt Engineering
    - **資料工程師, Data Engineer**
        - 建立 ETL Pipeline
        - 實作資料去識別化與隱私合規處理
        - 維護總經資料庫