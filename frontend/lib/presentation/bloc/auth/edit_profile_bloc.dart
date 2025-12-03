import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/auth_usecase.dart';
import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final AuthUseCase authUseCase;

  EditProfileBloc({required this.authUseCase})
    : super(const EditProfileInitial()) {
    on<LoadUserDataEvent>(_onLoadUserData);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordEvent>(_onChangePassword);
    on<UploadAvatarEvent>(_onUploadAvatar);
    on<DeleteAvatarEvent>(_onDeleteAvatar);
    on<ResetFormEvent>(_onResetForm);
  }

  /// Load user data
  Future<void> _onLoadUserData(
    LoadUserDataEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    try {
      emit(const EditProfileLoading());
      final result = await authUseCase.getMe();
      result.fold(
        (failure) => emit(
          EditProfileError(message: failure.message, previousState: state),
        ),
        (user) => emit(UserDataLoaded(user: user)),
      );
    } catch (e) {
      emit(
        EditProfileError(
          message: 'Failed to load user data: $e',
          previousState: state,
        ),
      );
    }
  }

  /// Update profile
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    try {
      // Validation
      final errors = _validateProfileInput(event);
      if (errors.isNotEmpty) {
        emit(FormValidationError(errors: errors));
        return;
      }

      emit(const EditProfileLoading());

      final result = await authUseCase.updateProfile(
        fullName: event.fullName,
        username: event.username,
        email: event.email,
        phoneNumber: event.phoneNumber,
      );

      result.fold(
        (failure) => emit(
          EditProfileError(message: failure.message, previousState: state),
        ),
        (user) => emit(
          ProfileUpdateSuccess(
            updatedUser: user,
            message: 'Profile updated successfully',
          ),
        ),
      );
    } catch (e) {
      emit(
        EditProfileError(
          message: 'Failed to update profile: $e',
          previousState: state,
        ),
      );
    }
  }

  /// Change password
  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    try {
      // Validation
      final errors = _validatePasswordInput(event);
      if (errors.isNotEmpty) {
        emit(FormValidationError(errors: errors));
        return;
      }

      emit(const EditProfileLoading());

      final result = await authUseCase.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );

      result.fold(
        (failure) => emit(
          EditProfileError(message: failure.message, previousState: state),
        ),
        (_) => emit(
          const PasswordChangeSuccess(message: 'Password changed successfully'),
        ),
      );
    } catch (e) {
      emit(
        EditProfileError(
          message: 'Failed to change password: $e',
          previousState: state,
        ),
      );
    }
  }

  /// Upload avatar
  Future<void> _onUploadAvatar(
    UploadAvatarEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    try {
      emit(const EditProfileLoading());

      final result = await authUseCase.uploadAvatar(imagePath: event.imagePath);

      result.fold(
        (failure) => emit(
          EditProfileError(message: failure.message, previousState: state),
        ),
        (avatarUrl) => emit(AvatarUploadSuccess(avatarUrl: avatarUrl)),
      );
    } catch (e) {
      emit(
        EditProfileError(
          message: 'Failed to upload avatar: $e',
          previousState: state,
        ),
      );
    }
  }

  /// Delete avatar
  Future<void> _onDeleteAvatar(
    DeleteAvatarEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    try {
      emit(const EditProfileLoading());

      final result = await authUseCase.deleteAvatar();

      result.fold(
        (failure) => emit(
          EditProfileError(message: failure.message, previousState: state),
        ),
        (_) => emit(const AvatarDeleteSuccess()),
      );
    } catch (e) {
      emit(
        EditProfileError(
          message: 'Failed to delete avatar: $e',
          previousState: state,
        ),
      );
    }
  }

  /// Reset form
  Future<void> _onResetForm(
    ResetFormEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(const EditProfileInitial());
  }

  /// Validate profile input
  Map<String, String> _validateProfileInput(UpdateProfileEvent event) {
    final errors = <String, String>{};

    if (event.username != null && event.username!.isEmpty) {
      errors['username'] = 'Username is required';
    }

    if (event.fullName != null && event.fullName!.isEmpty) {
      errors['fullName'] = 'Full name is required';
    }

    if (event.email != null) {
      if (event.email!.isEmpty) {
        errors['email'] = 'Email is required';
      } else if (!_isValidEmail(event.email!)) {
        errors['email'] = 'Invalid email format';
      }
    }

    if (event.phoneNumber != null && event.phoneNumber!.isEmpty) {
      errors['phoneNumber'] = 'Phone number is required';
    }

    return errors;
  }

  /// Validate password input
  Map<String, String> _validatePasswordInput(ChangePasswordEvent event) {
    final errors = <String, String>{};

    if (event.currentPassword.isEmpty) {
      errors['currentPassword'] = 'Current password is required';
    }

    if (event.newPassword.isEmpty) {
      errors['newPassword'] = 'New password is required';
    } else if (event.newPassword.length < 6) {
      errors['newPassword'] = 'Password must be at least 6 characters';
    }

    if (event.confirmPassword.isEmpty) {
      errors['confirmPassword'] = 'Confirm password is required';
    } else if (event.newPassword != event.confirmPassword) {
      errors['confirmPassword'] = 'Passwords do not match';
    }

    if (event.currentPassword == event.newPassword) {
      errors['newPassword'] =
          'New password must be different from current password';
    }

    return errors;
  }

  /// Check if email is valid
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
