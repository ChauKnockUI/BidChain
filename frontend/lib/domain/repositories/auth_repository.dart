import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> register({
    required String username,
    required String password,
    required String email,
    required String fullName,
    String role = 'USER',
  });

  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, String?>> getToken();

  Future<Either<Failure, void>> saveToken(String token);

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
  });

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
