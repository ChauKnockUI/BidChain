import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginEvent({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

class AuthRegisterEvent extends AuthEvent {
  final String username;
  final String password;
  final String email;
  final String fullName;

  const AuthRegisterEvent({
    required this.username,
    required this.password,
    required this.email,
    required this.fullName,
  });

  @override
  List<Object?> get props => [username, password, email, fullName];
}

class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}

class UpdateUserEvent extends AuthEvent {
  final UserEntity user;

  const UpdateUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUpdateProfileEvent extends AuthEvent {
  final String? fullName;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? country;
  final String? city;
  final String? district;
  final String? address;
  final String? bio;

  const AuthUpdateProfileEvent({
    this.fullName,
    this.username,
    this.email,
    this.phoneNumber,
    this.country,
    this.city,
    this.district,
    this.address,
    this.bio,
  });

  @override
  List<Object?> get props => [
    fullName,
    username,
    email,
    phoneNumber,
    country,
    city,
    district,
    address,
    bio,
  ];
}

class AuthChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

class AuthUploadAvatarEvent extends AuthEvent {
  final String filePath;

  const AuthUploadAvatarEvent({required this.filePath});

  @override
  List<Object> get props => [filePath];
}
