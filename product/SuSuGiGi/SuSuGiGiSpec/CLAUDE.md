# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 專案概述

SuSuGiGi App 的產品規格文件庫，涵蓋從產品定位、功能模組規格到開發管理政策的完整文件。無程式碼、無 build 流程。

---

## 目錄結構

- **no1_product_initiation** — 產品定位，含 App 核心心法、核心價值、商業模式
- **no2_product_planning** — 產品規劃
  - **no1_requirements** — 問題定義與方案評估
  - **no2_product_map** — 模組地圖，依平台拆分（見 Product Map 使用規範）
  - **no3_dev_roadmap** — 開發里程碑規劃
- **no3_product_specs** — 功能模組規格書
  - **no1_user_management** — 使用者管理，含架構與邏輯
  - **no2_accounting_app** — 記帳 App，含畫面、邏輯、資料模型、設計政策
- **no4_project_management** — 專案管理
- **no99_archive** — 封存舊文件，不納入日常讀取

---

## 撰寫規範

所有規格文件依循 universal_writing_linter skill 的寫作政策，核心禁令包含禁止使用括弧、禁止數字編號列表、UI 元件須包裹反引號、標題不得使用數字排序。修改規格文件前請先閱讀 policy 目錄下的通用寫作政策。
---

## Product Map 使用規範

Product Map 位於 `no2_product_planning/no2_product_map/`，依平台拆分：

- 找方向或確認模組歸屬：讀 `structure.md`（< 100 行）
- 需要 App 模組概覽：讀 `app/index.md`（< 30 行）
- 需要特定 App 模組細節：讀 `app/<module>.md`（auth / recording-core / asset-management / home-dashboard / app-preference / cloud-sync / logic-engine / payment）
- 需要 Web Console 細節：讀 `web.md`
- 需要 Firebase 細節：讀 `firebase.md`
- 需要 Cloud Service 細節：讀 `cloud.md`
- 需要外部服務細節：讀 `external.md`

禁止一次 glob 或 list 整個 `no2_product_map/` 目錄後全部讀入。
