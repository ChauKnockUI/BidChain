import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isUserMessage; // true = user, false = AI
  final String? auctionId; // Optional: linked to specific auction

  const ChatMessageEntity({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isUserMessage,
    this.auctionId,
  });

  @override
  List<Object?> get props => [id, content, timestamp, isUserMessage, auctionId];
}
