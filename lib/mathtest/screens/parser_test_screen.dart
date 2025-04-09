import 'package:flutter/material.dart';
import '../parsers/markdown_parser.dart';

/// Markdown解析器测试屏幕
class ParserTestScreen extends StatefulWidget {
  const ParserTestScreen({Key? key}) : super(key: key);

  @override
  State<ParserTestScreen> createState() => _ParserTestScreenState();
}

class _ParserTestScreenState extends State<ParserTestScreen> {
  final TextEditingController _controller = TextEditingController();
  String _markdownText = '''
# 标题测试
这是一个段落，包含**粗体**和*斜体*文本。

## 二级标题
> 这是一个引用，引用中也可以有**粗体**和*斜体*。

### 三级标题
- 无序列表项1
- **粗体列表项**
- 包含*斜体*的列表项

#### 四级标题
1. 有序列表项1
2. **粗体有序列表项**
3. 包含*斜体*的有序列表项

##### 公式测试
这是一个包含LaTeX公式的段落: \$E=mc^2\$ 和 \\\\(\\\\alpha + \\\\beta\\\\)

\\\\[ \\\\int_{a}^{b} f(x) dx = F(b) - F(a) \\\\]
''';

  @override
  void initState() {
    super.initState();
    _controller.text = _markdownText;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown解析器测试'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '输入Markdown文本...',
                ),
                onChanged: (value) {
                  setState(() {
                    _markdownText = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: MarkdownParser.parseDocument(_markdownText),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 