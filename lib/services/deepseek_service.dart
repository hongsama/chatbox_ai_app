import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'chat_service.dart';

class DeepSeekService {
  // API 相关常量
  static const String _baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  static const String _model = 'deepseek-chat';
  
  // 消息历史记录
  static final List<Map<String, dynamic>> _messageHistory = [];

  // 发送聊天请求并获取流式响应
  static Stream<String> sendMessageStream(String message) async* {
    try {
      // 添加用户消息到历史记录
      _messageHistory.add({
        'role': 'user',
        'content': message,
      });

      // 准备请求体
      final requestBody = {
        'model': _model,
        'messages': _messageHistory,
        'temperature': 0.7,
        'max_tokens': 2000,
        'stream': true, // 启用流式输出
      };

      // 发送请求
      final request = http.Request('POST', Uri.parse(_baseUrl));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ChatService.DEEPSEEK_API_KEY}',
      });
      request.body = jsonEncode(requestBody);

      final response = await http.Client().send(request);

      // 处理流式响应
      if (response.statusCode == 200) {
        String fullResponse = '';

        // 监听响应流
        await for (final chunk in response.stream.transform(utf8.decoder)) {
          // 处理SSE格式的数据流
          for (final line in chunk.split('\n')) {
            if (line.startsWith('data: ') && line != 'data: [DONE]') {
              final jsonData = line.substring(6); // 移除 'data: ' 前缀
              try {
                final data = jsonDecode(jsonData);
                if (data['choices'] != null && 
                    data['choices'][0]['delta'] != null && 
                    data['choices'][0]['delta']['content'] != null) {
                  
                  final content = data['choices'][0]['delta']['content'];
                  fullResponse += content;
                  yield content; // 返回部分响应内容
                }
              } catch (e) {
                // 解析JSON失败，跳过
              }
            }
          }
        }

        // 将完整响应添加到历史记录
        _messageHistory.add({
          'role': 'assistant',
          'content': fullResponse,
        });
      } else {
        final errorMessage = '发生错误：HTTP ${response.statusCode}';
        yield errorMessage;
      }
    } catch (e) {
      yield '发生错误：$e';
    }
  }

  // 发送聊天请求并获取响应（非流式，保留向后兼容性）
  static Future<String> sendMessage(String message) async {
    try {
      // 添加用户消息到历史记录
      _messageHistory.add({
        'role': 'user',
        'content': message,
      });

      // 准备请求体
      final requestBody = {
        'model': _model,
        'messages': _messageHistory,
        'temperature': 0.7,
        'max_tokens': 2000,
      };

      // 发送请求
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ChatService.DEEPSEEK_API_KEY}',
        },
        body: jsonEncode(requestBody),
      );

      // 处理响应
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final assistantMessage = responseData['choices'][0]['message']['content'];
        
        // 添加助手回复到历史记录
        _messageHistory.add({
          'role': 'assistant',
          'content': assistantMessage,
        });
        
        return assistantMessage;
      } else {
        // 如果API调用失败，返回错误信息
        return '发生错误：HTTP ${response.statusCode}\n${response.body}';
      }
    } catch (e) {
      // 捕获并返回任何异常
      return '发生错误：$e';
    }
  }

  // 清除消息历史
  static void clearHistory() {
    _messageHistory.clear();
  }
} 