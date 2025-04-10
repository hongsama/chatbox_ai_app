import 'package:flutter/material.dart';
import 'dart:async';
import '../index.dart';
import '../data/markdown_examples.dart';
import '../../mathtest/data/content_array.dart'; // 导入content_array数据
import '../stream_markdown.dart' as markdown_module;

/// 流式Markdown示例页面
class StreamMarkdownDemoScreen extends StatefulWidget {
  const StreamMarkdownDemoScreen({Key? key}) : super(key: key);

  @override
  State<StreamMarkdownDemoScreen> createState() => _StreamMarkdownDemoScreenState();
}

class _StreamMarkdownDemoScreenState extends State<StreamMarkdownDemoScreen> {
  /// 显示的内容列表，每个元素包含type和stream
  List<DisplayItem> _displayItems = [];
  
  /// 当前发送索引
  int _currentIndex = 0;
  
  /// 定时器
  Timer? _timer;
  
  /// 数据流发送间隔 (毫秒)
  final int _streamInterval = 10;
  
  /// 示例类型
  final List<String> _exampleTypes = ['基础', '数学公式', '嵌套结构', 'Content数组'];
  
  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // 初始状态不加载数据，保持空白
  }
  
  /// 加载示例数据
  List<String> _loadExampleData(int typeIndex) {
    if (typeIndex == 3) {
      // Content Array模式 - 直接使用数组元素
      return [...contentList];
    }
    
    // 普通示例模式
    String source;
    switch (typeIndex) {
      case 1:
        source = MarkdownExamples.mathExample;
        break;
      case 2:
        source = MarkdownExamples.nestedExample;
        break;
      case 0:
      default:
        source = MarkdownExamples.basicExample;
    }
    
    // 将源文本分割成小片段
    return MarkdownExamples.getStreamingChunks(source, chunkSize: 20);
  }
  
  /// 添加新的显示项
  void _addDisplayItem(int typeIndex) {
    // 中断当前的流处理
    _timer?.cancel();
    _currentIndex = 0;
    
    // 创建新的流控制器
    final StreamController<String> controller = StreamController<String>();
    
    // 创建一个新的DisplayItem
    final displayItem = DisplayItem(
      exampleType: _exampleTypes[typeIndex],
      displayWidget: markdown_module.StreamMarkdown.getStreamMarkdownDisplay(
        input: controller.stream,
      ),
      controller: controller,
    );
    
    // 添加新项目到列表
    setState(() {
      _displayItems.add(displayItem);
    });
    
    // 开始流式发送
    final exampleData = _loadExampleData(typeIndex);
    _startStreaming(controller, exampleData);
    
    // 滚动到底部
    _scrollToBottom();
  }
  
  /// 滚动到底部
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // 使用jumpTo直接跳转到底部，没有动画，避免动画冲突
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }
  
  /// 开始流式发送数据
  void _startStreaming(StreamController<String> controller, List<String> data) {
    int index = 0;
    final int scrollInterval = 5; // 每5个数据块触发一次滚动
    
    _timer = Timer.periodic(Duration(milliseconds: _streamInterval), (timer) {
      if (index < data.length) {
        controller.add(data[index]);
        index++;
        
        // 减少滚动频率，只在特定间隔滚动
        if (index % scrollInterval == 0 || index == data.length) {
          _scrollToBottom();
        }
      } else {
        timer.cancel();
        // 确保完成后也滚动到底部
        _scrollToBottom();
      }
    });
  }
  
  /// 清空所有内容
  void _clearAll() {
    _timer?.cancel();
    
    // 关闭所有控制器
    for (var item in _displayItems) {
      item.controller.close();
    }
    
    setState(() {
      _displayItems = [];
    });
    
    // 滚动到顶部
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    for (var item in _displayItems) {
      item.controller.close();
    }
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('流式Markdown演示'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _displayItems.isNotEmpty ? _clearAll : null,
            tooltip: '清空内容',
          ),
        ],
      ),
      body: Column(
        children: [
          // 示例类型选择器
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              children: List.generate(_exampleTypes.length, (index) {
                return ActionChip(
                  label: Text(_exampleTypes[index]),
                  onPressed: () {
                    _addDisplayItem(index);
                  },
                );
              }),
            ),
          ),
          
          // Markdown内容区
          Expanded(
            child: Container(
              width: 700, // 固定宽度
              child: _displayItems.isEmpty
                ? Center(
                    child: Text(
                      '请选择一个示例类型',
                      style: TextStyle(
                        fontSize: 18, 
                        color: Colors.grey[600]
                      ),
                    ),
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      // 当用户手动滚动结束时，如果还在接收流数据，恢复自动滚动
                      if (notification is ScrollEndNotification && _timer != null && _timer!.isActive) {
                        _scrollToBottom();
                      }
                      return true;
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _displayItems.map((item) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 类型标题
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                                child: Text(
                                  '${item.exampleType}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // 内容显示
                              Container(
                                width: double.infinity,
                                alignment: Alignment.topLeft,
                                child: item.displayWidget,
                              ),
                              // 分隔线
                              const Divider(height: 32),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
            ),
          ),
          
          // 底部状态栏
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _displayItems.isEmpty 
                ? '请选择一个示例类型添加演示' 
                : '已添加 ${_displayItems.length} 个示例',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

/// 显示项目类
class DisplayItem {
  final String exampleType;
  final Widget displayWidget;
  final StreamController<String> controller;
  
  DisplayItem({
    required this.exampleType,
    required this.displayWidget,
    required this.controller,
  });
} 