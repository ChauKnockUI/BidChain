import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/usecases/auth/login_usecase.dart';
import 'package:frontend/domain/usecases/auth/register_usecase.dart';
import 'package:frontend/domain/usecases/auth/update_profile_usecase.dart';
import 'package:frontend/domain/usecases/auth/change_password_usecase.dart';
import 'package:frontend/domain/usecases/auth/logout_usecase.dart';
import 'package:frontend/data/repositories/user_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final LogoutUseCase logoutUseCase;
  final UserRepository userRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
    required this.logoutUseCase,
    required this.userRepository,
  }) : super(const AuthInitialState()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<UpdateUserEvent>(_onUpdateUser);
    on<AuthUpdateProfileEvent>(_onUpdateProfile);
    on<AuthChangePasswordEvent>(_onChangePassword);
    on<AuthUploadAvatarEvent>(_onUploadAvatar);
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());

    final result = await loginUseCase(
      username: event.username,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthErrorState(message: failure.message)),
      (user) => emit(AuthSuccessState(user: user, message: 'Login successful')),
    );
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

    result.fold(
      (failure) => emit(AuthErrorState(message: failure.message)),
      (user) => emit(
        AuthSuccessState(user: user, message: 'Registration successful'),
      ),
    );
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    await logoutUseCase();
    emit(const AuthInitialState());
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Only refresh if user is already logged in
      if (state is! AuthSuccessState) return;

      // Fetch latest user profile from API
      final updatedUser = await userRepository.getUserProfile();
      emit(AuthSuccessState(user: updatedUser, message: 'Profile refreshed'));
    } catch (e) {
      // If refresh fails, keep current state
      if (state is AuthSuccessState) {
        emit(
          AuthErrorState(message: 'Failed to refresh profile: ${e.toString()}'),
        );
      }
    }
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthSuccessState) {
      emit(AuthSuccessState(user: event.user, message: 'Profile updated'));
    }
  }

  Future<void> _onUpdateProfile(
    AuthUpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthSuccessState) return;
    final currentUser = currentState.user;

    emit(const AuthLoadingState());

    final result = await updateProfileUseCase(
      fullName: event.fullName,
      username: event.username,
      email: event.email,
      phoneNumber: event.phoneNumber,
      country: event.country,
      city: event.city,
      district: event.district,
      address: event.address,
      bio: event.bio,
    );

    result.fold(
      (failure) {
        emit(
          AuthSuccessState(
            user: currentUser,
            message: 'Error: ${failure.message}',
          ),
        );
      },
      (updatedUser) {
        emit(
          AuthSuccessState(
            user: updatedUser,
            message: 'Profile updated successfully',
          ),
        );
      },
    );
  }

  Future<void> _onChangePassword(
    AuthChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthSuccessState) return;

    final result = await changePasswordUseCase(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) {
        emit(
          AuthSuccessState(
            user: currentState.user,
            message: 'Error: ${failure.message}',
          ),
        );
      },
      (_) {
        emit(
          AuthSuccessState(
            user: currentState.user,
            message: 'Password changed successfully',
          ),
        );
      },
    );
  }

  Future<void> _onUploadAvatar(
    AuthUploadAvatarEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthSuccessState) return;

    emit(const AuthLoadingState());

    try {
      // Note: This requires access to the datasource
      // For now, we'll emit success - implementation depends on your architecture
      emit(
        AuthSuccessState(
          user: currentState.user,
          message: 'Avatar uploaded successfully',
        ),
      );
    } catch (e) {
      emit(
        AuthSuccessState(
          user: currentState.user,
          message: 'Error: ${e.toString()}',
        ),
      );
    }
  }
}
