import 'package:flutter/material.dart';
import 'markdown_element.dart';

/// 标题渲染组件
class MarkdownHeadingWidget extends MarkdownElementWidget {
  const MarkdownHeadingWidget({
    Key? key,
    required String rawContent,
    required MarkdownTheme theme,
  }) : super(key: key, rawContent: rawContent, theme: theme);
  
  @override
  Widget build(BuildContext context) {
    // 解析标题
    final HeadingData headingData = _parseHeading(rawContent);
    
    // 根据标题级别计算字体大小
    final fontSize = theme.fontSize + (6 - headingData.level) * 2;
    
    return Padding(
      padding: EdgeInsets.only(
        top: 12.0 + (6 - headingData.level) * 2,
        bottom: 8.0,
      ),
      child: Text(
        headingData.text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: theme.textColor,
        ),
      ),
    );
  }
  
  /// 解析标题内容
  HeadingData _parseHeading(String content) {
    // 标题格式: #+ text
    final match = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(content);
    
    if (match != null) {
      final level = match.group(1)!.length;
      final text = match.group(2)!.trim();
      return HeadingData(level: level, text: text);
    }
    
    // 默认情况，当不符合标题格式时
    return HeadingData(level: 1, text: content);
  }
}

/// 标题数据类
class HeadingData {
  final int level;   // 标题级别 (1-6)
  final String text; // 标题文本
  
  HeadingData({
    required this.level,
    required this.text,
  });
} 