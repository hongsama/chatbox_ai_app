import 'package:flutter/material.dart';
import '../models/message.dart';

class UserMessageBubble extends StatelessWidget {
  final Message message;
  static const double _edgeMargin = 8.0;

  const UserMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
          right: _edgeMargin,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20.0),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.content,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
} 