import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entities/user_entity.dart';


abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthSuccessState extends AuthState {
  final UserEntity user;
  final String message;

  const AuthSuccessState({
    required this.user,
    required this.message,
  });

  @override
  List<Object?> get props => [user, message];
}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthUnauthorizedState extends AuthState {
  const AuthUnauthorizedState();
}