import 'package:flutter/material.dart';
import '../../pages/chat/chat_screen.dart';
import '../chat/floating_chat_bubble.dart';

class ChatBubbleWrapper extends StatefulWidget {
  final Widget child;
  final String? auctionId;
  final Map<String, dynamic>? auctionData;

  const ChatBubbleWrapper({
    super.key, 
    required this.child,
    this.auctionId,
    this.auctionData,
  });

  @override
  State<ChatBubbleWrapper> createState() => _ChatBubbleWrapperState();
}

class _ChatBubbleWrapperState extends State<ChatBubbleWrapper> {
  bool _isChatOpen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isChatOpen)
          ChatScreen(
            auctionId: widget.auctionId,
            auctionData: widget.auctionData,
            onClose: () {
              setState(() {
                _isChatOpen = false;
              });
            },
          ),
        if (!_isChatOpen)
          FloatingChatBubble(
            onTap: () {
              setState(() {
                _isChatOpen = true;
              });
            },
            isVisible: true,
          ),
      ],
    );
  }
}
