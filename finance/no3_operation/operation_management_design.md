# 股權運營管理系統設計

## 系統概述

本系統用於追蹤價值點數的產生、分配與兌現，包含角色管理、功能上線追蹤、點數發放、現金管理、營收統計與毛利分配等功能。

---

## 表格結構設計

### 角色Owner表 `role_owners.csv`

**用途：** 記錄各角色當前負責人

| 欄位名稱 | 資料型別 | 說明 | 範例 |
|:---|:---|:---|:---|
| role_id | string | 角色ID，主鍵 | PDM_001 |
| role_name | string | 角色名稱 | PDM |
| owner_name | string | 當前負責人姓名 | 張三 |
| owner_email | string | 負責人Email | zhang@example.com |
| start_date | date | 開始負責日期 | 2025-01-01 |
| status | string | 狀態：active/inactive | active |
| updated_at | datetime | 最後更新時間 | 2025-01-15 10:30:00 |

---

### 角色Owner異動紀錄表 `role_owner_changes.csv`

**用途：** 記錄角色負責人的所有變更歷史

| 欄位名稱 | 資料型別 | 說明 | 範例 |
|:---|:---|:---|:---|
| change_id | string | 變更ID，主鍵 | CHG_20250115_001 |
| role_id | string | 角色ID，外鍵 | PDM_001 |
| role_name | string | 角色名稱 | PDM |
| action_type | string | 操作類型：add/update/delete | update |
| old_owner | string | 原負責人 | 李四 |
| new_owner | string | 新負責人 | 張三 |
| change_date | datetime | 變更時間 | 2025-01-15 10:30:00 |
| reason | string | 變更原因 | 角色交接 |
| operator | string | 操作人 | Admin |

---

### 功能上線Log `feature_launch_log.csv`

**用途：** 記錄User Story上線時間及負責人

| 欄位名稱 | 資料型別 | 說明 | 範例 |
|:---|:---|:---|:---|
| launch_id | string | 上線ID，主鍵 | LAUNCH_20250120_001 |
| module | string | 產品模組名稱 | Accounting App |
| sub_module | string | 子模組名稱 | 交易與自動化 |
| user_story | string | User Story名稱 | 支出管理 |
| launch_date | date | 上線日期 | 2025-01-20 |
| pdm_owner | string | PDM負責人 | 張三 |
| app_rd_owner | string | App RD負責人 | 李四 |
| backend_rd_owner | string | Backend RD負責人 | 王五 |
| ui_designer_owner | string | UI Designer負責人 | 趙六 |
| ux_designer_owner | string | UX Designer負責人 | 錢七 |
| qa_owner | string | QA負責人 | 孫八 |
| construction_points | integer | 該功能施工總點數 | 750 |
| operation_points_monthly | integer | 該功能每月維運點數 | 17 |
| notes | string | 備註 | Beta版本 |

---

### Module線上價值點數 `module_live_points.csv`

**用途：** 統計各模組已上線功能的累積價值點數

| 欄位名稱 | 資料型別 | 說明 | 範例 |
|:---|:---|:---|:---|
| module_id | string | 模組ID，主鍵 | MOD_記帳_001 |
| module | string | 產品模組名稱 | Accounting App |
| sub_module | string | 子模組名稱 | 交易與自動化 |
| total_construction_points | integer | 累積施工點數 | 3,450 |
| total_operation_points_monthly | integer | 每月維運點數 | 85 |
| feature_count | integer | 已上線功能數 | 5 |
| last_updated | date | 最後更新日期 | 2025-01-20 |

---

### 價值點數發放Log `points_distribution_log.csv`

**用途：** 記錄施工點數和維護點數的發放

| 欄位名稱 | 資料型別 | 說明 | 範例 |
|:---|:---|:---|:---|
| distribution_id | string | 發放ID，主鍵 | DIST_20250120_001 |
| distribution_date | date | 發放日期 | 2025-01-20 |
| distribution_type | string | 類型：construction/operation | construction |
| module | string | 產品模組名稱 | Accounting App |
| sub_module | string | 子模組名稱 | 交易與自動化 |
| user_story | string | User Story名稱 | 支出管理 |
| role_name | string | 角色名稱 | PDM |
| owner_name | string | 獲得者姓名 | 張三 |
| points | integer | 發放點數 | 90 |
| month | string | 發放月份，維運用 | 2025-01 |
| reference | string | 參考來源 | LAUNCH_20250120_001 |
| notes | string | 備註 | 功能上線發放 |

