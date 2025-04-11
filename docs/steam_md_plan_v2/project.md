# 流式Markdown渲染系统 - 项目规划

## 1. 迁移计划

### 1.1 保留并重构的文件
- `markdown_element.dart` → `types/markdown_types.dart`
- `markdown_display.dart` → `widgets/markdown_display.dart`
- `content_array.dart` → 保留在`data/content_array.dart`(包含数学公式和Markdown示例)
- 各元素渲染组件 → 对应的新组件文件

### 1.2 新增文件
- `stream_markdown.dart`：新的流式渲染入口
- `content_parser.dart`：流式内容解析器
- `parsing_state.dart`：解析状态定义
- `text_splitter.dart`：文本分割工具
- `markdown_theme.dart`：主题定义类（包含默认主题配置）
- `theme_provider.dart`：主题传递Provider

### 1.3 需删除的文件
- 旧版解析器实现
- 旧版状态管理相关代码

## 2. 实施计划与进度跟踪

### 2.1 阶段一：基础结构搭建 v1 ✅
- ✅ 创建 `lib/markdown` 目录结构
- ✅ 按照文件结构规划创建基础文件
- ✅ 创建新的演示页面 `MarkdownStreamScreen`
- ✅ 在 `main.dart` 中替换原有Markdown显示为新创建的组件
- ✅ 编写项目入口文件 `index.dart`

### 2.2 阶段二：基础文本显示功能  ✅
- ✅ 创建基础的 `MarkdownDisplayV2` 组件
- ✅ 将 `data/content_array.dart` 移动到新目录结构
- ✅ 实现基础文本拼接逻辑，将流式输入字符串拼接显示
- ✅ 测试组件能正确接收并显示完整文本（不解析标记）
- ✅ 添加简单的布局和样式

### 2.3 阶段三：标记识别与调试输出 v2 ✅
- ✅ 实现基础标记识别功能（不改变UI渲染）
- ✅ 在识别到标记时输出调试信息，如：
  - 遇到 `---` 在文本前加入 "找到分隔符"
  - 遇到 ``` 加入 "找到代码块起始/结束"
  - 遇到 `#` 加入 "找到标题标记"
- ✅ 识别LaTeX公式标记如 `\\[`, `\\]`, `\\(`, `\\)`
- ✅ 实现基础状态管理，跟踪当前解析状态

### 2.4 阶段四：基础组件实现与UI集成 v3 🔲
- ✅ 创建MarkdownDisplayV3组件，替代V2版本
- 🔲 更改MarkdownDisplayV3组件
  - ✅ 实现BaseMarkdownElement基础组件（仅显示输入的文本流）
  - 🔲 改写_processMarkdownElement方法，根据元素类型创建BaseMarkdownElement实例
  - 🔲 逐个创建子类Element替换BaseMarkdownElement：
    - 🔲 实现TextMarkdownElement（含内联样式处理）
    - 🔲 实现HeadingMarkdownElement（一级、二级、三级）
    - 🔲 实现CodeBlockMarkdownElement（含语法高亮）
    - 🔲 实现QuoteMarkdownElement
    - 🔲 实现ListMarkdownElement（有序、无序、嵌套）
    - 🔲 实现DividerMarkdownElement
    - 🔲 实现LatexInlineMarkdownElement
    - 🔲 实现LatexBlockMarkdownElement
    - 🔲 实现ImageMarkdownElement
  - 🔲 每个子类Element通过不同文字颜色区分
  - 🔲 逐步完善各个Element的具体实现
  - 🔲 最终完成完整Markdown渲染功能

### 2.5 阶段五：主题系统实现 v4 ��
- 🔲 主题系统实现计划（待定）

### 2.6 阶段六：主题系统完善 v4🔲
- 🔲 完善主题系统，添加更多主题选项
- 🔲 实现主题属性批量更新功能
- 🔲 添加主题深度复制功能
- 🔲 优化主题回调注册和通知机制
- 🔲 测试多实例下的主题隔离性
- 🔲 测试主题切换功能

### 2.7 阶段七：完整文本处理优化 🔲
- 🔲 优化处理完整或较长Markdown文本的逻辑
- 🔲 实现按行分割文本算法
- 🔲 在文本中查找并提取Markdown标记
- 🔲 根据标记将文本切割成数组
- 🔲 优化解析器处理大块文本的性能

### 2.8 阶段八：测试与完善 🔲
- 🔲 全面测试各类Markdown标记的处理
- 🔲 查找并修复漏处理的Markdown标记
- 🔲 检查并修复解析和渲染中的bug
- 🔲 处理边界条件和错误输入
- 🔲 优化渲染性能
- 🔲 完善文档和示例

### 2.9 阶段九：预定义主题与切换能力实现 🔲
- 🔲 设计并实现标准预定义主题(亮色/暗色/高对比度/护眼主题)
- 🔲 实现主题工厂方法，便于创建预定义主题
- 🔲 设计主题预览功能
- 🔲 添加主题配置序列化与反序列化支持
- 🔲 实现主题持久化存储功能
- 🔲 添加系统主题自动响应能力

## 3. 当前任务状态

### 3.1 进行中任务
- BaseMarkdownElement基础组件与主题系统的集成
- 重构MarkdownDisplayV3以支持组件化渲染
- 组件类型与主题绑定实现

### 3.2 待解决问题
- 处理不完整Markdown标记的策略
- 复杂嵌套结构渲染
- 性能优化

### 3.3 完成的关键里程碑
- ✅ 基础目录结构创建
- ✅ Markdown标记检测
- ✅ 流式输入处理
- ✅ 基础组件和主题框架定义
- ✅ 元素组件接口定义

## 4. 后续计划

### 4.1 下一步任务
1. 完成基础元素组件实现
2. 集成元素组件与解析器
3. 处理特殊Markdown元素如代码块、公式等

### 4.2 文档完善计划
- 添加API文档
- 创建使用示例
- 编写开发指南

### 4.3 预定义主题开发计划
- 收集颜色方案和排版规范资料
- 设计各种场景下的主题模板
- 为每个元素组件创建对应的主题变体
- 实现主题切换动效

---

## 相关文档

- [概述](./overview.md) - 项目背景、需求和整体架构
- [组件设计](./components.md) - 组件分类与设计原则
- [API文档](./api.md) - 接口定义和使用方法
- [实现计划](./implementation.md) - 项目结构、文件职责、数据处理流程和算法实现 