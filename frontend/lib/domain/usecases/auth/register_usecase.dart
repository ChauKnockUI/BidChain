import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/domain/entities/user_entity.dart';
import 'package:frontend/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String username,
    required String password,
    required String email,
    required String fullName,
    String role = 'USER',
  }) {
    return repository.register(
      username: username,
      password: password,
      email: email,
      fullName: fullName,
      role: role,
    );
  }
}