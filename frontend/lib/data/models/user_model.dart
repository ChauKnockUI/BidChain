import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String username,
    required String ethAddress,
    required DateTime createdAt,
  }) : super(
    id: id,
    username: username,
    ethAddress: ethAddress,
    createdAt: createdAt,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      ethAddress: json['ethAddress'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'ethAddress': ethAddress,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}