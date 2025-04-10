import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../widgets/markdown_display_v2.dart';
import '../data/content_array.dart' as content_data;

class LatexScreen extends StatefulWidget {
  const LatexScreen({Key? key}) : super(key: key);

  @override
  State<LatexScreen> createState() => _LatexScreenState();
}

class _LatexScreenState extends State<LatexScreen> {
  // 使用contentList作为流式数据源
  late final List<String> contentList;
  
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
  
  @override
  void initState() {
    super.initState();
    contentList = content_data.contentList;
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
    if (isTyping || currentIndex >= contentList.length) return;
    
    isTyping = true;
    
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (currentIndex < contentList.length) {
        setState(() {
          displayedText += contentList[currentIndex];
          currentIndex++;
        });
        
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
                displayedText = contentList.join();
                currentIndex = contentList.length;
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
              MarkdownDisplayV2(
                markdownText: displayedText,
                isTyping: isTyping,
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