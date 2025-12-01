import '../../../config/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> register({
    required String username,
    required String password,
    required String email,
    required String fullName,
    String role = 'USER',
  });

  Future<AuthResponse> login({
    required String username,
    required String password,
  });

  Future<AuthResponse> updateProfile({
    String? fullName,
    String? username,
    String? email,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<AuthResponse> register({
    required String username,
    required String password,
    required String email,
    required String fullName,
    String role = 'USER',
  }) async {
    try {
      final response = await dioClient.post(
        ApiConstants.register,
        data: {
          'username': username,
          'password': password,
          'email': email,
          'full_name': fullName,
          'role': role,
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

  @override
  Future<AuthResponse> updateProfile({
    String? fullName,
    String? username,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (username != null) data['username'] = username;
      if (email != null) data['email'] = email;

      final response = await dioClient.put(
        ApiConstants.updateUserProfile,
        data: data,
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Update failed',
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
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await dioClient.put(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (error) {
      throw ServerException(
        message: error.response?.data['error'] ?? 'Failed to change password',
        statusCode: error.response?.statusCode ?? 500,
      );
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
    // Backend trả về user object hoặc trực tiếp các field
    final user = json['user'] ?? json;
    return AuthResponse(
      token: json['token'] ?? json['access_token'] ?? '',
      user: UserModel(
        id: user['_id'] ?? user['id'] ?? '',
        username: user['username'] ?? '',
        email: user['email'] ?? '',
        fullName: user['full_name'] ?? '',
        role: user['role'] ?? 'USER',
        walletAddress: user['wallet_address'] ?? '',
        balanceEth: (user['balance_eth'] is num)
            ? (user['balance_eth'] as num).toDouble()
            : 0.0,
        lockedEth: (user['locked_eth'] is num)
            ? (user['locked_eth'] as num).toDouble()
            : 0.0,
        createdAt: user['createdAt'] != null
            ? DateTime.parse(user['createdAt'])
            : DateTime.now(),
      ),
    );
  }
}
