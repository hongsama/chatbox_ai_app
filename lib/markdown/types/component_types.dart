/// Markdown组件类型枚举
/// 
/// 定义了所有需要特殊处理的Markdown组件类型
/// 普通文本、内联样式、标题和图片使用flutter_markdown处理
enum MarkdownComponentType {
  /// 文本组件，使用flutter_markdown处理所有文本、内联样式、标题和图片
  text,
  
  /// 代码块组件
  /// 开始：'```' 或 '```language'
  /// 结束：'```'
  codeBlock,
  
  /// LaTeX公式组件
  /// 开始：'$' 或 '\('
  /// 结束：'$' 或 '\)'
  latexInline,
  /// 开始：'$$' 或 '\['
  /// 结束：'$$' 或 '\]'
  latexBlock,
}

/// 文本组件需要解析的类型
/// 这些类型在text组件内部处理，不会触发组件切换
enum TextComponentType {
  /// 普通文本
  normal,
  
  /// 加粗文本
  bold,
  
  /// 斜体文本
  italic,
  
  /// 删除线文本
  strikethrough,
  
  /// 行内代码
  inlineCode,
  
  /// 链接
  link,
  
  /// 无序列表项
  unorderedListItem,
  
  /// 有序列表项
  orderedListItem,
  
  /// 引用
  quote,
  
  /// 分隔线
  divider,
}

/// 文本组件需要解析的头部标记
/// 这些标记在text组件内部处理，不会触发组件切换
class TextComponentMarkers {
  /// 加粗标记
  static const List<String> bold = ['**', '__'];
  
  /// 斜体标记
  static const List<String> italic = ['*', '_'];
  
  /// 删除线标记
  static const List<String> strikethrough = ['~~'];
  
  /// 行内代码标记
  static const List<String> inlineCode = ['`'];
  
  /// 链接标记
  static const List<String> link = ['['];
  
  /// 列表标记
  static const List<String> unorderedList = ['- ', '* ', '+ '];
  static const List<String> orderedList = ['1. ', '2. ', '3. ', '4. ', '5. ', '6. ', '7. ', '8. ', '9. '];
  
  /// 引用标记
  static const List<String> quote = ['> '];
  
  /// 分隔线标记
  static const List<String> divider = ['---', '***', '___'];
  
  /// 获取所有文本组件需要解析的标记
  static List<String> get allMarkers => [
    ...bold,
    ...italic,
    ...strikethrough,
    ...inlineCode,
    ...link,
    ...unorderedList,
    ...orderedList,
    ...quote,
    ...divider,
  ];
} 