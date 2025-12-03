BidChain - Ứng dụng quản lý đấu giá trên Blockchain

Mô tả Dự Án

BidChain là một ứng dụng di động full-stack cho phép người dùng tham gia các cuộc đấu giá trực tuyến với tính năng blockchain. Ứng dụng được xây dựng bằng Flutter cho frontend và Node.js + Express + MongoDB cho backend, kết hợp với smart contract để đảm bảo tính minh bạch và bảo mật.

---

Tính Năng Chính

Quản Lý Người Dùng
- Đăng ký tài khoản và đăng nhập
- Xem và chỉnh sửa hồ sơ cá nhân
- Thêm ảnh đại diện từ camera hoặc thư viện
- Quên mật khẩu với xác thực OTP
- Liên kết ví Ethereum (wallet)
- Quản lý địa chỉ giao hàng (quốc gia, thành phố, quận, phường)

Chức Năng Đấu Giá
- Duyệt danh sách các cuộc đấu giá đang diễn ra
- Xem chi tiết sản phẩm, giá khởi điểm, và lịch sử bid
- Đặt giá (bid) trực tiếp cho các sản phẩm
- Xem danh sách các cuộc đấu giá của mình (My Activity)
- Nhận thông báo khi bị "phả ngàn" (bid bị vượt qua)
- Quản lý các sản phẩm đã thắng đấu giá

Hệ Thống Thanh Toán
- Nạp tiền (Deposit) vào ví
- Rút tiền (Withdraw) từ ví
- Liên kết với MoMo (số điện thoại)
- Hỗ trợ blockchain transactions trên Ethereum
- Theo dõi lịch sử giao dịch

Chatbot AI
- Hỗ trợ người dùng thông qua AI (Gemini 2.0 Flash)
- Trả lời câu hỏi về sản phẩm, giá cả, chiến lược đấu giá
- Lưu lịch sử chat locally

Quản Trị Viên
- Đăng nhập admin riêng biệt
- Quản lý danh sách người dùng (khóa/mở khóa, thay đổi role)
- Phê duyệt hoặc từ chối các cuộc đấu giá
- Quản lý trạng thái đấu giá (Deploy, Start, End, Settle)
- Xem thống kê dashboard (doanh thu, số bidder, top bidders)
- Xem lịch sử hoạt động của user

---

Công Nghệ Sử Dụng


Frontend
| Công Nghệ | Phiên Bản | Mục Đích |
|-----------|----------|---------|
| Flutter | ^3.8.1 | Framework phát triển ứng dụng di động |
| Flutter BLoC | ^9.1.1 | Quản lý trạng thái (State Management) |
| Dio | ^5.9.0 | HTTP client cho API requests |
| Go Router | ^17.0.0 | Điều hướng và routing trong ứng dụng |
| Shared Preferences | ^2.5.3 | Lưu trữ dữ liệu cục bộ |
| Image Picker | ^1.0.7 | Chọn ảnh từ camera/thư viện |
| QR Flutter | ^4.1.0 | Tạo mã QR |
| Google Fonts | 6.3.2 | Thư viện font Google |
| Flutter DotEnv | ^5.1.0 | Đọc biến môi trường từ .env |
| Google Generative AI | ^0.4.0 | Tích hợp Gemini AI |
| Socket.io Client | ^2.0.3+1 | WebSocket cho real-time updates |

Backend
| Công Nghệ | Phiên Bản | Mục Đích |
|-----------|----------|---------|
| Node.js | - | Runtime JavaScript |
| Express | ^4.18.2 | Web framework |
| MongoDB | - | NoSQL database |
| Mongoose | ^7.3.1 | ODM cho MongoDB |
| Ethers.js | ^5.7.2 | Blockchain interactions |
| JWT | ^9.0.0 | Xác thực token |
| Bcrypt | ^5.1.0 | Mã hóa mật khẩu |
| Cloudinary | ^2.8.0 | Lưu trữ và quản lý hình ảnh |
| Multer | ^2.0.2 | Upload file |
| Pinata SDK | ^2.1.0 | IPFS storage |
| Socket.io | ^4.7.0 | Real-time communication |
| Express Validator | ^7.3.1 | Xác thực dữ liệu input |

---

Cấu Trúc Dự Án

