# IAP Product ID 更新總結

## 更新日期
2026-02-01

## 更新原因
為了支援未來的 Level 2 Premium 訂閱層級，將 Product ID 命名從 `premium_*` 改為 `level1_*`，確保可擴展性。

---

## 新的 Product ID 命名規範

### Level 1 - Basic Premium
- **月訂閱**: `susugigi_level1_monthly`
- **年訂閱**: `susugigi_level1_yearly`

### Level 2 - Pro Premium - 未來擴展
- **月訂閱**: `susugigi_level2_monthly` - 尚未建立
- **年訂閱**: `susugigi_level2_yearly` - 尚未建立

---

## 訂閱層級說明

### Level 0 - Free
- 最多 3 個帳戶
- 最多 10 個分類
- 本地儲存

### Level 1 - Basic Premium
- 無限帳戶
- 無限分類
- 雲端同步
- 跨裝置同步

### Level 2 - Pro Premium - 未來
- Level 1 所有功能
- 進階分析報表
- 優先客服支援
- 自訂主題

---

## 已更新的檔案

### 程式碼檔案

#### `src/constants/entitlements.ts`
- 新增 `LEVEL_2` 到 `PlanTier` enum
- 新增 `LEVEL1_MONTHLY` 和 `LEVEL1_YEARLY` 常數
- 保留 `PREMIUM_MONTHLY` 和 `PREMIUM_YEARLY` 作為 deprecated 別名，指向新的 Level 1 產品

#### `src/contexts/PremiumContext.tsx`
- 更新 `refreshStatus()` 檢查邏輯
- 支援檢查新舊兩種 Product ID
- 新增 Level 2 檢查的註解程式碼，方便未來啟用

#### `src/screens/Paywall/PaywallScreen.tsx`
- 更新 `loadProducts()` 使用新的 Product IDs
- 更新產品選項渲染使用新的 Product IDs

### 文件檔案

#### `Apple_IAP_Integration_Guide.md`
- 更新產品 ID 表格
- 更新建立訂閱產品的步驟
- 更新程式碼範例
- 新增訂閱層級說明

---

## 向後相容性

由於 App 尚未上線，**不需要**向後相容性處理。

所有程式碼直接使用新的 Product ID：
- `susugigi_level1_monthly`
- `susugigi_level1_yearly`

```typescript
export const PRODUCT_IDS = {
    // Level 1 - Basic Premium
    LEVEL1_MONTHLY: 'susugigi_level1_monthly',
    LEVEL1_YEARLY: 'susugigi_level1_yearly',
    
    // Level 2 - Pro Premium (未來擴展)
    // LEVEL2_MONTHLY: 'susugigi_level2_monthly',
    // LEVEL2_YEARLY: 'susugigi_level2_yearly',
};
```

---

## Apple Developer Portal 設定步驟

### 步驟一：註冊 Bundle ID
- 前往 [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list)
- 建立新的 App ID
- **Bundle ID**: `com.almightyken0425.susugigiapp`
- **Type**: Explicit
- **Capabilities**: 勾選 **In-App Purchase**

### 步驟二：在 App Store Connect 建立訂閱產品
- 建立訂閱群組: `SuSuGiGi Premium Plans`
- 建立產品:
  - **Level 1 Monthly**
    - Product ID: `susugigi_level1_monthly`
    - Duration: 1 Month
    - Price: USD 0.99 / TWD 30
  - **Level 1 Yearly**
    - Product ID: `susugigi_level1_yearly`
    - Duration: 1 Year
    - Price: USD 9.99 / TWD 300

---

## 測試檢查清單

- [ ] Bundle ID 已在 Apple Developer Portal 註冊
- [ ] In-App Purchase capability 已啟用
- [ ] 訂閱產品已在 App Store Connect 建立
- [ ] Product IDs 與程式碼完全一致
- [ ] Sandbox 測試帳號已建立
- [ ] 可以成功載入產品列表
- [ ] 可以成功購買 Level 1 Monthly
- [ ] 可以成功購買 Level 1 Yearly
- [ ] 購買後 Premium 狀態正確更新
- [ ] Restore Purchases 功能正常

---

## 未來擴展計畫

當準備推出 Level 2 時：

- 在 `entitlements.ts` 中取消註解 Level 2 Product IDs
- 在 App Store Connect 建立 Level 2 產品
- 在 `PremiumContext.tsx` 中取消註解 Level 2 檢查邏輯
- 更新 `PaywallScreen.tsx` 顯示 Level 2 選項
- 實作 Level 2 專屬功能

---

## 注意事項

- **Product ID 不可更改** - 一旦在 App Store Connect 建立，Product ID 就無法修改
- **舊使用者遷移** - 由於我們使用相同的實際 Product ID，不需要遷移現有使用者
- **測試環境** - 務必在 Sandbox 環境充分測試後再提交審核
- **價格設定** - 建議年訂閱價格約為月訂閱的 10 倍，提供折扣誘因

---

## 相關資源

- [Apple IAP Integration Guide](./Apple_IAP_Integration_Guide.md)
- [Apple Developer Portal](https://developer.apple.com/account/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [react-native-iap Documentation](https://react-native-iap.dooboolab.com/)

**文件結束**
