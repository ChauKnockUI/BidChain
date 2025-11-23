import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> saveToken(String token) async {
    try {
      await sharedPreferences.setString(AppConstants.tokenKey, token);
    } catch (e) {
      throw CacheException(message: 'Failed to save token');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return sharedPreferences.getString(AppConstants.tokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to get token');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await sharedPreferences.setString(
        AppConstants.userKey,
        jsonEncode(user.toJson()),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to save user');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = sharedPreferences.getString(AppConstants.userKey);
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get user');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await sharedPreferences.remove(AppConstants.tokenKey);
      await sharedPreferences.remove(AppConstants.userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache');
    }
  }
}