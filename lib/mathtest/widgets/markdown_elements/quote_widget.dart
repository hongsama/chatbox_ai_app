import 'package:flutter/material.dart';
import 'markdown_element.dart';

/// 引用块渲染组件
class MarkdownQuoteWidget extends MarkdownElementWidget {
  const MarkdownQuoteWidget({
    Key? key,
    required String rawContent,
    required MarkdownTheme theme,
  }) : super(key: key, rawContent: rawContent, theme: theme);

  @override
  Widget build(BuildContext context) {
    final quoteData = _parseQuote(rawContent);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.quoteBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: Colors.grey[400]!,
            width: 4.0,
          ),
        ),
      ),
      child: Text(
        quoteData.content,
        style: TextStyle(
          fontSize: theme.fontSize,
          color: theme.textColor.withOpacity(0.8),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  /// 解析引用块内容
  QuoteData _parseQuote(String content) {
    final lines = content.split('\n');
    final List<String> quoteLines = [];
    
    for (final line in lines) {
      // 引用行格式: > text
      if (line.trim().startsWith('>')) {
        // 提取引用行内容（移除 '>' 前缀）
        final match = RegExp(r'^>\s*(.*)$').firstMatch(line);
        if (match != null) {
          final quoteText = match.group(1) ?? '';
          quoteLines.add(quoteText);
        } else {
          quoteLines.add(line.substring(1).trim());
        }
      } else {
        // 如果不是以'>'开头，也添加进去
        // 在一些Markdown解析中，连续引用行中即使没有'>'也会被视为引用的一部分
        quoteLines.add(line);
      }
    }
    
    return QuoteData(
      content: quoteLines.join('\n'),
    );
  }
}

/// 引用块数据类
class QuoteData {
  final String content;  // 引用内容
  
  QuoteData({
    required this.content,
  });
} 