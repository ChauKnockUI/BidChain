import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/socket_service.dart';
import 'package:frontend/domain/usecases/auth/login_usecase.dart';
import 'package:frontend/domain/usecases/auth/register_usecase.dart';
import 'package:frontend/main.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final SocketService _socketService = SocketService();

  AuthBloc({required this.loginUseCase, required this.registerUseCase})
    : super(const AuthInitialState()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthUpdateUserEvent>(_onUpdateUser);

    // Listen for balance updates from Socket.IO
    _socketService.onBalanceUpdated = (updatedUser) {
      add(AuthUpdateUserEvent(updatedUser));
      print('💰 Balance updated via Socket.IO: ${updatedUser.balanceEth} ETH');
    };
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
    // Disconnect Socket.IO on logout
    _socketService.disconnect();
    emit(const AuthInitialState());
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Manually fetch fresh user data
    await _socketService.fetchAndUpdateBalance();
  }

  Future<void> _onUpdateUser(
    AuthUpdateUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthSuccessState) {
      emit(
        AuthSuccessState(
          user: event.user,
          message: (state as AuthSuccessState).message,
        ),
      );
    }
  }
}
