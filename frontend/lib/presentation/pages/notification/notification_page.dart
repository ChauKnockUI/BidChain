import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../../data/models/notification_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications when page opens
    context.read<NotificationBloc>().add(FetchNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              context.read<NotificationBloc>().add(MarkAsReadEvent([]));
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.isLoading && state.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.notifications.isEmpty) {
            return Center(child: Text('Error: ${state.error}'));
          }

          if (state.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<NotificationBloc>().add(FetchNotificationsEvent());
            },
            child: ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _buildNotificationItem(context, notification);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
  ) {
    return Container(
      color: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getIconColor(notification.type).withOpacity(0.1),
          child: Icon(
            _getIcon(notification.type),
            color: _getIconColor(notification.type),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              notification.formattedTime,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationBloc>().add(
              MarkAsReadEvent([notification.id]),
            );
          }
          // Navigate to related auction if applicable
          if (notification.relatedId != null) {
            context.push('/auction-detail/${notification.relatedId}');
          }
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'OUTBID':
        return Icons.gavel;
      case 'NEW_BID':
        return Icons.monetization_on;
      case 'AUCTION_SOLD':
      case 'WON_AUCTION':
        return Icons.emoji_events;
      case 'AUCTION_APPROVED':
        return Icons.check_circle;
      case 'AUCTION_STARTED':
        return Icons.play_circle_fill;
      case 'AUCTION_REJECTED':
        return Icons.cancel;
      case 'DEPOSIT_SUCCESS':
        return Icons.account_balance_wallet;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'OUTBID':
      case 'AUCTION_REJECTED':
        return Colors.red;
      case 'NEW_BID':
      case 'DEPOSIT_SUCCESS':
      case 'AUCTION_STARTED':
        return Colors.green;
      case 'AUCTION_SOLD':
      case 'WON_AUCTION':
        return Colors.amber;
      case 'AUCTION_APPROVED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
