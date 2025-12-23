import 'package:equatable/equatable.dart';
import '../../../data/models/chat_message_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize chatbot with optional auction context
class InitializeChatEvent extends ChatEvent {
  final String? auctionId;
  final Map<String, dynamic>? auctionData;

  const InitializeChatEvent({this.auctionId, this.auctionData});

  @override
  List<Object?> get props => [auctionId, auctionData];
}

/// Send message to AI
class SendMessageEvent extends ChatEvent {
  final String userMessage;
  final String? auctionId;
  final Map<String, dynamic>? auctionData;

  const SendMessageEvent(this.userMessage, {this.auctionId, this.auctionData});

  @override
  List<Object?> get props => [userMessage, auctionId, auctionData];
}

/// Load chat history
class LoadChatHistoryEvent extends ChatEvent {
  const LoadChatHistoryEvent();
}

/// Clear chat history
class ClearChatHistoryEvent extends ChatEvent {
  const ClearChatHistoryEvent();
}

/// Update chat with new message (used internally)
class UpdateChatEvent extends ChatEvent {
  final ChatMessageModel message;

  const UpdateChatEvent(this.message);

  @override
  List<Object?> get props => [message];
}
