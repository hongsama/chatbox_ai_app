import 'package:flutter/material.dart';
import 'markdown_element.dart';

/// 分隔线渲染组件
class MarkdownDividerWidget extends MarkdownElementWidget {
  const MarkdownDividerWidget({
    Key? key,
    required String rawContent,
    required MarkdownTheme theme,
  }) : super(key: key, rawContent: rawContent, theme: theme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(
        color: theme.dividerColor,
        thickness: 1.0,
        height: 1.0,
      ),
    );
  }

  /// 检查是否是有效的分隔线
  static bool isValidDivider(String content) {
    // Markdown中分隔线的格式为:
    // 1. 三个或更多连字符: ---
    // 2. 三个或更多星号: ***
    // 3. 三个或更多下划线: ___
    final trimmedContent = content.trim();
    
    // 检查是否只包含特定字符
    if (!RegExp(r'^[-*_\s]+$').hasMatch(trimmedContent)) {
      return false;
    }
    
    // 检查是否至少有3个连续的特殊字符
    if (trimmedContent.contains('---') || 
        trimmedContent.contains('***') || 
        trimmedContent.contains('___')) {
      return true;
    }
    
    return false;
  }
} 