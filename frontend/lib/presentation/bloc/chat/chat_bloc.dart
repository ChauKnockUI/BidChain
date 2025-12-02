import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/gemini_service.dart';
import '../../../data/models/chat_message_model.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GeminiService geminiService;
  String? currentAuctionId;
  Map<String, dynamic>? currentAuctionData;

  ChatBloc({required this.geminiService}) : super(const ChatInitial()) {
    // Register event handlers
    on<InitializeChatEvent>(_onInitializeChat);
    on<SendMessageEvent>(_onSendMessage);
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<ClearChatHistoryEvent>(_onClearChatHistory);
  }

  /// Handle initialization with optional auction context
  Future<void> _onInitializeChat(
    InitializeChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      currentAuctionId = event.auctionId;
      currentAuctionData = event.auctionData;

      // Load chat history from local storage
      await geminiService.loadChatHistory();

      // Check if we have existing chat history
      final storedMessages = geminiService.getChatHistory();

      if (storedMessages.isNotEmpty) {
        // Convert stored messages to ChatMessageModel
        final messages = storedMessages.map((msg) {
          final uuid = Uuid();
          final parts = msg['parts'] as List<dynamic>? ?? [];
          final text = parts.isNotEmpty
              ? (parts[0] as Map<String, dynamic>)['text'] ?? ''
              : '';

          return ChatMessageModel(
            id: uuid.v4(),
            content: text,
            timestamp: DateTime.now(),
            isUserMessage: msg['role'] == 'user',
          );
        }).toList();

        emit(ChatLoaded(messages: messages));
      } else {
        // No stored history, create welcome message
        const uuid = Uuid();
        final welcomeMessage = ChatMessageModel(
          id: uuid.v4(),
          content:
              'Hello! I\'m here to help you with questions about products, prices, trends, and bidding strategies. What can I help you with today?',
          timestamp: DateTime.now(),
          isUserMessage: false,
        );

        emit(ChatLoaded(messages: [welcomeMessage]));
      }
    } catch (e) {
      emit(ChatError('Failed to initialize chat: $e'));
    }
  }

  /// Handle sending user message
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    // Get current state
    final currentState = state;
    if (currentState is! ChatLoaded) {
      emit(const ChatLoading());
      return;
    }

    try {
      // Create user message
      const uuid = Uuid();
      final userMessage = ChatMessageModel(
        id: uuid.v4(),
        content: event.userMessage,
        timestamp: DateTime.now(),
        isUserMessage: true,
        auctionId: event.auctionId ?? currentAuctionId,
      );

      // Update state with user message
      final updatedMessages = [...currentState.messages, userMessage];
      emit(
        currentState.copyWith(
          messages: updatedMessages,
          isWaitingForResponse: true,
        ),
      );

      // Build prompt with auction context if available
      String prompt = event.userMessage;
      if (currentAuctionData != null) {
        final context = geminiService.formatAuctionContext(currentAuctionData!);
        prompt = '$context\n\nUser question: $prompt';
      }

      // Get AI response
      final aiResponse = await geminiService.sendMessage(prompt);

      // Create AI message
      final aiMessage = ChatMessageModel(
        id: uuid.v4(),
        content: aiResponse,
        timestamp: DateTime.now(),
        isUserMessage: false,
        auctionId: event.auctionId ?? currentAuctionId,
      );

      // Update state with AI message
      final currentLoadedState = state;
      if (currentLoadedState is ChatLoaded) {
        final finalMessages = [...currentLoadedState.messages, aiMessage];
        emit(
          currentLoadedState.copyWith(
            messages: finalMessages,
            isWaitingForResponse: false,
          ),
        );
      }
    } catch (e) {
      final errorState = state;
      if (errorState is ChatLoaded) {
        emit(ChatError('Failed to send message: $e'));
        emit(errorState.copyWith(isWaitingForResponse: false));
      } else {
        emit(ChatError('Failed to send message: $e'));
      }
    }
  }

  /// Handle loading chat history
  Future<void> _onLoadChatHistory(
    LoadChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(const ChatLoading());

      // TODO: Load from local storage if needed
      // For now, just emit empty chat
      emit(const ChatLoaded(messages: []));
    } catch (e) {
      emit(ChatError('Failed to load chat history: $e'));
    }
  }

  /// Handle clearing chat
  Future<void> _onClearChatHistory(
    ClearChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Clear Gemini chat history and local storage
      await geminiService.clearStoredChatHistory();

      // Emit cleared state
      emit(const ChatCleared());

      // Reinitialize with welcome message
      const uuid = Uuid();
      final welcomeMessage = ChatMessageModel(
        id: uuid.v4(),
        content:
            'Hello! I\'m here to help you with questions about products, prices, trends, and bidding strategies. What can I help you with today?',
        timestamp: DateTime.now(),
        isUserMessage: false,
      );

      emit(ChatLoaded(messages: [welcomeMessage]));
    } catch (e) {
      emit(ChatError('Failed to clear chat: $e'));
    }
  }

  @override
  Future<void> close() async {
    geminiService.clearChatHistory();
    return super.close();
  }
}
