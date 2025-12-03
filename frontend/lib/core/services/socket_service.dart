import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import '../network/dio_client.dart';
import '../../config/constants/api_constants.dart';
import '../../data/models/user_model.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  String? _userId;
  Function(UserModel)? onBalanceUpdated;
  final _notificationController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get notificationStream => _notificationController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String userId, {required String baseUrl}) {
    if (_socket?.connected == true) {
      disconnect();
    }

    _userId = userId;

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ Socket connected: ${_socket!.id}');
      // Join user-specific room
      _socket!.emit('join_user_room', userId);
      print('📍 Joined user room: user_$userId');
    });

    _socket!.on('balance_updated', (data) async {
      print('💰 Balance updated event received: $data');
      await fetchAndUpdateBalance();
    });

    _socket!.on('notification', (data) {
      print('🔔 Notification received: $data');
      _notificationController.add(data);
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
    });

    _socket!.onError((error) {
      print('⚠️ Socket error: $error');
    });

    _socket!.onReconnect((_) {
      print('🔄 Socket reconnected');
      if (_userId != null) {
        _socket!.emit('join_user_room', _userId);
      }
    });
  }

  Future<void> fetchAndUpdateBalance() async {
    try {
      print('🔄 Fetching fresh user data...');
      final dio = DioClient();
      final response = await dio.get(ApiConstants.getUserProfile);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Data Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        // Backend /user/me returns user object directly, not wrapped in 'data'
        final userData = response.data as Map<String, dynamic>;

        print(
          '🔍 Raw balance_eth: ${userData['balance_eth']} (Type: ${userData['balance_eth'].runtimeType})',
        );

        final user = UserModel.fromJson(userData);
        onBalanceUpdated?.call(user);
        print('✅ Balance updated: ${user.balanceEth} ETH');
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching balance: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void joinAuctionRoom(String auctionId) {
    if (_socket?.connected == true) {
      _socket!.emit('join_auction', auctionId);
      print('📍 Joined auction room: auction_$auctionId');
    }
  }

  void leaveAuctionRoom(String auctionId) {
    if (_socket?.connected == true) {
      _socket!.emit('leave_auction', auctionId);
      print('👋 Left auction room: auction_$auctionId');
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _userId = null;
      print('🔌 Socket disconnected and disposed');
    }
  }
}