---

### 價值點數擁有總計 `points_ownership_total.csv`

**用途：** 統計每個人累積獲得的價值點數

| 欄位名稱 | 資料型別 | 說明 | 範例 |
|:---|:---|:---|:---|
| owner_name | string | 擁有者姓名，主鍵 | 張三 |
| owner_email | string | Email | zhang@example.com |
| total_construction_points | integer | 累積施工點數 | 5,230 |
| total_operation_points | integer | 累積維運點數 | 1,450 |
| total_points | integer | 總點數 | 6,680 |
| percentage | decimal | 佔總點數比例 | 8.5% |
| last_updated | datetime | 最後更新時間 | 2025-01-31 23:59:59 |

---

### 現金代墊Log `cash_advance_log.csv`

**用途：** 記錄現金支出及轉換為點數

| 欄位名稱 | 資料型別 | 說明 | 範例 |
|:---|:---|:---|:---|
| expense_id | string | 支出ID，主鍵 | EXP_20250115_001 |
| expense_date | date | 支出日期 | 2025-01-15 |
| payer_name | string | 出資人姓名 | 張三 |
| category | string | 費用類別 | 雲端服務 |
| description | string | 費用說明 | AWS 年費 |
| amount_usd | decimal | 金額 USD | 1200.00 |
| point_to_usd_rate | decimal | 轉換匯率 | 2.00 |
| converted_points | integer | 轉換點數 | 600 |
| allocation_type | string | 歸屬類型：module/全產品 | 全產品 |
| allocated_module | string | 歸屬模組，若有 | - |
| invoice_url | string | 發票連結 | https://... |
| status | string | 狀態：pending/approved/rejected | approved |
| approved_by | string | 核准人 | Admin |
| approved_date | date | 核准日期 | 2025-01-16 |

---

### 每月營收紀錄表 `monthly_revenue_log.csv`

**用途：** 統計各模組營收並計算毛利

| 欄位名稱 | 資料型別 | 說明 | 範例 |
|:---|:---|:---|:---|
| record_id | string | 紀錄ID，主鍵 | REV_202501_001 |
| month | string | 月份 | 2025-01 |
| module | string | 產品模組名稱 | Accounting App |
| sub_module | string | 子模組名稱 | 交易與自動化 |
| revenue | decimal | 該模組營收 USD | 5,000.00 |
| module_specific_cost | decimal | 模組專屬費用 USD | 200.00 |
| shared_cost_allocated | decimal | 分攤的共用費用 USD | 150.00 |
| total_cost | decimal | 總費用 USD | 350.00 |
| gross_profit | decimal | 毛利 USD | 4,650.00 |
| profit_margin | decimal | 毛利率 % | 93.0% |
| calculation_date | datetime | 計算時間 | 2025-02-01 10:00:00 |

---

### 毛利發放Log `profit_distribution_log.csv`

**用途：** 記錄毛利按點數比例分配給各owner

| 欄位名稱 | 資料型別 | 說明 | 範例 |
|:---|:---|:---|:---|
| distribution_id | string | 發放ID，主鍵 | PROF_202501_001 |
| month | string | 發放月份 | 2025-01 |
| module | string | 產品模組名稱 | Accounting App |
| sub_module | string | 子模組名稱 | 交易與自動化 |
| module_gross_profit | decimal | 該模組毛利 USD | 4,650.00 |
| owner_name | string | 獲得者姓名 | 張三 |
| owner_points_in_module | integer | 該owner在此模組點數 | 450 |
| module_total_points | integer | 該模組總點數 | 3,450 |
| ownership_percentage | decimal | 持有比例 % | 13.04% |
| profit_share | decimal | 分得毛利 USD | 606.36 |
| payment_status | string | 支付狀態：pending/paid | paid |
| payment_date | date | 支付日期 | 2025-02-05 |
| payment_method | string | 支付方式 | 銀行轉帳 |
| notes | string | 備註 | - |

