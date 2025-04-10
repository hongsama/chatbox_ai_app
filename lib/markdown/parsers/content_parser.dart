import 'dart:async';
import '../types/markdown_element_type.dart';
import '../types/parsing_state.dart';

/// Markdown内容解析器
/// 
/// 负责解析Markdown文本内容，识别各种Markdown标记和元素。
/// 提供一次性解析功能，能够识别文本中的Markdown标记并返回对应的元素类型。
///
/// 该解析器能够识别多种Markdown元素类型，包括：
/// - 标题（H1-H3）
/// - 代码块
/// - 分隔线
/// - 引用块
/// - 数学公式（行内和块级）
class MarkdownContentParser {
  /// Markdown标记类型定义映射
  /// 
  /// 将Markdown语法标记字符串映射到对应的元素类型
  /// 例如：'#' 映射到 MarkdownElementType.heading1
  static const Map<String, MarkdownElementType> _markupTypes = {
    '###': MarkdownElementType.heading3,
    '##': MarkdownElementType.heading2,
    '#': MarkdownElementType.heading1,
    '```': MarkdownElementType.codeBlock,
    '---': MarkdownElementType.divider,
    '***': MarkdownElementType.divider,
    '___': MarkdownElementType.divider,
    '>': MarkdownElementType.quote,
    '\\[': MarkdownElementType.blockFormulaStart,
    '\\]': MarkdownElementType.blockFormulaEnd,
    '\\(': MarkdownElementType.inlineFormulaStart,
    '\\)': MarkdownElementType.inlineFormulaEnd,
  };
  
  /// 直接解析文本
  /// 
  /// 一次性解析输入文本，返回识别出的第一个Markdown元素类型及相关信息。
  /// 这是一个简化版本的解析器，只检测一个标记并立即返回。
  /// 
  /// 参数:
  /// - text: 要解析的文本内容
  /// 
  /// 返回:
  /// 包含以下字段的Map:
  /// - 'text': 原始文本
  /// - 'element': 检测到的Markdown元素类型
  /// - 'isMarkup': 是否检测到了Markdown标记
  Map<String, dynamic> parseText(String text) {
    // 默认为普通文本
    MarkdownElementType elementType = MarkdownElementType.text;
    bool isMarkup = false;
    
    // 检查每个标记
    for (var entry in _markupTypes.entries) {
      String marker = entry.key;
      if (text.contains(marker)) {
        // 检测到标记
        elementType = entry.value;
        isMarkup = true;
        break; // 找到一个标记就退出循环
      }
    }
    
    // 返回解析结果
    return {
      'text': text,
      'element': elementType,
      'isMarkup': isMarkup,
    };
  }
  
  /// 获取标记类型的可读描述
  /// 
  /// 将元素类型枚举转换为人类可读的描述文本
  /// 
  /// 参数:
  /// - type: Markdown元素类型
  /// 
  /// 返回:
  /// 元素类型的可读描述
  String _getMarkupTypeDescription(MarkdownElementType type) {
    switch (type) {
      case MarkdownElementType.heading1:
        return '一级标题标记';
      case MarkdownElementType.heading2:
        return '二级标题标记';
      case MarkdownElementType.heading3:
        return '三级标题标记';
      case MarkdownElementType.codeBlock:
        return '代码块标记';
      case MarkdownElementType.divider:
        return '分隔线标记';
      case MarkdownElementType.quote:
        return '引用标记';
      case MarkdownElementType.blockFormulaStart:
        return '块级公式开始标记';
      case MarkdownElementType.blockFormulaEnd:
        return '块级公式结束标记';
      case MarkdownElementType.inlineFormulaStart:
        return '行内公式开始标记';
      case MarkdownElementType.inlineFormulaEnd:
        return '行内公式结束标记';
      default:
        return '未知标记';
    }
  }
}

/// 解析后的Markdown元素
/// 
/// 表示解析后的单个Markdown元素，包含其类型和内容
/// 用于在解析过程和显示组件之间传递解析结果
class ParsedMarkdownElement {
  /// 元素类型
  /// 
  /// 表示该元素的Markdown类型（如标题、代码块等）
  final MarkdownElementType type;
  
  /// 元素内容
  /// 
  /// 元素的原始文本内容
  final String content;
  
  /// 是否为调试信息
  /// 
  /// 标记该元素是否包含调试信息，用于开发调试
  final bool isDebug;
  
  /// 创建一个解析后的Markdown元素
  /// 
  /// 参数:
  /// - type: 元素类型
  /// - content: 元素内容
  /// - isDebug: 是否为调试信息，默认为false
  ParsedMarkdownElement({
    required this.type,
    required this.content,
    this.isDebug = false,
  });
} 