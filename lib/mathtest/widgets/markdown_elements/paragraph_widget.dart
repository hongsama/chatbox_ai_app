import 'package:flutter/material.dart';
import 'markdown_element.dart';

/// 段落渲染组件
class MarkdownParagraphWidget extends MarkdownElementWidget {
  const MarkdownParagraphWidget({
    Key? key,
    required String rawContent,
    required MarkdownTheme theme,
  }) : super(key: key, rawContent: rawContent, theme: theme);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: theme.contentPadding,
      child: Text.rich(
        _parseStyledText(rawContent),
        style: TextStyle(
          fontSize: theme.fontSize,
          color: theme.textColor,
        ),
      ),
    );
  }
  
  /// 解析带格式的文本
  TextSpan _parseStyledText(String text) {
    // 粗体和斜体的正则表达式
    final boldRegExp = RegExp(r'\*\*(.*?)\*\*|__(.*?)__');
    final italicRegExp = RegExp(r'\*((?!\*).+?)\*|_((?!_).+?)_');
    
    List<InlineSpan> spans = [];
    int currentPosition = 0;
    
    // 处理粗体
    final boldMatches = boldRegExp.allMatches(text);
    for (final match in boldMatches) {
      // 添加粗体前的普通文本
      if (match.start > currentPosition) {
        final plainText = text.substring(currentPosition, match.start);
        spans.add(TextSpan(text: plainText));
      }
      
      // 添加粗体文本
      final boldText = match.group(1) ?? match.group(2) ?? '';
      spans.add(TextSpan(
        text: boldText,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      
      currentPosition = match.end;
    }
    
    // 添加剩余文本
    if (currentPosition < text.length) {
      final remainingText = text.substring(currentPosition);
      
      // 处理斜体
      final italicMatches = italicRegExp.allMatches(remainingText);
      int italicPosition = 0;
      
      for (final match in italicMatches) {
        // 添加斜体前的普通文本
        if (match.start > italicPosition) {
          final plainText = remainingText.substring(italicPosition, match.start);
          spans.add(TextSpan(text: plainText));
        }
        
        // 添加斜体文本
        final italicText = match.group(1) ?? match.group(2) ?? '';
        spans.add(TextSpan(
          text: italicText,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
        
        italicPosition = match.end;
      }
      
      // 添加最后的普通文本
      if (italicPosition < remainingText.length) {
        spans.add(TextSpan(text: remainingText.substring(italicPosition)));
      } else if (italicMatches.isEmpty) {
        // 如果没有斜体，则添加全部剩余文本
        spans.add(TextSpan(text: remainingText));
      }
    }
    
    return TextSpan(children: spans);
  }
} 