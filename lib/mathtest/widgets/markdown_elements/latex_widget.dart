import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'markdown_element.dart';

/// LaTeX公式渲染组件
class MarkdownLatexWidget extends MarkdownElementWidget {
  const MarkdownLatexWidget({
    Key? key,
    required String rawContent,
    required MarkdownTheme theme,
  }) : super(key: key, rawContent: rawContent, theme: theme);

  @override
  Widget build(BuildContext context) {
    final latexData = _parseLatex(rawContent);
    
    return Padding(
      padding: theme.contentPadding,
      child: Center(
        child: _buildLatexWidget(context, latexData),
      ),
    );
  }

  /// 解析LaTeX公式内容
  LatexData _parseLatex(String content) {
    LatexType type = LatexType.inline;
    String formula = '';

    // 检查是否是块级公式 \[ ... \]
    final blockMatch = RegExp(r'\\\[([\s\S]*?)\\\]', dotAll: true).firstMatch(content);
    if (blockMatch != null) {
      type = LatexType.block;
      formula = blockMatch.group(1)?.trim() ?? '';
      return LatexData(formula: formula, type: type);
    }

    // 检查是否是行内公式 \( ... \) 或 $ ... $
    final inlineMatchParens = RegExp(r'\\\(([\s\S]*?)\\\)', dotAll: true).firstMatch(content);
    if (inlineMatchParens != null) {
      formula = inlineMatchParens.group(1)?.trim() ?? '';
      return LatexData(formula: formula, type: type);
    }

    final inlineMatchDollar = RegExp(r'\$((?!\$)[\s\S]*?)\$', dotAll: true).firstMatch(content);
    if (inlineMatchDollar != null) {
      formula = inlineMatchDollar.group(1)?.trim() ?? '';
      return LatexData(formula: formula, type: type);
    }

    // 默认情况，尝试使用整个内容作为公式
    return LatexData(formula: content.trim(), type: type);
  }

  /// 构建LaTeX公式组件
  Widget _buildLatexWidget(BuildContext context, LatexData latexData) {
    try {
      if (latexData.type == LatexType.block) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Math.tex(
            latexData.formula,
            textStyle: TextStyle(
              fontSize: theme.fontSize * 1.1,
              color: theme.textColor,
            ),
            mathStyle: MathStyle.display,
          ),
        );
      } else {
        return Math.tex(
          latexData.formula,
          textStyle: TextStyle(
            fontSize: theme.fontSize,
            color: theme.textColor,
          ),
          mathStyle: MathStyle.text,
        );
      }
    } catch (e) {
      // 如果渲染失败，显示错误信息
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
          'LaTeX解析错误: ${latexData.formula}',
          style: TextStyle(
            color: Colors.red,
            fontSize: theme.fontSize * 0.9,
          ),
        ),
      );
    }
  }
}

/// LaTeX公式类型
enum LatexType {
  inline,  // 行内公式
  block,   // 块级公式
}

/// LaTeX公式数据类
class LatexData {
  final String formula;  // 公式内容
  final LatexType type;  // 公式类型
  
  LatexData({
    required this.formula,
    required this.type,
  });
} 