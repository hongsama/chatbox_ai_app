import 'package:flutter/material.dart';
import '../widgets/markdown_display_v2.dart';

class FixedMarkdownScreen extends StatefulWidget {
  const FixedMarkdownScreen({Key? key}) : super(key: key);

  @override
  State<FixedMarkdownScreen> createState() => _FixedMarkdownScreenState();
}

class _FixedMarkdownScreenState extends State<FixedMarkdownScreen> {
  // 固定的Markdown文本
  final String fixedMarkdown = '''### 二元二次方程组消元法简介

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
\\( y = 8 + x \\)

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

如果需要进一步解释或扩展，请随时提问！''';
  
  // 控制滚动
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('二元方程组消元法'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          child: MarkdownDisplayV2(
            markdownText: fixedMarkdown,
            isTyping: false,
          ),
        ),
      ),
    );
  }
} 