import 'package:flutter/material.dart';
import 'latex_parser.dart';

/// 主Markdown解析器
class MarkdownParser {
  /// 解析整个文档
  static List<Widget> parseDocument(String markdown) {
    if (markdown.isEmpty) {
      return [];
    }
    
    try {
      final List<Widget> widgets = [];
      
      // 简单分割段落
      final paragraphs = markdown.split('\n\n');
      
      for (var paragraph in paragraphs) {
        paragraph = paragraph.trim();
        if (paragraph.isEmpty) continue;
        
        widgets.add(parseParagraph(paragraph));
      }
      
      return widgets;
    } catch (e) {
      debugPrint('解析Markdown文档时出错: $e');
      // 返回错误提示
      return [
        Text('解析文档时出错: $e', 
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
        )
      ];
    }
  }
  
  /// 解析单个段落
  static Widget parseParagraph(String text, {TextStyle? style}) {
    try {
      final defaultStyle = style ?? const TextStyle(fontSize: 16, color: Colors.black);
    
      // 处理标题
      if (text.startsWith('#')) {
        final headerMatch = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(text);
        if (headerMatch != null) {
          final level = headerMatch.group(1)!.length;
          final headerText = headerMatch.group(2)!;
          final fontSize = 24.0 - (level - 1) * 2;
          
          final headerStyle = defaultStyle.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          );
          
          final styledText = parseTextWithStyles(headerText, headerStyle);
          
          return Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: RichText(text: styledText),
          );
        }
      }
      
      // 处理引用
      if (text.startsWith('>')) {
        final quoteMatch = RegExp(r'^>\s(.+)$', multiLine: true).firstMatch(text);
        if (quoteMatch != null) {
          final quoteText = quoteMatch.group(1)!;
          
          final quoteStyle = defaultStyle.copyWith(
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          );
          
          final styledText = parseTextWithStyles(quoteText, quoteStyle);
          
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: Colors.grey[400]!,
                  width: 4.0,
                ),
              ),
            ),
            child: RichText(text: styledText),
          );
        }
      }
      
      // 处理无序列表
      if (text.startsWith('- ') || text.startsWith('* ') || text.startsWith('+ ')) {
        final listItems = text.split('\n');
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listItems.map((item) {
              final itemMatch = RegExp(r'^[-*+]\s(.+)$').firstMatch(item);
              if (itemMatch != null) {
                final itemText = itemMatch.group(1)!;
                final styledText = parseTextWithStyles(itemText, defaultStyle);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: RichText(text: styledText),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ),
        );
      }
      
      // 处理有序列表
      if (RegExp(r'^\d+\.\s').hasMatch(text)) {
        final listItems = text.split('\n');
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listItems.map((item) {
              final itemMatch = RegExp(r'^(\d+)\.\s(.+)$').firstMatch(item);
              if (itemMatch != null) {
                final number = itemMatch.group(1)!;
                final itemText = itemMatch.group(2)!;
                final styledText = parseTextWithStyles(itemText, defaultStyle);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$number. ', style: TextStyle(fontSize: defaultStyle.fontSize)),
                      Expanded(
                        child: RichText(text: styledText),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ),
        );
      }
      
      // 检查是否包含LaTeX公式
      if (text.contains(r'\[') || text.contains(r'\(') || text.contains(r'$')) {
        // 如果包含LaTeX公式，使用LatexParser处理
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: LatexParser.parseLatex(
            text,
            style: defaultStyle,
          ),
        );
      }
      
      // 处理普通段落
      final styledText = parseTextWithStyles(text, defaultStyle);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: RichText(text: styledText),
      );
    } catch (e) {
      debugPrint('解析段落时出错: $e');
      // 返回原始文本，但标记为红色
      return Text(
        text,
        style: const TextStyle(color: Colors.red),
      );
    }
  }
  
  /// 检测文本中的Markdown语法，并应用相应的样式
  static TextSpan parseTextWithStyles(String text, TextStyle baseStyle) {
    try {
      // 粗体和斜体的正则表达式
      final boldRegExp = RegExp(r'\*\*(.*?)\*\*|__(.+?)__');
      final italicRegExp = RegExp(r'\*((?!\*).+?)\*|_((?!_).+?)_');
      
      // 存储所有的文本片段
      final List<InlineSpan> spans = [];
      
      // 当前处理位置
      int currentPosition = 0;
      
      // 合并粗体和斜体匹配，按位置排序
      final allMatches = [
        ...boldRegExp.allMatches(text),
        ...italicRegExp.allMatches(text)
      ]..sort((a, b) => a.start.compareTo(b.start));
      
      // 已处理的区间
      final List<List<int>> processedRanges = [];
      
      // 检查一个位置是否在已处理的区间内
      bool isProcessed(int position) {
        for (final range in processedRanges) {
          if (position >= range[0] && position < range[1]) {
            return true;
          }
        }
        return false;
      }
      
      // 处理每个匹配
      for (final match in allMatches) {
        // 如果已经处理过这个区间，跳过
        if (isProcessed(match.start)) continue;
        
        // 添加匹配前的普通文本
        if (match.start > currentPosition) {
          final textBefore = text.substring(currentPosition, match.start);
          spans.add(TextSpan(text: textBefore, style: baseStyle));
        }
        
        String matchedText;
        TextStyle matchedStyle;
        
        // 判断是粗体还是斜体
        if (match.input.substring(match.start, match.start + 2) == '**' || 
            match.input.substring(match.start, match.start + 2) == '__') {
          // 粗体
          matchedText = match.group(1) ?? match.group(2)!;
          matchedStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
        } else {
          // 斜体
          matchedText = match.group(1) ?? match.group(2)!;
          matchedStyle = baseStyle.copyWith(fontStyle: FontStyle.italic);
        }
        
        // 递归处理嵌套的样式
        spans.add(parseTextWithStyles(matchedText, matchedStyle));
        
        // 更新当前位置并标记为已处理
        currentPosition = match.end;
        processedRanges.add([match.start, match.end]);
      }
      
      // 添加最后一段普通文本
      if (currentPosition < text.length) {
        final textAfter = text.substring(currentPosition);
        spans.add(TextSpan(text: textAfter, style: baseStyle));
      }
      
      // 如果没有任何样式，直接返回原始文本
      if (spans.isEmpty) {
        return TextSpan(text: text, style: baseStyle);
      }
      
      return TextSpan(children: spans, style: baseStyle);
    } catch (e) {
      debugPrint('解析文本样式时出错: $e');
      // 出错时返回原始文本
      return TextSpan(text: text, style: baseStyle);
    }
  }
  
  /// 测试解析器功能
  static Widget testParser() {
    const testMarkdown = '''
# 标题1
## 标题2
### 标题3

这是一个**粗体**和*斜体*文本测试。

> 这是一个引用，包含**粗体**和*斜体*。

- 列表项1
- **粗体列表项**
- 包含*斜体*的列表项

1. 有序列表项1
2. **粗体有序列表项**
3. 包含*斜体*的有序列表项

这是一个包含LaTeX公式的段落: \$E=mc^2\$ 和 \\\\(\\\\alpha + \\\\beta\\\\)

\\\\[ \\\\int_{a}^{b} f(x) dx = F(b) - F(a) \\\\]
''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parseDocument(testMarkdown),
    );
  }
} 