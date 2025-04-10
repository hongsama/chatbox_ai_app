/// Markdown元素类型枚举
/// 
/// 定义了所有支持的Markdown元素类型
/// 作为全局通用枚举，避免各组件重复创建类似枚举
///
/// 元素类型分为三类：
/// 1. 块级元素：独占一行或多行的元素，如标题、代码块等
/// 2. 行内元素：嵌入在文本中的元素，如链接、行内公式等
/// 3. 特殊标记：用于标记特定元素的开始或结束
enum MarkdownElementType {
  // 块级元素
  text,              // 普通文本，不包含特殊Markdown标记的纯文本内容
  heading1,          // 一级标题，使用 # 标记
  heading2,          // 二级标题，使用 ## 标记
  heading3,          // 三级标题，使用 ### 标记
  codeBlock,         // 代码块，使用 ``` 包围的代码内容
  blockFormula,      // 块级公式，使用 $$ 包围的数学公式
  quote,             // 引用，使用 > 标记的引用内容
  unorderedList,     // 无序列表，使用 -、* 或 + 标记的列表项
  orderedList,       // 有序列表，使用数字+点标记的列表项
  divider,           // 分隔线，使用 ---、*** 或 ___ 标记
  
  // 行内元素
  inlineFormula,     // 行内公式，使用单个 $ 包围的数学公式
  link,              // 链接，使用 [文本](URL) 格式
  image,             // 图片，使用 ![替代文本](图片URL) 格式
  
  // 特殊标记
  blockFormulaStart, // 块级公式开始标记 $$
  blockFormulaEnd,   // 块级公式结束标记 $$
  inlineFormulaStart,// 行内公式开始标记 $
  inlineFormulaEnd,  // 行内公式结束标记 $
} 