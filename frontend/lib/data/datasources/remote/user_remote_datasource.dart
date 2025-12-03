import 'dart:io';
import 'package:dio/dio.dart';
import '../../../config/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUserProfile();
  Future<UserModel> getUserById(String userId);
  Future<UserModel> updateUserProfile({
    String? fullName,
    String? avatar,
    String? momoPhone,
  });
  Future<UserModel> uploadAndUpdateAvatar(String filePath);
  Future<UserModel> uploadAndUpdateAvatarBytes(
    List<int> bytes,
    String fileName,
  );
  Future<UserModel> deleteAvatar();
  Future<List<dynamic>> getUserAuctions();
  Future<List<dynamic>> getUserBids();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioClient dioClient;

  UserRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final response = await dioClient.get(ApiConstants.getUserProfile);

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to get user profile',
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
  Future<UserModel> getUserById(String userId) async {
    try {
      final response = await dioClient.get('/user/$userId');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to get user',
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
  Future<UserModel> updateUserProfile({
    String? fullName,
    String? avatar,
    String? momoPhone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (avatar != null) data['avatar'] = avatar;
      if (momoPhone != null) data['momo_phone'] = momoPhone;

      final response = await dioClient.put(
        ApiConstants.updateUserProfile,
        data: data,
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to update profile',
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
  Future<UserModel> uploadAndUpdateAvatar(String filePath) async {
    try {
      // Read file as bytes - works on both web and mobile
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final filename = file.path.split('/').last;

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await dioClient.postMultipart(
        ApiConstants.uploadAvatar,
        data: formData,
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to upload avatar',
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
  Future<UserModel> uploadAndUpdateAvatarBytes(
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final response = await dioClient.postMultipart(
        ApiConstants.uploadAvatar,
        data: formData,
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to upload avatar',
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
  Future<UserModel> deleteAvatar() async {
    try {
      final response = await dioClient.put(
        ApiConstants.updateUserProfile,
        data: {'avatar': null},
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to delete avatar',
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
  Future<List<dynamic>> getUserAuctions() async {
    try {
      final response = await dioClient.get(ApiConstants.getUserAuctions);

      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data as List<dynamic>;
        } else if (response.data is Map && response.data['data'] is List) {
          return response.data['data'] as List<dynamic>;
        } else {
          return [];
        }
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to get user auctions',
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
  Future<List<dynamic>> getUserBids() async {
    try {
      final response = await dioClient.get(ApiConstants.getUserBids);

      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data as List<dynamic>;
        } else if (response.data is Map && response.data['data'] is List) {
          return response.data['data'] as List<dynamic>;
        } else {
          return [];
        }
      } else {
        throw ServerException(
          message: response.data['error'] ?? 'Failed to get user bids',
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
