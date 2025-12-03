# 📦 Chatbot & Profile Backup

Folder này chứa backup của tất cả các file liên quan đến **Chatbot** và **Profile Page** để có thể restore lại nếu team members revert thay đổi.

## 📋 Danh sách File Backup

### Profile Page (1 file)
- `frontend/lib/presentation/pages/profile/profile_page.dart`

### Chatbot - Pages (1 file)
- `frontend/lib/presentation/pages/chat/chat_screen.dart`

### Chatbot - Widgets (3 files)
- `frontend/lib/presentation/widgets/chat/chat_bubble_wrapper.dart`
- `frontend/lib/presentation/widgets/chat/floating_chat_bubble.dart`
- `frontend/lib/presentation/widgets/chat/message_bubble.dart`

### Chatbot - Bloc (3 files)
- `frontend/lib/presentation/bloc/chat/chat_bloc.dart`
- `frontend/lib/presentation/bloc/chat/chat_event.dart`
- `frontend/lib/presentation/bloc/chat/chat_state.dart`

### Chatbot - Data Layer (1 file)
- `frontend/lib/data/models/chat_message_model.dart`

### Chatbot - Domain Layer (1 file)
- `frontend/lib/domain/entities/chat_message_entity.dart`

### Chatbot - Services (1 file)
- `frontend/lib/core/services/gemini_service.dart`

### Chatbot - DI Container (1 file)
- `frontend/lib/core/di/injection_container.dart`

### Chatbot - Config (1 file)
- `frontend/lib/config/constants/gemini_config.dart`

### Integration Files (2 files)
- `frontend/lib/main.dart`
- `frontend/pubspec.yaml`

## 🚀 Cách Sử Dụng

### Khi cần restore code:
1. Nếu team members revert hoặc pull về phiên bản cũ, code sẽ mất
2. Copy các file từ folder `BACKUP_CHATBOT_PROFILE/frontend/lib/` vào `frontend/lib/` của project
3. Ensure dependencies trong `pubspec.yaml` đã được cập nhật (hoặc copy file cũ)
4. Chạy `flutter pub get` để cài đặt dependencies
5. Chạy ứng dụng lại: `flutter run -d chrome`

### Cấu trúc cây:
```
BACKUP_CHATBOT_PROFILE/
└── frontend/
    ├── pubspec.yaml
    └── lib/
        ├── main.dart
        ├── config/
        │   └── constants/
        │       └── gemini_config.dart
        ├── core/
        │   ├── di/
        │   │   └── injection_container.dart
        │   └── services/
        │       └── gemini_service.dart
        ├── data/
        │   └── models/
        │       └── chat_message_model.dart
        ├── domain/
        │   └── entities/
        │       └── chat_message_entity.dart
        └── presentation/
            ├── bloc/
            │   └── chat/
            │       ├── chat_bloc.dart
            │       ├── chat_event.dart
            │       └── chat_state.dart
            ├── pages/
            │   ├── chat/
            │   │   └── chat_screen.dart
            │   └── profile/
            │       └── profile_page.dart
            └── widgets/
                └── chat/
                    ├── chat_bubble_wrapper.dart
                    ├── floating_chat_bubble.dart
                    └── message_bubble.dart
```

## ✨ Tính Năng Chatbot
- ✅ Floating chat bubble (bottom: 90, right: 20)
- ✅ Persistent chat history (lưu trong SharedPreferences)
- ✅ Gemini API integration (REST v1 + gemini-2.0-flash)
- ✅ Message color feedback (button changes color on text input)
- ✅ Welcome message on first open
- ✅ Clear chat history
- ✅ Loading states

## 📝 Commit Reference
- Main commit: `0e80cc7` - Persistent chat history with local storage
- Branch: `features/chatbot` → merged to `develop`

## ⚙️ Configuration
Ensure `.env` file có:
```
GEMINI_API_KEY=your_api_key_here
ENVIRONMENT=development
```

---
**Last Updated:** December 2, 2025
**Status:** ✅ All files backed up and ready to restore
