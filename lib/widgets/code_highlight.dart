import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs.dart';

class CodeHighlight extends StatelessWidget {
  final String code;
  final String language;

  const CodeHighlight({
    super.key,
    required this.code,
    required this.language,
  });

  Map<String, TextStyle> get _vscodeTheme {
    // 定义VS Code浅色主题的颜色
    return {
      'root': const TextStyle(
        backgroundColor: Color(0xFFE8E8E8),  // 原来的灰色背景
        color: Color(0xFF000000),            // 默认文本颜色
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'keyword': const TextStyle(
        color: Color(0xFF9B2393),            // 关键字（如if, for, while）- 紫红色
        fontWeight: FontWeight.normal,
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'literal': const TextStyle(
        color: Color(0xFF9B2393),            // 文字常量 - 紫红色
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'type': const TextStyle(
        color: Color(0xFF267F99),            // 类型（如int, string）
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'built_in': const TextStyle(
        color: Color(0xFF267F99),            // 内置类型
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'number': const TextStyle(
        color: Color(0xFF098658),            // 数字
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'regexp': const TextStyle(
        color: Color(0xFFEE0000),            // 正则表达式
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'string': const TextStyle(
        color: Color(0xFFA31515),            // 字符串
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'subst': const TextStyle(
        color: Color(0xFF000000),            // 替换
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'symbol': const TextStyle(
        color: Color(0xFF9B2393),            // 符号 - 紫红色
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'class': const TextStyle(
        color: Color(0xFF267F99),            // 类
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'function': const TextStyle(
        color: Color(0xFF795E26),            // 函数
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'title': const TextStyle(
        color: Color(0xFF795E26),            // 标题（函数名等）
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'params': const TextStyle(
        color: Color(0xFF001080),            // 参数
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'comment': const TextStyle(
        color: Color(0xFF008000),            // 注释
        fontStyle: FontStyle.italic,
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'doctag': const TextStyle(
        color: Color(0xFF008000),            // 文档标签
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'meta': const TextStyle(
        color: Color(0xFF001080),            // 元数据
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'meta-keyword': const TextStyle(
        color: Color(0xFF9B2393),            // 元数据关键字 - 紫红色
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'meta-string': const TextStyle(
        color: Color(0xFFA31515),            // 元数据字符串
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'section': const TextStyle(
        color: Color(0xFF795E26),            // 节
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'tag': const TextStyle(
        color: Color(0xFF800000),            // 标签
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'name': const TextStyle(
        color: Color(0xFF800000),            // 名称
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'attr': const TextStyle(
        color: Color(0xFFFF0000),            // 属性
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'attribute': const TextStyle(
        color: Color(0xFFFF0000),            // 属性
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'variable': const TextStyle(
        color: Color(0xFF001080),            // 变量
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'bullet': const TextStyle(
        color: Color(0xFF000000),            // 项目符号
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'code': const TextStyle(
        color: Color(0xFF000000),            // 代码
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'emphasis': const TextStyle(
        fontStyle: FontStyle.italic,         // 强调
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'strong': const TextStyle(
        fontWeight: FontWeight.bold,         // 加粗
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'formula': const TextStyle(
        color: Color(0xFF000000),            // 公式
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'link': const TextStyle(
        color: Color(0xFF9B2393),            // 链接 - 紫红色
        decoration: TextDecoration.underline,
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'quote': const TextStyle(
        color: Color(0xFF008000),            // 引用
        fontStyle: FontStyle.italic,
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'selector-tag': const TextStyle(
        color: Color(0xFF800000),            // 选择器标签
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'selector-id': const TextStyle(
        color: Color(0xFF001080),            // 选择器ID
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'selector-class': const TextStyle(
        color: Color(0xFF001080),            // 选择器类
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'selector-attr': const TextStyle(
        color: Color(0xFF001080),            // 选择器属性
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'selector-pseudo': const TextStyle(
        color: Color(0xFF800000),            // 选择器伪类
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'template-tag': const TextStyle(
        color: Color(0xFF9B2393),            // 模板标签 - 紫红色
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'template-variable': const TextStyle(
        color: Color(0xFF001080),            // 模板变量
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'addition': const TextStyle(
        color: Color(0xFF098658),            // 添加
        backgroundColor: Color(0xFFE8E8E8),
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'deletion': const TextStyle(
        color: Color(0xFFA31515),            // 删除
        backgroundColor: Color(0xFFE8E8E8),
        fontSize: 14.0,                      // 添加固定字体大小
      ),
      'preprocessor': const TextStyle(
        color: Color(0xFF9B2393),            // 预处理指令，如#include - 紫红色
        fontSize: 14.0,                      // 添加固定字体大小
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),  // 原来的灰色背景
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  language,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.0,
                    fontWeight: FontWeight.normal,
                    height: 1.0,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.content_copy, size: 14),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('代码已复制'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(24, 24),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          HighlightView(
            code.trimRight(),
            language: language,
            theme: _vscodeTheme,
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              top: 4.0,
              bottom: 8.0,
            ),
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
} 