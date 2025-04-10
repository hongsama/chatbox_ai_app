import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:flutter/services.dart';
import 'markdown_elements/markdown_element.dart';
import 'markdown_content_parser.dart';
import 'markdown_elements/heading_widget.dart';
import 'markdown_elements/paragraph_widget.dart';
import 'markdown_elements/code_block_widget.dart';
import 'markdown_elements/quote_widget.dart';
import 'markdown_elements/list_widget.dart';
import 'markdown_elements/latex_block_widget.dart';
import 'markdown_elements/latex_inline_widget.dart';
import 'markdown_elements/divider_widget.dart';
import 'markdown_elements/image_widget.dart';

/// Markdown显示组件V2 - 协调器版本
class MarkdownDisplayV2 extends StatefulWidget {
  // 要显示的Markdown文本
  final String markdownText;
  // 当前打字状态
  final bool isTyping;
  // 主题配置
  final MarkdownTheme? theme;

  const MarkdownDisplayV2({
    Key? key,
    required this.markdownText,
    this.isTyping = false,
    this.theme,
  }) : super(key: key);

  @override
  State<MarkdownDisplayV2> createState() => _MarkdownDisplayV2State();
}

class _MarkdownDisplayV2State extends State<MarkdownDisplayV2> {
  // 解析后的Markdown元素列表
  List<ParsedMarkdownElement> _elements = [];
  
  @override
  void initState() {
    super.initState();
    _parseContent();
  }
  
  @override
  void didUpdateWidget(MarkdownDisplayV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当文本内容变化时，重新解析
    if (oldWidget.markdownText != widget.markdownText) {
      _parseContent();
    }
  }
  
  // 解析Markdown内容
  void _parseContent() {
    _elements = MarkdownContentParser.parseMarkdown(widget.markdownText);
  }

  @override
  Widget build(BuildContext context) {
    // 使用默认主题或传入的主题
    final effectiveTheme = widget.theme ?? const MarkdownTheme();
    
    // 构建元素小部件列表
    final List<Widget> widgets = _buildElementWidgets(effectiveTheme);
    
    // 如果正在打字，添加打字光标
    if (widget.isTyping) {
      widgets.add(_buildTypingCursor());
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
  
  /// 为每个Markdown元素构建对应的渲染组件
  List<Widget> _buildElementWidgets(MarkdownTheme theme) {
    final List<Widget> widgets = [];
    
    for (final element in _elements) {
      Widget widget;
      
      // 根据元素类型选择对应的渲染组件
      switch (element.type) {
        case MarkdownElementType.heading:
          widget = MarkdownHeadingWidget(
            rawContent: element.rawContent,
            theme: theme,
          );
          break;
          
        case MarkdownElementType.paragraph:
          widget = MarkdownParagraphWidget(
            rawContent: element.rawContent,
            theme: theme,
          );
          break;
          
        case MarkdownElementType.codeBlock:
          widget = MarkdownCodeBlockWidget(
            rawContent: element.rawContent,
            theme: theme,
          );
          break;
          
        case MarkdownElementType.quote:
          widget = MarkdownQuoteWidget(
            rawContent: element.rawContent,
            theme: theme,
          );
          break;
          
        case MarkdownElementType.list:
          widget = MarkdownListWidget(
            rawContent: element.rawContent,
            theme: theme,
          );
          break;
          
        case MarkdownElementType.latexBlock:
          widget = MarkdownLatexBlockWidget(
            rawContent: element.rawContent,
            theme: theme,
          );
          break;
          
        case MarkdownElementType.latexInline:
          widget = MarkdownLatexInlineWidget(
            rawContent: element.rawContent,
            theme: theme,
          );
          break;
          
        case MarkdownElementType.divider:
          widget = MarkdownDividerWidget(
            rawContent: element.rawContent,
            theme: theme,
          );
          break;
          
        case MarkdownElementType.image:
          widget = MarkdownImageWidget(
            rawContent: element.rawContent,
            theme: theme,
          );
          break;
      }
      
      widgets.add(widget);
    }
    
    return widgets;
  }
  
  /// 构建打字光标
  Widget _buildTypingCursor() {
    return Container(
      width: 2,
      height: 20,
      margin: const EdgeInsets.only(left: 2),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(1),
      ),
      child: const SizedBox.shrink(),
    );
  }
} 