import 'package:flutter/material.dart';
import '../../pages/chat/chat_screen.dart';
import '../chat/floating_chat_bubble.dart';

class ChatBubbleWrapper extends StatefulWidget {
  final Widget child;

  const ChatBubbleWrapper({Key? key, required this.child}) : super(key: key);

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
            auctionId: null,
            auctionData: null,
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
