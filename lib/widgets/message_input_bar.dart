import 'package:flutter/material.dart';

class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isButtonEnabled;
  final bool isTyping;
  final VoidCallback onSendMessage;
  final VoidCallback onStopGeneration;
  final Function(String) onChanged;
  final Function(String) onSubmitted;

  const MessageInputBar({
    Key? key,
    required this.controller,
    required this.isButtonEnabled,
    required this.isTyping,
    required this.onSendMessage,
    required this.onStopGeneration,
    required this.onChanged,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              enabled: !isTyping,
              style: TextStyle(
                fontSize: 14.0, 
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: isTyping ? '正在生成回答...' : '输入消息...',
                hintStyle: TextStyle(
                  fontSize: 14.0,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: isTyping
                    ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.7)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
              ),
              maxLines: null,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              onSubmitted: isTyping ? null : onSubmitted,
            ),
          ),
          const SizedBox(width: 8.0),
          SizedBox(
            width: 40.0,
            height: 40.0,
            child: IconButton(
              onPressed: isTyping 
                  ? onStopGeneration
                  : (isButtonEnabled ? onSendMessage : null),
              icon: Icon(
                isTyping ? Icons.stop : Icons.arrow_upward_sharp,
                size: 24.0,
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey.shade400;
                  }
                  return isTyping ? Colors.red : Colors.blue;
                }),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                alignment: AlignmentDirectional.center,
                minimumSize: WidgetStateProperty.all(const Size(40, 40)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 