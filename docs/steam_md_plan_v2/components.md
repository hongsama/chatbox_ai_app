# 流式Markdown渲染系统 - 组件设计

## 1. 基础组件设计原则

1. **简单接口**：只提供必要的`appendText`方法接口，由子类实现具体处理逻辑
2. **统一类型**：通过`componentType`属性标识组件类型
3. **状态管理自治**：各子类负责自己的状态管理，无需复杂的全局状态
4. **流式处理**：设计支持流式文本输入，由子类决定如何处理接收到的文本

## 2. 元素组件分类

### 2.1 文本处理组件
- **描述**：处理普通文本并识别内联样式
- **功能**：识别并应用加粗(`**text**`)、斜体(`*text*`、`_text_`)、加粗斜体(`***text***`)等样式
- **特性**：在组件内部处理样式标记，避免外部状态管理的复杂性
- **实现类**：`TextMarkdownElement`
- **组件类型**：`MarkdownComponentTypes.text`

### 2.2 独立渲染组件
- **分隔线组件**：渲染水平分隔线(`---`、`***`、`___`)
- **图片组件**：渲染图片元素(`![](...)`)
- **特性**：渲染后即结束，不需要等待结束标记
- **实现类**：`DividerMarkdownElement`, `ImageMarkdownElement`
- **组件类型**：`MarkdownComponentTypes.divider`, `MarkdownComponentTypes.image`

