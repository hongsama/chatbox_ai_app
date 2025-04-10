import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'markdown_element.dart';

/// LaTeX块级公式渲染组件
class MarkdownLatexBlockWidget extends MarkdownElementWidget {
  const MarkdownLatexBlockWidget({
    Key? key,
    required String rawContent,
    required MarkdownTheme theme,
  }) : super(key: key, rawContent: rawContent, theme: theme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: theme.contentPadding,
      child: Center(
        child: Math.tex(
          rawContent,
          textStyle: TextStyle(
            fontSize: theme.fontSize * 1.2,
            color: theme.textColor,
          ),
        ),
      ),
    );
  }
} 