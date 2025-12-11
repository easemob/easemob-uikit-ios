import os
import re



def infer_description(func_name):
    # Dictionary of common method names and their descriptions
    common_descriptions = {
        "viewDidLoad": "Called after the controller's view is loaded into memory.",
        "viewWillAppear": "Notifies the view controller that its view is about to be added to a view hierarchy.",
        "viewDidAppear": "Notifies the view controller that its view was added to a view hierarchy.",
        "viewWillDisappear": "Notifies the view controller that its view is about to be removed from a view hierarchy.",
        "viewDidDisappear": "Notifies the view controller that its view was removed from a view hierarchy.",
        "layoutSubviews": "Lays out subviews.",
        "setupViews": "Sets up the view hierarchy and layout.",
        "pop": "Pops the current view controller from the navigation stack.",
        "dismiss": "Dismisses the view controller.",
        "cellForRowAt": "Asks the data source for a cell to insert in a particular location of the table view.",
        "didSelectRowAt": "Tells the delegate that the specified row is now selected.",
        "numberOfSections": "Asks the data source to return the number of sections in the table view.",
        "numberOfRowsInSection": "Asks the data source to return the number of rows in a given section of a table view.",
        "init": "Initializes the object.",
        "deinit": "Deinitializes the object.",
    }
    
    if func_name in common_descriptions:
        return common_descriptions[func_name]
    
    # Heuristic: Split camelCase
    # e.g., createAvatarStatus -> Create Avatar Status
    # e.g., navigationClick -> Navigation Click
    
    # Insert space before capital letters
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1 \2', func_name)
    s2 = re.sub('([a-z0-9])([A-Z])', r'\1 \2', s1).lower()
    
    # Capitalize first letter of each word
    words = s2.split()
    capitalized_words = [w.capitalize() for w in words]
    description = " ".join(capitalized_words)
    
    # Heuristic: Detect keywords
    lower_name = func_name.lower()
    if "click" in lower_name or "action" in lower_name or "tap" in lower_name:
        description += " (Action handler)"
    elif "create" in lower_name or "make" in lower_name:
        description += " (Factory method)"
    elif "update" in lower_name:
        description += " (Update logic)"
    elif "setup" in lower_name or "config" in lower_name:
        description += " (Configuration)"
        
    return description

def parse_swift_file(file_path, relative_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    module_name = os.path.dirname(relative_path)
    if module_name == "":
        module_name = "Root"
    
    filename = os.path.basename(file_path)
    
    # Regex patterns
    # Matches: open class ClassName ...
    class_pattern = re.compile(r'.*\bopen\s+class\s+(\w+)')
    # Matches: open func funcName... or @objc open func ...
    # We want to capture the function name. It might be `funcName(` or `funcName<T>(`
    func_pattern = re.compile(r'.*\bopen\s+func\s+([^\(\s<]+)')
    
    results = []
    current_class = "Global/Extension" # Default if outside a class
    comments = []
    
    for line in lines:
        stripped_line = line.strip()
        
        # Collect documentation comments
        if stripped_line.startswith('///'):
            # Remove '///' and leading space
            comment_content = stripped_line[3:].strip()
            comments.append(comment_content)
            continue
        
        # Check for class definition
        class_match = class_pattern.match(stripped_line)
        if class_match:
            current_class = class_match.group(1)
            comments = [] # Reset comments after consuming or if not relevant
            continue
            
        # Check for function definition
        func_match = func_pattern.match(stripped_line)
        if func_match:
            func_name = func_match.group(1)
            if comments:
                description = " ".join(comments)
            else:
                description = infer_description(func_name)
                
            results.append({
                "Module": module_name,
                "Class": current_class,
                "Function": func_name,
                "Description": description
            })
            comments = [] # Reset after usage
            continue
            
        # If line is not a comment and not a definition, reset comments
        # Note: This is a simple heuristic. Attributes (like @objc) on separate lines might break this.
        # To be more robust, we could allow lines starting with @ to not reset comments.
        if stripped_line and not stripped_line.startswith('@'):
             comments = []

    return results

def generate_markdown(data):
    # Sort by Module, then Class
    data.sort(key=lambda x: (x['Module'], x['Class'], x['Function']))
    
    md_lines = []
    md_lines.append("# Open API Reference")
    md_lines.append("")
    md_lines.append("| Module | Class | Function | Description |")
    md_lines.append("| :--- | :--- | :--- | :--- |")
    
    for item in data:
        # Escape pipe characters in description to avoid breaking table
        desc = item['Description'].replace('|', '\|')
        line = f"| {item['Module']} | {item['Class']} | {item['Function']} | {desc} |"
        md_lines.append(line)
        
    return "\n".join(md_lines)

def main():
    root_dir = "."
    all_results = []
    
    print(f"Scanning for .swift files in '{os.path.abspath(root_dir)}'...")
    
    for dirpath, dirnames, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith(".swift"):
                full_path = os.path.join(dirpath, filename)
                relative_path = os.path.relpath(full_path, root_dir)
                
                # Skip the script itself if it's a swift file (unlikely but good practice)
                # and maybe skip hidden folders
                if filename.startswith('.'): continue
                
                file_results = parse_swift_file(full_path, relative_path)
                all_results.extend(file_results)
                
    if not all_results:
        print("No 'open func' found.")
        return

    md_content = generate_markdown(all_results)
    
    output_file = "API_README.md"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(md_content)
        
    print(f"Successfully generated {output_file} with {len(all_results)} entries.")

if __name__ == "__main__":
    main()
