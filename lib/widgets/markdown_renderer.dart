import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'code_builder.dart';

/// 自定义Markdown渲染组件
class MarkdownRenderer extends StatelessWidget {
  final String data;
  
  const MarkdownRenderer({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final codeBackgroundColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    
    return MarkdownBody(
      data: data,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: textColor),
        strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        em: TextStyle(color: textColor, fontStyle: FontStyle.italic),
        code: TextStyle(color: textColor, backgroundColor: Colors.transparent),
        codeblockDecoration: BoxDecoration(
          color: codeBackgroundColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        blockquoteDecoration: BoxDecoration(
          color: codeBackgroundColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
        a: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
      builders: {
        'code': CodeElementBuilder(),
      },
      extensionSet: md.ExtensionSet(
        [
          const md.FencedCodeBlockSyntax(),
          const md.TableSyntax(),
        ],
        [
          md.InlineHtmlSyntax(),
          md.AutolinkExtensionSyntax(),
          md.StrikethroughSyntax(),
        ],
      ),
      selectable: true,
    );
  }
} 