```
BidChain/
├── backend/                    # Server Node.js
│   ├── src/
│   │   ├── app.js             # Entry point ứng dụng
│   │   ├── models/            # Mongoose schemas
│   │   ├── routes/            # API endpoints
│   │   │   ├── admin/         # Admin routes
│   │   │   ├── auth.js        # Authentication
│   │   │   ├── auction.js     # Auction management
│   │   │   ├── payment.js     # Payment processing
│   │   │   └── ...
│   │   ├── controllers/       # Business logic
│   │   ├── middleware/        # Express middleware
│   │   ├── services/          # External services
│   │   ├── blockchain/        # Smart contract logic
│   │   ├── config/            # Configuration
│   │   └── utils/             # Helper functions
│   ├── package.json
│   └── .env.example
│
├── frontend/                   # Ứng dụng Flutter
│   ├── lib/
│   │   ├── main.dart          # Entry point Flutter
│   │   ├── config/            # Cấu hình ứng dụng
│   │   ├── core/              # Core logic, DI, networking
│   │   ├── data/              # Data layer (repositories, datasources)
│   │   ├── domain/            # Domain layer (entities, usecases)
│   │   └── presentation/      # UI layer (screens, widgets, BLoC)
│   ├── pubspec.yaml
│   └── .env
│
├── blockchain/                # Smart contracts
│   ├── contracts/             # Solidity contracts
│   ├── scripts/               # Deployment scripts
│   └── hardhat.config.js
│
└── README.md                  # Tài liệu này
```

---

Hướng Dẫn Cài Đặt

Yêu Cầu Trước Khi Cài Đặt
- Node.js phiên bản 14+ và npm/yarn
- Flutter SDK phiên bản 3.8.1+
- MongoDB (có thể dùng MongoDB Atlas cloud)
- Git
- Hardhat (để deploy blockchain contracts)
- Cloudinary account (để lưu trữ ảnh)
- Google Gemini API key (cho chatbot)

---

Cấu Hình Backend

1. Thiết Lập Biến Môi Trường

Tạo file `.env` trong thư mục `backend/`:

```env
# Server
PORT=5000
NODE_ENV=development

# Database
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/bidchain

# JWT
JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRES_TIME=7d

# Blockchain
ADMIN_PRIVATE_KEY=your_admin_wallet_private_key

# Momo Payment
MOMO_API_URL=https://test-payment.momo.vn/v2/gateway/api/create
MOMO_PARTNER_CODE=your_momo_partner_code
MOMO_ACCESS_KEY=your_momo_access_key
MOMO_SECRET_KEY=your_momo_secret_key

# Cloudinary (Image Storage)
CLOUDINARY_NAME=your_cloudinary_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret

# SMTP (Email)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_EMAIL=your_email@gmail.com
SMTP_PASSWORD=your_app_password
SMTP_FROM_EMAIL=noreply@bidchain.com
SMTP_FROM_NAME=BidChain Team
```

2. Khởi Động Backend

```bash
# Vào thư mục backend
cd backend

# Cài đặt dependencies
npm install

# Chạy development mode (với auto-reload)
npm run dev

# Hoặc chạy production mode
npm start
```

Backend sẽ khởi động tại: `http://localhost:5000`

---

Cấu Hình Frontend

1. Thiết Lập Biến Môi Trường

Tạo file `.env` trong thư mục `frontend/`:

```env
# Backend API
API_BASE_URL=http://your-backend-ip:5000/api

# Gemini AI
GEMINI_API_KEY=your_google_gemini_api_key

# Environment
ENVIRONMENT=development
```

Lưu ý: 
- Nếu chạy backend trên local, dùng địa chỉ IPv4 thay vì `localhost`
- Lệnh tìm IPv4: `ipconfig` (Windows) hoặc `ifconfig` (Mac/Linux)

2. Khởi Động Frontend

```bash
# Vào thư mục frontend
cd frontend

# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run

# Hoặc chạy trên Android emulator cụ thể
flutter run -d emulator-5554
```

---

Hướng Dẫn Kiểm Tra Ứng Dụng

Trên Android
1. Chuẩn bị Android Emulator hoặc kết nối thiết bị thật qua USB
2. Chạy lệnh: flutter run
3. Ứng dụng sẽ tự động build và cài đặt trên emulator/device
4. Ứng dụng sẽ tự động cập nhật khi có thay đổi (hot reload)

Trên iOS
1. Chuẩn bị iOS Simulator hoặc thiết bị thật
2. Chạy lệnh: flutter run
3. Hoặc sử dụng Xcode: flutter run -v
4. Ứng dụng sẽ load và chạy trực tiếp

Lưu Ý Quan Trọng
- Backend có thể bị trễ 30 giây lần đầu tiên do server free tier sleep
- Đây là hành vi bình thường, không phải lỗi
- Các request sau sẽ nhanh hơn

---

API Documentation

Postman Collection
Tài liệu API đầy đủ có trong file: `BidChain_API_Collection.postman_collection.json`

Cách import:
1. Mở Postman
2. Click Import → Chọn file collection
3. Thiết lập environment variable: `base_url=http://localhost:5000/api`

Các API Chính

Authentication
```
POST   /api/auth/register          - Đăng ký tài khoản
POST   /api/auth/login             - Đăng nhập
POST   /api/auth/forgot-password   - Quên mật khẩu
```

