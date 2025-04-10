import 'package:flutter/material.dart';
import 'widgets/markdown_display_v2.dart';

/// 流式Markdown显示组件
///
/// 支持流式输入的Markdown渲染组件，可以接收流式文本输入并实时渲染
class StreamMarkdownDisplay extends StatefulWidget {
  /// 输入源，可以是Stream<String>或String
  final dynamic input;
  
  /// 主题设置
  final ThemeData? theme;
  
  /// 创建流式Markdown显示组件
  const StreamMarkdownDisplay({
    Key? key,
    required this.input,
    this.theme,
  }) : super(key: key);

  @override
  State<StreamMarkdownDisplay> createState() => _StreamMarkdownDisplayState();
}

class _StreamMarkdownDisplayState extends State<StreamMarkdownDisplay> {
  @override
  Widget build(BuildContext context) {
    // 直接使用V2组件
    return MarkdownDisplayV2(
      input: widget.input,
      theme: widget.theme,
    );
  }
}

/// 提供对流式Markdown组件的访问
class StreamMarkdown {
  /// 返回流式Markdown渲染组件
  static Widget getStreamMarkdownDisplay({
    required dynamic input, // Stream<String>或String类型
    ThemeData? theme,
  }) {
    return StreamMarkdownDisplay(
      input: input,
      theme: theme,
    );
  }
} 