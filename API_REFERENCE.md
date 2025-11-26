# 🚀 BIDCHAIN API REFERENCE - POSTMAN GUIDE

## 📋 **TỔNG QUAN**

Dự án BidChain có **4 nhóm API chính**:
- 🔐 **Authentication** - Đăng ký, đăng nhập, quản lý ví
- 💰 **Auction** - Nạp/rút tiền, đấu giá, số dư
- 💳 **Payment** - Tích hợp Momo payment
- 👤 **User** - Thông tin cá nhân, lịch sử

**Base URL:** `http://localhost:3000/api`

---

## 🔧 **POSTMAN SETUP**

### **1. Tạo Environment**
```json
{
  "base_url": "http://localhost:3000/api",
  "jwt_token": "",
  "admin_token": "",
  "user_id": "",
  "auction_id": "",
  "deposit_request_id": ""
}
```

### **2. Authentication Headers**
```javascript
// Thêm vào request headers:
Authorization: Bearer {{jwt_token}}
```

### **3. Test Scripts**
```javascript
// Thêm vào Tests tab để tự động lưu token:
if (pm.response.code === 200 && pm.response.json().token) {
    pm.environment.set("jwt_token", pm.response.json().token);
}
```

---

## 🔐 **1. AUTHENTICATION APIs**

### **1.1 REGISTER USER**
```
Method: POST
Endpoint: {{base_url}}/auth/register
Auth: None
```

**Request Body:**
```json
{
  "username": "testuser",
  "password": "123456"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "testuser",
  "wallet_address": "0x742d35Cc6...",
  "balance_eth": 0,
  "locked_eth": 0
}
```

**Postman Setup:**
- Method: POST
- URL: `{{base_url}}/auth/register`
- Body: raw JSON
- Tests: `pm.environment.set("jwt_token", pm.response.json().token);`

---

### **1.2 LOGIN USER**
```
Method: POST
Endpoint: {{base_url}}/auth/login
Auth: None
```

**Request Body:**
```json
{
  "username": "testuser",
  "password": "123456"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "testuser",
  "wallet_address": "0x742d35Cc6...",
  "balance_eth": 10,
  "locked_eth": 0
}
```

---

### **1.3 DEMO: FUND ALL USERS (Development Only)**
```
Method: POST
Endpoint: {{base_url}}/demo/fund-all-users
Auth: Bearer Token (Admin)
```

**Response (200):**
```json
{
  "success": true,
  "message": "Funded 3/3 users",
  "results": [
    {
      "username": "user1",
      "status": "success",
      "amount_eth": "10.0",
      "tx_hash": "0x..."
    }
  ]
}
```

---

### **1.4 GET BLOCKCHAIN BALANCE**
```
Method: GET
Endpoint: {{base_url}}/auth/wallet/balance-blockchain/:userId
Auth: Bearer Token
```

**Response (200):**
```json
{
  "user_id": "...",
  "username": "testuser",
  "wallet_address": "0x...",
  "blockchain_balance_eth": 10.0,
  "blockchain_balance_vnd": 500000000,
  "formatted_blockchain_balance": "500.000.000 đ"
}
```

---

## 💰 **2. AUCTION APIs**

### **2.1 GET WALLET BALANCE**
```
Method: GET
Endpoint: {{base_url}}/auction/wallet/balance
Auth: Bearer Token
```

**Response (200):**
```json
{
  "wallet_address": "0x...",
  "balance_eth": 10.0,
  "locked_eth": 0.24,
  "available_eth": 9.76,
  "balance_vnd": 500000000,
  "locked_vnd": 12000000,
  "available_vnd": 488000000,
  "formatted_balance": "500.000.000 đ",
  "formatted_locked": "12.000.000 đ",
  "formatted_available": "488.000.000 đ",
  "contract_balance_eth": 10.0,
  "balance_verified": true
}
```

---

