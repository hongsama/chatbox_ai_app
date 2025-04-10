import 'package:flutter/material.dart';
import 'dart:async';
import '../types/markdown_element_type.dart';
import '../parsers/content_parser.dart';

/// MarkdownDisplayV2 组件
///
/// 流式Markdown显示组件，基于标记识别功能。
/// 该组件可以接收字符串或字符串流作为输入，实时解析并渲染Markdown内容。
/// 支持解析常见的Markdown元素，如标题、代码块、公式块等。
///
/// 特点：
/// - 支持流式输入，实时渲染
/// - 特殊块（如代码块、公式块）的识别和处理
/// - 基于标记的Markdown元素检测
class MarkdownDisplayV2 extends StatefulWidget {
  /// 输入内容，可以是String或Stream<String>
  /// 
  /// 如果是String，组件会一次性渲染全部内容
  /// 如果是Stream<String>，组件会随着流数据的到来逐步渲染内容
  final dynamic input;
  
  /// 主题设置
  /// 
  /// 用于自定义Markdown渲染的样式，如文本颜色、字体大小等
  /// 如果为null，则使用默认样式
  final ThemeData? theme;
  
  /// 创建Markdown显示组件
  const MarkdownDisplayV2({
    Key? key,
    required this.input,
    this.theme,
  }) : super(key: key);

  @override
  State<MarkdownDisplayV2> createState() => _MarkdownDisplayV2State();
}

class _MarkdownDisplayV2State extends State<MarkdownDisplayV2> {
  /// 当前显示的文本
  /// 保存所有已处理的文本内容
  String _currentText = '';
  
  /// 当前检测到的Markdown元素类型
  /// 用于跟踪最后一次检测到的Markdown元素类型
  MarkdownElementType _currentElementType = MarkdownElementType.text;
  
  /// 期望的下一个关闭类型，null表示不在特殊块内
  /// 用于跟踪是否在特殊块内部（如代码块、公式块）
  /// 当不为null时，表示当前正在处理的特殊块的关闭类型
  MarkdownElementType? _expectedCloseType;
  
  /// 内容解析器
  /// 负责解析输入文本，识别Markdown标记
  final MarkdownContentParser _parser = MarkdownContentParser();
  
  /// 流订阅
  /// 当input是Stream<String>时用于接收流数据
  StreamSubscription<String>? _streamSubscription;
  
  /// 文本样式
  /// 定义Markdown文本的基本样式
  late final TextStyle _textStyle;
  
  @override
  void initState() {
    super.initState();
    // 初始化文本样式，优先使用传入的主题样式，否则使用默认样式
    _textStyle = TextStyle(
      fontSize: 16.0,
      height: 1.5,
      color: widget.theme?.textTheme.bodyMedium?.color ?? Colors.black,
    );
    // 处理输入数据
    _processInput();
  }
  
  @override
  void didUpdateWidget(MarkdownDisplayV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当输入源发生变化时，重新处理输入
    if (oldWidget.input != widget.input) {
      _disposeStreams();
      _processInput();
    }
  }
  
  @override
  void dispose() {
    // 确保在组件销毁时释放资源
    _disposeStreams();
    super.dispose();
  }
  
  /// 处理输入源
  /// 
  /// 根据输入类型（String或Stream<String>）采取不同的处理策略：
  /// - 如果是String，直接解析并显示
  /// - 如果是Stream<String>，订阅流并逐块处理
  void _processInput() {
    // 清空旧内容
    _currentText = '';
    _currentElementType = MarkdownElementType.text;
    _expectedCloseType = null;
    
    // 处理字符串输入
    if (widget.input is String) {
      _processTextChunk(widget.input as String);
    }
    // 处理流输入
    else if (widget.input is Stream<String>) {
      // 订阅流，对每个数据块进行处理
      _streamSubscription = (widget.input as Stream<String>).listen((chunk) {
        _processTextChunk(chunk);
      });
    }
  }
  
