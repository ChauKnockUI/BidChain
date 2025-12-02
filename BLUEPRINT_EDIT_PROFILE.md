# 📋 BLUEPRINT: Edit Profile Feature

## Tổng Quan
Tạo UI Profile mới theo thiết kế với các tính năng:
- ✅ Edit username, fullname, email, phone
- ✅ Upload/Delete avatar
- ✅ Change password
- ✅ Tách biệt logic để tránh conflict
- ✅ Reuse components & colors

## Cấu Trúc File Cần Tạo

```
frontend/lib/
├── presentation/
│   ├── bloc/auth/
│   │   ├── edit_profile_bloc.dart       (Business logic)
│   │   ├── edit_profile_event.dart      (5 events)
│   │   └── edit_profile_state.dart      (5 states)
│   ├── pages/profile/
│   │   ├── edit_profile_page.dart       (Main UI)
│   │   └── widgets/
│   │       └── password_change_form.dart
│   └── widgets/profile/
│       └── avatar_picker.dart
├── domain/usecases/
│   └── auth_usecase.dart
└── data/datasources/remote/
    └── [Update auth_remote_datasource.dart]
```

## Events

- LoadUserDataEvent()
- UpdateProfileEvent(fullName, username, email, phoneNumber)
- ChangePasswordEvent(currentPassword, newPassword, confirmPassword)
- UploadAvatarEvent(imagePath)
- DeleteAvatarEvent()
- ResetFormEvent()

## States

- EditProfileInitial
- EditProfileLoading
- UserDataLoaded(user)
- ProfileUpdateSuccess(updatedUser, message)
- AvatarUploadSuccess(avatarUrl)
- PasswordChangeSuccess(message)
- EditProfileError(message, previousState)
- FormValidationError(errors)

## Validation Rules

**Profile:**
- Username: Not empty
- Email: Valid format
- Full Name: Not empty

**Password:**
- Current: Not empty
- New: 6+ chars, different from current
- Confirm: Must match new

## Color & Style

- Background: AppColors.white
- Border/Input: AppColors.tertiary
- Focus/Button: AppColors.accent (black)
- Text: AppTextStyles (Lexend font)

## Integration

1. Update InjectionContainer with EditProfileBloc
2. Add route in route_generator.dart
3. Update profile_page.dart with edit button
4. Ensure no profile_page.dart modifications (only add edit nav)

## Files to Create

✅ edit_profile_event.dart
✅ edit_profile_state.dart
✅ edit_profile_bloc.dart
✅ auth_usecase.dart (facade)
✅ edit_profile_page.dart
✅ password_change_form.dart
✅ avatar_picker.dart

---

**Ready to implement when needed. Focus on clean separation to avoid conflicts.**
