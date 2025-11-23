import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginEvent({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

class AuthRegisterEvent extends AuthEvent {
  final String username;
  final String password;

  const AuthRegisterEvent({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}