  /// 处理特定类型的Markdown元素
  /// 
  /// 根据元素类型生成对应的显示内容，并维护特殊块的状态
  /// 
  /// 参数:
  /// - elementType: 要处理的Markdown元素类型
  /// - text: 原始文本内容
  /// 
  /// 返回:
  /// 处理后的文本内容，用于显示
  String _processMarkdownElement(MarkdownElementType elementType, String text) {
    // 根据元素类型进行特殊处理
    switch (elementType) {
      case MarkdownElementType.heading1:
        return "# 一级标题处理\n";
      case MarkdownElementType.heading2:
        return "## 二级标题处理\n";
      case MarkdownElementType.heading3:
        return "### 三级标题处理\n";
      case MarkdownElementType.codeBlock:
        // 判断是开始还是结束
        if (_expectedCloseType != MarkdownElementType.codeBlock) {
          // 设置期望的关闭类型 - 进入代码块模式
          _expectedCloseType = MarkdownElementType.codeBlock;
          return "``` 代码块开始\n";
        } else {
          // 清除期望的关闭类型 - 退出代码块模式
          _expectedCloseType = null;
          return "代码块结束 ```\n";
        }
      case MarkdownElementType.blockFormulaStart:
        // 设置期望的关闭类型为blockFormulaEnd - 进入块级公式模式
        _expectedCloseType = MarkdownElementType.blockFormulaEnd;
        return "\\[ 块级公式开始\n";
      case MarkdownElementType.blockFormulaEnd:
        // 清除期望的关闭类型 - 退出块级公式模式
        _expectedCloseType = null;
        return "块级公式结束 \\]\n";
      case MarkdownElementType.inlineFormulaStart:
        // 设置期望的关闭类型为inlineFormulaEnd - 进入行内公式模式
        _expectedCloseType = MarkdownElementType.inlineFormulaEnd;
        return "\\( 行内公式开始\n";
      case MarkdownElementType.inlineFormulaEnd:
        // 清除期望的关闭类型 - 退出行内公式模式
        _expectedCloseType = null;
        return "行内公式结束 \\)\n";
      case MarkdownElementType.quote:
        return "> 引用块处理\n";
      case MarkdownElementType.divider:
        return "---分隔线处理\n";
      default:
        // 其他类型暂不特殊处理
        return "";
    }
  }
  
  /// 处理文本片段
  /// 
  /// 解析输入的文本片段，识别Markdown元素，并更新UI显示
  /// 根据当前状态（是否在特殊块内）采取不同的处理策略
  /// 
  /// 参数:
  /// - chunk: 要处理的文本片段
  void _processTextChunk(String chunk) {
    // 进行文本解析，获取Markdown元素信息
    final result = _parser.parseText(chunk);
    
    // 获取当前元素类型和是否为标记
    final elementType = result['element'] as MarkdownElementType;
    final isMarkup = result['isMarkup'] as bool;
    
    // 更新UI
    setState(() {
      // 如果在特殊块内部（有期望的关闭类型）
      if (_expectedCloseType != null) {
        // 只有当解析到的是期望的关闭类型时才进行特殊处理
        if (isMarkup && elementType == _expectedCloseType) {
          // 处理特殊块的结束标记
          _currentText += _processMarkdownElement(elementType, result['text']);
        } else {
          // 不是期望的关闭类型，直接添加原始文本，不解析其中的Markdown标记
          // 这确保了特殊块（如代码块）内部的内容不会被错误解析
          _currentText += result['text'];
        }
      } else {
        // 不在特殊块内部，正常处理Markdown标记
        if (!isMarkup) {
          // 普通文本，直接添加
          _currentText += result['text'];
        } else {
          // Markdown标记，进行特殊处理
          _currentText += _processMarkdownElement(elementType, result['text']);
        }
      }
      
      // 最后更新当前元素类型，用于后续处理
      _currentElementType = elementType;
    });
  }
  
  /// 释放流订阅
  /// 
  /// 取消当前的流订阅并释放资源
  void _disposeStreams() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }
  
  @override
  Widget build(BuildContext context) {
    // 构建UI，显示解析后的Markdown内容
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.theme?.cardColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 显示解析后的Markdown内容
          SelectableText(
            _currentText,
            style: _textStyle,
          ),
        ],
      ),
    );
  }
} 