### **2.2 DEPOSIT VND TO CONTRACT**
```
Method: POST
Endpoint: {{base_url}}/auction/wallet/deposit
Auth: Bearer Token
```

**Request Body:**
```json
{
  "amount_vnd": 1000000,
  "momo_ref_id": "MM123456"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Deposit successful",
  "amount_vnd": 1000000,
  "amount_eth": 0.02,
  "formatted_amount": "1.000.000 đ",
  "transaction_id": "...",
  "tx_hash": "0x..."
}
```

---

### **2.3 WITHDRAW FROM CONTRACT**
```
Method: POST
Endpoint: {{base_url}}/auction/wallet/withdraw
Auth: Bearer Token
```

**Request Body:**
```json
{
  "amount_vnd": 500000
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Withdrawal successful",
  "amount_vnd": 500000,
  "amount_eth": 0.01,
  "formatted_amount": "500.000 đ",
  "transaction_id": "...",
  "tx_hash": "0x..."
}
```

---

### **2.4 GET TRANSACTION HISTORY**
```
Method: GET
Endpoint: {{base_url}}/auction/wallet/transactions
Auth: Bearer Token
```

**Response (200):**
```json
{
  "transactions": [
    {
      "type": "DEPOSIT",
      "amount_vnd": 1000000,
      "amount_eth": 0.02,
      "exchange_rate": 50000000,
      "status": "COMPLETED",
      "formatted_amount_vnd": "1.000.000 đ",
      "formatted_amount_eth": "0.020000 ETH",
      "created_at": "2025-11-25T...",
      "tx_hash": "0x..."
    }
  ]
}
```

---

### **2.5 CREATE AUCTION**
```
Method: POST
Endpoint: {{base_url}}/auction/create
Auth: Bearer Token
```

**Request Body:**
```json
{
  "startingPriceWei": "200000000000000000000",
  "stepPriceWei": "10000000000000000000",
  "durationSeconds": 1800,
  "metadataUrl": "ipfs://test-metadata"
}
```

**Response (200):**
```json
{
  "auctionId": "1"
}
```

---

### **2.6 GET ALL AUCTIONS**
```
Method: GET
Endpoint: {{base_url}}/auction/all
Auth: None
```

**Response (200):**
```json
[
  {
    "_id": "1",
    "title": "iPhone 15 Pro",
    "start_price_vnd": 10000000,
    "current_price_vnd": 12000000,
    "step_price_vnd": 500000,
    "formatted_start_price": "10.000.000 đ",
    "formatted_current_price": "12.000.000 đ",
    "formatted_step_price": "500.000 đ",
    "end_time": "2025-11-25T15:00:00.000Z",
    "status": "ACTIVE"
  }
]
```

---

### **2.7 GET AUCTION DETAILS**
```
Method: GET
Endpoint: {{base_url}}/auction/:auctionId
Auth: None
```

**Response (200):**
```json
{
  "_id": "1",
  "title": "iPhone 15 Pro",
  "start_price_vnd": 10000000,
  "current_price_vnd": 12000000,
  "formatted_current_price": "12.000.000 đ",
  "bids": [
    {
      "user_id": "...",
      "amount_vnd": 12000000,
      "formatted_amount": "12.000.000 đ",
      "created_at": "2025-11-25T..."
    }
  ]
}
```

---

### **2.8 PLACE BID**
```
Method: POST
Endpoint: {{base_url}}/auction/bid
Auth: Bearer Token
```

**Request Body:**
```json
{
  "auction_id": "1",
  "amount_vnd": 12500000,
  "signature": "0x_eip712_signature",
  "nonce": 1
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Bid placed successfully",
  "bid_id": "...",
  "amount_vnd": 12500000,
  "formatted_amount": "12.500.000 đ",
  "current_price_vnd": 12500000,
  "formatted_current_price": "12.500.000 đ"
}
```

---

