import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/domain/entities/user_entity.dart';
import 'package:frontend/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String username,
    required String password,
  }) {
    return repository.login(username: username, password: password);
  }
}