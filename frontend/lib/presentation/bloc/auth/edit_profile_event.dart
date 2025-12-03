import 'package:equatable/equatable.dart';

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event để load thông tin user hiện tại
class LoadUserDataEvent extends EditProfileEvent {
  const LoadUserDataEvent();
}

/// Event để update profile
class UpdateProfileEvent extends EditProfileEvent {
  final String? fullName;
  final String? username;
  final String? email;
  final String? phoneNumber;

  const UpdateProfileEvent({
    this.fullName,
    this.username,
    this.email,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullName, username, email, phoneNumber];
}

/// Event để change password
class ChangePasswordEvent extends EditProfileEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}

/// Event để upload avatar
class UploadAvatarEvent extends EditProfileEvent {
  final String imagePath;

  const UploadAvatarEvent({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

/// Event để delete avatar
class DeleteAvatarEvent extends EditProfileEvent {
  const DeleteAvatarEvent();
}

/// Event để reset form
class ResetFormEvent extends EditProfileEvent {
  const ResetFormEvent();
}