### **2.9 END AUCTION (Seller Only)**
```
Method: POST
Endpoint: {{base_url}}/auction/:auctionId/end
Auth: Bearer Token (Seller)
```

---

## 💳 **3. PAYMENT APIs (MOMO)**

### **3.1 CREATE DEPOSIT REQUEST**
```
Method: POST
Endpoint: {{base_url}}/payment/deposit/request
Auth: Bearer Token
```

**Request Body:**
```json
{
  "amount_vnd": 1000000
}
```

**Response (200):**
```json
{
  "success": true,
  "deposit_request_id": "...",
  "amount_vnd": 1000000,
  "momo_payment": {
    "order_id": "BIDCHAIN_1234567890_user123",
    "pay_url": "https://test-payment.momo.vn/...",
    "qr_code_url": "https://api.qrserver.com/...",
    "deeplink": "momo://..."
  }
}
```

---

### **3.2 MOMO CALLBACK (Internal)**
```
Method: POST
Endpoint: {{base_url}}/payment/momo/callback
Auth: None (Momo webhook)
```

**Request Body (from Momo):**
```json
{
  "partnerCode": "MOMO_TEST_PARTNER",
  "orderId": "BIDCHAIN_1234567890_user123",
  "amount": "1000000",
  "resultCode": 0,
  "signature": "..."
}
```

---

### **3.3 ADMIN APPROVE DEPOSIT**
```
Method: POST
Endpoint: {{base_url}}/payment/admin/approve-deposit/:requestId
Auth: Bearer Token (Admin)
```

**Response (200):**
```json
{
  "success": true,
  "message": "Approved deposit of 1.000.000 đ for username",
  "tx_hash": "0x..."
}
```

---

### **3.4 ADMIN REJECT DEPOSIT**
```
Method: POST
Endpoint: {{base_url}}/payment/admin/reject-deposit/:requestId
Auth: Bearer Token (Admin)
```

**Request Body:**
```json
{
  "reason": "Invalid transaction"
}
```

---

### **3.5 GET DEPOSIT HISTORY (User)**
```
Method: GET
Endpoint: {{base_url}}/payment/deposit/history
Auth: Bearer Token
```

**Response (200):**
```json
{
  "deposit_requests": [
    {
      "id": "...",
      "amount_vnd": 1000000,
      "formatted_amount": "1.000.000 đ",
      "status": "COMPLETED",
      "momo_order_id": "BIDCHAIN_...",
      "created_at": "2025-11-25T...",
      "completed_at": "2025-11-25T...",
      "qr_code_url": "https://..."
    }
  ]
}
```

---

### **3.6 GET ALL DEPOSIT REQUESTS (Admin)**
```
Method: GET
Endpoint: {{base_url}}/payment/admin/deposit-requests
Auth: Bearer Token (Admin)
```

**Query Params:**
- `?status=PAID` - Filter by status
- `?status=PENDING_PAYMENT`

---

## 👤 **4. USER APIs**

### **4.1 GET USER PROFILE**
```
Method: GET
Endpoint: {{base_url}}/user/me
Auth: Bearer Token
```

**Response (200):**
```json
{
  "_id": "...",
  "username": "testuser",
  "email": null,
  "full_name": null,
  "role": "BIDDER",
  "status": "ACTIVE",
  "wallet_address": "0x...",
  "balance_eth": 10.0,
  "locked_eth": 0.24,
  "last_nonce": 5
}
```

---

### **4.2 GET USER AUCTIONS (Seller)**
```
Method: GET
Endpoint: {{base_url}}/user/me/auctions
Auth: Bearer Token
```

---

### **4.3 GET USER BIDS**
```
Method: GET
Endpoint: {{base_url}}/user/me/bids
Auth: Bearer Token
```

---

## 📊 **POSTMAN COLLECTION STRUCTURE**

### **Tạo Collection:**
1. New Collection → "BidChain API"
2. Import từ file hoặc tạo manual

