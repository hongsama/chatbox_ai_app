import 'package:flutter/material.dart';

/// Markdown基础元素组件
/// 
/// 用于显示Markdown文本内容的基础组件。
/// 该组件使用StringBuffer来处理文本追加，支持高效更新。
class BaseMarkdownElement extends StatefulWidget {
  /// 文本样式
  /// 
  /// 用于自定义文本的显示样式，如字体大小、颜色等
  /// 如果为null，则使用默认样式
  final TextStyle? style;
  
  /// 文本缓冲区
  /// 可由子类访问的受保护成员
  final StringBuffer buffer;
  
  /// 状态更新函数
  /// 可由子类访问的受保护成员
  VoidCallback updateState = () {};
  
  /// 创建Markdown基础元素组件
  BaseMarkdownElement({
    Key? key,
    this.style,
  }) : buffer = StringBuffer(),
       super(key: key);

  /// 追加文本内容
  /// 
  /// 参数:
  /// - newText: 要追加的文本内容
  void appendText(String newText) {
    buffer.write(newText);
    
    // 触发状态更新
    if (key is GlobalKey<_BaseMarkdownElementState>) {
      (key as GlobalKey<_BaseMarkdownElementState>).currentState?.refresh();
    } else {
      // 使用默认方式触发更新
      updateState();
    }
  }
  
  /// 获取当前文本内容
  String getText() {
    return buffer.toString();
  }

  @override
  State<BaseMarkdownElement> createState() => _BaseMarkdownElementState();
}

/// BaseMarkdownElement的状态类
class _BaseMarkdownElementState extends State<BaseMarkdownElement> {
  /// 刷新UI
  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  void initState() {
    super.initState();
    // 设置更新状态的回调函数
    widget.updateState = () {
      refresh();
    };
  }

  @override
  Widget build(BuildContext context) {
    // 简单地显示文本内容，不进行额外解析
    return SelectableText(
      widget.buffer.toString(),
      style: widget.style,
    );
  }
} 