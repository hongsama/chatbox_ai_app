/// Markdown示例文本集合
class MarkdownExamples {
  /// 基础Markdown示例
  static const String basicExample = '''
# 标题1
## 标题2
### 标题3

这是一段普通文本，包含**加粗**、*斜体*和~~删除线~~。

> 这是一个引用块
> 多行引用

- 无序列表项1
- 无序列表项2
  - 嵌套列表项

1. 有序列表项1
2. 有序列表项2

---

[链接文本](https://www.baidu.com)

![图片描述](https://www.baidu.com/img/PCtm_d9c8750bed0b3c7d089fa7d55720d6cf.png)

`行内代码`

```dart
// 代码块
void main() {
  print('Hello World');
}
```
''';

  /// 数学公式示例
  static const String mathExample = '''
# 数学公式示例

行内公式: \\(E = mc^2\\)

块级公式:

\\[
\\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}
\\]

矩阵示例:

\\[
\\begin{bmatrix} 
a & b \\\\ 
c & d 
\\end{bmatrix}
\\]

方程组:

\\[
\\begin{cases}
a_1x + b_1y = c_1 \\\\
a_2x + b_2y = c_2
\\end{cases}
\\]
''';

  /// 复杂嵌套示例
  static const String nestedExample = '''
# 嵌套结构测试

- 列表中的代码块:
  ```
  function test() {
    console.log("Hello");
  }
  ```

- 列表中的引用:
  > 这是嵌套在列表中的引用
  > 包含多行

> 引用中的列表:
> - 第一项
> - 第二项
>
> 引用中的代码:
> ```
> const value = "test";
> ```

1. 有序列表中的数学公式:
   \\[\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}\\]

2. 嵌套列表结构:
   - 子项A
     - 子子项1
     - 子子项2
   - 子项B
''';

  /// 获取所有示例内容
  static List<String> getAllExamples() {
    return [basicExample, mathExample, nestedExample];
  }
  
  /// 流式分割示例，返回小片段用于流式显示
  static List<String> getStreamingChunks(String source, {int chunkSize = 10}) {
    List<String> result = [];
    for (int i = 0; i < source.length; i += chunkSize) {
      final end = (i + chunkSize < source.length) ? i + chunkSize : source.length;
      result.add(source.substring(i, end));
    }
    return result;
  }
} 