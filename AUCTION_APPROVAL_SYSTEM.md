# 🎯 AUCTION APPROVAL SYSTEM - CHI TIẾT IMPLEMENTATION

## 📋 **TỔNG QUAN**

Hệ thống approval cho phép **Admin/Manager duyệt từ chối** các yêu cầu tạo auction trước khi chúng được kích hoạt.

### **Workflow Hoàn Chỉnh:**
```
User → Tạo Auction Request → Status: PENDING_APPROVAL
                                    ↓
Admin/Manager → Duyệt/Từ chối
                                    ↓
Nếu duyệt: Status → APPROVED → Deploy Contract → ACTIVE
Nếu từ chối: Status → REJECTED + Reason
```

---

## 🔄 **DETAILED FLOW**

### **PHASE 1: User Tạo Auction Request**

#### **API Call:**
```http
POST /api/auction/create
Authorization: Bearer user_jwt_token
Content-Type: application/json

{
  "title": "iPhone 15 Pro Max",
  "description": "Điện thoại mới 100%",
  "start_price": 10000000,     // VND
  "step_price": 500000,        // VND
  "end_time": "2025-12-01T10:00:00Z",
  "images": ["image1.jpg", "image2.jpg"],
  "category_id": "507f1f77bcf86cd799439011"
}
```

#### **Validation Rules:**
- ✅ `title`: Required, 1-200 chars
- ✅ `description`: Required, 1-2000 chars
- ✅ `start_price`: Min 10,000 VND
- ✅ `step_price`: Min 1,000 VND
- ✅ `end_time`: Future date only
- ✅ User role: Must be `SELLER`

#### **Database Changes:**
```javascript
// Auction record created
{
  _id: "...",
  seller_id: user._id,
  title: "iPhone 15 Pro Max",
  status: "PENDING_APPROVAL",  // ← Key change
  start_price: "200000000000000000000", // Wei
  step_price: "10000000000000000000",   // Wei
  current_price: start_price,
  end_time: "2025-12-01T10:00:00Z",
  start_time: null,  // Set when approved
  approved_by: null,
  approved_at: null,
  contract_address: null,
  deploy_tx_hash: null
}
```

#### **Notifications:**
```javascript
// Notify all admins/managers
await Notification.create({
  user_id: adminId,
  type: 'AUCTION_PENDING_APPROVAL',
  title: 'Yêu cầu duyệt phiên đấu giá mới',
  message: `${user.full_name} đã tạo yêu cầu duyệt auction: ${title}`,
  related_id: auctionId
});
```

---

### **PHASE 2: Admin/Manager Review**

#### **Xem Danh Sách Pending:**
```http
GET /api/auction/admin/pending-approvals?page=1&limit=20
Authorization: Bearer admin_jwt_token
```

**Response:**
```json
{
  "auctions": [
    {
      "id": "...",
      "title": "iPhone 15 Pro Max",
      "description": "Điện thoại mới 100%",
      "seller": {
        "username": "seller123",
        "full_name": "Nguyễn Văn A",
        "email": "seller@gmail.com"
      },
      "start_price_vnd": 10000000,
      "step_price_vnd": 500000,
      "formatted_start_price": "10.000.000 đ",
      "formatted_step_price": "500.000 đ",
      "end_time": "2025-12-01T10:00:00Z",
      "created_at": "2025-11-25T09:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 5,
    "pages": 1
  }
}
```

#### **Approve Auction:**
```http
POST /api/auction/admin/approve/{auctionId}
Authorization: Bearer admin_jwt_token
```

**Process:**
1. ✅ Validate admin permissions
2. ✅ Check auction status = PENDING_APPROVAL
3. 🔧 **Deploy Smart Contract**
4. 📝 Update database
5. 📢 Send notifications

