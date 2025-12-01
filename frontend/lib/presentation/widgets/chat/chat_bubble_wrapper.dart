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

  void _openChatDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ChatScreen(auctionId: null, auctionData: null),
    ).then((_) {
      setState(() {
        _isChatOpen = false;
      });
    });

    setState(() {
      _isChatOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        FloatingChatBubble(onTap: _openChatDialog, isVisible: !_isChatOpen),
      ],
    );
  }
}