Auction
```
GET    /api/auction                - Danh sách đấu giá
GET    /api/auction/:id            - Chi tiết đấu giá
POST   /api/auction                - Tạo đấu giá (Seller)
POST   /api/auction/:id/bid        - Đặt giá
GET    /api/auction/:id/bids       - Danh sách bids
```

Payment
```
POST   /api/payment/deposit        - Nạp tiền
POST   /api/payment/withdraw       - Rút tiền
GET    /api/payment/history        - Lịch sử giao dịch
```

User Profile
```
GET    /api/user/profile           - Hồ sơ người dùng
PUT    /api/user/profile           - Cập nhật hồ sơ
POST   /api/user/avatar            - Tải ảnh đại diện
```

Admin
```
GET    /api/admin/users            - Danh sách user
GET    /api/admin/auctions         - Danh sách auction
POST   /api/admin/auctions/:id/approve   - Phê duyệt
POST   /api/admin/auctions/:id/reject    - Từ chối
GET    /api/admin/dashboard/stats  - Thống kê
```

Xem file `API_REFERENCE.md` để có danh sách đầy đủ

---

Quản Trị & Bảo Mật

Truy Cập Admin Panel
1. Đăng nhập với tài khoản có role ADMIN
2. Truy cập: Menu → Admin Panel
3. Quản lý: Users, Auctions, Payments, Statistics

Bảo Mật
- Mật khẩu được mã hóa bằng Bcrypt
- Token JWT có hạn 7 ngày
- CORS được cấu hình cho phép request từ frontend
- Input validation trên mọi API endpoint
- Private key lưu trữ được mã hóa

---

Blockchain Integration

Smart Contract
- Language: Solidity
- Network: Ethereum (Sepolia testnet khuyên dùng)
- Features:
  - Quản lý giá khởi điểm và giá hiện tại
  - Ghi lại lịch sử bid trên chain
  - Xác định người thắng cuộc đấu giá

Deployment
```bash
cd blockchain
npm install

# Deploy contract
npx hardhat run scripts/deploy.js --network sepolia
```

---

Xử Lý Sự Cố Thường Gặp

Lỗi: "API_BASE_URL không được cấu hình"
Giải pháp:
- Kiểm tra file `.env` ở folder `frontend/`
- Đảm bảo `API_BASE_URL` đúng định dạng
- Restart ứng dụng Flutter

Lỗi: "Không kết nối được database"
Giải pháp:
- Kiểm tra `MONGODB_URI` trong `.env`
- Kiểm tra IP whitelist trên MongoDB Atlas
- Đảm bảo MongoDB service đang chạy

Lỗi: "GEMINI_API_KEY not found"
Giải pháp:
- Truy cập: https://aistudio.google.com/app/apikey
- Tạo API key mới
- Cập nhật vào `.env`
- Restart ứng dụng

Backend tự động tắt sau 30 giây
Giải pháp:
- Đây là hành vi bình thường trên server free tier
- Lần tiếp theo sẽ khởi động lại tự động
- Nếu muốn deployment production, nâng cấp hosting

---

Tài Liệu Tham Khảo

| Tài Liệu | Mô Tả |
|----------|-------|
| API_REFERENCE.md | Danh sách đầy đủ tất cả API endpoints |
| POSTMAN_GUIDE.md | Hướng dẫn sử dụng Postman collection |
| GEMINI_API_SETUP.md | Cấu hình Gemini AI chatbot |
| MOMO_INTEGRATION_README.md | Hướng dẫn tích hợp MoMo payment |
| AUCTION_APPROVAL_SYSTEM.md | Quy trình phê duyệt đấu giá |
| EDIT_PROFILE_INTEGRATION_STRATEGY.md | Chiến lược cập nhật hồ sơ |

---

Vai Trò & Quyền

| Vai Trò | Quyền |
|---------|-------|
| USER | Duyệt auction, bid, quản lý profile, nạp/rút tiền |
| MANAGER | Duyệt/từ chối auction, xem thống kê |
| ADMIN | Toàn quyền: quản lý user, auction, deploy contract, view stats |

---

Deployment

Frontend (Google Play/App Store)
```bash
# Build APK cho Android
flutter build apk --release

# Build IPA cho iOS
flutter build ios --release
```

Backend (Heroku, Railway, Render)
```bash
# Tạo file Procfile
echo "web: npm start" > Procfile

# Deploy lên platform
git push heroku main
```

---

Hỗ Trợ & Liên Hệ

Nếu gặp vấn đề:
1. Kiểm tra các file tài liệu trong thư mục root
2. Xem logs trong terminal (backend/frontend)
3. Tạo issue trên GitHub
4. Liên hệ team development

---

Ghi Chú Quan Trọng

Trước khi đẩy code lên repository:
- Không commit file `.env` (chứa secrets)
- Commit file `.env.example` làm template
- Thêm `.env` vào `.gitignore`

Last Updated: December 3, 2025  
Project Status: Active Development
