import 'package:flutter/material.dart';
import 'base_markdown_element.dart';

/// 文本元素组件
/// 
/// 专门用于显示纯文本内容的Markdown元素组件。
/// 继承自BaseMarkdownElement，提供文本处理功能。
class TextMarkdownElement extends BaseMarkdownElement {  
  /// 创建文本元素组件
  TextMarkdownElement({
    Key? key,
    TextStyle? style,
  }) : super(key: key, style: style);
  
  @override
  State<TextMarkdownElement> createState() => _TextMarkdownElementState();
}

/// TextMarkdownElement的状态类
class _TextMarkdownElementState extends State<TextMarkdownElement> {
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
    // 简单地显示文本内容，不进行额外解析，直接使用基类的buffer
    return SelectableText(
      widget.buffer.toString(),
      style: widget.style,
    );
  }
} 