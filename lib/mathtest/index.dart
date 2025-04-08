import 'package:flutter/material.dart';
import 'latex_screen.dart';

/// 导出数学测试模块的所有组件
export 'latex_screen.dart';

class MathTest {
  /// 返回LaTeX公式展示屏幕
  static Widget getLatexScreen() {
    return const LatexScreen();
  }
} 