---

## 資料流程圖

```
1. 功能開發
   ↓
2. 記錄角色Owner（角色Owner表）
   ↓
3. 功能上線（功能上線Log）
   ↓
4. 發放施工點數（價值點數發放Log）
   ↓
5. 更新Module線上價值（Module線上價值點數）
   ↓
6. 每月維運點數發放（價值點數發放Log）
   ↓
7. 更新點數總計（價值點數擁有總計）
   ↓
8. 記錄現金支出（現金代墊Log）
   ↓
9. 統計月營收與毛利（每月營收紀錄表）
   ↓
10. 按點數比例分配毛利（毛利發放Log）
```

---

## 關鍵業務邏輯

### 施工點數發放規則
- 功能上線當月，依據`no5_1_module_role_points.csv`中該User Story的角色點數
- 發放給`功能上線Log`中記錄的各角色owner
- 一次性發放，不重複

### 維運點數發放規則
- 每月月底，依據`角色Owner表`當月負責人
- 發放該User Story對應角色的每月維運點數
- 持續每月發放，直到功能下線或owner變更

### 費用分類與處理規則

#### 模組專屬費用 Module-Specific Costs
適用於僅該模組使用的費用，直接計入該模組成本，不分攤給其他模組。

**範例：**
- **AI Advisor 專用的 OpenAI API 費用**：僅計入 AI Advisor 模組
- **Macro Data 專用的資料源訂閱費**：僅計入 Macro Data 模組
- **特定模組的專屬雲端資源**：如獨立的資料庫實例

**處理方式：**
```
在現金代墊Log中：
- allocation_type = "module"
- allocated_module = "AI Advisor" (具體模組名稱)

在每月營收紀錄表中：
- module_specific_cost 直接記入該模組
```

#### 全產品共用費用 Shared Costs
適用於所有模組共同使用的基礎設施費用，需按營收比例分攤。

**範例：**
- **共用雲端基礎設施**：AWS EC2、Load Balancer
- **共用開發工具**：GitHub、Figma Team
- **共用域名與SSL**：主域名、憑證
- **共用資料庫**：所有模組共用的 PostgreSQL

**處理方式：**
```
在現金代墊Log中：
- allocation_type = "全產品"
- allocated_module = "-" (留空)

分攤公式：
某模組分攤費用 = 全產品共用費用 × (該模組營收 ÷ 總營收)
```

#### 費用歸屬判定流程
```
費用發生 → 判斷是否僅特定模組使用？
           ↓ Yes                    ↓ No
    記為模組專屬費用          記為全產品共用費用
           ↓                        ↓
    直接計入該模組成本      按營收比例分攤給各模組
```

#### 混合費用處理
若費用部分專屬、部分共用，需拆分為兩筆記錄：

**範例：AWS 總費用 $1,000**
- 模組專屬部分：AI Advisor 專用 GPU $400 → 記為模組專屬
- 共用部分：通用 EC2、RDS $600 → 記為全產品共用


### 毛利分配規則
```
個人毛利 = 模組毛利 × (個人在該模組的點數 ÷ 該模組總點數)
```

---

## 實作建議

### 檔案位置
建議將所有表格放在：
```
no2_equity_model/operations/
├── role_owners.csv
├── role_owner_changes.csv
├── feature_launch_log.csv
├── module_live_points.csv
├── points_distribution_log.csv
├── points_ownership_total.csv
├── cash_advance_log.csv
├── monthly_revenue_log.csv
└── profit_distribution_log.csv
```

### 自動化腳本
建議開發以下Python腳本：
- `distribute_construction_points.py` - 功能上線時自動發放施工點數
- `distribute_operation_points.py` - 每月自動發放維運點數
- `calculate_monthly_profit.py` - 計算月度毛利
- `distribute_profit.py` - 按比例分配毛利

### 資料驗證
- 確保發放點數與`no5_1_module_role_points.csv`一致
- 檢查毛利分配總和等於模組毛利
- 驗證owner存在於角色Owner表中
