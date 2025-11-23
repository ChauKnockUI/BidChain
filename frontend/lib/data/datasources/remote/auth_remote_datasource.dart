import 'package:dio/dio.dart';
import '../../../config/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> register({
    required String username,
    required String password,
  });

  Future<AuthResponse> login({
    required String username,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<AuthResponse> register({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        ApiConstants.register,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

class AuthResponse {
  final String token;
  final UserModel user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    return AuthResponse(
      token: json['token'] ?? json['access_token'] ?? '',
      user: UserModel(
        id: user['_id'] ?? user['id'] ?? '',
        username: user['username'] ?? '',
        ethAddress: user['ethAddress'] ?? user['wallet'] ?? '',
        createdAt: user['createdAt'] != null
            ? DateTime.parse(user['createdAt'])
            : DateTime.now(),
      ),
    );
  }
}
