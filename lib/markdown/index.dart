/// 流式Markdown渲染模块
/// 
/// 提供对流式输入Markdown的实时渲染支持，
/// 特别适用于AI生成内容的实时显示。
library markdown;

import 'package:flutter/material.dart';
import 'stream_markdown.dart';
import 'examples/markdown_v3_test_screen.dart';

// 导出主要组件
export 'stream_markdown.dart';
export 'widgets/markdown_display_v2.dart';
export 'widgets/markdown_display_v3.dart';
export 'examples/markdown_v3_test_screen.dart';

// 导出类型定义
export 'types/markdown_element_type.dart';
export 'types/parsing_state.dart';
export 'types/element_state.dart';

/// 提供对流式Markdown组件的访问
class StreamMarkdown {
  /// 返回流式Markdown渲染组件
  static Widget getStreamMarkdownDisplay({
    required dynamic input, // Stream<String>或String
    ThemeData? theme,
  }) {
    return StreamMarkdownDisplay(
      input: input,
      theme: theme,
    );
  }
}

/// 获取V3测试页面
Widget getMarkdownV3TestScreen() {
  return const MarkdownV3TestScreen();
} 