#### **Contract Deployment Process:**
```javascript
async function deployAuctionContract(auction) {
  // 1. Get deployer wallet
  const deployerWallet = new ethers.Wallet(process.env.DEPLOYER_PRIVATE_KEY);

  // 2. Deploy Auction contract
  const AuctionFactory = await ethers.getContractFactory('Auction');
  const contract = await AuctionFactory.connect(deployerWallet).deploy();
  await contract.deployed();

  // 3. Create auction metadata on-chain
  const tx = await contract.connect(deployerWallet).createAuction(
    auction.start_price.toString(),    // Wei
    auction.step_price.toString(),     // Wei
    durationSeconds,                   // Seconds
    auction.title                      // Metadata
  );
  await tx.wait();

  return contract.address;
}
```

#### **Database Updates After Approval:**
```javascript
await Auction.findByIdAndUpdate(auctionId, {
  status: AUCTION_STATUS.APPROVED,
  approved_by: adminId,
  approved_at: new Date(),
  contract_address: deployedContractAddress,
  start_time: new Date()  // Set to now or scheduled time
});
```

#### **Notifications After Approval:**
```javascript
// Notify seller
await Notification.create({
  user_id: sellerId,
  type: 'AUCTION_APPROVED',
  title: 'Phiên đấu giá đã được duyệt',
  message: `Auction "${auction.title}" đã được duyệt và sẽ bắt đầu sớm.`,
  related_id: auctionId
});

// Socket broadcast
io.to(`user_${sellerId}`).emit('auction_approved', {
  auction_id: auctionId,
  title: auction.title,
  contract_address: deployedContractAddress
});
```

#### **Reject Auction:**
```http
POST /api/auction/admin/reject/{auctionId}
Authorization: Bearer admin_jwt_token
Content-Type: application/json

{
  "reason": "Hình ảnh không rõ ràng, vui lòng cung cấp ảnh chất lượng cao hơn"
}
```

**Database Updates After Rejection:**
```javascript
await Auction.findByIdAndUpdate(auctionId, {
  status: AUCTION_STATUS.REJECTED,
  approved_by: adminId,
  approved_at: new Date(),
  rejection_reason: reason
});
```

---

### **PHASE 3: Auction Activation**

#### **Cron Job Process:**
```javascript
// Runs every minute
const manageAuctions = async () => {
  const now = new Date();

  // Activate approved auctions when start_time arrives
  const auctionsToActivate = await Auction.find({
    status: AUCTION_STATUS.APPROVED,
    start_time: { $lte: now },    // Time to start
    end_time: { $gt: now }        // Not ended yet
  });

  for (const auction of auctionsToActivate) {
    // Update status to ACTIVE
    await Auction.findByIdAndUpdate(auction._id, {
      status: AUCTION_STATUS.ACTIVE
    });

    // Notify seller
    await Notification.create({
      user_id: auction.seller_id,
      type: 'AUCTION_STARTED',
      title: 'Phiên đấu giá đã bắt đầu',
      message: `Auction "${auction.title}" đã bắt đầu nhận bids.`,
      related_id: auction._id
    });

    // Broadcast to all users
    io.emit('auction_started', {
      auction_id: auction._id,
      title: auction.title,
      start_price_vnd: weiToVnd(auction.start_price),
      end_time: auction.end_time
    });
  }
};
```

---

### **PHASE 4: Public Auction Listing**

#### **API Changes:**
```javascript
// OLD: Show all auctions
GET /api/auction/all → Return all auctions

// NEW: Show only active approved auctions
GET /api/auction/all → Return only ACTIVE/APPROVED auctions with start_time <= now
```

#### **Query Logic:**
```javascript
const auctions = await Auction.find({
  status: { $in: [AUCTION_STATUS.ACTIVE, AUCTION_STATUS.APPROVED] },
  start_time: { $lte: new Date() }  // Only started auctions
})
.populate('seller_id', 'username full_name')
.sort({ end_time: 1 }); // Ending soon first
```

---

## 🔒 **SECURITY & VALIDATION**

### **User Permissions:**
```javascript
// Only SELLER role can create auctions
if (user.role !== 'SELLER') {
  return res.status(403).json({ error: "Only sellers can create auctions" });
}

// Only ADMIN/MANAGER can approve/reject
if (!['ADMIN', 'MANAGER'].includes(user.role)) {
  return res.status(403).json({ error: "Admin/Manager access required" });
}
```