### 2.3 容器组件
- **标题组件**：处理标题元素(`#`、`##`、`###`)
- **代码块组件**：处理代码块元素(` ``` `)，支持语法高亮
- **数学公式组件**：处理行内公式(`\\(`, `\\)`)和块级公式(`\\[`, `\\]`)
- **引用组件**：处理引用块元素(`>`)
- **特性**：需要持续接收内容直到遇到结束标记
- **实现类**：`HeadingMarkdownElement`, `CodeBlockMarkdownElement`, `LaTeXInlineMarkdownElement`, `LaTeXBlockMarkdownElement`, `QuoteMarkdownElement`
- **组件类型**：`MarkdownComponentTypes.h1/h2/h3`, `MarkdownComponentTypes.codeBlock`, `MarkdownComponentTypes.latexInline`, `MarkdownComponentTypes.latexBlock`, `MarkdownComponentTypes.quote`

### 2.4 特殊处理组件
- **列表组件**：处理有序和无序列表
  - 自动识别列表标记(`-`、`*`、`+`、`1.`等)
  - 处理缩进与嵌套
  - 维护列表项的连续性
  - 支持混合列表（有序+无序）
  - 特性：基于行首标记和缩进级别进行处理
- **实现类**：`ListMarkdownElement`
- **组件类型**：`MarkdownComponentTypes.orderedList`, `MarkdownComponentTypes.unorderedList`

## 3. 组件类型定义

在实现具体组件前，我们首先定义一个独立的组件类型系统：

```dart
/// Markdown组件类型定义
class MarkdownComponentTypes {
  // 私有构造函数，防止实例化
  MarkdownComponentTypes._();

  // 文本元素类型
  static const String text = 'text';
  
  // 标题元素类型
  static const String h1 = 'h1';
  static const String h2 = 'h2';
  static const String h3 = 'h3';
  
  // 代码块元素类型
  static const String codeBlock = 'code_block';
  
  // 引用元素类型
  static const String quote = 'quote';
  
  // 列表元素类型
  static const String orderedList = 'ordered_list';
  static const String unorderedList = 'unordered_list';
  
  // 分隔线元素类型
  static const String divider = 'divider';
  
  // 图片元素类型
  static const String image = 'image';
  
  // LaTeX公式元素类型
  static const String latexInline = 'latex_inline';
  static const String latexBlock = 'latex_block';
  
  // 获取所有元素类型列表
  static List<String> get allTypes => [
    text, h1, h2, h3, codeBlock, quote, 
    orderedList, unorderedList, divider, 
    image, latexInline, latexBlock
  ];
}
```

## 4. 组件接口设计

### 4.1 基础组件接口

所有Markdown元素组件继承自BaseMarkdownElement，并通过MarkdownElement接口定义核心功能：

```dart
/// Markdown元素接口
abstract class MarkdownElement extends Widget {
  /// 获取组件类型
  String get componentType;
  
  /// 向元素追加文本
  void appendText(String text);
}

/// 基础Markdown元素组件
class BaseMarkdownElement extends StatefulWidget implements MarkdownElement {
  final String componentType;
  final String text;
  final MarkdownTheme theme;
  
  BaseMarkdownElement({
    Key? key,
    required this.componentType,
    required this.text,
    required this.theme,
  }) : super(key: key ?? GlobalKey<BaseMarkdownElementState>());

  @override
  State<BaseMarkdownElement> createState() => BaseMarkdownElementState();
  
  @override
  void appendText(String text) {
    final state = (key as GlobalKey<BaseMarkdownElementState>).currentState;
    state?.appendText(text);
  }
}
```

### 4.2 元素状态管理

BaseMarkdownElement的状态类负责管理文本内容和主题响应：

```dart
class BaseMarkdownElementState extends State<BaseMarkdownElement> {
  String _text = '';
  
  @override
  void initState() {
    super.initState();
    _text = widget.text;
    
    // 注册主题回调
    widget.theme.registerCallback(_onThemeChanged);
  }
  
  @override
  void dispose() {
    // 注销主题回调
    widget.theme.unregisterCallback(_onThemeChanged);
    super.dispose();
  }
  
  void appendText(String text) {
    if (mounted) {
      setState(() {
        _text += text;
      });
    }
  }
  
  /// 主题变更回调
  void _onThemeChanged() {
    if (mounted) {
      setState(() {
        // 主题变更时重新构建UI
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // 根据组件类型获取样式
    final style = widget.theme.getStyleForType(widget.componentType);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SelectableText(
        _text,
        style: TextStyle(
          color: style.color,
          fontSize: style.fontSize,
          fontWeight: style.fontWeight,
          height: style.lineHeight,
        ),
      ),
    );
  }
}
```

### 4.3 组件类型映射系统

通过ComponentRegistry类管理组件类型到组件类的映射：

```dart
class ComponentRegistry {
  /// 私有构造函数，防止实例化
  ComponentRegistry._();
  
  /// 从组件类型获取对应的组件类
  static Type getComponentType(String componentType) {
    return _typeMap[componentType] ?? BaseMarkdownElement;
  }
  
  /// 创建对应类型的组件实例
  static Widget createElement(String componentType, {
    required String text,
    required MarkdownTheme theme,
  }) {
    switch (componentType) {
      case MarkdownComponentTypes.text:
        return TextMarkdownElement(
          componentType: componentType,
          text: text,
          theme: theme,
        );
      case MarkdownComponentTypes.h1:
      case MarkdownComponentTypes.h2:
      case MarkdownComponentTypes.h3:
        return HeadingMarkdownElement(
          componentType: componentType,
          text: text,
          theme: theme,
        );
      // 其他组件类型映射...
      default:
        return BaseMarkdownElement(
          componentType: componentType,
          text: text,
          theme: theme,
        );
    }
  }
  
  /// 组件类型到组件类的映射
  static final Map<String, Type> _typeMap = {
    MarkdownComponentTypes.text: TextMarkdownElement,
    MarkdownComponentTypes.h1: HeadingMarkdownElement,
    MarkdownComponentTypes.h2: HeadingMarkdownElement,
    MarkdownComponentTypes.h3: HeadingMarkdownElement,
    // 其他映射...
  };
}
```

## 5. 组件继承关系

```
flowchart TD
    A[BaseMarkdownElement] --> B[TextMarkdownElement]
    A --> C[HeadingMarkdownElement]
    A --> D[CodeBlockMarkdownElement]
    A --> E[QuoteMarkdownElement]
    A --> F[ListMarkdownElement]
    A --> G[DividerMarkdownElement]
    A --> H[ImageMarkdownElement]
    A --> I[LaTeXInlineMarkdownElement]
    A --> J[LaTeXBlockMarkdownElement]
```

## 6. 组件类型说明

### 6.1 文本组件 (TextMarkdownElement)
- 处理普通文本内容
- 负责解析并渲染内联样式标记
- 通过内部状态管理记录样式变化
- 从主题系统获取文本样式属性
- **组件类型**: `MarkdownComponentTypes.text`

### 6.2 标题组件 (HeadingMarkdownElement)
- 支持1-3级标题
- 根据标题级别应用不同大小和样式
- 完整接收整行内容作为标题文本
- 从主题系统获取对应级别的标题样式
- **组件类型**: `MarkdownComponentTypes.h1`, `MarkdownComponentTypes.h2`, `MarkdownComponentTypes.h3`

### 6.3 代码块组件 (CodeBlockMarkdownElement)
- 支持可选的语言标签
- 处理代码块内部的文本，保留格式
- 根据语言提供语法高亮支持
- 从主题系统获取代码块样式
- **组件类型**: `MarkdownComponentTypes.codeBlock`

### 6.4 引用组件 (QuoteMarkdownElement)
- 处理引用块内容
- 支持多行引用
- 应用特定的引用样式（如左侧边框）
- 从主题系统获取引用样式
- **组件类型**: `MarkdownComponentTypes.quote`

### 6.5 列表组件 (ListMarkdownElement)
- 处理有序和无序列表
- 支持嵌套列表结构
- 维护列表项的序号和层级关系
- 从主题系统获取列表样式
- **组件类型**: `MarkdownComponentTypes.orderedList`, `MarkdownComponentTypes.unorderedList`

### 6.6 LaTeX公式组件
- 行内公式组件 (LaTeXInlineMarkdownElement): 处理内联数学公式
- 块级公式组件 (LaTeXBlockMarkdownElement): 处理独立块级数学公式
- 各自从主题系统获取对应的公式样式
- **组件类型**: `MarkdownComponentTypes.latexInline`, `MarkdownComponentTypes.latexBlock`

## 7. 组件交互流程

### 7.1 数据流转机制
```
flowchart LR
    A[MarkdownDisplayV3] -->|appendText| B[BaseMarkdownElement子类]
    B -->|setState| C[更新UI]
```

### 7.2 流式处理流程
1. `MarkdownDisplayV3`接收流式文本输入
2. `MarkdownContentParser`解析输入并识别组件类型
3. `MarkdownDisplayV3`根据组件类型创建或获取对应的组件
4. 通过`appendText`方法将文本传递给组件
5. 组件处理文本并更新内部状态
6. 组件通过`setState`触发界面更新

### 7.3 组件管理策略
- 组件在创建后会被添加到`MarkdownDisplayV3`的组件列表中
- 每个组件独立处理自己的状态更新
- 当识别到新的标记时，创建新的组件
- 特殊组件（如代码块、引用等）在遇到结束标记前持续接收文本

## 8. 组件生命周期

### 8.1 组件创建
- 在识别到标记时由`MarkdownDisplayV3`创建对应组件
- 初始化组件所需的参数（如标题级别、列表类型）
- 将组件加入组件树
- 组件获取Display实例并注册主题回调

### 8.2 内容接收阶段
- 组件通过`appendText`接收流式文本
- 根据内容更新内部状态
- 特殊组件处理换行和格式标记

### 8.3 渲染阶段
- 根据当前状态和内容进行渲染
- 应用主题样式
- 处理特殊格式和样式

### 8.4 组件结束
- 检测结束标记（如代码块的结束标记）
- 完成最终渲染
- 通知Display当前组件已完成处理

### 8.5 组件销毁
- Display移除对组件的引用
- 组件注销主题回调
- 释放占用的资源

## 9. 组件渲染策略

### 9.1 内联样式渲染
- 使用正则表达式识别内联样式标记
- 将文本分割成有样式和无样式的片段
- 为每个片段应用相应的样式
- 处理嵌套样式（如加粗中的斜体）

### 9.2 代码块渲染
- 保留原始格式和缩进
- 根据指定的语言应用语法高亮
- 使用等宽字体和特殊背景
- 支持水平滚动

### 9.3 LaTeX公式渲染
- 使用专门的LaTeX渲染库
- 行内公式和块级公式使用不同的布局
- 支持数学符号和公式结构

### 9.4 列表渲染
- 根据列表类型显示不同的标记
- 处理嵌套缩进和层级
- 维护序号和项目符号的一致性

## 10. 实现顺序

为确保系统的渐进式开发，组件实现将按以下顺序进行：

1. **类型定义**:
   - 首先定义组件类型常量文件
   - 建立组件类型和渲染组件的映射关系

2. **基础组件**:
   - 实现BaseMarkdownElement
   - 建立与主题系统的连接

3. **核心组件**:
   - TextMarkdownElement (文本)
   - HeadingMarkdownElement (标题)

4. **结构组件**:
   - CodeBlockMarkdownElement (代码块)
   - QuoteMarkdownElement (引用)
   - ListMarkdownElement (列表)

5. **特殊组件**:
   - LaTeXInlineMarkdownElement (行内公式)
   - LaTeXBlockMarkdownElement (块级公式)
   - DividerMarkdownElement (分隔线)
   - ImageMarkdownElement (图片)

## 11. 技术实现注意事项

1. **状态管理**: 每个组件负责管理自己的状态，避免全局状态管理的复杂性
2. **主题响应**: 所有组件需要正确响应主题变化
3. **性能优化**: 最小化重绘范围，使用缓存策略
4. **内存管理**: 组件在不需要时及时释放资源
5. **流式处理**: 设计支持流式文本输入，避免阻塞UI线程
6. **错误处理**: 提供合理的降级渲染方案，确保系统稳定性

---

## 相关文档

- [概述](./overview.md) - 项目背景、需求和整体架构
- [API文档](./api.md) - 接口定义和使用方法
- [实现计划](./implementation.md) - 数据处理流程和算法实现
- [项目规划](./project.md) - 项目结构和进度跟踪

## 6. 组件开发进度

### 6.1 已完成组件

1. **基础框架**
   - ✅ MarkdownElement接口
   - ✅ BaseMarkdownElement基础组件
   - ✅ ElementThemeBehavior主题行为混入
   - ✅ ComponentTypes组件类型映射

2. **核心组件**
   - ✅ MarkdownDisplayV3（基础结构）

### 6.2 进行中组件

1. **完善基础组件**
   - 🔲 组件渲染逻辑集成
   - 🔲 主题交互完善
   - 🔲 状态更新优化

2. **特定元素组件开发准备**
   - 🔲 TextMarkdownElement设计
   - 🔲 HeadingMarkdownElement设计
   - 🔲 其他特定元素组件规划 