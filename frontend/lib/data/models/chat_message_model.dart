import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.timestamp,
    required super.isUserMessage,
    super.auctionId,
  });

  // Convert from Entity to Model
  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return ChatMessageModel(
      id: entity.id,
      content: entity.content,
      timestamp: entity.timestamp,
      isUserMessage: entity.isUserMessage,
      auctionId: entity.auctionId,
    );
  }

  // Convert to Entity
  ChatMessageEntity toEntity() {
    return ChatMessageEntity(
      id: id,
      content: content,
      timestamp: timestamp,
      isUserMessage: isUserMessage,
      auctionId: auctionId,
    );
  }

  // For JSON serialization (if needed for storage)
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isUserMessage: json['isUserMessage'] as bool,
      auctionId: json['auctionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isUserMessage': isUserMessage,
      'auctionId': auctionId,
    };
  }
}
