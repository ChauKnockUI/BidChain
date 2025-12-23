import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/chat/chat_event.dart';
import '../../bloc/chat/chat_state.dart';
import '../../../config/theme/app_colors.dart';
import '../../widgets/chat/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String? auctionId;
  final Map<String, dynamic>? auctionData;
  final VoidCallback? onClose;

  const ChatScreen({super.key, this.auctionId, this.auctionData, this.onClose});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();

    // Listen to text changes to trigger rebuild
    _messageController.addListener(() {
      setState(() {});
    });

    // Always initialize chat when opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(
        InitializeChatEvent(
          auctionId: widget.auctionId,
          auctionData: widget.auctionData,
        ),
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 2),
          child: SizedBox(
            width: 360,
            height: 480,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Header
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'BidBot - Trợ lý đấu giá',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Clear history button
                            GestureDetector(
                              onTap: () {
                                context.read<ChatBloc>().add(const ClearChatHistoryEvent());
                              },
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Close button
                            GestureDetector(
                              onTap: () {
                                widget.onClose?.call();
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Messages
                  Expanded(
                    child: BlocListener<ChatBloc, ChatState>(
                      listener: (context, state) {
                        if (state is ChatLoaded) {
                          _scrollToBottom();
                        }
                      },
                      child: BlocBuilder<ChatBloc, ChatState>(
                        builder: (context, state) {
                          if (state is ChatInitial) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.message_outlined,
                                    size: 36,
                                    color: AppColors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Bắt đầu cuộc trò chuyện',
                                    style: TextStyle(
                                      color: AppColors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (state is ChatLoading) {
                            return const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          if (state is ChatError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 32,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (state is ChatLoaded) {
                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(12),
                              itemCount: state.messages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: MessageBubble(
                                    message: state.messages[index],
                                  ),
                                );
                              },
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),

                  // Input area
                  BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      final isLoading = state is ChatLoading;
                      final hasText = _messageController.text.trim().isNotEmpty;

                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: AppColors.tertiary,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                enabled: !isLoading,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (text) {
                                  if (text.trim().isNotEmpty) {
                                    _sendMessage();
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Nhập tin nhắn...',
                                  hintStyle: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: AppColors.tertiary,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: hasText
                                          ? AppColors.accent
                                          : AppColors.tertiary,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: AppColors.accent,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: (isLoading || !hasText)
                                  ? null
                                  : _sendMessage,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isLoading || !hasText)
                                      ? AppColors.tertiary
                                      : AppColors.accent,
                                ),
                                child: Center(
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.send,
                                          color: (isLoading || !hasText)
                                              ? AppColors.grey
                                              : Colors.white,
                                          size: 16,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<ChatBloc>().add(
      SendMessageEvent(
        message, 
        auctionId: widget.auctionId,
        auctionData: widget.auctionData,
      ),
    );
    _messageController.clear();
  }
}
