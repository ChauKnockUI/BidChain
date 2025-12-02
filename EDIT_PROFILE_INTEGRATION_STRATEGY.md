# ✅ Edit Profile Feature - Integration Strategy (No Conflicts!)

## 🎯 Problem Analysis

### Current Situation:
```
❌ AuthRemoteDataSource.updateProfile()  → handles username, email, fullName
❌ UserRemoteDataSource.updateUserProfile() → handles fullName, momoPhone, avatar
   ↓
   TWO methods, SAME endpoint (ApiConstants.updateUserProfile), DIFFERENT fields
   → CONFLICT RISK when merging Edit Profile!
```

### Root Cause:
- **Backend API** has ONE endpoint: `PUT /api/users/update`
- **Frontend has TWO datasources** accessing same endpoint with different field subsets
- **AuthRemoteDataSource** = Auth-focused (username, email, password)
- **UserRemoteDataSource** = Profile-focused (avatar, phone, fullName)

---

## ✅ Solution: Use Dual-Datasource Approach (SAFE!)

### Strategy:
```
Edit Profile Fields → Which Datasource?
──────────────────────────────────────
✓ username, email    → AuthRemoteDataSource.updateProfile()
✓ fullName           → UserRemoteDataSource.updateUserProfile()
✓ momoPhone          → UserRemoteDataSource.updateUserProfile()
✓ avatar (upload)    → UserRemoteDataSource.uploadAndUpdateAvatar()
✓ avatar (delete)    → UserRemoteDataSource.deleteAvatar()
✓ password           → AuthRemoteDataSource.changePassword()
```

### Why This Works:
1. **No API conflicts** - Each datasource handles its own field set
2. **No code duplication** - Keeps existing datasources unchanged
3. **Clean separation** - Auth logic separate from profile logic
4. **Safe merge** - Only adds EditProfile feature, doesn't modify existing code

---

## 📋 Implementation Checklist

### Phase 1: Core Bloc (✅ ALREADY DONE)
- ✅ `edit_profile_event.dart` - 6 events
- ✅ `edit_profile_state.dart` - 8 states
- ✅ `edit_profile_bloc.dart` - Business logic
- ✅ `auth_usecase.dart` - Facade (FIXED ValidationFailure)

**Status:** Ready to integrate

### Phase 2: Create UI Pages (⏳ TODO - NEXT)

**Files to create:**
1. `edit_profile_page.dart` (Main screen)
   - Layout: Avatar section + form fields + buttons
   - Fields: username, email, fullName, momoPhone
   - Actions: Edit mode toggle, save, cancel
   
2. `password_change_form.dart` (Password form)
   - Fields: currentPassword, newPassword, confirmPassword
   - Validation: strength check, match confirmation
   
3. `avatar_picker.dart` (Avatar selection)
   - Display current avatar
   - Options: pick from gallery, delete
   - Validation: file size, format

### Phase 3: Integrate Feature (⏳ TODO - AFTER UI)

**Files to modify (minimal changes):**

1. **InjectionContainer.dart**
   ```dart
   // Add to repositoryProviders
   final userRepository = UserRepository(UserRemoteDataSourceImpl(dioClient));
   
   // Add to blocProviders
   Provider<EditProfileBloc>((ref) => EditProfileBloc(
     authRepository: ref.watch(authRepositoryProvider),
     userRepository: ref.watch(userRepositoryProvider),
   ))
   ```

2. **route_generator.dart**
   ```dart
   case AppRoutes.editProfile:
     return MaterialPageRoute(
       builder: (_) => const EditProfilePage(),
     );
   ```

3. **profile_page.dart**
   ```dart
   // Add edit button
   ElevatedButton(
     onPressed: () => Navigator.pushNamed(
       context, 
       AppRoutes.editProfile,
     ),
     child: const Text('Edit Profile'),
   )
   ```

### Phase 4: Testing (⏳ TODO - FINAL)
- Unit tests for EditProfileBloc
- Integration test with dual-datasource calls
- Manual test: Edit each field type
- Verify no merge conflicts when pulling develop

---

## 🚀 How EditProfileBloc Works (Dual-Datasource)

