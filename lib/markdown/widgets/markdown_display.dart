import 'package:flutter/material.dart';
import 'dart:async';
import '../types/markdown_element_type.dart';

/// Markdown显示组件
///
/// 用于渲染Markdown内容的核心组件，支持流式更新
class MarkdownDisplay extends StatefulWidget {
  /// 输入内容，可以是String或Stream<String>
  final dynamic input;
  
  /// 主题设置
  final ThemeData? theme;
  
  /// 创建Markdown显示组件
  const MarkdownDisplay({
    Key? key,
    required this.input,
    this.theme,
  }) : super(key: key);

  @override
  State<MarkdownDisplay> createState() => _MarkdownDisplayState();
}

class _MarkdownDisplayState extends State<MarkdownDisplay> {
  /// 当前显示的文本
  String _currentText = '';
  
  /// 流订阅
  StreamSubscription<String>? _streamSubscription;
  
  /// 文本样式
  late final TextStyle _textStyle;
  
  @override
  void initState() {
    super.initState();
    _textStyle = TextStyle(
      fontSize: 16.0,
      height: 1.5,
      color: widget.theme?.textTheme.bodyMedium?.color ?? Colors.black,
    );
    _processInput();
  }
  
  @override
  void didUpdateWidget(MarkdownDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.input != widget.input) {
      _disposeStream();
      _processInput();
    }
  }
  
  @override
  void dispose() {
    _disposeStream();
    super.dispose();
  }
  
  /// 处理输入源
  void _processInput() {
    // 处理字符串输入
    if (widget.input is String) {
      setState(() {
        _currentText = widget.input as String;
      });
    }
    // 处理流输入
    else if (widget.input is Stream<String>) {
      _streamSubscription = (widget.input as Stream<String>).listen((chunk) {
        setState(() {
          _currentText += chunk;
        });
      });
    }
  }
  
  /// 释放流订阅
  void _disposeStream() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }
  
  @override
  Widget build(BuildContext context) {
    // 在第二阶段，我们添加更好的样式和布局
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
      child: SelectableText(
        _currentText,
        style: _textStyle,
      ),
    );
  }
} 