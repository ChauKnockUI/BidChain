import '../datasources/remote/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepository(this.remoteDataSource);

  Future<UserModel> getUserProfile() async {
    return await remoteDataSource.getUserProfile();
  }

  Future<UserModel> getUserById(String userId) async {
    return await remoteDataSource.getUserById(userId);
  }

  Future<UserModel> updateUserProfile({
    String? fullName,
    String? avatar,
    String? momoPhone,
  }) async {
    return await remoteDataSource.updateUserProfile(
      fullName: fullName,
      avatar: avatar,
      momoPhone: momoPhone,
    );
  }

  Future<UserModel> uploadAndUpdateAvatar(String filePath) async {
    return await remoteDataSource.uploadAndUpdateAvatar(filePath);
  }

  Future<UserModel> uploadAndUpdateAvatarBytes(
    List<int> bytes,
    String fileName,
  ) async {
    return await remoteDataSource.uploadAndUpdateAvatarBytes(bytes, fileName);
  }

  Future<UserModel> deleteAvatar() async {
    return await remoteDataSource.deleteAvatar();
  }

  Future<List<dynamic>> getUserAuctions() async {
    return await remoteDataSource.getUserAuctions();
  }

  Future<List<dynamic>> getUserBids() async {
    return await remoteDataSource.getUserBids();
  }
}
