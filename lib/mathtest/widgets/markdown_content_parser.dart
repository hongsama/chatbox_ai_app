import 'markdown_elements/markdown_element.dart';
import 'package:flutter/foundation.dart';

/// 段落部分类型
enum ParagraphPartType {
  text,
  inlineFormula
}

/// 段落部分
class ParagraphPart {
  final ParagraphPartType type;
  final String content;

  ParagraphPart(this.type, this.content);
}

/// 解析状态
enum ParsingState {
  text,              // 普通文本
  dollarFormula,     // $...$ 公式
  parenFormula,      // \(...\) 公式
  blockFormula,      // \[...\] 公式
  codeBlock,         // ```...``` 代码块
  quote,            // > 引用
  list,             // 列表项
  heading,          // # 标题
  divider,          // 水平分隔线
  image             // 图片
}

/// Markdown内容解析器
/// 负责将原始Markdown文本解析为结构化的内容块
class MarkdownContentParser {
  
  /// 将Markdown文本解析为元素列表
  static List<ParsedMarkdownElement> parseMarkdown(String markdownText) {
    final List<ParsedMarkdownElement> elements = [];
    
    // 空文本直接返回空列表
    if (markdownText.isEmpty) {
      return elements;
    }
    
    // 分割文本为行
    final lines = markdownText.split('\n');
    
    // 当前解析状态
    ParsingState state = ParsingState.text;
    StringBuffer currentContent = StringBuffer();
    StringBuffer formulaBuffer = StringBuffer();
    
    // 遍历每一行
    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      debugPrint('Processing line ${lineIndex + 1}: "$line"');
      
      // 检查行首特殊标记
      if (state == ParsingState.text) {
        if (line.trim().isEmpty) {
          // 处理空行
          if (currentContent.isNotEmpty) {
            _addParagraph(elements, currentContent.toString());
            currentContent.clear();
          }
          continue;
        }
        
        // 检查特殊行首标记
        final lineStart = line.trimLeft();
        
        // 检查水平分隔线
        if (lineStart == '---' || lineStart == '***' || lineStart == '___') {
          if (currentContent.isNotEmpty) {
            _addParagraph(elements, currentContent.toString());
            currentContent.clear();
          }
          elements.add(ParsedMarkdownElement(
            type: MarkdownElementType.divider,
            rawContent: line,
          ));
          continue;
        }
        
        // 检查图片
        final imageMatch = RegExp(r'!\[(.*?)\]\((.*?)\)').firstMatch(lineStart);
        if (imageMatch != null) {
          if (currentContent.isNotEmpty) {
            _addParagraph(elements, currentContent.toString());
            currentContent.clear();
          }
          elements.add(ParsedMarkdownElement(
            type: MarkdownElementType.image,
            rawContent: line,
          ));
          continue;
        }
        
        if (lineStart.startsWith('```')) {
          // 开始代码块
          if (currentContent.isNotEmpty) {
            _addParagraph(elements, currentContent.toString());
            currentContent.clear();
          }
          state = ParsingState.codeBlock;
          currentContent.writeln(line);
          continue;
        } else if (lineStart.startsWith('#')) {
          // 标题
          if (currentContent.isNotEmpty) {
            _addParagraph(elements, currentContent.toString());
            currentContent.clear();
          }
          final headerMatch = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(lineStart);
          if (headerMatch != null) {
            elements.add(ParsedMarkdownElement(
              type: MarkdownElementType.heading,
              rawContent: line,
            ));
          }
          continue;
        } else if (lineStart.startsWith('>')) {
          // 引用
          if (currentContent.isNotEmpty) {
            _addParagraph(elements, currentContent.toString());
            currentContent.clear();
          }
          state = ParsingState.quote;
          currentContent.writeln(line);
          continue;
        } else if (lineStart.startsWith('- ') || 
                   lineStart.startsWith('* ') || 
                   lineStart.startsWith('+ ') ||
                   RegExp(r'^\d+\.\s').hasMatch(lineStart)) {
          // 列表
          if (currentContent.isNotEmpty) {
            _addParagraph(elements, currentContent.toString());
            currentContent.clear();
          }
          state = ParsingState.list;
          currentContent.writeln(line);
          continue;
        } else if (lineStart.startsWith('\\[')) {
          // 块级公式开始
          if (currentContent.isNotEmpty) {
            _addParagraph(elements, currentContent.toString());
            currentContent.clear();
          }
          state = ParsingState.blockFormula;
          formulaBuffer.write(line.substring(2));
          continue;
        }
      }
      
      // 处理不同状态下的行内容
      switch (state) {
        case ParsingState.text:
          _processTextLine(line, currentContent, elements);
          break;
          
        case ParsingState.codeBlock:
          if (line.trim() == '```') {
            // 代码块结束
            currentContent.writeln(line);
            elements.add(ParsedMarkdownElement(
              type: MarkdownElementType.codeBlock,
              rawContent: currentContent.toString(),
            ));
            currentContent.clear();
            state = ParsingState.text;
          } else {
            currentContent.writeln(line);
          }
          break;
          
        case ParsingState.quote:
          if (!line.trimLeft().startsWith('>') && line.trim().isNotEmpty) {
            // 引用结束
            elements.add(ParsedMarkdownElement(
              type: MarkdownElementType.quote,
              rawContent: currentContent.toString(),
            ));
            currentContent.clear();
            state = ParsingState.text;
            // 重新处理当前行
            lineIndex--;
          } else {
            currentContent.writeln(line);
          }
          break;
          
        case ParsingState.list:
          if (line.trim().isEmpty) {
            // 列表可能结束
            if (lineIndex + 1 < lines.length) {
              final nextLine = lines[lineIndex + 1].trimLeft();
              if (!nextLine.startsWith('- ') && 
                  !nextLine.startsWith('* ') && 
                  !nextLine.startsWith('+ ') &&
                  !RegExp(r'^\d+\.\s').hasMatch(nextLine)) {
                // 列表确实结束了
                elements.add(ParsedMarkdownElement(
                  type: MarkdownElementType.list,
                  rawContent: currentContent.toString(),
                ));
                currentContent.clear();
                state = ParsingState.text;
              } else {
                // 列表项之间的空行
                currentContent.writeln(line);
              }
            }
          } else if (!line.trimLeft().startsWith('- ') && 
                    !line.trimLeft().startsWith('* ') && 
                    !line.trimLeft().startsWith('+ ') &&
                    !RegExp(r'^\d+\.\s').hasMatch(line.trimLeft())) {
            // 列表结束
            elements.add(ParsedMarkdownElement(
              type: MarkdownElementType.list,
              rawContent: currentContent.toString(),
            ));
            currentContent.clear();
            state = ParsingState.text;
            // 重新处理当前行
            lineIndex--;
          } else {
            currentContent.writeln(line);
          }
          break;
          
        case ParsingState.blockFormula:
          if (line.contains('\\]')) {
            // 块级公式结束
            final endIndex = line.indexOf('\\]');
            formulaBuffer.write(line.substring(0, endIndex));
            elements.add(ParsedMarkdownElement(
              type: MarkdownElementType.latexBlock,
              rawContent: formulaBuffer.toString().trim(),
            ));
            formulaBuffer.clear();
            state = ParsingState.text;
          } else {
            formulaBuffer.writeln(line);
          }
          break;
          
        default:
          break;
      }
    }
    