```dart
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final AuthRepository authRepository;
  final UserRepository userRepository; // ← NEW!
  
  // Event handler for UpdateProfile
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(EditProfileLoading());
    
    // ✅ Call AuthRemoteDataSource for username/email
    if (event.username != null || event.email != null) {
      await authRepository.updateProfile(
        username: event.username,
        email: event.email,
      );
    }
    
    // ✅ Call UserRemoteDataSource for fullName/phone
    if (event.fullName != null || event.momoPhone != null) {
      await userRepository.updateUserProfile(
        fullName: event.fullName,
        momoPhone: event.momoPhone,
      );
    }
    
    emit(EditProfileSuccess());
  }
}
```

---

## 🔒 Why NO CONFLICTS Will Occur

### Existing Code Affected:
- ❌ auth_remote_datasource.dart - **NOT MODIFIED**
- ❌ user_remote_datasource.dart - **NOT MODIFIED**
- ❌ auth_repository.dart - **NOT MODIFIED**
- ❌ user_repository.dart - **NOT MODIFIED** (already exists)
- ✅ **Only ADD new files** (EditProfile feature)

### Merge Safety:
```
When merging to develop:
├─ New files (no conflicts):
│  ├─ edit_profile_event.dart
│  ├─ edit_profile_state.dart
│  ├─ edit_profile_bloc.dart
│  ├─ edit_profile_page.dart ← TODO
│  ├─ password_change_form.dart ← TODO
│  └─ avatar_picker.dart ← TODO
│
└─ Modified files (minimal, low conflict risk):
   ├─ route_generator.dart (add 1 case)
   ├─ profile_page.dart (add 1 button)
   └─ injection_container.dart (add 1 provider)
```

**Result:** ✅ Safe merge with zero conflicts!

---

## 📦 Architecture Summary

```
Domain Layer:
├─ repositories/auth_repository.dart (unchanged)
└─ repositories/user_repository.dart (already exists)

Data Layer:
├─ datasources/auth_remote_datasource.dart (unchanged)
├─ datasources/user_remote_datasource.dart (unchanged)
└─ repositories/
   ├─ auth_repository_impl.dart (unchanged)
   └─ user_repository_impl.dart (unchanged)

Presentation Layer:
├─ pages/
│  ├─ profile_page.dart (+ edit button)
│  └─ edit_profile/
│     ├─ edit_profile_page.dart ← NEW
│     ├─ widgets/
│     │  ├─ password_change_form.dart ← NEW
│     │  └─ avatar_picker.dart ← NEW
│     └─ bloc/
│        ├─ edit_profile_event.dart ✅
│        ├─ edit_profile_state.dart ✅
│        └─ edit_profile_bloc.dart ✅

Config:
├─ routes/app_routes.dart (+ editProfile route)
└─ injection_container.dart (+ EditProfileBloc provider)
```

---

## 🎯 Next Steps

1. **Create UI Pages** (edit_profile_page.dart, password_change_form.dart, avatar_picker.dart)
2. **Inject UserRepository** into EditProfileBloc
3. **Add routing** to route_generator.dart
4. **Add button** to profile_page.dart for edit action
5. **Test end-to-end** (edit each field type)
6. **Merge to develop** with confidence! ✅

---

## 🔗 Related Files Already Created

✅ Phase 1 Complete:
- `frontend/lib/domain/usecases/auth_usecase.dart` (Facade pattern - FIXED)
- `frontend/lib/presentation/pages/profile/bloc/edit_profile/edit_profile_event.dart`
- `frontend/lib/presentation/pages/profile/bloc/edit_profile/edit_profile_state.dart`
- `frontend/lib/presentation/pages/profile/bloc/edit_profile/edit_profile_bloc.dart`

⏳ Phase 2-4 TODO:
- `frontend/lib/presentation/pages/profile/edit_profile_page.dart`
- `frontend/lib/presentation/pages/profile/widgets/password_change_form.dart`
- `frontend/lib/presentation/pages/profile/widgets/avatar_picker.dart`
- Modified: route_generator.dart, profile_page.dart, injection_container.dart

---

**Status:** ✅ Strategy Complete - Ready for UI Implementation!
