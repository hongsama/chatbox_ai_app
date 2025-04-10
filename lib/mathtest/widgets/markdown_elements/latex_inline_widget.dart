import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'markdown_element.dart';

/// LaTeX行内公式渲染组件
class MarkdownLatexInlineWidget extends MarkdownElementWidget {
  const MarkdownLatexInlineWidget({
    Key? key,
    required String rawContent,
    required MarkdownTheme theme,
  }) : super(key: key, rawContent: rawContent, theme: theme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: theme.contentPadding,
      child: Math.tex(
        rawContent,
        textStyle: TextStyle(
          fontSize: theme.fontSize,
          color: theme.textColor,
        ),
      ),
    );
  }
} 