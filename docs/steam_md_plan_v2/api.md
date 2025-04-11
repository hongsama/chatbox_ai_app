# 流式Markdown渲染系统 - API文档

## 1. 核心类定义

### 1.1 MarkdownTypes
```dart
class MarkdownTypes {
  // 标记类型定义映射
  static const Map<String, MarkdownElementType> markupTypes;
  
  // 核心方法定义
  static MarkdownElementType? getMarkupType(String text);
  static bool needsEndTag(MarkdownElementType type);
  static String? getEndTag(MarkdownElementType type);
  static bool isListMarker(String text);
  static ListProperties? getListProperties(String text);
}
```

### 1.2 解析状态定义
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

### 1.3 MarkdownContentParser
```dart
class MarkdownContentParser {
  // 状态管理
  ParsingState _state;
  StringBuffer _buffer;
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

## 2. 公共接口

### 2.1 基础元素接口
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
  
  // 获取元素状态的方法
  BaseMarkdownElementState createState();
  
  // 基础状态类
  @override
  State<BaseMarkdownElement> createState() => createState();
}

// 所有Markdown元素状态的基类
abstract class BaseMarkdownElementState<T extends BaseMarkdownElement> extends State<T> {
  // 核心接口方法：接收文本流
  void appendText(String text);
}
```

### 2.2 流式解析接口
```dart
// 流式解析算法
Stream<ParsedMarkdownElement> parseStream(Stream<String> input);
```

## 3. 组件API

### 3.1 MarkdownDisplayV2
```dart
class MarkdownDisplayV2 extends StatefulWidget {
  // 支持Stream或完整文本作为输入
  final dynamic input; // Stream<String>或String类型
  final MarkdownTheme? theme;
  
  const MarkdownDisplayV2({
    Key? key,
    required this.input,
    this.theme,  // 主题现在是可选的
  }) : super(key: key);
  
  // 访问默认主题
  static MarkdownTheme get defaultTheme => MarkdownTheme.light;
  
  @override
  State<MarkdownDisplayV2> createState() => _MarkdownDisplayV2State();
}

class _MarkdownDisplayV2State extends State<MarkdownDisplayV2> {
  void _setupInput();
  void _handleTextChunk(String text);
  void _createNewElement(MarkdownElementType type);
  
  @override
  Widget build(BuildContext context);
}
```

### 3.2 文本元素API
```dart
// 文本组件
class TextMarkdownElement extends BaseMarkdownElement {
  @override
  TextMarkdownElementState createState() => TextMarkdownElementState();
}

class TextMarkdownElementState extends BaseMarkdownElementState<TextMarkdownElement> {
  @override
  void appendText(String text);
  
  @override
  Widget build(BuildContext context);
}
```

### 3.3 代码块元素API
```dart
class CodeBlockMarkdownElement extends BaseMarkdownElement {
  final String? language;
  
  const CodeBlockMarkdownElement({Key? key, this.language}) 
      : super(key: key, elementType: MarkdownElementType.codeBlock);
  
  @override
  CodeBlockMarkdownElementState createState() => CodeBlockMarkdownElementState();
}

class CodeBlockMarkdownElementState extends BaseMarkdownElementState<CodeBlockMarkdownElement> {
  @override
  void appendText(String text);
  
  @override
  Widget build(BuildContext context);
}
```

### 3.4 其他元素API
- **HeadingMarkdownElement**：标题元素API，支持h1-h3
- **QuoteMarkdownElement**：引用块元素API
- **LaTeXInlineMarkdownElement**：行内公式元素API
- **LaTeXBlockMarkdownElement**：块级公式元素API
- **ListMarkdownElement**：列表元素API，支持有序和无序列表
- **DividerMarkdownElement**：分隔线元素API
- **ImageMarkdownElement**：图片元素API

## 4. 主题API

### 4.1 主题定义
```dart
class MarkdownTheme {
  // 文本样式
  final TextStyle textStyle;
  final TextStyle headingStyle;
  final TextStyle codeBlockStyle;
  final TextStyle quoteStyle;
  // ...其他样式属性
  
  // 主题构造函数
  const MarkdownTheme({
    required this.textStyle,
    required this.headingStyle,
    required this.codeBlockStyle,
    required this.quoteStyle,
    // ...其他样式属性
  });
  
  // 复制主题，覆盖部分属性
  MarkdownTheme copyWith({
    TextStyle? textStyle,
    TextStyle? headingStyle,
    TextStyle? codeBlockStyle,
    TextStyle? quoteStyle,
    // ...其他样式属性
  });
  
  // 深度复制方法，用于主题切换
  void copyFrom(MarkdownTheme other);
}
```

> **注意**: 每个MarkdownTheme实例代表一个完整的皮肤。主题切换通过copyFrom方法实现，将一个主题的所有属性深度复制到当前主题。预定义的亮色/暗色等主题将在后期设计阶段实现。

### 4.2 主题Provider
```dart
// 主题Provider，使用InheritedWidget传递主题
class MarkdownThemeProvider extends InheritedWidget {
  final MarkdownTheme theme;
  
  const MarkdownThemeProvider({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(key: key, child: child);
  
  // 获取当前主题
  static MarkdownTheme of(BuildContext context);
  
  @override
  bool updateShouldNotify(MarkdownThemeProvider oldWidget);
}
```

## 5. 使用示例

### 5.1 基本使用
```dart
// 1. 流式使用方式（不指定主题，使用默认主题）
MarkdownDisplayV2(
  input: textController.stream,
)

// 2. 流式使用方式（指定自定义主题）
MarkdownDisplayV2(
  input: textController.stream,
  theme: MarkdownTheme(
    textStyle: TextStyle(fontSize: 18.0, color: Colors.blue),
    // 其他样式...
  ),
)

// 3. 完整文本使用方式
MarkdownDisplayV2(
  input: """# 标题
这是**加粗**的文本
```
代码块
```""",
)

// 4. 流式内容发送示例
textController.add("这是");
textController.add("**");
textController.add("加粗");
textController.add("**");
textController.add("的文本");
```

### 5.2 主题使用
```dart
// 1. 使用默认主题
MarkdownDisplayV2(
  input: textController.stream,
)

// 2. 使用自定义主题
final customTheme = MarkdownTheme(
  textStyle: TextStyle(fontSize: 16.0, fontFamily: 'Roboto'),
  headingStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
  codeBlockStyle: TextStyle(fontFamily: 'Fira Code', fontSize: 14.0, backgroundColor: Colors.grey[200]),
  quoteStyle: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700], borderLeft: BorderSide(color: Colors.blue, width: 3.0)),
  // 其他样式...
);

MarkdownDisplayV2(
  input: textController.stream,
  theme: customTheme,
)

// 3. 基于现有主题自定义部分样式
final customizedTheme = existingTheme.copyWith(
  headingStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
  codeBlockStyle: TextStyle(fontFamily: 'Source Code Pro'),
);

MarkdownDisplayV2(
  input: textController.stream,
  theme: customizedTheme,
)

// 4. 主题切换示例（通过深度复制实现）
void switchTheme(MarkdownDisplayV2 display, MarkdownTheme newTheme) {
  // 将新主题的所有属性深度复制到当前主题
  display.theme.copyFrom(newTheme);
}
```

---

## 相关文档

- [概述](./overview.md) - 项目背景、需求和整体架构
- [组件设计](./components.md) - 组件分类与设计原则
- [实现计划](./implementation.md) - 数据处理流程和算法实现
- [项目规划](./project.md) - 项目结构和进度跟踪 