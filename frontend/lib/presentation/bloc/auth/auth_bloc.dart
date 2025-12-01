import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/socket_service.dart';
import 'package:frontend/domain/usecases/auth/login_usecase.dart';
import 'package:frontend/domain/usecases/auth/register_usecase.dart';
import 'package:frontend/domain/usecases/auth/update_profile_usecase.dart';
import 'package:frontend/domain/usecases/auth/change_password_usecase.dart';
import 'package:frontend/domain/usecases/auth/logout_usecase.dart';
import 'package:frontend/main.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(const AuthInitialState()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthCheckStatusEvent>(_onCheckStatus);
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    final result = await loginUseCase(
      username: event.username,
      password: event.password,
    );

    result.fold((failure) => emit(AuthErrorState(message: failure.message)), (
      user,
    ) {
      // Connect Socket.IO after successful login
      _socketService.connect(user.id, baseUrl: ApiConfig.baseUrl);

      emit(AuthSuccessState(user: user, message: 'Login successful'));
    });
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());

    final result = await registerUseCase(
      username: event.username,
      password: event.password,
      email: event.email,
      fullName: event.fullName,
      role: 'USER',
    );

    result.fold((failure) => emit(AuthErrorState(message: failure.message)), (
      user,
    ) {
      // Connect Socket.IO after successful registration
      _socketService.connect(user.id, baseUrl: ApiConfig.baseUrl);

      emit(AuthSuccessState(user: user, message: 'Registration successful'));
    });
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthInitialState());
  }

  Future<void> _onCheckStatus(AuthCheckStatusEvent event, Emitter<AuthState> emit) async {
    // Implementation for checking if user has valid token on app start
    // This can be expanded to validate stored tokens
  }
}
