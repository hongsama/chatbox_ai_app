import 'dart:async';
import 'deepseek_service.dart';

class ChatService {
  // API密钥常量，后续您可以自行填写
  static const String DEEPSEEK_API_KEY = 'sk-d9f0590101dc492595eb910fdc53d449';
  
  // 使用DeepSeek API获取流式响应
  static Stream<String> generateStreamResponse(String userMessage) {
    try {
      // 调用DeepSeek API服务的流式方法
      return DeepSeekService.sendMessageStream(userMessage);
    } catch (e) {
      // 如果发生错误，创建一个包含错误信息的流
      return Stream.value('抱歉，发生了错误：$e');
    }
  }

  // 使用DeepSeek API生成响应（非流式，保留向后兼容性）
  static Future<String> generateResponseWithAPI(String userMessage) async {
    try {
      // 调用DeepSeek API服务
      return await DeepSeekService.sendMessage(userMessage);
    } catch (e) {
      // 如果API调用失败，返回错误信息
      return '抱歉，发生了错误：$e';
    }
  }
  
  // 清除聊天历史
  static void clearChatHistory() {
    DeepSeekService.clearHistory();
  }
} 