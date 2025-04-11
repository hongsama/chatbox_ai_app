/// Markdown元素类型枚举
/// 
/// 定义了所有需要特殊处理的Markdown元素类型
/// 普通文本、内联样式、标题、图片、列表、引用和分隔线使用flutter_markdown处理
///
/// 元素类型分为两类：
/// 1. 块级元素：独占一行或多行的元素，如代码块等
/// 2. 特殊标记：用于标记特定元素的开始或结束
enum MarkdownElementType {
  // 块级元素
  text,              // 普通文本，当检测不到特殊标记时使用
  codeBlock,         // 代码块，使用 ``` 包围的代码内容
  
  // 特殊标记
  blockFormulaStart, // 块级公式开始标记 $$ 或 \[
  blockFormulaEnd,   // 块级公式结束标记 $$ 或 \]
} 