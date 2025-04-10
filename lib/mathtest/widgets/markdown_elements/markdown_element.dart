import 'package:flutter/material.dart';

/// Markdown元素类型枚举
enum MarkdownElementType {
  heading,    // 标题
  paragraph,  // 段落
  list,       // 列表
  codeBlock,  // 代码块
  latexBlock, // LaTeX块级公式
  latexInline,// LaTeX行内公式
  quote,      // 引用
  divider,    // 分隔线
  image,      // 图片
}

/// Markdown元素的基础主题配置
class MarkdownTheme {
  final double fontSize;
  final Color textColor;
  final Color backgroundColor;
  final Color codeBlockBackground;
  final Color quoteBackground;
  final Color dividerColor;
  final EdgeInsets contentPadding;
  
  const MarkdownTheme({
    this.fontSize = 16.0,
    this.textColor = const Color(0xFF000000),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.codeBlockBackground = const Color(0xFF1E1E1E),
    this.quoteBackground = const Color(0xFFF5F5F5),
    this.dividerColor = const Color(0xFFDDDDDD),
    this.contentPadding = const EdgeInsets.symmetric(vertical: 4.0),
  });
  
  /// 创建主题的副本并覆盖指定的值
  MarkdownTheme copyWith({
    double? fontSize,
    Color? textColor,
    Color? backgroundColor,
    Color? codeBlockBackground,
    Color? quoteBackground,
    Color? dividerColor,
    EdgeInsets? contentPadding,
  }) {
    return MarkdownTheme(
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      codeBlockBackground: codeBlockBackground ?? this.codeBlockBackground,
      quoteBackground: quoteBackground ?? this.quoteBackground,
      dividerColor: dividerColor ?? this.dividerColor,
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }
}

/// 所有Markdown渲染组件的基础接口
abstract class MarkdownElementWidget extends StatelessWidget {
  final String rawContent;
  final MarkdownTheme theme;
  
  const MarkdownElementWidget({
    Key? key,
    required this.rawContent,
    required this.theme,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context);
} 