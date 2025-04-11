import 'package:flutter/material.dart';
import 'dart:async';
import '../types/markdown_element_type.dart';
import '../parsers/content_parser.dart';
import 'elements/base_markdown_element.dart';
import 'elements/text_markdown_element.dart';
import 'elements/latex_block_markdown_element.dart';

/// MarkdownDisplayV3 组件
///
/// 流式Markdown显示组件，基于标记识别功能。
/// 该组件可以接收字符串或字符串流作为输入，实时解析并渲染Markdown内容。
/// 支持解析需要特殊处理的Markdown元素，如代码块和公式块。
///
/// 特点：
/// - 支持流式输入，实时渲染
/// - 特殊块（如代码块、公式块）的识别和处理
/// - 基于标记的Markdown元素检测
class MarkdownDisplayV3 extends StatefulWidget {
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
  const MarkdownDisplayV3({
    Key? key,
    required this.input,
    this.theme,
  }) : super(key: key);

  @override
  State<MarkdownDisplayV3> createState() => _MarkdownDisplayV3State();
}

class _MarkdownDisplayV3State extends State<MarkdownDisplayV3> {
  /// 当前检测到的Markdown元素类型
  /// 用于跟踪最后一次检测到的Markdown元素类型
  MarkdownElementType _currentElementType = MarkdownElementType.text;
  
  /// 当前创建的BaseMarkdownElement或其子类
  /// 用于接收文本流
  BaseMarkdownElement? _currentElement;
  
  /// 存储所有Markdown元素的列表
  /// 按照添加顺序存储，用于UI显示
  final List<BaseMarkdownElement> _baseList = [];
  
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
  void didUpdateWidget(MarkdownDisplayV3 oldWidget) {
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
    _currentElement = null;
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
  void _processMarkdownElement(MarkdownElementType elementType, String text) {
    // 根据元素类型进行特殊处理
    switch (elementType) {
      case MarkdownElementType.text:
        // 普通文本处理
        // 如果当前元素不存在，创建一个新的TextMarkdownElement
        if (_currentElement == null) {
          _currentElement = TextMarkdownElement(
            style: _textStyle,
          );
          _baseList.add(_currentElement!);
        }
        // 添加到当前元素
        _currentElement!.appendText(text);
        break;
      case MarkdownElementType.codeBlock:
        // 判断是开始还是结束
        if (_expectedCloseType != MarkdownElementType.codeBlock) {
          // 设置期望的关闭类型 - 进入代码块模式
          _expectedCloseType = MarkdownElementType.codeBlock;
          // 创建新的BaseMarkdownElement
          _currentElement = BaseMarkdownElement();
          _baseList.add(_currentElement!);
        } else {
          // 清除期望的关闭类型 - 退出代码块模式
          _expectedCloseType = null;
          _currentElement = null;
        }
        break;
      case MarkdownElementType.blockFormulaStart:
        // 设置期望的关闭类型为blockFormulaEnd - 进入块级公式模式
        _expectedCloseType = MarkdownElementType.blockFormulaEnd;
        // 创建新的LaTeXBlockMarkdownElement
        _currentElement = LaTeXBlockMarkdownElement(
          style: _textStyle,
        );
        _baseList.add(_currentElement!);
        break;
      case MarkdownElementType.blockFormulaEnd:
        // 清除期望的关闭类型 - 退出块级公式模式
        _expectedCloseType = null;
        _currentElement = null;
        break;
    }
  }
  
  /// 处理文本片段
  /// 
  /// 解析输入的文本片段，识别Markdown元素，并更新UI显示
  /// 
  /// 参数:
  /// - chunk: 要处理的文本片段
  void _processTextChunk(String chunk) {
    // 进行文本解析，获取Markdown元素信息
    final result = _parser.parseText(chunk);
    
    // 获取当前元素类型
    final elementType = result['element'] as MarkdownElementType;
    
    // 更新UI
    setState(() {
      // 更新当前元素类型
      _currentElementType = elementType;
      _processMarkdownElement(elementType, result['text']);

    });
  }
  
  /// 释放流订阅
  /// 
  /// 取消当前的流订阅并释放资源
  void _disposeStreams() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }
  
  /// 添加并显示Markdown元素
  /// 
  /// 参数:
  /// - element: 要添加的Markdown元素（BaseMarkdownElement或其子类）
  void addMarkdownElement(BaseMarkdownElement element) {
    setState(() {
      _baseList.add(element);
    });
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
          // 按照顺序显示所有Markdown元素
          ..._baseList,
        ],
      ),
    );
  }
} 