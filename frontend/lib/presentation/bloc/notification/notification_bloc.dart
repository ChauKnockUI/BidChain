import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:frontend/core/services/socket_service.dart';
import 'package:frontend/data/models/notification_model.dart';
import 'package:frontend/domain/repositories/notification_repository.dart';

// Events
abstract class NotificationEvent {}

class FetchNotificationsEvent extends NotificationEvent {}

class MarkAsReadEvent extends NotificationEvent {
  final List<String> notificationIds;
  MarkAsReadEvent(this.notificationIds);
}

class ReceiveNotificationEvent extends NotificationEvent {
  final NotificationModel notification;
  ReceiveNotificationEvent(this.notification);
}

// State
class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error:
          error, // If null passed, it means clear error? Or keep? Usually clear.
    );
  }
}

// Bloc
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;
  final SocketService _socketService;
  StreamSubscription? _notificationSubscription;

  NotificationBloc({
    required NotificationRepository repository,
    required SocketService socketService,
  }) : _repository = repository,
       _socketService = socketService,
       super(NotificationState()) {
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<ReceiveNotificationEvent>(_onReceiveNotification);

    // Listen to socket notifications
    _notificationSubscription = _socketService.notificationStream.listen((
      data,
    ) {
      if (!isClosed) {
        add(FetchNotificationsEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }

  Future<void> _onFetchNotifications(
    FetchNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final notifications = await _repository.getNotifications();
      emit(state.copyWith(notifications: notifications, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Optimistic update
      final updatedList = state.notifications.map((n) {
        if (event.notificationIds.isEmpty ||
            event.notificationIds.contains(n.id)) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            type: n.type,
            title: n.title,
            message: n.message,
            relatedId: n.relatedId,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      emit(state.copyWith(notifications: updatedList));

      await _repository.markAsRead(event.notificationIds);
    } catch (e) {
      // Revert or show error? For read status, silent fail is often acceptable
      print('Error marking as read: $e');
    }
  }

  void _onReceiveNotification(
    ReceiveNotificationEvent event,
    Emitter<NotificationState> emit,
  ) {
    final currentList = List<NotificationModel>.from(state.notifications);
    currentList.insert(0, event.notification);
    emit(state.copyWith(notifications: currentList));
  }
}
