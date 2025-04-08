import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message.dart';
import '../widgets/markdown_renderer.dart';

class AIMessageBubble extends StatelessWidget {
  final Message message;
  final bool isTyping;
  static const double _edgeMargin = 8.0;

  const AIMessageBubble({
    super.key,
    required this.message,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(left: _edgeMargin, right: 4.0, top: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: AssetImage('assets/images/ai_avatar.png'),
              fit: BoxFit.cover,
            ),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(
              top: 0.0,
              bottom: 4.0,
              left: 0.0,
              right: _edgeMargin,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 使用Markdown渲染器
                MarkdownRenderer(
                  data: message.content,
                ),
                
                // 复制按钮 - 只有在回答完成后显示
                if (!isTyping)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.copy_rounded,
                        size: 16.0,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: message.content));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('内容已复制到剪贴板'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4.0),
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(24, 24),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 