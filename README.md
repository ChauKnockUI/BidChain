
<h1 align="center">🔗 BidChain</h1>

<p align="center">
  <strong>Nền tảng đấu giá trực tuyến ứng dụng công nghệ Blockchain</strong>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/></a>
  <a href="https://nodejs.org"><img src="https://img.shields.io/badge/Node.js-18.x-339933?style=for-the-badge&logo=node.js&logoColor=white" alt="Node.js"/></a>
  <a href="https://mongodb.com"><img src="https://img.shields.io/badge/MongoDB-6.x-47A248?style=for-the-badge&logo=mongodb&logoColor=white" alt="MongoDB"/></a>
  <a href="https://ethereum.org"><img src="https://img.shields.io/badge/Ethereum-Blockchain-3C3C3D?style=for-the-badge&logo=ethereum&logoColor=white" alt="Ethereum"/></a>
  <a href="https://ai.google.dev"><img src="https://img.shields.io/badge/Gemini-AI-4285F4?style=for-the-badge&logo=google&logoColor=white" alt="Gemini AI"/></a>
</p>

<p align="center">
  <a href="#-giới-thiệu">Giới thiệu</a> •
  <a href="#-tính-năng">Tính năng</a> •
  <a href="#-công-nghệ">Công nghệ</a> •
  <a href="#-cài-đặt">Cài đặt</a> •
  <a href="#-giao-diện">Giao diện</a>
</p>

---

## 🎯 Giới thiệu

**BidChain** là nền tảng đấu giá trực tuyến hiện đại, tích hợp công nghệ **Blockchain** để đảm bảo tính minh bạch, bảo mật và không thể thay đổi của các giao dịch. Hệ thống bao gồm:

- 📱 **Ứng dụng di động** (iOS & Android) cho người dùng
- 🖥️ **Trang web quản trị** cho quản trị viên
- 🤖 **AI Chatbot** hỗ trợ người dùng (Google Gemini)

<table>
  <tr>
    <td align="center">🔒<br/><strong>Minh bạch</strong><br/><sub>Giao dịch ghi trên Blockchain</sub></td>
    <td align="center">💰<br/><strong>Thanh toán an toàn</strong><br/><sub>Ví điện tử tích hợp</sub></td>
    <td align="center">🤖<br/><strong>AI Chatbot</strong><br/><sub>Hỗ trợ bởi Gemini</sub></td>
  </tr>
</table>

---

## ✨ Tính năng

<table>
  <tr>
    <th>👤 Người dùng</th>
    <th>🛡️ Quản trị viên</th>
  </tr>
  <tr>
    <td>
      ✅ Đăng ký / Đăng nhập tài khoản<br/>
      ✅ Xem danh sách phiên đấu giá<br/>
      ✅ Tham gia đấu giá thời gian thực<br/>
      ✅ Tạo phiên đấu giá mới<br/>
      ✅ Quản lý ví điện tử (nạp/rút tiền)<br/>
      ✅ Theo dõi lịch sử hoạt động<br/>
      ✅ AI Chatbot hỗ trợ (Gemini API)
    </td>
    <td>
      ✅ Dashboard tổng quan<br/>
      ✅ Quản lý phiên đấu giá<br/>
      ✅ Quản lý người dùng<br/>
      ✅ Phê duyệt phiên đấu giá<br/>
      ✅ Thống kê và báo cáo<br/>
      ✅ Giám sát giao dịch Blockchain
    </td>
  </tr>
</table>

---