    // 处理最后一个元素
    if (currentContent.isNotEmpty) {
      switch (state) {
        case ParsingState.text:
          _addParagraph(elements, currentContent.toString());
          break;
        case ParsingState.codeBlock:
          elements.add(ParsedMarkdownElement(
            type: MarkdownElementType.codeBlock,
            rawContent: currentContent.toString(),
          ));
          break;
        case ParsingState.quote:
          elements.add(ParsedMarkdownElement(
            type: MarkdownElementType.quote,
            rawContent: currentContent.toString(),
          ));
          break;
        case ParsingState.list:
          elements.add(ParsedMarkdownElement(
            type: MarkdownElementType.list,
            rawContent: currentContent.toString(),
          ));
          break;
        case ParsingState.blockFormula:
          elements.add(ParsedMarkdownElement(
            type: MarkdownElementType.latexBlock,
            rawContent: formulaBuffer.toString().trim(),
          ));
          break;
        default:
          break;
      }
    }
    
    return elements;
  }
  
  /// 处理普通文本行，解析行内公式
  static void _processTextLine(
    String line, 
    StringBuffer currentContent,
    List<ParsedMarkdownElement> elements
  ) {
    int pos = 0;
    final int length = line.length;
    StringBuffer textBuffer = StringBuffer();
    ParsingState state = ParsingState.text;
    StringBuffer formulaBuffer = StringBuffer();
    bool escapeNext = false;  // 用于处理转义字符
    String lastChar = '';     // 记录上一个字符
    
    while (pos < length) {
      final char = line[pos];
      
      switch (state) {
        case ParsingState.text:
          if (escapeNext) {
            textBuffer.write(char);
            escapeNext = false;
          } else if (char == '\\') {
            escapeNext = true;
          } else if (char == '(' && lastChar == '\\') {
            // 发现 \( 开始的行内公式
            // 移除之前添加的反斜杠
            if (textBuffer.isNotEmpty) {
              textBuffer.write(lastChar);
              currentContent.write(textBuffer.toString().substring(0, textBuffer.length - 1));
              textBuffer.clear();
            }
            state = ParsingState.parenFormula;
            formulaBuffer.clear();
          } else if (char == '\$') {
            if (textBuffer.isNotEmpty) {
              currentContent.write(textBuffer.toString());
              textBuffer.clear();
            }
            state = ParsingState.dollarFormula;
            formulaBuffer.clear();
          } else {
            textBuffer.write(char);
          }
          break;

        case ParsingState.parenFormula:
          if (char == '\\') {
            escapeNext = true;
          } else if (char == ')' && lastChar == '\\' && !escapeNext) {
            // 公式结束
            // 移除最后的反斜杠
            final formula = formulaBuffer.toString();
            if (formula.length > 0) {
              final trimmedFormula = formula.substring(0, formula.length - 1).trim();
              if (trimmedFormula.isNotEmpty) {
                debugPrint('Found inline formula (parentheses): $trimmedFormula');
                currentContent.write('\\(${trimmedFormula}\\)');
                elements.add(ParsedMarkdownElement(
                  type: MarkdownElementType.latexInline,
                  rawContent: trimmedFormula,
                ));
              }
            }
            state = ParsingState.text;
          } else {
            if (escapeNext) {
              formulaBuffer.write('\\');
              escapeNext = false;
            }
            formulaBuffer.write(char);
          }
          break;

        case ParsingState.dollarFormula:
          if (char == '\$') {
            // 公式结束
            final formula = formulaBuffer.toString().trim();
            if (formula.isNotEmpty) {
              debugPrint('Found inline formula (dollar): $formula');
              currentContent.write('\\(${formula}\\)');
              elements.add(ParsedMarkdownElement(
                type: MarkdownElementType.latexInline,
                rawContent: formula,
              ));
            }
            state = ParsingState.text;
          } else {
            formulaBuffer.write(char);
          }
          break;

        default:
          break;
      }
      
      lastChar = char;
      pos++;
    }
    
    // 处理未闭合的公式
    if (state != ParsingState.text) {
      // 如果公式未闭合，将已缓存的内容作为普通文本处理
      if (state == ParsingState.parenFormula) {
        if (textBuffer.isNotEmpty) {
          currentContent.write(textBuffer.toString());
        }
        currentContent.write('\\(${formulaBuffer.toString()}');
      } else if (state == ParsingState.dollarFormula) {
        if (textBuffer.isNotEmpty) {
          currentContent.write(textBuffer.toString());
        }
        currentContent.write('\$${formulaBuffer.toString()}');
      }
    } else {
      // 添加剩余的文本
      if (textBuffer.isNotEmpty) {
        currentContent.write(textBuffer.toString());
      }
    }
    currentContent.write('\n');
  }
  
  /// 添加段落元素
  static void _addParagraph(List<ParsedMarkdownElement> elements, String content) {
    final trimmedContent = content.trim();
    if (trimmedContent.isNotEmpty) {
      elements.add(ParsedMarkdownElement(
        type: MarkdownElementType.paragraph,
        rawContent: trimmedContent,
      ));
    }
  }
}

/// 解析结果类
/// 包含解析的内容和下一个要处理的索引
class ParseResult {
  final String content;
  final int nextIndex;
  
  ParseResult({
    required this.content,
    required this.nextIndex,
  });
}

/// 解析后的Markdown元素
class ParsedMarkdownElement {
  final MarkdownElementType type;
  final String rawContent;
  
  ParsedMarkdownElement({
    required this.type,
    required this.rawContent,
  });
} 