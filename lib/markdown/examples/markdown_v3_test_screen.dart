import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/markdown_display_v3.dart';

/// MarkdownV3 测试页面
///
/// 用于测试MarkdownDisplayV3组件的功能和行为
class MarkdownV3TestScreen extends StatefulWidget {
  const MarkdownV3TestScreen({Key? key}) : super(key: key);

  @override
  State<MarkdownV3TestScreen> createState() => _MarkdownV3TestScreenState();
}

class _MarkdownV3TestScreenState extends State<MarkdownV3TestScreen> {
  // Stream控制器，用于发送流式文本
  final StreamController<String> _textController = StreamController<String>();
  
  // 预设的Markdown文本示例
  final List<String> _markdownChunks = [
    "# 流式 Markdown 组件演示\n\n",
    "这是一个 ",
    "**流式**",
    " Markdown ",
    "组件的演示。可以看到文本是",
    "逐步渲染的。\n\n",
    "## 代码示例\n\n",
    "```dart\n",
    "void main() {\n",
    "  print('Hello, ",
    "Stream Markdown",
    "!');\n",
    "}\n",
    "```\n\n",
    "### 数学公式示例\n\n",
    "行内公式：",
    "\\(",
    "E=mc^2",
    "\\)",
    " 是著名的质能方程。\n\n",
    "块级公式：\n\n",
    "\\[",
    "\\int_{a}^{b} f(x) \\, dx = F(b) - F(a)",
    "\\]\n\n",
    "---\n\n",
    "这是一段带有 > 引用 的文本。\n\n",
    "完成！"
  ];
  
  // 当前发送的块索引
  int _currentIndex = 0;
  
  // 定时器，用于模拟流式输入
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    // 启动定时器，每隔一段时间发送一个文本块
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_currentIndex < _markdownChunks.length) {
        _textController.add(_markdownChunks[_currentIndex]);
        _currentIndex++;
      } else {
        _timer?.cancel();
        _timer = null;
      }
    });
  }
  
  @override
  void dispose() {
    // 清理资源
    _timer?.cancel();
    _textController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MarkdownDisplayV3 测试'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MarkdownDisplayV3(
              input: _textController.stream,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 重置状态并重新开始
                    setState(() {
                      _currentIndex = 0;
                      _timer?.cancel();
                      _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
                        if (_currentIndex < _markdownChunks.length) {
                          _textController.add(_markdownChunks[_currentIndex]);
                          _currentIndex++;
                        } else {
                          _timer?.cancel();
                          _timer = null;
                        }
                      });
                    });
                  },
                  child: const Text('重新开始'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 