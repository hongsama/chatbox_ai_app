import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';

/// 代码解析器
class CodeParser {
  /// 解析代码块
  static Widget parseCodeBlock(String code, String language) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: HighlightView(
        code,
        language: language,
        theme: vs2015Theme,
        padding: const EdgeInsets.all(16),
        textStyle: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
        ),
      ),
    );
  }
  
  /// 检测代码语言
  static String detectLanguage(String code) {
    // TODO: 实现语言检测
    return 'plaintext';
  }
  
  /// 创建代码块记录
  static ActiveCodeBlock createCodeBlock({
    required String language,
    required int startLine,
  }) {
    return ActiveCodeBlock(
      language: language,
      startLine: startLine,
    );
  }
}

/// 用于跟踪代码块的类
class ActiveCodeBlock {
  String language;
  String code;
  bool isComplete;
  int startLine;
  int endLine;
  
  ActiveCodeBlock({
    required this.language,
    required this.startLine,
    this.code = '',
    this.isComplete = false,
    this.endLine = -1,
  });
} 