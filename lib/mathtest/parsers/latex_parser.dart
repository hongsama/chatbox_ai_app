import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// LaTeX公式解析器
class LatexParser {
  /// 解析包含LaTeX公式的文本，返回RichText Widget
  static Widget parseLatex(String text, {TextStyle? style}) {
    final defaultStyle = style ?? const TextStyle(fontSize: 16);
    
    // 存储解析结果的span列表
    final List<InlineSpan> spans = [];
    
    // 当前处理位置
    int currentPosition = 0;
    
    // 解析块级公式 \[...\]
    final blockRegExp = RegExp(r'\\\[([\s\S]*?)\\\]');
    final blockMatches = blockRegExp.allMatches(text);
    
    // 解析行内公式 \(...\) 或 $...$
    final inlineRegExp = RegExp(r'\\\(([\s\S]*?)\\\)|\$((?!\$).*?)\$');
    final inlineMatches = inlineRegExp.allMatches(text);
    
    // 合并所有匹配，并按位置排序
    final allMatches = [...blockMatches, ...inlineMatches]
      ..sort((a, b) => a.start.compareTo(b.start));
    
    // 处理每个匹配
    for (final match in allMatches) {
      // 添加匹配前的普通文本
      if (match.start > currentPosition) {
        final textBefore = text.substring(currentPosition, match.start);
        spans.add(TextSpan(text: textBefore, style: defaultStyle));
      }
      
      // 获取匹配的公式文本
      String formula;
      if (match.input.substring(match.start, match.end).startsWith(r'\[')) {
        // 块级公式
        formula = match.group(1)!;
        spans.add(WidgetSpan(
          child: parseBlockFormula(formula, style: defaultStyle),
        ));
      } else {
        // 行内公式
        formula = match.group(1) ?? match.group(2)!;
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: parseInlineFormula(formula, style: defaultStyle),
        ));
      }
      
      // 更新当前位置
      currentPosition = match.end;
    }
    
    // 添加最后一段普通文本
    if (currentPosition < text.length) {
      final textAfter = text.substring(currentPosition);
      spans.add(TextSpan(text: textAfter, style: defaultStyle));
    }
    
    return RichText(
      text: TextSpan(children: spans, style: defaultStyle),
    );
  }

  /// 解析行内公式
  static Widget parseInlineFormula(String formula, {TextStyle? style}) {
    return Math.tex(
      formula,
      textStyle: style ?? const TextStyle(fontSize: 16),
    );
  }
  
  /// 解析块级公式
  static Widget parseBlockFormula(String formula, {TextStyle? style}) {
    final defaultStyle = style ?? const TextStyle(fontSize: 16);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Math.tex(
          formula,
          textStyle: defaultStyle.copyWith(
            fontSize: defaultStyle.fontSize! * 1.2,
          ),
        ),
      ),
    );
  }
} 