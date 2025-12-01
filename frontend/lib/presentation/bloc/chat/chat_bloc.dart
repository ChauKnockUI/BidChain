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

      // Create initial empty state
      emit(const ChatLoaded(messages: []));

      // Optionally add welcome message
      if (currentAuctionData != null) {
        _addWelcomeMessage(emit);
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
    if (currentState is! ChatLoaded) return;

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
      emit(currentState.copyWith(
        messages: updatedMessages,
        isWaitingForResponse: true,
      ));

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
      final finalMessages = [...updatedMessages, aiMessage];
      emit(currentState.copyWith(
        messages: finalMessages,
        isWaitingForResponse: false,
      ));
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
      // Emit loaded state to allow retry
      emit(currentState.copyWith(isWaitingForResponse: false));
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
      // Clear Gemini chat history
      geminiService.clearChatHistory();

      // Emit cleared state
      emit(const ChatCleared());

      // Reinitialize if auction data exists
      if (currentAuctionData != null) {
        emit(const ChatLoaded(messages: []));
        _addWelcomeMessage(emit);
      } else {
        emit(const ChatLoaded(messages: []));
      }
    } catch (e) {
      emit(ChatError('Failed to clear chat: $e'));
    }
  }

  /// Add welcome message
  void _addWelcomeMessage(Emitter<ChatState> emit) {
    const uuid = Uuid();
    final welcomeMessage = ChatMessageModel(
      id: uuid.v4(),
      content: 'Hello! I\'m here to help you with questions about this auction. Feel free to ask me anything about the product, pricing, or bidding strategies!',
      timestamp: DateTime.now(),
      isUserMessage: false,
    );

    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(currentState.copyWith(
        messages: [welcomeMessage],
      ));
    }
  }

  @override
  Future<void> close() async {
    geminiService.clearChatHistory();
    return super.close();
  }
}
