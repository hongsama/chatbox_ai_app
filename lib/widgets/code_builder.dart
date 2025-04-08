import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter/services.dart';
import 'code_highlight.dart';

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // 如果是pre标签包裹的code，通常是代码块，从其中提取语言
    var language = element.attributes['class']?.replaceAll('language-', '');
    var code = element.textContent;
    
    // 打印调试信息
    print('代码块 - 语言: $language');
    print('代码内容(前30个字符): ${code.length > 30 ? code.substring(0, 30) + '...' : code}');
    
    // 简单代码块 - 没有语言标记，默认为文本
    if (language == null || language.isEmpty) {
      language = 'text';
    }

    // 当语言是text时，使用行内文本样式
    if (language == 'text') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),  // 浅灰色背景
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
          code,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14.0,
          ),
        ),
      );
    }

    // 对于其他语言，继续使用CodeHighlight组件渲染代码块
    return CodeHighlight(
      code: code,
      language: language,
    );
  }
}

// 专门处理内联代码（单反引号）
class InlineCodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Text(
      element.textContent,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 14.0,
        backgroundColor: Color(0xFFEEEEEE),
      ),
    );
  }
} 