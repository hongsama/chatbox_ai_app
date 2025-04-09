import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'markdown_element.dart';

/// 代码块渲染组件
class MarkdownCodeBlockWidget extends MarkdownElementWidget {
  const MarkdownCodeBlockWidget({
    Key? key,
    required String rawContent,
    required MarkdownTheme theme,
  }) : super(key: key, rawContent: rawContent, theme: theme);
  
  @override
  Widget build(BuildContext context) {
    // 解析代码块内容
    final codeBlockData = _parseCodeBlock(rawContent);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.codeBlockBackground,
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
          _buildToolbar(context, codeBlockData.language),
          
          // 代码内容
          _buildCodeContent(codeBlockData.code, codeBlockData.language),
        ],
      ),
    );
  }
  
  /// 解析代码块内容
  CodeBlockData _parseCodeBlock(String rawContent) {
    final lines = rawContent.split('\n');
    String language = '';
    String code = '';
    
    // 处理第一行以获取语言
    if (lines.isNotEmpty && lines[0].startsWith('```')) {
      language = lines[0].substring(3).trim();
      
      // 提取代码内容 (不包括首尾的```标记)
      if (lines.length > 2) {
        // 查找结束标记的位置
        int endIndex = lines.length - 1;
        for (int i = 1; i < lines.length; i++) {
          if (lines[i].startsWith('```')) {
            endIndex = i - 1;
            break;
          }
        }
        
        // 提取代码内容
        if (endIndex >= 1) {
          code = lines.sublist(1, endIndex + 1).join('\n');
        }
      }
    }
    
    // 为常见的语言别名进行转换
    language = _normalizeLanguage(language);
    
    return CodeBlockData(code: code, language: language);
  }
  
  /// 标准化语言名称
  String _normalizeLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'js':
        return 'javascript';
      case 'py':
        return 'python';
      case 'ts':
        return 'typescript';
      case 'dart':
      case 'flutter':
        return 'dart';
      case '':
        return 'plaintext';
      default:
        return language.toLowerCase();
    }
  }
  
  /// 构建工具栏
  Widget _buildToolbar(BuildContext context, String language) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 语言指示器
          Text(
            language == 'plaintext' ? '' : language,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
          // 复制按钮
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.grey[400],
            onPressed: () {
              _copyCodeToClipboard(context);
            },
            tooltip: '复制代码',
          ),
        ],
      ),
    );
  }
  
  /// 构建代码内容
  Widget _buildCodeContent(String code, String language) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: HighlightView(
          code,
          language: language,
          theme: vs2015Theme,
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
  
  /// 复制代码到剪贴板
  void _copyCodeToClipboard(BuildContext context) {
    final codeBlockData = _parseCodeBlock(rawContent);
    Clipboard.setData(ClipboardData(text: codeBlockData.code));
    
    // 显示提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('代码已复制到剪贴板'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

/// 代码块数据类
class CodeBlockData {
  final String code;
  final String language;
  
  CodeBlockData({
    required this.code,
    required this.language,
  });
} 