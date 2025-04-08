import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'components/markdown_display.dart';

class LatexScreen extends StatefulWidget {
  const LatexScreen({Key? key}) : super(key: key);

  @override
  State<LatexScreen> createState() => _LatexScreenState();
}

class _LatexScreenState extends State<LatexScreen> {
  // 原始的Markdown文本，包含LaTeX分隔符
  final String markdownText = r'''
# 数学公式展示

以下是方程组的公式块:

\[
\begin{cases}
x^2 + y^2 = 25 \\
x + y = 7
\end{cases}
\]

这是一个行内公式 \( y = 7 - x \)，它表示从第二个方程解出的y。

## 解释

上面的方程组是一个联立方程组，包含:
1. 一个圆方程 $x^2 + y^2 = 25$（半径为5的圆）
2. 一条直线方程 $x + y = 7$

通过求解这个方程组，我们可以找到圆和直线的交点。

**代码实现**：
```python
from sympy import symbols, Eq, solve

# 定义变量
x, y = symbols('x y')

# 定义方程组
eq1 = Eq(x**2 + y**2, 25)
eq2 = Eq(x + y, 7)

# 解方程组
solutions = solve((eq1, eq2), (x, y))
print("解为:", solutions)
```

**输出**：
```
解为: [(3, 4), (4, 3)]
```
''';

  // 当前已经显示的文本
  String displayedText = '';
  // 当前字符索引
  int currentIndex = 0;
  // 计时器
  Timer? _timer;
  // 是否正在输出
  bool isTyping = false;
  // 控制滚动
  final ScrollController _scrollController = ScrollController();
  
  // 保存当前活动中的代码块信息
  Map<int, ActiveCodeBlock> _activeCodeBlocks = {};
  
  @override
  void initState() {
    super.initState();
    // 延迟一下再开始输出，让界面先渲染好
    Future.delayed(const Duration(milliseconds: 500), () {
      _startTyping();
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
  
  // 开始逐字输出
  void _startTyping() {
    // 如果已经在输出或者已经输出完毕，不再处理
    if (isTyping || currentIndex >= markdownText.length) return;
    
    isTyping = true;
    
    // 启动计时器，每50毫秒输出一个字符
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (currentIndex < markdownText.length) {
        setState(() {
          // 添加新字符
          final newChar = markdownText[currentIndex];
          displayedText = markdownText.substring(0, currentIndex + 1);
          currentIndex++;
          
          // 检查是否遇到代码块开始标记
          if (newChar == '`' && 
              currentIndex >= 3 && 
              markdownText.substring(currentIndex-3, currentIndex) == '```') {
            
            // 提取语言标识符
            String language = '';
            int lineEndIndex = markdownText.indexOf('\n', currentIndex);
            if (lineEndIndex > currentIndex) {
              language = markdownText.substring(currentIndex, lineEndIndex).trim();
            }
            
            // 创建代码块记录
            _activeCodeBlocks[currentIndex-3] = ActiveCodeBlock(
              language: language,
              startLine: displayedText.split('\n').length - 1
            );
          }
        });
        
        // 自动滚动到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        // 输出完毕，停止计时器
        timer.cancel();
        setState(() {
          isTyping = false;
        });
      }
    });
  }

  // 重置状态
  void _resetState() {
    setState(() {
      displayedText = '';
      currentIndex = 0;
      _timer?.cancel();
      isTyping = false;
      _activeCodeBlocks.clear();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LaTeX公式展示'),
        actions: [
          // 添加重播按钮
          IconButton(
            icon: const Icon(Icons.replay),
            onPressed: () {
              _resetState();
              
              // 重新开始打字效果
              Future.delayed(const Duration(milliseconds: 300), () {
                _startTyping();
              });
            },
          ),
          // 添加完成按钮
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: () {
              _timer?.cancel();
              setState(() {
                displayedText = markdownText;
                currentIndex = markdownText.length;
                isTyping = false;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 使用新组件显示Markdown内容
              MarkdownDisplay(
                markdownText: displayedText,
                isTyping: isTyping,
                activeCodeBlocks: _activeCodeBlocks,
              ),
              
              // 分隔线
              const Divider(height: 40),
              
              // 控制区域
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isTyping ? () {
                      // 暂停打字
                      _timer?.cancel();
                      setState(() {
                        isTyping = false;
                      });
                    } : () {
                      // 继续打字
                      _startTyping();
                    },
                    child: Text(isTyping ? '暂停' : '继续'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _resetState();
                      
                      // 重新开始打字效果
                      Future.delayed(const Duration(milliseconds: 300), () {
                        _startTyping();
                      });
                    },
                    child: const Text('重新开始'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 