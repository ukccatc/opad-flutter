#!/usr/bin/env python3
"""
Update all file sizes in uploaded_files_data.dart based on actual files
"""
import os
import re
from pathlib import Path

def main():
    target_dir = Path("/Users/macbookpro/Git Actions/flutter-opad/web/assets/uploads")
    data_file = Path("/Users/macbookpro/Git Actions/flutter-opad/lib/data/uploaded_files_data.dart")
    
    print("Updating file sizes...")
    
    if not target_dir.exists():
        print("⚠️  Uploads directory not found")
        return False
    
    # Read data file
    with open(data_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all path: '...' entries and update their sizes
    pattern = r"path:\s*'([^']+)'"
    paths = re.findall(pattern, content)
    
    updated = 0
    for path_str in paths:
        file_path = target_dir / path_str
        if file_path.exists():
            size = file_path.stat().st_size
            # Replace size: 0, or size: number, with actual size
            # Match the pattern: path: '...', type: '...', size: number,
            block_pattern = rf"(path:\s*'{re.escape(path_str)}',\s*type:\s*'[^']+',\s*size:\s*)\d+"
            replacement = rf"\g<1>{size}"
            new_content = re.sub(block_pattern, replacement, content)
            if new_content != content:
                content = new_content
                updated += 1
    
    # Write back
    with open(data_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✓ Updated {updated} file sizes")
    return True

if __name__ == "__main__":
    main()

