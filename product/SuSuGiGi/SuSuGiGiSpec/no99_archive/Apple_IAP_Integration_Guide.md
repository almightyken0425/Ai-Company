# Apple In-App Purchase 整合指南 - SuSuGiGiApp

## 目錄

- 前置準備
- App Store Connect 設定
- iOS 專案設定
- 程式碼架構說明
- 測試流程
- 常見問題排除
- 進階主題

---

## 前置準備

### 必要條件

- Apple Developer Program 會員資格 - 年費 USD 99
- 有效的 Bundle ID - `com.almightyken0425.susugigiapp`
- 實體 iOS 裝置 - 模擬器對 IAP 支援有限
- Xcode 安裝完成

### 重要概念

- **Product ID** - 產品的唯一識別碼，必須與程式碼中完全一致
- **Subscription Group** - 訂閱群組，同群組內的訂閱互斥
- **Sandbox Testing** - 測試環境，不會實際扣款
- **Auto-Renewable Subscription** - 自動續訂訂閱

---

## App Store Connect 設定

### 步驟一 - 簽署付費 App 協議

這是**最關鍵**的步驟，新帳號必須完成此步驟才能使用 IAP 功能。

- 登入 [App Store Connect](https://appstoreconnect.apple.com/)
- 點選 **Business** 或 **Agreements, Tax, and Banking**
- 找到 **Paid Apps** 協議
- 點擊 **View and Agree**
- 填寫必要資訊
  - **Contact Info** - 聯絡人資訊
  - **Bank Info** - 收款銀行帳戶
  - **Tax Forms** - 稅務表格，非美國人填寫 W-8BEN
- 等待協議狀態變成 **Active**

> **注意** - 如果協議狀態是 Processing 或 Pending User Info，IAP 功能將無法運作。這個驗證過程可能需要 1-48 小時。

### 步驟二 - 建立或選擇 App

- 點選 **My Apps**
- 如果尚未建立 App，點擊 **+** 建立新 App
  - **Bundle ID** - 選擇 `com.almightyken0425.susugigiapp`
  - **SKU** - 可以使用 `susugigi-app-001`
  - **Name** - SuSuGiGi

### 步驟三 - 建立訂閱群組

- 選擇您的 App
- 左側選單 **Features** → **Subscriptions**
- 點選 **Create Subscription Group**
- **Reference Name** - 輸入 `SuSuGiGi Premium Plans`
  - 這個名稱僅供內部使用，使用者看不到

### 步驟四 - 建立訂閱產品

SuSuGiGiApp 目前使用 Level 1 訂閱產品，未來可擴展至 Level 2：

#### Level 1 月訂閱

- 點選群組內的 **Create** 或 **+**
- **Reference Name** - `Level 1 Premium Monthly`
- **Product ID** - `susugigi_level1_monthly` - **必須完全一致**
- **Duration** - 選擇 **1 Month**

#### Level 1 年訂閱

- 重複上述步驟
- **Reference Name** - `Level 1 Premium Yearly`
- **Product ID** - `susugigi_level1_yearly` - **必須完全一致**
- **Duration** - 選擇 **1 Year**

> **未來擴展** - Level 2 產品將使用 `susugigi_level2_monthly` 和 `susugigi_level2_yearly`

### 步驟五 - 設定產品細節

針對每個產品進行以下設定：

#### 定價設定

- 點選 **Subscription Prices**
- 設定基礎價格
  - Level 1 Monthly - USD 0.99 或 TWD 30
  - Level 1 Yearly - USD 9.99 或 TWD 300
- Apple 會自動計算其他幣別的價格

#### 本地化資訊

- 點選 **App Store Localization**
- 新增語言 - 至少需要一個語言
- **Display Name** - 顯示在 App Store 訂閱管理介面
  - Level 1 Monthly - `Level 1 Premium Monthly`
  - Level 1 Yearly - `Level 1 Premium Yearly`
- **Description** - 功能描述
  - 例如：`Unlock all premium features including unlimited accounts, cloud sync, and advanced analytics`

#### 審查資訊

- **Review Information** - 上傳截圖
  - 建議上傳 Paywall 畫面的截圖
  - 可以使用模擬器截圖

### 步驟六 - 設定 Sandbox 測試帳號

Sandbox 帳號用於開發階段免費測試購買流程。

- 回到 App Store Connect 首頁
- 點選 **Users and Access**
- 左側選單選擇 **Sandbox Testers**
- 點選 **+** 建立測試帳號
- 填寫資訊
  - **Email** - 必須是**未註冊過 Apple ID** 的 Email
    - 建議使用 Gmail 的 `+` 功能，例如 `yourname+test1@gmail.com`
  - **Password** - 設定測試帳號密碼
  - **Region** - 建議與測試裝置的商店區域一致
  - **First Name / Last Name** - 可以填寫測試用名稱

---

## iOS 專案設定

### 步驟一 - 檢查 Bundle ID

- 開啟 Xcode
- 選擇專案 `SuSuGiGiApp`
- 確認 **Bundle Identifier** 為 `com.almightyken0425.susugigiapp`

### 步驟二 - 啟用 In-App Purchase Capability

- 在 Xcode 中選擇專案
- 選擇 Target `SuSuGiGiApp`
- 點選 **Signing & Capabilities** 標籤
- 點選 **+ Capability**
- 搜尋並新增 **In-App Purchase**

### 步驟三 - 檢查依賴套件

專案已經安裝 `react-native-iap` v14.7.7，無需額外安裝。

```json
"react-native-iap": "^14.7.7"
```

### 步驟四 - 執行 Pod Install

```bash
cd ios
pod install
cd ..
```

---

## 程式碼架構說明

### 核心檔案

#### 產品 ID 定義

檔案位置：`src/constants/entitlements.ts`

```typescript
export enum PlanTier {
    LEVEL_0 = 0,  // Free - 最多 3 帳戶, 10 分類
    LEVEL_1 = 1,  // Basic Premium - 無限帳戶, 無限分類, 雲端同步
    LEVEL_2 = 2,  // Pro Premium - Level 1 + 進階分析 + 優先支援 (未來擴展)
}

export const PRODUCT_IDS = {
    // Level 1 - Basic Premium
    LEVEL1_MONTHLY: 'susugigi_level1_monthly',
    LEVEL1_YEARLY: 'susugigi_level1_yearly',
    
    // Level 2 - Pro Premium (未來擴展)
    // LEVEL2_MONTHLY: 'susugigi_level2_monthly',
    // LEVEL2_YEARLY: 'susugigi_level2_yearly',
};
```

#### IAP 服務層

檔案位置：`src/services/iapService.ts`

主要功能：

- `initialize()` - 初始化 IAP 連線
- `getSubscriptions(skus)` - 取得訂閱產品資訊
- `requestPurchase(sku)` - 發起購買請求
- `restorePurchases()` - 恢復已購買項目
- `addPurchaseListener(callback)` - 監聽購買事件

關鍵實作：

```typescript
// 初始化 IAP
async initialize() {
    const hasConnected = await initConnection();
    if (hasConnected) {
        this.setupListeners();
    }
}

// 購買監聽器
private setupListeners() {
    this.purchaseUpdateSubscription = purchaseUpdatedListener(
        async (purchase: Purchase) => {
            await finishTransaction({ purchase, isConsumable: false });
            this.notifyPurchaseConfigured(purchase);
        }
    );
}

// 發起購買
async requestPurchase(sku: string) {
    await requestPurchase({
        skus: [sku],
        sku: sku,
        andDangerouslyFinishTransactionAutomaticallyIOS: false,
    });
}
```

#### Premium Context

檔案位置：`src/contexts/PremiumContext.tsx`

主要功能：

- 管理使用者的訂閱狀態
- 自動檢查購買狀態
- 監聽購買事件並更新狀態
- 在 App 進入前景時自動同步

關鍵實作：

```typescript
const refreshStatus = useCallback(async () => {
    const purchases = await iapService.getAvailablePurchases();
    
    const hasPremium = purchases.some(p => 
        p.productId === PRODUCT_IDS.PREMIUM_MONTHLY || 
        p.productId === PRODUCT_IDS.PREMIUM_YEARLY
    );

    if (hasPremium) {
        setCurrentTier(PlanTier.LEVEL_1);
    }
}, []);

// 監聽購買事件
useEffect(() => {
    const unsubscribe = iapService.addPurchaseListener(() => {
        refreshStatus();
    });
    return () => unsubscribe();
}, [refreshStatus]);
```

#### Paywall 畫面

檔案位置：`src/screens/Paywall/PaywallScreen.tsx`

主要功能：

- 顯示訂閱方案
- 處理購買流程
- 恢復購買

關鍵流程：

```typescript
// 載入產品
const loadProducts = async () => {
    const skus = [PRODUCT_IDS.LEVEL1_MONTHLY, PRODUCT_IDS.LEVEL1_YEARLY];
    const fetched = await iapService.getSubscriptions(skus);
    setProducts(fetched);
};

// 處理購買
const handlePurchase = async () => {
    await iapService.requestPurchase(selectedProductId);
    await refreshStatus();
    navigation.goBack();
};

// 恢復購買
const handleRestore = async () => {
    await iapService.restorePurchases();
    await refreshStatus();
};
```

### 資料流程

```
使用者點擊購買
    ↓
PaywallScreen.handlePurchase()
    ↓
iapService.requestPurchase()
    ↓
系統購買流程
    ↓
purchaseUpdatedListener 觸發
    ↓
finishTransaction()
    ↓
notifyPurchaseConfigured()
    ↓
PremiumContext.refreshStatus()
    ↓
更新 currentTier
    ↓
觸發雲端同步
```

---

## 測試流程

### 準備工作

- 確保已在 App Store Connect 建立 Sandbox 測試帳號
- 確保 iOS 裝置已登出 App Store 正式帳號的 Sandbox 設定

### 步驟一 - 在裝置上登入 Sandbox 帳號

- 開啟 iOS 裝置
- 前往 **設定** → **App Store**
- 捲動到最下方找到 **SANDBOX ACCOUNT**
- 點選並登入您建立的 Sandbox 測試帳號

> **重要** - 不要在 iCloud 設定中登入 Sandbox 帳號，只在 App Store 的 Sandbox 區域登入。

### 步驟二 - 建置並執行 App

```bash
# 清理建置
cd ios
rm -rf build
pod install
cd ..

# 執行 App
npx react-native run-ios --device
```

### 步驟三 - 測試購買流程

- 開啟 App
- 導航至 Paywall 畫面
- 選擇訂閱方案 - Monthly 或 Yearly
- 點擊 **Subscribe** 按鈕
- 系統會顯示購買確認對話框
  - 顯示 **[Sandbox]** 標記
  - 顯示價格
- 點擊 **確認** 完成購買
- 購買成功後應該會：
  - 自動關閉 Paywall
  - 更新使用者的 Premium 狀態
  - 解鎖 Premium 功能

### 步驟四 - 測試恢復購買

- 刪除 App 並重新安裝
- 或是登出並重新登入
- 開啟 Paywall 畫面
- 點擊 **Restore Purchases** 按鈕
- 系統應該會自動恢復之前的購買
- 確認 Premium 狀態已恢復

### 步驟五 - 測試訂閱管理

- 前往 iOS **設定** → **Apple ID** → **訂閱項目**
- 應該可以看到 SuSuGiGi 的訂閱
- 可以取消訂閱進行測試

---

## 常見問題排除

### 問題一 - 抓不到產品 - Empty Product List

**症狀** - `getSubscriptions()` 回傳空陣列

**可能原因與解決方法**

- **Paid Apps 協議未生效**
  - 檢查 App Store Connect → Business → Paid Apps 協議狀態
  - 確認狀態為 **Active**
  - 如果是 Processing，需要等待驗證完成

- **Product ID 不一致**
  - 檢查 App Store Connect 中的 Product ID
  - 檢查程式碼中的 `PRODUCT_IDS` 常數
  - 確保完全一致，包括大小寫

- **Bundle ID 不一致**
  - 檢查 Xcode 中的 Bundle Identifier
  - 檢查 App Store Connect 中的 Bundle ID
  - 確保兩者完全一致

- **產品狀態未就緒**
  - 確認產品在 App Store Connect 中的狀態
  - 新建立的產品可能需要幾分鐘才會生效
  - 嘗試等待 5-10 分鐘後重試

- **網路連線問題**
  - 確認裝置有網路連線
  - 嘗試切換 Wi-Fi 或行動網路

**除錯方法**

```typescript
// 在 iapService.ts 中加入詳細 log
async getSubscriptions(skus: string[]) {
    console.log('Fetching subscriptions for SKUs:', skus);
    try {
        const subs = await fetchProducts({ skus });
        console.log('Fetched products:', JSON.stringify(subs, null, 2));
        return subs.map(s => {
            console.log('Processing product:', s.productId);
            return {
                productId: s.productId,
                price: s.localizedPrice,
                // ...
            };
        });
    } catch (err) {
        console.error('Error fetching subscriptions:', err);
        throw err;
    }
}
```

### 問題二 - 購買失敗

**症狀** - 點擊購買後出現錯誤

**可能原因與解決方法**

- **未使用實體裝置**
  - 模擬器對 IAP 支援有限
  - 必須使用實體 iOS 裝置測試

- **未登入 Sandbox 帳號**
  - 確認已在 設定 → App Store → Sandbox Account 登入
  - 確認登入的是正確的 Sandbox 測試帳號

- **Sandbox 帳號已被使用**
  - Sandbox 帳號可能已經在其他裝置使用過
  - 嘗試建立新的 Sandbox 測試帳號

- **Transaction 未完成**
  - 檢查是否有未完成的交易
  - 嘗試呼叫 `finishTransaction()` 清理

**除錯方法**

```typescript
// 在 PaywallScreen.tsx 中加入詳細錯誤處理
const handlePurchase = async () => {
    try {
        console.log('Starting purchase for:', selectedProductId);
        await iapService.requestPurchase(selectedProductId);
        console.log('Purchase request sent successfully');
    } catch (e: any) {
        console.error('Purchase error:', {
            code: e.code,
            message: e.message,
            debugMessage: e.debugMessage,
        });
        
        if (e.code === 'E_USER_CANCELLED') {
            console.log('User cancelled purchase');
        } else if (e.code === 'E_ITEM_UNAVAILABLE') {
            Alert.alert('Error', 'Product not available');
        } else {
            Alert.alert('Purchase Error', e.message || 'Unknown error');
        }
    }
};
```

### 問題三 - 購買成功但狀態未更新

**症狀** - 購買完成但 `currentTier` 仍為 `LEVEL_0`

**可能原因與解決方法**

- **購買監聽器未設定**
  - 檢查 `PremiumContext` 中的 `useEffect`
  - 確認 `addPurchaseListener` 有被呼叫

- **finishTransaction 失敗**
  - 檢查 `purchaseUpdatedListener` 中的邏輯
  - 確認 `finishTransaction` 有被正確呼叫

- **refreshStatus 未被觸發**
  - 檢查購買監聽器是否有呼叫 `refreshStatus()`
  - 手動呼叫 `refreshStatus()` 測試

**除錯方法**

```typescript
// 在 PremiumContext.tsx 中加入 log
const refreshStatus = useCallback(async () => {
    console.log('Refreshing premium status...');
    
    try {
        const purchases = await iapService.getAvailablePurchases();
        console.log('Available purchases:', purchases.map(p => p.productId));
        
        const hasPremium = purchases.some(p => 
            p.productId === PRODUCT_IDS.PREMIUM_MONTHLY || 
            p.productId === PRODUCT_IDS.PREMIUM_YEARLY
        );
        
        console.log('Has premium:', hasPremium);
        
        if (hasPremium) {
            console.log('Setting tier to LEVEL_1');
            setCurrentTier(PlanTier.LEVEL_1);
        } else {
            console.log('Setting tier to LEVEL_0');
            setCurrentTier(PlanTier.LEVEL_0);
        }
    } catch (e) {
        console.error('Error refreshing status:', e);
    }
}, []);
```

### 問題四 - Restore Purchases 無效

**症狀** - 點擊 Restore 按鈕後沒有恢復購買

**可能原因與解決方法**

- **使用不同的 Apple ID**
  - 確認使用的是購買時的同一個 Sandbox 帳號
  - Sandbox 購買綁定特定的 Apple ID

- **購買未完成**
  - 確認之前的購買有成功完成
  - 檢查 App Store Connect → Sales and Trends

- **getAvailablePurchases 回傳空陣列**
  - 檢查網路連線
  - 嘗試重新啟動 App

**除錯方法**

```typescript
// 在 iapService.ts 中加入詳細 log
async restorePurchases() {
    console.log('Restoring purchases...');
    try {
        const purchases = await getAvailablePurchases();
        console.log('Restored purchases:', purchases.map(p => ({
            productId: p.productId,
            transactionId: p.transactionId,
            transactionDate: p.transactionDate,
        })));
        
        if (purchases && purchases.length > 0) {
            purchases.forEach(p => {
                console.log('Notifying purchase:', p.productId);
                this.notifyPurchaseConfigured(p);
            });
        } else {
            console.log('No purchases to restore');
        }
        
        return purchases;
    } catch (e) {
        console.error('Error restoring purchases:', e);
        throw e;
    }
}
```

### 問題五 - Sandbox 環境問題

**症狀** - 各種 Sandbox 相關錯誤

**解決方法**

- **登出並重新登入 Sandbox 帳號**
  - 設定 → App Store → Sandbox Account → 登出
  - 重新登入

- **清除 App 資料**
  - 刪除 App 並重新安裝
  - 清除 Xcode 的 Derived Data

- **重置 Sandbox 環境**
  - 在 App Store Connect 建立新的 Sandbox 測試帳號
  - 使用新帳號測試

- **檢查 Sandbox 伺服器狀態**
  - 前往 [Apple System Status](https://developer.apple.com/system-status/)
  - 確認 App Store Connect 和 Sandbox 服務正常

---

## 進階主題

### 收據驗證

目前的實作是客戶端驗證，生產環境建議實作伺服器端驗證。

#### 客戶端驗證 - 目前實作

```typescript
// 在 iapService.ts 中
purchaseUpdatedListener(async (purchase: Purchase) => {
    const receipt = purchase.transactionId;
    if (receipt) {
        // 客戶端直接完成交易
        await finishTransaction({ purchase, isConsumable: false });
        this.notifyPurchaseConfigured(purchase);
    }
});
```

#### 伺服器端驗證 - 建議實作

```typescript
// 1. 修改 purchaseUpdatedListener
purchaseUpdatedListener(async (purchase: Purchase) => {
    const receipt = purchase.transactionReceipt;
    
    try {
        // 2. 發送收據到後端驗證
        const response = await fetch('https://your-backend.com/api/verify-receipt', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                receipt,
                productId: purchase.productId,
                userId: user.uid,
            }),
        });
        
        const result = await response.json();
        
        if (result.valid) {
            // 3. 驗證成功，完成交易
            await finishTransaction({ purchase, isConsumable: false });
            this.notifyPurchaseConfigured(purchase);
        } else {
            console.warn('Receipt validation failed');
        }
    } catch (error) {
        console.error('Receipt validation error:', error);
    }
});
```

#### 後端驗證 API 範例 - Node.js

```javascript
// Express.js endpoint
app.post('/api/verify-receipt', async (req, res) => {
    const { receipt, productId, userId } = req.body;
    
    // Apple 收據驗證 endpoint
    const verifyUrl = process.env.NODE_ENV === 'production'
        ? 'https://buy.itunes.apple.com/verifyReceipt'
        : 'https://sandbox.itunes.apple.com/verifyReceipt';
    
    try {
        const response = await fetch(verifyUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                'receipt-data': receipt,
                'password': process.env.APPLE_SHARED_SECRET,
            }),
        });
        
        const result = await response.json();
        
        if (result.status === 0) {
            // 驗證成功，更新 Firestore
            await admin.firestore()
                .collection('users')
                .doc(userId)
                .update({
                    premiumTier: 1,
                    subscriptionProductId: productId,
                    subscriptionExpiresAt: result.latest_receipt_info[0].expires_date_ms,
                });
            
            res.json({ valid: true });
        } else {
            res.json({ valid: false, error: result.status });
        }
    } catch (error) {
        console.error('Verification error:', error);
        res.status(500).json({ valid: false, error: 'Server error' });
    }
});
```

### 訂閱狀態同步

確保訂閱狀態在 Firestore 中正確同步。

```typescript
// 在 PremiumContext.tsx 中
const syncSubscriptionToFirestore = async (purchases: Purchase[]) => {
    if (!user) return;
    
    const hasPremium = purchases.some(p => 
        p.productId === PRODUCT_IDS.PREMIUM_MONTHLY || 
        p.productId === PRODUCT_IDS.PREMIUM_YEARLY
    );
    
    if (hasPremium) {
        const activePurchase = purchases.find(p => 
            p.productId === PRODUCT_IDS.PREMIUM_MONTHLY || 
            p.productId === PRODUCT_IDS.PREMIUM_YEARLY
        );
        
        // 更新 Firestore
        await firestore()
            .collection('users')
            .doc(user.uid)
            .update({
                premiumTier: PlanTier.LEVEL_1,
                subscriptionProductId: activePurchase?.productId,
                subscriptionPlatform: 'ios',
                lastSyncedAt: new Date(),
            });
    }
};
```

### 優惠與促銷代碼

Apple 支援訂閱優惠和促銷代碼。

#### 在 App Store Connect 設定優惠

- 選擇訂閱產品
- 點選 **Subscription Offers**
- 建立優惠
  - **Offer Type** - Introductory Offer 或 Promotional Offer
  - **Duration** - 優惠期間
  - **Price** - 優惠價格

#### 在程式碼中使用優惠

```typescript
// 購買時指定優惠
await requestPurchase({
    sku: PRODUCT_IDS.PREMIUM_YEARLY,
    withOffer: {
        identifier: 'intro_offer_1',
        keyIdentifier: 'YOUR_KEY_ID',
        nonce: 'YOUR_NONCE',
        signature: 'YOUR_SIGNATURE',
        timestamp: Date.now(),
    },
});
```

### 處理訂閱降級與升級

使用者可能會在月訂閱和年訂閱之間切換。

```typescript
// 檢查訂閱類型
const getActiveSubscriptionType = (purchases: Purchase[]) => {
    const yearly = purchases.find(p => p.productId === PRODUCT_IDS.PREMIUM_YEARLY);
    const monthly = purchases.find(p => p.productId === PRODUCT_IDS.PREMIUM_MONTHLY);
    
    if (yearly) return 'yearly';
    if (monthly) return 'monthly';
    return null;
};

// 處理升級
const handleUpgrade = async () => {
    const currentType = getActiveSubscriptionType(await iapService.getAvailablePurchases());
    
    if (currentType === 'monthly') {
        // 從月訂閱升級到年訂閱
        await iapService.requestPurchase(PRODUCT_IDS.PREMIUM_YEARLY);
    }
};
```

### 訂閱到期處理

定期檢查訂閱是否到期。

```typescript
// 在 PremiumContext.tsx 中
const checkSubscriptionExpiry = async () => {
    const purchases = await iapService.getAvailablePurchases();
    
    if (purchases.length === 0) {
        // 沒有有效訂閱
        setCurrentTier(PlanTier.LEVEL_0);
        return;
    }
    
    // 檢查訂閱是否過期
    // 注意：react-native-iap 會自動處理過期訂閱
    // getAvailablePurchases 只會回傳有效的訂閱
};

// 定期檢查 - 每天一次
useEffect(() => {
    const interval = setInterval(() => {
        checkSubscriptionExpiry();
    }, 24 * 60 * 60 * 1000); // 24 小時
    
    return () => clearInterval(interval);
}, []);
```

### 分析與追蹤

追蹤 IAP 事件以進行分析。

```typescript
// 整合 Firebase Analytics
import analytics from '@react-native-firebase/analytics';

// 追蹤購買開始
const trackPurchaseStarted = (productId: string) => {
    analytics().logEvent('purchase_started', {
        product_id: productId,
        platform: 'ios',
    });
};

// 追蹤購買成功
const trackPurchaseCompleted = (purchase: Purchase) => {
    analytics().logEvent('purchase_completed', {
        product_id: purchase.productId,
        transaction_id: purchase.transactionId,
        platform: 'ios',
    });
};

// 追蹤購買失敗
const trackPurchaseFailed = (productId: string, error: string) => {
    analytics().logEvent('purchase_failed', {
        product_id: productId,
        error_message: error,
        platform: 'ios',
    });
};
```

---

## 檢查清單

### App Store Connect

- [ ] Apple Developer Program 會員資格已啟用
- [ ] Paid Apps 協議已簽署並生效
- [ ] App 已建立，Bundle ID 正確
- [ ] 訂閱群組已建立
- [ ] 月訂閱產品已建立 - `susugigi_premium_monthly`
- [ ] 年訂閱產品已建立 - `susugigi_premium_yearly`
- [ ] 產品定價已設定
- [ ] 產品本地化資訊已填寫
- [ ] Sandbox 測試帳號已建立

### iOS 專案

- [ ] Bundle ID 與 App Store Connect 一致
- [ ] In-App Purchase Capability 已啟用
- [ ] `react-native-iap` 已安裝
- [ ] Pod install 已執行
- [ ] Product IDs 在程式碼中正確定義

### 測試

- [ ] 實體 iOS 裝置已準備
- [ ] Sandbox 帳號已在裝置上登入
- [ ] App 可以成功建置並執行
- [ ] 可以取得產品列表
- [ ] 可以成功購買
- [ ] 購買後狀態正確更新
- [ ] 可以恢復購買
- [ ] 訂閱管理功能正常

### 上線前

- [ ] 實作伺服器端收據驗證
- [ ] 設定訂閱到期處理邏輯
- [ ] 整合分析追蹤
- [ ] 測試所有邊界情況
- [ ] 準備客服文件
- [ ] 設定退款政策

---

## 參考資源

### Apple 官方文件

- [In-App Purchase Programming Guide](https://developer.apple.com/in-app-purchase/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [StoreKit Documentation](https://developer.apple.com/documentation/storekit)
- [Receipt Validation Guide](https://developer.apple.com/documentation/appstorereceipts/verifying_receipts_with_the_app_store)

### react-native-iap 文件

- [GitHub Repository](https://github.com/dooboolab/react-native-iap)
- [API Documentation](https://react-native-iap.dooboolab.com/)
- [Migration Guide](https://react-native-iap.dooboolab.com/docs/migration)

### 相關工具

- [Apple System Status](https://developer.apple.com/system-status/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Xcode](https://developer.apple.com/xcode/)

---

## 總結

Apple IAP 整合涉及多個步驟，從 App Store Connect 設定到程式碼實作，每個環節都需要仔細處理。本指南涵蓋了 SuSuGiGiApp 的完整整合流程，包括：

- App Store Connect 的詳細設定步驟
- iOS 專案的必要配置
- 程式碼架構的深入說明
- 完整的測試流程
- 常見問題的排除方法
- 進階主題的實作建議

遵循本指南，您應該能夠成功整合 Apple IAP 並提供穩定的訂閱服務。如果遇到問題，請參考常見問題排除章節，或查閱 Apple 官方文件。

**文件結束**
