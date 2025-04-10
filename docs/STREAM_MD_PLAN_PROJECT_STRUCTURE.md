# 流式Markdown渲染系统 - 项目结构

## 1. 文件结构图
```
lib/
└── markdown/                    # 流式Markdown模块根目录
    ├── index.dart               # 模块入口与导出
    ├── stream_markdown.dart     # 流式Markdown主入口组件
    ├── types/                   # 类型定义
    │   ├── markdown_types.dart  # Markdown类型定义
    │   └── parsing_state.dart   # 解析状态定义
    ├── parsers/                 # 解析器
    │   ├── content_parser.dart  # 主内容解析器
    │   ├── inline_parser.dart   # 内联样式解析器
    │   ├── code_parser.dart     # 代码块解析器
    │   └── latex_parser.dart    # LaTeX公式解析器
    ├── widgets/                 # UI组件
    │   ├── markdown_display.dart # 主显示组件
    │   └── elements/            # 元素渲染组件
    │       ├── text_widget.dart  # 文本渲染组件(处理内联样式)
    │       ├── heading_widget.dart # 标题组件
    │       ├── code_block_widget.dart # 代码块组件
    │       ├── quote_widget.dart # 引用组件
    │       ├── list_widget.dart  # 列表组件
    │       ├── divider_widget.dart # 分隔线组件
    │       ├── image_widget.dart # 图片组件
    │       ├── latex_inline_widget.dart # 行内公式组件
    │       └── latex_block_widget.dart  # 块级公式组件
    ├── data/                    # 测试和示例数据
    │   └── content_array.dart   # Markdown内容示例数据(保留现有文件)
    ├── utils/                   # 工具类
    │   ├── text_splitter.dart   # 文本分割工具
    │   └── style_manager.dart   # 样式管理工具
    └── examples/                # 示例页面
        ├── stream_demo_screen.dart # 流式演示页面
        └── full_demo_screen.dart   # 完整功能演示页面
```

## 2. 文件职责说明

### 2.1 核心文件

#### 2.1.1 入口文件
- **index.dart**: 统一导出接口，方便外部引用
- **stream_markdown.dart**: 流式Markdown主入口组件，对外暴露的主要API

#### 2.1.2 类型定义
- **markdown_types.dart**: 定义Markdown元素类型枚举和相关工具函数
- **parsing_state.dart**: 定义解析状态枚举和状态转换逻辑

#### 2.1.3 解析器
- **content_parser.dart**: 主内容解析器，处理流式输入和标记识别
- **inline_parser.dart**: 内联样式解析器，处理加粗、斜体等内联格式
- **code_parser.dart**: 代码块解析器，处理代码语言识别和语法高亮
- **latex_parser.dart**: LaTeX公式解析器，处理数学公式渲染

#### 2.1.4 UI组件
- **markdown_display.dart**: 主显示组件，协调整体渲染逻辑
- **elements/**: 各类元素渲染组件目录

### 2.2 元素组件

#### 2.2.1 基础组件
- **base_element.dart**: 基础元素组件接口，所有具体元素组件的父类

#### 2.2.2 文本处理组件
- **text_widget.dart**: 普通文本渲染，处理内联样式

#### 2.2.3 结构组件
- **heading_widget.dart**: 标题组件(h1-h3)
- **quote_widget.dart**: 引用块组件
- **list_widget.dart**: 列表组件(有序/无序)

#### 2.2.4 特殊内容组件
- **code_block_widget.dart**: 代码块组件
- **latex_inline_widget.dart**: 行内公式组件
- **latex_block_widget.dart**: 块级公式组件
- **divider_widget.dart**: 分隔线组件
- **image_widget.dart**: 图片组件

### 2.3 工具类
- **text_splitter.dart**: 文本分割工具，处理流式输入的分段和合并
- **style_manager.dart**: 样式管理工具，处理主题和样式配置

## 3. 迁移计划

### 3.1 保留并重构的文件
- `markdown_element.dart` → `types/markdown_types.dart`
- `markdown_display.dart` → `widgets/markdown_display.dart`
- `content_array.dart` → 保留在`data/content_array.dart`(包含数学公式和Markdown示例)
- 各元素渲染组件 → 对应的新组件文件

### 3.2 新增文件
- `stream_markdown.dart`：新的流式渲染入口
- `content_parser.dart`：流式内容解析器
- `parsing_state.dart`：解析状态定义
- `text_splitter.dart`：文本分割工具

### 3.3 需删除的文件
- 旧版解析器实现
- 旧版状态管理相关代码 