import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class AuthUseCase {
  final AuthRepository authRepository;

  AuthUseCase({required this.authRepository});

  /// Register user
  Future<Either<Failure, UserEntity>> register({
    required String username,
    required String password,
    required String email,
    required String fullName,
    String role = 'USER',
  }) async {
    return await authRepository.register(
      username: username,
      password: password,
      email: email,
      fullName: fullName,
      role: role,
    );
  }

  /// Login user
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  }) async {
    return await authRepository.login(username: username, password: password);
  }

  /// Logout user
  Future<Either<Failure, void>> logout() async {
    return await authRepository.logout();
  }

  /// Get stored token
  Future<Either<Failure, String?>> getToken() async {
    return await authRepository.getToken();
  }

  /// Save token
  Future<Either<Failure, void>> saveToken(String token) async {
    return await authRepository.saveToken(token);
  }

  /// Get current user (me)
  Future<Either<Failure, UserEntity>> getMe() async {
    // This should be implemented when backend API is ready
    // For now, return a validation failure
    return Left(ValidationFailure(message: 'getMe not implemented'));
  }

  /// Update profile
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? username,
    String? email,
    String? phoneNumber,
    String? country,
    String? city,
    String? district,
    String? address,
    String? bio,
  }) async {
    return await authRepository.updateProfile(
      fullName: fullName,
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      country: country,
      city: city,
      district: district,
      address: address,
      bio: bio,
    );
  }

  /// Change password
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  /// Upload avatar
  Future<Either<Failure, String>> uploadAvatar({
    required String imagePath,
  }) async {
    // This should be implemented when backend API is ready
    return Left(ValidationFailure(message: 'Upload avatar not implemented'));
  }

  /// Delete avatar
  Future<Either<Failure, void>> deleteAvatar() async {
    // This should be implemented when backend API is ready
    return Left(ValidationFailure(message: 'Delete avatar not implemented'));
  }
}
