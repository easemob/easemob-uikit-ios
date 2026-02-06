
import os
import re

def refactor_uiimage_in_swift_files(root_dir):
    # 1. 定义正则表达式
    # 解析：
    # UIImage\s*\(      -> 匹配 UIImage(，允许中间有空格
    # \s*named:\s* -> 匹配 named:，允许周围有空格
    # (.+?)             -> 捕获组1：捕获图片名称（非贪婪匹配，直到遇到后面的逗号）
    # \s*,\s*in:\s*\.chatBundle -> 匹配 , in: .chatBundle，允许空格和换行
    # \s*,\s*with:\s*nil\s*\)   -> 匹配 , with: nil)，允许空格和换行
    pattern = re.compile(r'UIImage\s*\(\s*named:\s*(.+?)\s*,\s*in:\s*\.chatBundle\s*,\s*with:\s*nil\s*\)', re.DOTALL)
    
    # 2. 定义替换模板
    # \1 代表保留原本 named 后面的参数内容（例如 "icon" 或 logic ? "a" : "b"）
    replacement = r'UIImage(chatNamed: \1)'

    file_count = 0
    replace_count = 0

    print(f"🚀 开始在 '{root_dir}' 目录下进行搜索和替换...")

    # 3. 递归遍历目录
    for dirpath, dirnames, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith(".swift"):
                file_path = os.path.join(dirpath, filename)
                
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()

                    # 检查是否有匹配项
                    if pattern.search(content):
                        # 执行替换
                        new_content, count = pattern.subn(replacement, content)
                        
                        if count > 0:
                            with open(file_path, 'w', encoding='utf-8') as f:
                                f.write(new_content)
                            
                            print(f"✅ 修改了: {filename} (替换了 {count} 处)")
                            file_count += 1
                            replace_count += count
                            
                except Exception as e:
                    print(f"⚠️ 读取/写入文件出错 {filename}: {e}")

    print("-" * 30)
    print(f"🎉 处理完成！")
    print(f"共修改文件数: {file_count}")
    print(f"共替换调用处: {replace_count}")

if __name__ == "__main__":
    # 获取当前脚本所在目录
    current_directory = os.getcwd()
    refactor_uiimage_in_swift_files(current_directory)