### **Input Validation:**
```javascript
const validationRules = [
  body('title').isString().notEmpty().withMessage('Title required'),
  body('description').isString().notEmpty().withMessage('Description required'),
  body('start_price').isFloat({ min: 10000 }).withMessage('Start price min 10k VND'),
  body('step_price').isFloat({ min: 1000 }).withMessage('Step price min 1k VND'),
  body('end_time').isISO8601().withMessage('Valid end time required'),
  body('category_id').isMongoId().withMessage('Valid category required')
];
```

### **State Validation:**
```javascript
// Can only approve PENDING_APPROVAL auctions
if (auction.status !== AUCTION_STATUS.PENDING_APPROVAL) {
  return res.status(400).json({ error: "Auction not pending approval" });
}
```

---

## 📊 **STATUS FLOW CHART**

```
PENDING_APPROVAL ← User creates auction
        ↓
   APPROVED ← Admin approves
        ↓
    ACTIVE ← Cron job activates when start_time arrives
        ↓
     ENDED ← Auction expires
        ↓
   SETTLED ← Admin settles with winner
```

**Alternative Path:**
```
PENDING_APPROVAL → REJECTED (Admin rejects with reason)
```

---

## 🔔 **NOTIFICATION SYSTEM**

### **Notification Types:**
```javascript
const NOTIFICATION_TYPES = {
  AUCTION_PENDING_APPROVAL: 'AUCTION_PENDING_APPROVAL', // To admins
  AUCTION_APPROVED: 'AUCTION_APPROVED',               // To seller
  AUCTION_REJECTED: 'AUCTION_REJECTED',               // To seller
  AUCTION_STARTED: 'AUCTION_STARTED',                 // To seller
  OUTBID: 'OUTBID',                                   // To bidders
  WON_AUCTION: 'WON_AUCTION'                          // To winner
};
```

### **Real-time Events:**
```javascript
// Socket.IO events
io.to(`user_${sellerId}`).emit('auction_approved', {...});
io.to(`user_${sellerId}`).emit('auction_rejected', {...});
io.emit('auction_started', {...}); // Broadcast to all
```

---

## 🧪 **TESTING SCENARIOS**

### **Happy Path Test:**
1. ✅ User creates auction → Status: PENDING_APPROVAL
2. ✅ Admin views pending → Sees auction in list
3. ✅ Admin approves → Status: APPROVED, Contract deployed
4. ✅ Cron activates → Status: ACTIVE, Notifications sent
5. ✅ Users can bid → Auction appears in /api/auction/all

### **Rejection Test:**
1. ✅ User creates auction → PENDING_APPROVAL
2. ✅ Admin rejects with reason → Status: REJECTED
3. ✅ User receives rejection notification
4. ✅ Auction not visible in public listings

### **Edge Cases:**
- ❌ Non-seller tries to create → 403 Forbidden
- ❌ Invalid dates → 400 Bad Request
- ❌ Non-admin tries to approve → 403 Forbidden
- ❌ Approve non-pending auction → 400 Bad Request

---

## 📈 **ADMIN DASHBOARD APIs**

### **Pending Approvals:**
```http
GET /api/auction/admin/pending-approvals?page=1&limit=20
```

### **All Auctions with Filters:**
```http
GET /api/auction/admin/all?status=APPROVED&page=1&limit=20
```

### **Approve/Reject Actions:**
```http
POST /api/auction/admin/approve/{auctionId}
POST /api/auction/admin/reject/{auctionId}
```

---

## 🎯 **IMPLEMENTATION SUMMARY**

✅ **User Flow**: Create → Pending → Approved/Rejected → Active → End
✅ **Admin Flow**: Review → Approve/Reject → Deploy Contract → Activate
✅ **Security**: Role-based access, input validation, state checks
✅ **Real-time**: Notifications, socket events, status updates
✅ **Blockchain**: Contract deployment, settlement integration
✅ **Testing**: Complete test scenarios for all edge cases

**Auction Approval System hoàn thiện với workflow production-ready!** 🚀</contents>
</xai:function_call">Tạo documentation chi tiết về auction approval system.
