import '../../core/network/dio_client.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final DioClient _dioClient = DioClient();

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dioClient.get('/user/me/notifications');
      final List<dynamic> data = response.data;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  @override
  Future<void> markAsRead(List<String> notificationIds) async {
    try {
      await _dioClient.put(
        '/user/me/notifications/read',
        data: {'notification_ids': notificationIds},
      );
    } catch (e) {
      throw Exception('Failed to mark notifications as read: $e');
    }
  }
}
