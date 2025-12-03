import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> register({
    required String username,
    required String password,
    required String email,
    required String fullName,
    String role = 'USER',
  }) async {
    try {
      final response = await remoteDataSource.register(
        username: username,
        password: password,
        email: email,
        fullName: fullName,
        role: role,
      );

      await localDataSource.saveToken(response.token);
      await localDataSource.saveUser(response.user);

      return Right(response.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(
        username: username,
        password: password,
      );

      await localDataSource.saveToken(response.token);
      await localDataSource.saveUser(response.user);

      return Right(response.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearAll();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveToken(String token) async {
    try {
      await localDataSource.saveToken(token);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
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
    try {
      final response = await remoteDataSource.updateProfile(
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

      // Update local storage with new user info
      await localDataSource.saveUser(response.user);

      return Right(response.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
