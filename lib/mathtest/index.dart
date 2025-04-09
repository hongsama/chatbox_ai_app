import 'package:flutter/material.dart';
import 'screens/latex_screen.dart';
import 'screens/fixed_markdown_screen.dart';
import 'screens/parser_test_screen.dart';

/// 导出数学测试模块的所有组件
export 'screens/latex_screen.dart';
export 'screens/fixed_markdown_screen.dart';
export 'screens/parser_test_screen.dart';

class MathTest {
  /// 返回LaTeX公式展示屏幕
  static Widget getLatexScreen() {
    return const LatexScreen();
  }
  
  /// 返回固定Markdown展示屏幕
  static Widget getFixedMarkdownScreen() {
    return const FixedMarkdownScreen();
  }
  
  /// 返回解析器测试屏幕
  static Widget getParserTestScreen() {
    return const ParserTestScreen();
  }
} 