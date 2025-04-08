import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// 用于解析Markdown文本中的LaTeX公式并生成对应的Widget
class MarkdownLatexParser {
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
      if (match.pattern == blockRegExp.pattern) {
        // 块级公式
        formula = match.group(1)!;
        spans.add(WidgetSpan(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Math.tex(
                formula,
                textStyle: defaultStyle.copyWith(fontSize: defaultStyle.fontSize! * 1.2),
              ),
            ),
          ),
        ));
      } else {
        // 行内公式
        formula = match.group(1) ?? match.group(2)!;
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            formula,
            textStyle: defaultStyle,
          ),
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
  
  /// 解析整个Markdown文档，处理不同部分
  static List<Widget> parseMarkdown(String markdown) {
    final List<Widget> widgets = [];
    
    // 简单分割段落
    final paragraphs = markdown.split('\n\n');
    
    for (var paragraph in paragraphs) {
      paragraph = paragraph.trim();
      if (paragraph.isEmpty) continue;
      
      if (paragraph.startsWith('#')) {
        // 处理标题
        final headerLevel = paragraph.indexOf(' ');
        if (headerLevel > 0 && headerLevel <= 6) {
          final headerText = paragraph.substring(headerLevel).trim();
          final fontSize = 24.0 - (headerLevel - 1) * 2;
          
          widgets.add(Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: parseLatex(
              headerText,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ));
        }
      } else if (paragraph.startsWith('- ') || RegExp(r'^\d+\. ').hasMatch(paragraph)) {
        // 处理列表项
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
          child: parseLatex(paragraph, style: const TextStyle(fontSize: 16, color: Colors.black)),
        ));
      } else {
        // 处理普通段落
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: parseLatex(paragraph, style: const TextStyle(fontSize: 16, color: Colors.black)),
        ));
      }
    }
    
    return widgets;
  }
} 