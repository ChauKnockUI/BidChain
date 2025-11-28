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
}