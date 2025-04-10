import 'package:flutter/material.dart';
import '../widgets/markdown_display.dart' hide ActiveCodeBlock;
import '../widgets/markdown_display_v2.dart';
import '../parsers/code_parser.dart';

class MarkdownTestScreen extends StatefulWidget {
  const MarkdownTestScreen({Key? key}) : super(key: key);

  @override
  State<MarkdownTestScreen> createState() => _MarkdownTestScreenState();
}

class _MarkdownTestScreenState extends State<MarkdownTestScreen> {
  // 测试用的Markdown文本
  final String testMarkdown = '''
# Markdown测试

这是一个用于测试Markdown渲染的示例内容。我们可以看看**粗体**和*斜体*的渲染效果。

## 数学公式

我们可以测试行内公式：\\(a^2 + b^2 = c^2\\) 以及块级公式：

\\[
\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}
\\]

## 代码块

```python
def hello_world():
    print("Hello, World!")
    
# 调用函数
hello_world()
```

## 引用块

> 这是一段引用内容
> 它可以有多行

## 列表

有序列表:
1. 第一项
2. 第二项
3. 第三项

无序列表:
- 项目1
- 项目2
- 项目3

## 水平线

---

就是这样！
''';

  // 当前渲染器选择（0: 旧实现, 1: 新实现）
  int _selectedRenderer = 1;
  
  // 模拟打字效果
  bool _isTyping = false;
  
  // 保存当前活动中的代码块信息 (只用于旧实现)
  Map<int, ActiveCodeBlock> _activeCodeBlocks = {};
  
  // 控制滚动
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 为旧实现解析内容中的代码块
    _parseContent();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 解析内容中的代码块 (只用于旧实现)
  void _parseContent() {
    final lines = testMarkdown.split('\n');
    bool inCodeBlock = false;
    String language = '';
    int startLine = 0;
    String codeContent = '';
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.startsWith('```')) {
        if (inCodeBlock) {
          // 代码块结束
          final codeBlock = ActiveCodeBlock(
            language: language,
            startLine: startLine,
          );
          codeBlock.code = codeContent;
          codeBlock.isComplete = true;
          codeBlock.endLine = i;
          _activeCodeBlocks[startLine] = codeBlock;
          
          inCodeBlock = false;
          codeContent = '';
        } else {
          // 代码块开始
          inCodeBlock = true;
          startLine = i;
          // 提取语言标识符
          language = '';
          if (line.length > 3) {
            language = line.substring(3).trim();
          }
        }
      } else if (inCodeBlock) {
        // 在代码块内部
        if (codeContent.isEmpty) {
          codeContent = line;
        } else {
          codeContent += '\n$line';
        }
      }
    }
    
    // 处理未闭合的代码块
    if (inCodeBlock) {
      final codeBlock = ActiveCodeBlock(
        language: language,
        startLine: startLine,
      );
      codeBlock.code = codeContent;
      codeBlock.isComplete = true;
      codeBlock.endLine = lines.length - 1;
      _activeCodeBlocks[startLine] = codeBlock;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown渲染测试'),
        actions: [
          // 添加切换实现的按钮
          IconButton(
            icon: Icon(_selectedRenderer == 0 
                ? Icons.looks_one 
                : Icons.looks_two),
            onPressed: () {
              setState(() {
                _selectedRenderer = _selectedRenderer == 0 ? 1 : 0;
              });
            },
            tooltip: _selectedRenderer == 0 
                ? '当前: 旧实现 (点击切换)' 
                : '当前: 新实现 (点击切换)',
          ),
          // 添加打字模式切换
          IconButton(
            icon: Icon(_isTyping 
                ? Icons.keyboard 
                : Icons.text_fields),
            onPressed: () {
              setState(() {
                _isTyping = !_isTyping;
              });
            },
            tooltip: _isTyping 
                ? '打字模式: 开启' 
                : '打字模式: 关闭',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 状态指示器
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(bottom: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '当前渲染器: ${_selectedRenderer == 0 ? '旧实现' : '新实现'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    '打字模式: ${_isTyping ? '开启' : '关闭'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            // Markdown渲染区域
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                child: _selectedRenderer == 0
                    ? MarkdownDisplay(
                        markdownText: testMarkdown,
                        isTyping: _isTyping,
                        activeCodeBlocks: _activeCodeBlocks,
                      )
                    : MarkdownDisplayV2(
                        markdownText: testMarkdown,
                        isTyping: _isTyping,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 