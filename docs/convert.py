import json

def parse_content_from_file(file_path):
    """
    解析 JSON 格式的文件，提取所有 `content` 字段，并返回 Python 列表。
    
    Args:
        file_path (str): 输入文件的路径
    
    Returns:
        list: 包含所有 `content` 的列表
    """
    content_list = []
    
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            line = line.strip()  # 去除首尾空白字符
            if not line.startswith("data:"):  # 确保是 JSON 数据行
                continue
            
            # 解析 JSON
            try:
                json_str = line[5:]  # 去掉 "data:"
                data = json.loads(json_str)
                
                # 提取 content
                if "choices" in data and len(data["choices"]) > 0:
                    choice = data["choices"][0]
                    if "delta" in choice and "content" in choice["delta"]:
                        content_list.append(choice["delta"]["content"])
            except json.JSONDecodeError as e:
                print(f"JSON 解析错误: {e}")
                continue
    
    return content_list

if __name__ == "__main__":
    input_file = "io.txt"  # 替换成你的文件路径
    output_file = "output.py"  # 输出 Python 列表的文件
    
    contents = parse_content_from_file(input_file)
    
    # 写入 Python 列表到文件
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("content_list = [\n")
        for content in contents:
            # 处理特殊字符（如换行符、引号）
            escaped_content = content.replace("\n", "\\n").replace("\"", "\\\"")
            f.write(f'    "{escaped_content}",\n')
        f.write("]\n")
    
    print(f"解析完成！结果已保存到 {output_file}")