### **Folder Structure:**
```
📁 BidChain API
├── 📁 1. Authentication
│   ├── Register User
│   ├── Login User
│   └── Fund Wallets (Demo)
├── 📁 2. Auction System
│   ├── Get Balance
│   ├── Deposit to Contract
│   ├── Withdraw from Contract
│   ├── Get Transactions
│   ├── Create Auction
│   ├── Get All Auctions
│   ├── Get Auction Details
│   └── Place Bid
├── 📁 3. Momo Payment
│   ├── Create Deposit Request
│   ├── Admin Approve Deposit
│   ├── Admin Reject Deposit
│   ├── Get Deposit History
│   └── Get All Requests (Admin)
└── 📁 4. User Management
    ├── Get Profile
    ├── Get My Auctions
    └── Get My Bids
```

---

## 🔄 **TEST FLOW COMPLETE**

### **Step 1: Setup Environment**
```javascript
// Set variables:
base_url: http://localhost:3000/api
jwt_token: "" (will be set automatically)
admin_token: ""
```

### **Step 2: Authentication Flow**
1. **Register User** → Save token to `jwt_token`
2. **Demo Fund Wallets** → Add ETH to user wallets
3. **Get Balance** → Verify ETH received

### **Step 3: Auction Flow**
1. **Create Auction** → Save `auction_id`
2. **Get All Auctions** → Verify auction created
3. **Deposit to Contract** → Add funds for bidding
4. **Place Bid** → Test bidding system
5. **Get Auction Details** → Verify bid recorded

### **Step 4: Payment Flow**
1. **Create Deposit Request** → Generate Momo QR
2. **Admin Approve** → Transfer ETH to user
3. **Get Balance** → Verify funds received

---

## 🎯 **TEST SCENARIOS**

### **Happy Path Test:**
1. ✅ Register → Login → Fund → Balance
2. ✅ Create Auction → Get Auctions → Deposit
3. ✅ Place Bid → Check Auction → Withdraw

### **Error Handling Test:**
1. ❌ Invalid JWT → 401 Unauthorized
2. ❌ Insufficient Balance → 400 Bad Request
3. ❌ Invalid Bid Amount → 400 Bad Request
4. ❌ Expired Auction → 400 Bad Request

### **Admin Functions Test:**
1. ✅ Approve Deposit → ETH Transfer
2. ✅ Reject Deposit → Status Update
3. ✅ Fund Users → Multiple ETH Transfers

---

## 🚨 **COMMON ISSUES & FIXES**

### **401 Unauthorized**
```javascript
// Check JWT token
console.log("Token:", pm.environment.get("jwt_token"));
```

### **400 Bad Request**
```javascript
// Check request body format
pm.test("Request Body", function () {
    const jsonData = pm.request.toJSON();
    console.log("Request:", jsonData);
});
```

### **500 Internal Server Error**
```javascript
// Check server logs
pm.test("Server Response", function () {
    console.log("Response:", pm.response.json());
});
```

### **Blockchain Connection Issues**
```javascript
// Check if Ganache is running
pm.test("Blockchain Connection", function () {
    const response = pm.response.json();
    pm.expect(response.contract_balance_eth).to.be.a('number');
});
```

---

## 📈 **PERFORMANCE TESTING**

### **Load Test Setup:**
```javascript
// Runner → Collection Runner
// Set iterations: 100
// Set delay: 1000ms
```

### **Expected Results:**
- Response Time: < 500ms
- Success Rate: > 99%
- Error Rate: < 1%

---

## 🎉 **SUCCESS CRITERIA**

✅ **All APIs return 200 OK**
✅ **JWT Authentication working**
✅ **Blockchain integration active**
✅ **Momo payment flow complete**
✅ **Balance calculations accurate**
✅ **Real-time bidding functional**

**Collection test pass = API integration successful!** 🚀</contents>
</xai:function_call">Tạo tài liệu API reference hoàn chỉnh với hướng dẫn Postman chi tiết.