## 🛠 Công nghệ

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              BIDCHAIN STACK                              │
├─────────────────┬─────────────────┬─────────────────┬───────────────────┤
│   📱 Mobile     │   🖥️ Admin      │   ⚙️ Backend    │   🔗 Blockchain   │
├─────────────────┼─────────────────┼─────────────────┼───────────────────┤
│ Flutter 3.x     │ React.js        │ Node.js 18.x    │ Ethereum          │
│ Dart            │ TypeScript      │ Express.js      │ Solidity          │
│ BLoC Pattern    │ TailwindCSS     │ MongoDB 6.x     │ Web3.js           │
│ Socket.IO       │ Chart.js        │ Socket.IO       │ Ganache           │
│ Gemini API      │ Recharts        │ JWT Auth        │ Truffle           │
└─────────────────┴─────────────────┴─────────────────┴───────────────────┘
```

---

## 📁 Cấu trúc dự án

```
bidchain/
│
├── 📱 mobile/                    # Flutter Mobile App
│   ├── lib/
│   │   ├── core/                # Theme, constants, utils
│   │   ├── features/
│   │   │   ├── auth/            # Authentication
│   │   │   ├── auction/         # Auction features
│   │   │   ├── wallet/          # Wallet management
│   │   │   └── chatbot/         # AI Chatbot (Gemini)
│   │   └── main.dart
│   └── pubspec.yaml
│
├── 🖥️ frontend/                  # React Admin Dashboard
│   ├── src/
│   │   ├── components/          # UI components
│   │   ├── pages/               # Page components
│   │   └── services/            # API services
│   └── package.json
│
├── ⚙️ backend/                    # Node.js API Server
│   ├── src/
│   │   ├── controllers/         # Request handlers
│   │   ├── models/              # MongoDB models
│   │   ├── routes/              # API routes
│   │   ├── middleware/          # Auth, validation
│   │   └── services/            # Business logic
│   └── package.json
│
├── 📜 contracts/                 # Smart Contracts
│   ├── Auction.sol
│   └── migrations/
│
└── 📄 README.md
```

---

## 🚀 Cài đặt

### Yêu cầu

| Phần mềm | Phiên bản |
|----------|-----------|
| Node.js  | >= 18.x   |
| Flutter  | >= 3.x    |
| MongoDB  | >= 6.x    |
| Ganache  | Latest    |

### Khởi chạy

<details>
<summary><strong>⚙️ Backend</strong></summary>

```bash
cd backend
npm install
cp .env.example .env
# Cấu hình MONGODB_URI, JWT_SECRET, GEMINI_API_KEY trong .env
npm run dev
```
</details>

<details>
<summary><strong>🖥️ Frontend (Admin)</strong></summary>

```bash
cd frontend
npm install
npm run dev
```
</details>

<details>
<summary><strong>📱 Mobile</strong></summary>

```bash
cd mobile
flutter pub get
flutter run
```
</details>

---

## 📱 Giao diện

### Ứng dụng di động

---

#### 📍 Màn hình chính

<p align="center">
  <img src="https://github.com/user-attachments/assets/e23e7bc2-3c5d-4edf-82ec-d5b9cc203e1e" width="280" alt="Home Screen"/>
</p>

<p align="center"><em>Hình 4.1 - Màn hình chính của ứng dụng</em></p>

Giao diện chính hiển thị danh sách các gói hàng đang được rao bán hoặc chuẩn bị đấu giá. Các gói hàng được trình bày với hình ảnh đại diện, tên sản phẩm, giá khởi điểm và thời gian còn lại. Giao diện thiết kế đơn giản, trực quan giúp người dùng nhanh chóng tiếp cận thông tin.

---

#### 📍 Màn hình hoạt động của tôi

<p align="center">
  <img src="https://github.com/user-attachments/assets/67bf5bae-8b8e-4c32-9cab-5c4682f34299" width="280" alt="My Bids"/>
  &nbsp;&nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/5c3f5fc6-112b-47a1-9986-b52384286a0f" width="280" alt="My Auctions"/>
</p>

<p align="center"><em>Hình 4.2 - Màn hình các hoạt động của tôi</em></p>

Giao diện **"Hoạt động của tôi"** giúp người dùng theo dõi lịch sử giao dịch với hai tab:
- **My Bids**: Các sản phẩm đang tham gia đấu giá
- **My Auctions**: Các tài sản do người dùng đăng bán

Thông tin hiển thị trực quan với các trạng thái realtime như "Đang diễn ra", "Đã thanh toán", "Chờ xác nhận".

---

#### 📍 Màn hình nạp tiền

<p align="center">
  <img src="https://github.com/user-attachments/assets/840dddaa-6328-4fd8-86b6-240f294c31d8" width="280" alt="Wallet"/>
  &nbsp;&nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/02c093c8-dcc4-4b83-bbc9-9718f33c7324" width="280" alt="QR Payment"/>
</p>

<p align="center"><em>Hình 4.3 - Màn hình nạp tiền vào tài khoản</em></p>

Giao diện **Ví điện tử** hiển thị số dư tổng, số dư khả dụng và lịch sử giao dịch. Khi nạp tiền, hệ thống điều hướng sang cổng thanh toán hiển thị mã QR (MoMo). Người dùng quét mã để hoàn tất, hệ thống tự động cập nhật số dư.

---

#### 📍 Màn hình chi tiết đấu giá

<p align="center">
  <img src="https://github.com/user-attachments/assets/f5189581-47fb-479f-9239-af2dd0adac15" width="280" alt="Auction Detail"/>
</p>

<p align="center"><em>Hình 4.4 - Màn hình xem chi tiết phiên đấu giá</em></p>

Giao diện chi tiết phiên đấu giá cung cấp đầy đủ thông tin: sản phẩm, lịch sử đặt giá, giá hiện tại, bước giá tối thiểu, mô tả và thời gian đếm ngược. Tích hợp nút **"Đặt giá"** và thông báo realtime khi có người nâng giá.

---

#### 📍 Màn hình trang cá nhân

<p align="center">
  <img src="./docs/images/profile.png" width="280" alt="Profile"/>
</p>

<p align="center"><em>Hình 4.5 - Màn hình trang cá nhân</em></p>

Màn hình trang cá nhân cho phép người dùng xem/chỉnh sửa thông tin hồ sơ (tên, email), kiểm tra số dư ví, xem lịch sử đấu giá, thay đổi mật khẩu và quản lý ví điện tử.

---

#### 📍 Màn hình tạo đấu giá

<p align="center">
  <img src="https://github.com/user-attachments/assets/bfc19897-1bd1-4449-8721-9afd8454414e" width="280" alt="Create Auction"/>
</p>

<p align="center"><em>Hình 4.6 - Màn hình tạo đấu giá</em></p>

Giao diện tạo phiên đấu giá với các trường: tên gói hàng, mô tả, giá khởi điểm, bước giá, thời gian bắt đầu/kết thúc và tải hình ảnh. Sau khi hoàn tất, phiên được gửi đến hệ thống kiểm duyệt trước khi hiển thị công khai.

---

#### 📍 AI Chatbot (Gemini)

<p align="center">
  <img src="https://github.com/user-attachments/assets/b6d1fe88-cfea-42eb-8f8a-b38f5810ffec" width="280" alt="Chatbot"/>
  &nbsp;&nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/298bc478-1903-46e0-9900-c59c695064b6" width="280" alt="Chatbot Response"/>
</p>

<p align="center"><em>Hình 4.7 - AI Chatbot hỗ trợ người dùng</em></p>

Tính năng **AI Chatbot** tích hợp **Google Gemini API** hỗ trợ người dùng:
- 💬 Trả lời câu hỏi về đấu giá
- 📊 Tư vấn chiến lược đặt giá
- 🔍 Hướng dẫn sử dụng ứng dụng
- 💡 Gợi ý sản phẩm phù hợp

---

### Trang quản trị

---

#### 📍 Dashboard quản lý

<p align="center">
  <img src="https://github.com/user-attachments/assets/6585ed78-8d6f-495b-bf89-d9aaa947c85a" width="800" alt="Admin Dashboard"/>
</p>

<p align="center"><em>Hình 4.8 - Màn hình Dashboard quản lý</em></p>

Giao diện **Dashboard** tổng quan hiển thị các thông số vận hành:
- **KPI**: Tổng giao dịch (ETH), số người dùng, phiên đấu giá hoạt động
- **Biểu đồ đường**: Biến động doanh số theo tháng
- **Biểu đồ tròn**: Thống kê trạng thái phiên đấu giá

---

#### 📍 Quản lý phiên đấu giá

<p align="center">
  <img src="https://github.com/user-attachments/assets/4234599c-4fda-4034-b8aa-cc086a9c7a86" width="800" alt="Auctions Management"/>
</p>

<p align="center"><em>Hình 4.9 - Màn hình quản lý phiên đấu giá</em></p>

Giao diện **Quản lý phiên đấu giá** tập trung toàn bộ dữ liệu: tổng số phiên, số phiên hoạt động, tổng giá trị giao dịch. Danh sách chi tiết hiển thị hình ảnh, người bán, giá hiện tại, thời gian còn lại và trạng thái (Active, Pending, Settled...).

---

#### 📍 Quản lý người dùng

<p align="center">
  <img src="https://github.com/user-attachments/assets/7a8e6a93-b7d8-48e4-aee6-c965902ffbf6" width="800" alt="Users Management"/>
</p>

<p align="center"><em>Hình 4.10 - Màn hình quản lý người dùng</em></p>

Giao diện **Quản lý người dùng** hiển thị KPI (tổng người dùng, đang hoạt động, mới trong tuần) và danh sách chi tiết gồm email, địa chỉ ví Blockchain, số dư, vai trò. Cột Actions cho phép xem, chỉnh sửa hoặc khóa tài khoản.

---

<p align="center">
  <strong>Made with ❤️ by BidChain Team</strong>
</p>

<p align="center">
  <a href="#-bidchain">⬆ Về đầu trang</a>
</p>
