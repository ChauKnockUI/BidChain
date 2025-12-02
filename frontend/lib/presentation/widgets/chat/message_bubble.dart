import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../config/theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.isUserMessage;

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUserMessage
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isUserMessage ? AppColors.accent : AppColors.tertiary,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isUserMessage ? 12 : 0),
                bottomRight: Radius.circular(isUserMessage ? 0 : 12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: isUserMessage ? Colors.white : AppColors.black,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(color: AppColors.grey, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
