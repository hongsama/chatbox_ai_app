import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:flutter/services.dart';
import '../parsers/code_parser.dart';

/// Markdown显示组件
class MarkdownDisplay extends StatelessWidget {
  // 要显示的Markdown文本
  final String markdownText;
  // 当前打字状态
  final bool isTyping;
  // 代码块信息
  final Map<int, ActiveCodeBlock> activeCodeBlocks;

  const MarkdownDisplay({
    Key? key,
    required this.markdownText,
    required this.isTyping,
    required this.activeCodeBlocks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildFormattedText();
  }

  /// 解析并渲染带LaTeX公式的文本
  Widget _buildFormattedText() {
    // 找出所有LaTeX公式
    final blockRegExp = RegExp(r'\\\[([\s\S]*?)\\\]', multiLine: true, dotAll: true);
    final inlineRegExp = RegExp(r'\\\(([\s\S]*?)\\\)|\$((?!\$).*?)\$');
    
    // 粗体和斜体的正则表达式
    final boldRegExp = RegExp(r'\*\*(.*?)\*\*|__(.+?)__');
    final italicRegExp = RegExp(r'\*((?!\*).+?)\*|_((?!_).+?)_');
    
    // 引用的正则表达式
    final quoteRegExp = RegExp(r'^>\s(.+)$', multiLine: true);
    
    // 存储所有的小部件
    final List<Widget> widgets = [];
    
    // 处理当前已显示的文本
    if (markdownText.isNotEmpty) {
      // 分割成行，以便处理标题等基于行的Markdown元素
      final lines = markdownText.split('\n');
      
      // 跟踪已处理的代码块行
      Set<int> processedCodeLines = {};
      
      int lineIndex = 0;
      while (lineIndex < lines.length) {
        // 如果这一行已经作为代码块的一部分处理过了，跳过
        if (processedCodeLines.contains(lineIndex)) {
          lineIndex++;
          continue;
        }
        
        final line = lines[lineIndex];
        final trimmedLine = line.trim();
        
        // 检测是否是代码块的开始行
        if (trimmedLine.startsWith('```')) {
          // 找到此代码块的记录
          ActiveCodeBlock? codeBlock;
          
          for (var entry in activeCodeBlocks.entries) {
            if (entry.value.startLine == lineIndex) {
              codeBlock = entry.value;
              break;
            }
          }
          
          if (codeBlock != null) {
            // 标记代码块的所有行为已处理
            processedCodeLines.add(lineIndex);
            if (codeBlock.isComplete && codeBlock.endLine > lineIndex) {
              for (int i = lineIndex + 1; i <= codeBlock.endLine; i++) {
                processedCodeLines.add(i);
              }
            }
            
            // 确保语言标识符是正确提取的（修复）
            String language = codeBlock.language;
            if (language.isEmpty && trimmedLine.length > 3) {
              language = trimmedLine.substring(3).trim();
              codeBlock.language = language;
            }
            
            // 添加高亮的代码块
            widgets.add(_buildHighlightedCodeBlock(codeBlock.code, codeBlock.language));
            
            // 如果代码块已完成，跳过到结束行之后
            if (codeBlock.isComplete) {
              lineIndex = codeBlock.endLine + 1;
              continue;
            }
          } else {
            // 如果没找到代码块记录，尝试自动创建一个代码块记录
            String codeBlockContent = '';
            String language = '';
            
            // 提取代码块语言
            if (trimmedLine.length > 3) {
              language = trimmedLine.substring(3).trim();
            }
            
            // 查找代码块的结束位置
            int endIndex = lineIndex + 1;
            while (endIndex < lines.length && !lines[endIndex].trim().startsWith('```')) {
              if (endIndex > lineIndex + 1) { // 跳过第一行（语言标识符行）
                if (codeBlockContent.isEmpty) {
                  codeBlockContent = lines[endIndex];
                } else {
                  codeBlockContent += '\n' + lines[endIndex];
                }
              }
              endIndex++;
            }
            
            // 标记所有代码块行为已处理
            for (int i = lineIndex; i <= endIndex && i < lines.length; i++) {
              processedCodeLines.add(i);
            }
            
            // 添加高亮的代码块
            widgets.add(_buildHighlightedCodeBlock(codeBlockContent, language));
            
            // 跳过整个代码块
            if (endIndex < lines.length && lines[endIndex].trim().startsWith('```')) {
              lineIndex = endIndex + 1;
            } else {
              lineIndex = endIndex;
            }
            continue;
          }
          lineIndex++;
          continue;
        }
        
        // 检查当前行是否在某个代码块内
        bool isInCodeBlock = false;
        for (var codeBlock in activeCodeBlocks.values) {
          if (lineIndex > codeBlock.startLine && 
              (!codeBlock.isComplete || lineIndex < codeBlock.endLine)) {
            isInCodeBlock = true;
            processedCodeLines.add(lineIndex);
            break;
          }
        }
        
        if (isInCodeBlock) {
          lineIndex++;
          continue;
        }
        
        // 处理引用
        if (trimmedLine.startsWith('>')) {
          final quoteMatch = quoteRegExp.firstMatch(line);
          if (quoteMatch != null) {
            final quoteText = quoteMatch.group(1)!;
            
            widgets.add(Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: Colors.grey[400]!,
                    width: 4.0,
                  ),
                ),
              ),
              child: Text(
                quoteText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ));
            
            lineIndex++;
            continue;
          }
        }
        
        // 处理标题
        if (trimmedLine.startsWith('#')) {
          // 识别标题级别和文本
          final headerMatch = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(trimmedLine);
          if (headerMatch != null) {
            final level = headerMatch.group(1)!.length;
            final text = headerMatch.group(2)!;
            
            // 添加标题组件
            widgets.add(SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(
                  top: (lineIndex > 0) ? 10.0 : 0.0,
                  bottom: 4.0,
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 24.0 - (level - 1) * 2.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ));
          } else {
            // 不是有效标题格式，当作普通文本
            _addTextLine(widgets, line);
          }
        }
        // 处理列表项
        else if (trimmedLine.startsWith('- ') || trimmedLine.startsWith('* ') || 
                 RegExp(r'^\d+\.\s').hasMatch(trimmedLine)) {
          // 处理列表项的符号和文本
          String marker;
          String itemText;
          
          if (trimmedLine.startsWith('- ') || trimmedLine.startsWith('* ')) {
            marker = '•';
            itemText = trimmedLine.substring(2);
          } else {
            // 有序列表
            final match = RegExp(r'^(\d+)\.(.+)$').firstMatch(trimmedLine);
            if (match != null) {
              marker = '${match.group(1)}.';
              itemText = match.group(2)!.trim();
            } else {
              marker = '•';
              itemText = trimmedLine;
            }
          }
          
          // 处理列表项中的强调格式（粗体、斜体）
          itemText = _processRichText(itemText);
          
          // 识别列表项中的LaTeX公式
          final inlineMatches = inlineRegExp.allMatches(itemText);
          
          if (inlineMatches.isEmpty) {
            // 没有公式的列表项
            widgets.add(SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 2.0, bottom: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      marker,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        _buildRichText(itemText),
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ));
          } else {
            // 包含公式的列表项，创建一个复杂的布局
            widgets.add(SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 2.0, bottom: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      marker,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: _buildInlineFormula(itemText),
                      ),
                    ),
                  ],
                ),
              ),
            ));
          }
        }
        // 处理公式块
        else if (lineIndex < lines.length - 2 && 
                 lines[lineIndex].trim() == '\\[' &&
                 lines.sublist(lineIndex).join('\n').contains('\\]')) {
          // 找到公式块的结束位置
          int endIndex = lineIndex + 1;
          while (endIndex < lines.length && !lines[endIndex].contains('\\]')) {
            endIndex++;
          }
          
          if (endIndex < lines.length) {
            // 提取公式内容
            final formulaLines = lines.sublist(lineIndex + 1, endIndex);
            final formula = formulaLines.join('\n');
            
            // 添加公式块，使用自定义容器
            widgets.add(FormulaScrollContainer(formula: formula));
            
            // 更新行索引跳过已处理的行
            lineIndex = endIndex;
          } else {
            // 公式块未闭合，作为普通文本处理
            _addTextLine(widgets, line);
          }
        }
        // 处理包含行内公式的普通文本行
        else if (inlineRegExp.hasMatch(line)) {
          widgets.add(_buildInlineFormulaContainer(line));
        }
        // 处理粗体、斜体等格式的普通文本行
        else if (boldRegExp.hasMatch(line) || italicRegExp.hasMatch(line)) {
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text.rich(
              _buildRichText(line),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ));
        }
        // 普通文本行
        else {
          _addTextLine(widgets, line);
        }
        
        lineIndex++;
      }
    }
    
    // 添加打字光标
    if (isTyping) {
      widgets.add(const TypeCursor());
    }
    
    // 使用Column包装所有内容，确保垂直布局正确
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
  
  /// 辅助方法：添加普通文本行
  void _addTextLine(List<Widget> widgets, String line) {
    if (line.trim().isNotEmpty) {
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Text(
          line,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ));
    } else {
      // 空行添加间距
      widgets.add(const SizedBox(height: 6.0));
    }
  }
  
  /// 辅助方法：构建包含行内公式的文本
  Widget _buildInlineFormula(String text) {
    final inlineRegExp = RegExp(r'\\\(([\s\S]*?)\\\)|\$((?!\$).*?)\$');
    final List<InlineSpan> spans = [];
    int currentPos = 0;
    
    // 查找所有行内公式
    final matches = inlineRegExp.allMatches(text);
    
    for (final match in matches) {
      // 添加公式前的文本
      if (match.start > currentPos) {
        spans.add(TextSpan(
          text: text.substring(currentPos, match.start),
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ));
      }
      
      // 添加公式
      final formula = match.group(1) ?? match.group(2)!;
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Math.tex(
            formula,
            textStyle: const TextStyle(fontSize: 16, color: Colors.black),
            onErrorFallback: (exception) {
              return Text(
                formula,
                style: const TextStyle(color: Colors.red),
              );
            },
          ),
        ),
      ));
      
      currentPos = match.end;
    }
    
    // 添加最后的文本
    if (currentPos < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentPos),
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ));
    }
    
    // 返回可以处理溢出的富文本
    return Text.rich(
      TextSpan(children: spans),
      softWrap: true,
      overflow: TextOverflow.visible,
    );
  }
  
  /// 处理包含行内公式的列表项或段落
  Widget _buildInlineFormulaContainer(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: _buildInlineFormula(text),
      ),
    );
  }

  /// 辅助方法：构建高亮的代码块
  Widget _buildHighlightedCodeBlock(String code, String language) {
    // 处理语言标识符
    String languageForHighlight = language.toLowerCase();
    // 为常见语言别名进行映射
    if (languageForHighlight == 'js') {
      languageForHighlight = 'javascript';
    } else if (languageForHighlight == 'py') {
      languageForHighlight = 'python';
    } else if (languageForHighlight == '') {
      // 默认为文本
      languageForHighlight = 'plaintext';
    }
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // VS Code暗色主题背景色
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部工具栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 语言指示器 - 不显示纯文本标签
                Text(
                  (language.isEmpty || language.toLowerCase() == 'plaintext') ? '' : language,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                  ),
                ),
                // 复制按钮
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.grey[400],
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('代码已复制到剪贴板'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 代码内容
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: HighlightView(
                code,
                language: languageForHighlight,
                theme: vs2015Theme,
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理富文本（粗体、斜体等）
  String _processRichText(String text) {
    // 处理粗体
    text = text.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*|__(.*?)__'), 
      (match) => '${match.group(1) ?? match.group(2)}'
    );
    
    // 处理斜体
    text = text.replaceAllMapped(
      RegExp(r'\*((?!\*).+?)\*|_((?!_).+?)_'), 
      (match) => '${match.group(1) ?? match.group(2)}'
    );
    
    return text;
  }
  
  /// 构建富文本
  TextSpan _buildRichText(String text) {
    List<InlineSpan> spans = [];
    int currentPos = 0;
    
    // 处理粗体
    final boldMatches = RegExp(r'\*\*(.*?)\*\*|__(.*?)__').allMatches(text);
    for (final match in boldMatches) {
      // 添加粗体前的文本
      if (match.start > currentPos) {
        spans.add(TextSpan(
          text: text.substring(currentPos, match.start),
        ));
      }
      
      // 添加粗体文本
      final boldText = match.group(1) ?? match.group(2) ?? '';
      spans.add(TextSpan(
        text: boldText,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      
      currentPos = match.end;
    }
    
    // 添加剩余文本
    if (currentPos < text.length) {
      // 处理斜体
      final remainingText = text.substring(currentPos);
      final italicMatches = RegExp(r'\*((?!\*).+?)\*|_((?!_).+?)_').allMatches(remainingText);
      
      int subPos = 0;
      for (final match in italicMatches) {
        // 添加斜体前的文本
        if (match.start > subPos) {
          spans.add(TextSpan(
            text: remainingText.substring(subPos, match.start),
          ));
        }
        
        // 添加斜体文本
        final italicText = match.group(1) ?? match.group(2) ?? '';
        spans.add(TextSpan(
          text: italicText,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
        
        subPos = match.end;
      }
      
      // 添加最后的文本
      if (subPos < remainingText.length) {
        spans.add(TextSpan(
          text: remainingText.substring(subPos),
        ));
      } else if (italicMatches.isEmpty) {
        spans.add(TextSpan(
          text: remainingText,
        ));
      }
    }
    
    return TextSpan(children: spans);
  }
}

/// 打字光标组件
class TypeCursor extends StatefulWidget {
  const TypeCursor({Key? key}) : super(key: key);

  @override
  State<TypeCursor> createState() => _TypeCursorState();
}

class _TypeCursorState extends State<TypeCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: const Text(
        '|',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}

/// 将公式滚动视图和滚动条连接在一起的组件
class FormulaScrollContainer extends StatefulWidget {
  final String formula;
  
  const FormulaScrollContainer({
    Key? key,
    required this.formula,
  }) : super(key: key);

  @override
  State<FormulaScrollContainer> createState() => _FormulaScrollContainerState();
}

class _FormulaScrollContainerState extends State<FormulaScrollContainer> {
  final ScrollController _scrollController = ScrollController();
  bool _hasOverflow = false;
  
  @override
  void initState() {
    super.initState();
    // 检查是否有溢出
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && 
          _scrollController.position.maxScrollExtent > 0) {
        setState(() {
          _hasOverflow = true;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasOverflow)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swipe, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  "滑动查看完整公式",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        RawScrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 6,
          radius: const Radius.circular(10),
          thumbColor: Colors.grey.withOpacity(0.6),
          trackColor: Colors.grey.withOpacity(0.1),
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Container(
              // 移除固定宽度，让容器自适应内容大小
              alignment: Alignment.centerLeft, // 使内容左对齐
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
              child: Math.tex(
                widget.formula,
                textStyle: const TextStyle(
                  fontSize: 18, 
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
                onErrorFallback: (exception) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '无法渲染公式: ${widget.formula}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
} 