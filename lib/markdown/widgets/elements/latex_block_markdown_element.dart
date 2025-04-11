import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'base_markdown_element.dart';

/// LaTeX块级公式元素组件
/// 
/// 专门用于显示块级数学公式内容的Markdown元素组件。
/// 继承自BaseMarkdownElement，支持显示LaTeX格式的数学公式。
class LaTeXBlockMarkdownElement extends BaseMarkdownElement {  
  /// 创建LaTeX块级公式元素组件
  LaTeXBlockMarkdownElement({
    Key? key,
    TextStyle? style,
  }) : super(key: key, style: style);
  
  /// 重写追加文本内容方法
  /// 
  /// 参数:
  /// - newText: 要追加的文本内容
  @override
  void appendText(String newText) {
    // 调用父类的实现，保持基本功能一致
    super.appendText(newText);
  }

  @override
  State<LaTeXBlockMarkdownElement> createState() => _LaTeXBlockMarkdownElementState();
}

/// LaTeXBlockMarkdownElement的状态类
class _LaTeXBlockMarkdownElementState extends State<LaTeXBlockMarkdownElement> {
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
    // 获取当前公式内容
    final formulaText = widget.buffer.toString();
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Math.tex(
          formulaText,
          textStyle: widget.style?.copyWith(
            fontFamily: 'serif',
          ) ?? const TextStyle(
            fontFamily: 'serif',
            fontSize: 16.0,
          ),
          onErrorFallback: (error) => SelectableText(
            formulaText,
            style: widget.style?.copyWith(
              fontStyle: FontStyle.italic,
              fontFamily: 'serif',
              color: Colors.red,
            ) ?? const TextStyle(
              fontStyle: FontStyle.italic,
              fontFamily: 'serif',
              fontSize: 16.0,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
} 