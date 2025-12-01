import 'package:equatable/equatable.dart';
import 'package:frontend/data/models/user_model.dart';

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

class AuthUpdateUserEvent extends AuthEvent {
  final UserModel user;
  const AuthUpdateUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}
