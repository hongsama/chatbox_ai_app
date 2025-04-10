# 流式Markdown渲染系统 - 组件设计与分类

## 1. 核心模块

### 1.1 MarkdownTypes
```dart
// 定义Markdown元素类型及标记识别
class MarkdownTypes {
  // 标记类型定义映射
  static const Map<String, MarkdownElementType> markupTypes = {
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
  
  // 核心方法定义
  static MarkdownElementType? getMarkupType(String text);
  static bool needsEndTag(MarkdownElementType type);
  static String? getEndTag(MarkdownElementType type);
  static bool isListMarker(String text);
  static ListProperties? getListProperties(String text);
}
```

### 1.2 MarkdownContentParser
```dart
// 流式内容解析器
class MarkdownContentParser {
  // 状态管理
  ParsingState _state = ParsingState.text;
  StringBuffer _buffer = StringBuffer();
  ActiveComponent? _activeComponent;
  
  // 核心流处理方法
  Stream<ParsedMarkdownElement> parseStream(Stream<String> input);
  List<ParsedMarkdownElement> parseChunk(String chunk);
  
  // 辅助方法
  void _handleSpecialMarkers(String text);
  void _processBuffer();
  void _updateState(ParsingState newState);
}
```

### 1.3 MarkdownDisplayV2
```dart
// 流式Markdown展示组件
class MarkdownDisplayV2 extends StatefulWidget {
  // 支持Stream或完整文本作为输入
  final dynamic input; // Stream<String>或String类型
  final MarkdownTheme? theme;
  
  @override
  State<MarkdownDisplayV2> createState() => _MarkdownDisplayV2State();
}
```

## 2. 状态管理

### 2.1 解析状态
```dart
enum ParsingState {
  text,              // 普通文本
  inlineFormula,     // 行内公式
  blockFormula,      // 块级公式
  codeBlock,         // 代码块
  quote,             // 引用
  unorderedList,     // 无序列表
  orderedList,       // 有序列表
  heading1,          // 一级标题
  heading2,          // 二级标题
  heading3,          // 三级标题
  link,              // 链接
  image,             // 图片
}
```

## 3. 组件分类

### 3.1 文本处理组件
- 处理普通文本并识别内联样式
- 识别并应用加粗(`**text**`)、斜体(`*text*`、`_text_`)、加粗斜体(`***text***`)等样式
- 特性：在组件内部处理样式标记，避免外部状态管理的复杂性

### 3.2 独立渲染组件
- 分隔线(`---`、`***`、`___`)
- 图片(`![](...)`)
- 特性：渲染后即结束，不需要等待结束标记

### 3.3 容器组件
- 标题(`#`、`##`、`###`)
- 代码块(` ``` `)
- 数学公式块(`\\[`、`\\]`)
- 引用块(`>`)
- 特性：需要持续接收内容直到遇到结束标记

### 3.4 特殊处理组件
- 列表组件：
  - 自动识别列表标记(`-`、`*`、`+`、`1.`等)
  - 处理缩进与嵌套
  - 维护列表项的连续性
  - 支持混合列表（有序+无序）
  - 特性：基于行首标记和缩进级别进行处理

## 4. 基础元素接口

```dart
// 所有Markdown元素的基类
abstract class BaseMarkdownElement extends StatefulWidget {
  // 元素类型
  final MarkdownElementType elementType;
  
  // 创建一个基础Markdown元素
  const BaseMarkdownElement({
    Key? key,
    required this.elementType,
  }) : super(key: key);
  
  // 文本缓冲区，用于存储接收到的文本
  final StringBuffer _buffer = StringBuffer();
  
  // 接收文本流的方法
  void appendText(String text) {
    // 默认实现：将文本添加到缓冲区
    _buffer.append(text);
    // 子类通常需要在此方法中调用setState以更新UI
  }
  
  // 获取当前文本内容的方法
  String getText() => _buffer.toString();
}
```

基础元素组件设计原则：
1. **简单接口**：只提供必要的`appendText`方法接口，简化组件间交互
2. **统一类型**：通过`elementType`属性标识元素类型
3. **状态管理自治**：各子类负责自己的状态管理，无需复杂的全局状态
4. **流式处理**：设计支持流式文本输入，渐进式构建内容 