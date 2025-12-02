import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

/// Loading state
class EditProfileLoading extends EditProfileState {
  const EditProfileLoading();
}

/// User data loaded
class UserDataLoaded extends EditProfileState {
  final UserEntity user;

  const UserDataLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Profile updated successfully
class ProfileUpdateSuccess extends EditProfileState {
  final UserEntity updatedUser;
  final String message;

  const ProfileUpdateSuccess({
    required this.updatedUser,
    required this.message,
  });

  @override
  List<Object?> get props => [updatedUser, message];
}

/// Avatar uploaded successfully
class AvatarUploadSuccess extends EditProfileState {
  final String avatarUrl;

  const AvatarUploadSuccess({required this.avatarUrl});

  @override
  List<Object?> get props => [avatarUrl];
}

/// Avatar deleted successfully
class AvatarDeleteSuccess extends EditProfileState {
  const AvatarDeleteSuccess();
}

/// Password changed successfully
class PasswordChangeSuccess extends EditProfileState {
  final String message;

  const PasswordChangeSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Error state
class EditProfileError extends EditProfileState {
  final String message;
  final EditProfileState previousState;

  const EditProfileError({required this.message, required this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

/// Form validation state
class FormValidationError extends EditProfileState {
  final Map<String, String> errors;

  const FormValidationError({required this.errors});

  @override
  List<Object?> get props => [errors];
}
