import 'package:equatable/equatable.dart';
import '../../../data/models/chat_message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Loading state
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Chat loaded successfully
class ChatLoaded extends ChatState {
  final List<ChatMessageModel> messages;
  final String? currentAuctionId;
  final bool isWaitingForResponse;

  const ChatLoaded({
    required this.messages,
    this.currentAuctionId,
    this.isWaitingForResponse = false,
  });

  @override
  List<Object?> get props => [messages, currentAuctionId, isWaitingForResponse];

  // CopyWith method for state updates
  ChatLoaded copyWith({
    List<ChatMessageModel>? messages,
    String? currentAuctionId,
    bool? isWaitingForResponse,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      currentAuctionId: currentAuctionId ?? this.currentAuctionId,
      isWaitingForResponse: isWaitingForResponse ?? this.isWaitingForResponse,
    );
  }
}

/// Error state
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Chat cleared
class ChatCleared extends ChatState {
  const ChatCleared();
}
