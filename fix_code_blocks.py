#!/usr/bin/env python3

import re

def convert_code_blocks(content):
    """Convert triple-backtick code blocks to indented code blocks"""
    
    # Pattern to match code blocks with triple backticks
    pattern = r'^```\n(.*?)\n```'
    
    def replace_code_block(match):
        code_content = match.group(1)
        # Indent each line with 4 spaces
        indented_lines = []
        for line in code_content.split('\n'):
            if line.strip():  # Don't indent empty lines
                indented_lines.append('    ' + line)
            else:
                indented_lines.append('')
        return '\n'.join(indented_lines)
    
    # Replace all code blocks
    result = re.sub(pattern, replace_code_block, content, flags=re.MULTILINE | re.DOTALL)
    return result

# Read the file
with open('draft-howe-sipcore-mcp-extension.md', 'r', encoding='utf-8') as f:
    content = f.read()

# Convert code blocks
new_content = convert_code_blocks(content)

# Write back to file
with open('draft-howe-sipcore-mcp-extension.md', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Code blocks converted from triple backticks to indented format")
