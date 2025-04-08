import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../widgets/user_message_bubble.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/message_input_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isButtonEnabled = false;
  bool _isLoading = false;  // 加载中状态（等待第一个响应）
  bool _showScrollToBottomButton = false; // 是否显示向下滚动按钮
  StreamSubscription? _streamSubscription;
  bool _isAtBottom = true; // 是否在底部

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateButtonState);
    
    // 添加滚动监听
    _scrollController.addListener(_updateScrollPosition);
    
    // 设置为始终显示向下按钮
    setState(() {
      _showScrollToBottomButton = true;
    });
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _messageController.text.trim().isNotEmpty;
    });
  }

  void _updateScrollPosition() {
    if (!_scrollController.hasClients) return;
    
    final position = _scrollController.position;
    // 计算距离底部的距离
    final distanceFromBottom = position.maxScrollExtent - position.pixels;
    // 如果距离底部超过150像素，才显示按钮
    final isAtBottom = distanceFromBottom < 150;
    
    print("距离底部: $distanceFromBottom, 是否在底部: $isAtBottom");
    
    // 设置状态
    setState(() {
      _isAtBottom = isAtBottom;
      print("状态已更新: _isAtBottom = $_isAtBottom");
    });
  }

  void _sendMessage() async {
    final trimmedText = _messageController.text.trim();
    if (trimmedText.isEmpty) return;

    final userMessage = trimmedText;
    _messageController.clear();

    setState(() {
      _messages.add(
        Message(
          content: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
      _isLoading = true;  // 显示加载指示器，等待第一个响应
    });

    // 添加一个空的AI消息，用于流式显示
    final aiMessage = Message(
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(aiMessage);
      _scrollToBottom();  // 立即滚动到底部
    });

    // 使用固定的响应内容
    const String fixedResponse = '''### 二元二次方程组消元法简介

二元二次方程组通常形式为：
\\[
\\begin{cases}
a_1x^2 + b_1xy + c_1y^2 + d_1x + e_1y + f_1 = 0 \\\\
a_2x^2 + b_2xy + c_2y^2 + d_2x + e_2y + f_2 = 0
\\end{cases}
\\]

**消元法步骤**：
1. **选择一个变量消元**（如消去 \\( y \\)）：
   - 从其中一个方程解出 \\( y \\) 用 \\( x \\) 表示（或部分表达式）。
   - 将表达式代入另一个方程，得到关于 \\( x \\) 的一元高次方程。
2. **求解一元方程**：
   - 解关于 \\( x \\) 的方程（可能是四次方程，需数值或符号计算）。
3. **回代求 \\( y \\)**：
   - 将 \\( x \\) 的解代入 \\( y \\) 的表达式，求出对应 \\( y \\)。

---

### Python 示例（使用 `sympy` 符号计算）

假设解方程组：
\\[
\\begin{cases}
x^2 + y^2 = 25 \\\\
x + y = 7
\\end{cases}
\\]

**步骤**：
1. 从第二个方程解出 \\( y = 7 - x \\)。
2. 代入第一个方程：\\( x^2 + (7 - x)^2 = 25 \\)。
3. 展开后解关于 \\( x \\) 的二次方程。

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

---

### 更一般化的消元法示例

对于一般二元二次方程组，`sympy` 可直接求解：
```python
from sympy import symbols, Eq, solve

x, y = symbols('x y')

# 示例方程组: x^2 + xy = 6, x + y^2 = 5
eq1 = Eq(x**2 + x*y, 6)
eq2 = Eq(x + y**2, 5)

solutions = solve((eq1, eq2), (x, y))
print("解为:", solutions)
```

**输出**：
```
解为: [(-3, -1), (1, 2), (2, -1), (5/4 - sqrt(41)/4, sqrt(41)/8 + 11/8), ...]
```

---

### 注意事项
1. **高次方程**：消元后可能得到四次方程，解析解复杂，需依赖符号计算库（如 `sympy`）。
2. **数值解**：若解析解不可行，可用数值方法（如 `scipy.optimize.fsolve`）。
3. **唯一解**：方程组可能有多个解、无解或无限解。

如果需要进一步解释或扩展，请随时提问！
''';

    // 创建一个流发送固定响应，模拟流式传输
    Stream<String> mockStream() async* {
      // 分段发送固定响应，模拟流式传输
      final chars = fixedResponse.split('');
      for (int i = 0; i < chars.length; i++) {
        await Future.delayed(const Duration(milliseconds: 5)); // 短暂延迟模拟流式效果
        yield chars[i];
      }
    }

    // 订阅模拟流
    _streamSubscription = mockStream().listen(
      (chunk) {
        // 更新AI消息内容
        setState(() {
          aiMessage.content += chunk;
          if (_isLoading) {
            _isLoading = false;  // 收到第一个响应后隐藏加载指示器
          }
        });
        
        // 滚动到底部
        _scrollToBottom();
      },
      onDone: () {
        setState(() {
          _isTyping = false;
          _isLoading = false;
        });
        _streamSubscription = null;
      },
      onError: (error) {
        setState(() {
          aiMessage.content = '抱歉，发生了错误：$error';
          _isTyping = false;
          _isLoading = false;
        });
        _streamSubscription = null;
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final extraScrollOffset = 50.0; // 额外滚动量，避开底部渐变遮罩
        final maxScroll = _scrollController.position.maxScrollExtent;
        
        _scrollController.animateTo(
          maxScroll + extraScrollOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 中止AI回答生成
  void _stopGeneration() {
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
      _streamSubscription = null;
      
      setState(() {
        _isTyping = false;
        _isLoading = false;
      });
      
      // 在最后一条消息后添加提示
      final lastMessage = _messages.last;
      if (!lastMessage.isUser) {
        setState(() {
          lastMessage.content += "\n\n*回答已中止*";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('AI 聊天室', style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length + (_isTyping && _messages.isEmpty ? 1 : 0) + 1,
                  padding: const EdgeInsets.all(8.0),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    // 底部填充空间
                    if (index == _messages.length + (_isTyping && _messages.isEmpty ? 1 : 0)) {
                      return const SizedBox(height: 50.0);
                    }
                    
                    // 显示正在输入状态
                    if (index == _messages.length && _isTyping && _messages.isEmpty) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('正在输入...'),
                            ],
                          ),
                        ),
                      );
                    }

                    final message = _messages[index];
                    return message.isUser
                        ? UserMessageBubble(message: message)
                        : Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              AIMessageBubble(
                                message: message,
                                isTyping: _isTyping && index == _messages.length - 1,
                              ),
                              if (_isLoading && index == _messages.length - 1)
                                const Positioned(
                                  left: 48, // 头像左边距(8) + 头像宽度(28) + 头像右边距(12)
                                  top: 10, // 头像顶部边距(4) + 头像高度的一半(14) - 加载指示器高度的一半(8)
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          );
                  },
                ),
                // 添加渐变阴影过渡效果
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 20, // 减小高度
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.surface.withAlpha(0),
                          Theme.of(context).colorScheme.surface.withAlpha(204),
                          Theme.of(context).colorScheme.surface.withAlpha(255),
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                // 向下滚动按钮 - 只有不在底部时才显示
                if (!_isAtBottom)
                  Positioned(
                    right: 16.0,
                    bottom: 16.0,
                    child: Container(
                      width: 28.0,
                      height: 28.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.8),
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _scrollToBottom,
                          customBorder: const CircleBorder(),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_downward,
                              color: Colors.black,
                              size: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          MessageInputBar(
            controller: _messageController,
            isButtonEnabled: _isButtonEnabled,
            isTyping: _isTyping,
            onSendMessage: _sendMessage,
            onStopGeneration: _stopGeneration,
            onChanged: (_) => _updateButtonState(),
            onSubmitted: (_) => _sendMessage(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _messageController.removeListener(_updateButtonState);
    _scrollController.removeListener(_updateScrollPosition);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
} 