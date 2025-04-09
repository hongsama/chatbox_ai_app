import 'package:flutter/material.dart';
import 'markdown_element.dart';

/// 列表渲染组件
class MarkdownListWidget extends MarkdownElementWidget {
  const MarkdownListWidget({
    Key? key,
    required String rawContent,
    required MarkdownTheme theme,
  }) : super(key: key, rawContent: rawContent, theme: theme);
  
  @override
  Widget build(BuildContext context) {
    final listData = _parseList(rawContent);
    
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        top: theme.contentPadding.top,
        bottom: theme.contentPadding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildListItems(listData),
      ),
    );
  }
  
  /// 解析列表内容
  ListData _parseList(String content) {
    final lines = content.split('\n');
    final items = <ListItem>[];
    ListType listType = ListType.unordered;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // 检测有序列表项
      final orderedMatch = RegExp(r'^(\d+)\.(.+)$').firstMatch(trimmedLine);
      if (orderedMatch != null) {
        final number = int.parse(orderedMatch.group(1)!);
        final text = orderedMatch.group(2)!.trim();
        items.add(ListItem(
          text: text,
          number: number,
          type: ListType.ordered,
        ));
        listType = ListType.ordered;
        continue;
      }
      
      // 检测无序列表项
      final unorderedMatch = RegExp(r'^[-*+](.+)$').firstMatch(trimmedLine);
      if (unorderedMatch != null) {
        final text = unorderedMatch.group(1)!.trim();
        items.add(ListItem(
          text: text,
          type: ListType.unordered,
        ));
        listType = ListType.unordered;
      }
    }
    
    return ListData(
      items: items,
      type: listType,
    );
  }
  
  /// 构建列表项组件
  List<Widget> _buildListItems(ListData listData) {
    return listData.items.map((item) {
      // 根据列表类型创建不同的前缀
      Widget prefix;
      if (item.type == ListType.ordered) {
        prefix = Text(
          '${item.number}. ',
          style: TextStyle(
            fontSize: theme.fontSize,
            color: theme.textColor,
            fontWeight: FontWeight.bold,
          ),
        );
      } else {
        prefix = Text(
          '• ',
          style: TextStyle(
            fontSize: theme.fontSize,
            color: theme.textColor,
            fontWeight: FontWeight.bold,
          ),
        );
      }
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            prefix,
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: theme.fontSize,
                  color: theme.textColor,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

/// 列表类型枚举
enum ListType {
  ordered,
  unordered,
}

/// 列表数据类
class ListData {
  final List<ListItem> items;
  final ListType type;
  
  ListData({
    required this.items,
    required this.type,
  });
}

/// 列表项数据类
class ListItem {
  final String text;
  final int? number;
  final ListType type;
  
  ListItem({
    required this.text,
    this.number,
    required this.type,
  });
} 