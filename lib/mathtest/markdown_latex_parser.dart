import 'package:flutter/material.dart';
import 'parsers/latex_parser.dart';
import 'parsers/markdown_parser.dart';

/// 用于解析Markdown文本中的LaTeX公式并生成对应的Widget
class MarkdownLatexParser {
  /// 解析包含LaTeX公式的文本，返回RichText Widget
  static Widget parseLatex(String text, {TextStyle? style}) {
    return LatexParser.parseLatex(text, style: style);
  }
  
  /// 解析整个Markdown文档，处理不同部分
  static List<Widget> parseMarkdown(String markdown) {
    return MarkdownParser.parseDocument(markdown);
  }
} 