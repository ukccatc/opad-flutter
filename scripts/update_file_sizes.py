#!/usr/bin/env python3
"""
Script to update file sizes in uploaded_files_data.dart based on actual files
"""
import os
import re
from pathlib import Path

def main():
    target_dir = Path("/Users/macbookpro/Git Actions/flutter-opad/web/assets/uploads")
    data_file = Path("/Users/macbookpro/Git Actions/flutter-opad/lib/data/uploaded_files_data.dart")
    
    print("=" * 70)
    print("UPDATING FILE SIZES IN uploaded_files_data.dart")
    print("=" * 70)
    
    # Check if files exist
    if not target_dir.exists():
        print(f"\n⚠️  Uploads directory not found: {target_dir}")
        print("   Please copy files first: python3 scripts/copy_uploads.py")
        return False
    
    # Read data file
    if not data_file.exists():
        print(f"\n❌ Data file not found: {data_file}")
        return False
    
    with open(data_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all file entries and update sizes
    pattern = r"(UploadedFile\(\s*name:\s*'([^']+)',\s*path:\s*'([^']+)',\s*type:\s*'([^']+)',\s*size:\s*)(\d+)(,\s*year:\s*'([^']+)',\s*category:\s*'([^']+)',\s*\))"
    
    updated_count = 0
    not_found = []
    
    def replace_size(match):
        nonlocal updated_count, not_found
        name = match.group(2)
        path = match.group(3)
        file_type = match.group(4)
        old_size = match.group(5)
        year = match.group(6)
        category = match.group(7)
        
        # Check if file exists
        file_path = target_dir / path
        if file_path.exists():
            size = file_path.stat().st_size
            updated_count += 1
            return f"{match.group(1)}{size}{match.group(6)}"
        else:
            not_found.append(path)
            return match.group(0)  # Keep original
    
    updated_content = re.sub(pattern, replace_size, content)
    
    # Write back
    with open(data_file, 'w', encoding='utf-8') as f:
        f.write(updated_content)
    
    print(f"\n✓ Updated {updated_count} file sizes")
    
    if not_found:
        print(f"\n⚠️  {len(not_found)} files not found in uploads directory:")
        for path in not_found[:5]:
            print(f"   - {path}")
        if len(not_found) > 5:
            print(f"   ... and {len(not_found) - 5} more")
    
    # Show some examples
    print(f"\nSample updated sizes:")
    for root, dirs, files in os.walk(target_dir):
        for file in files[:5]:
            if file.lower().endswith(('.pdf', '.doc', '.docx')):
                file_path = Path(root) / file
                size = file_path.stat().st_size
                size_mb = size / (1024 * 1024)
                size_kb = size / 1024
                if size_mb >= 1:
                    size_str = f"{size_mb:.2f} MB"
                else:
                    size_str = f"{size_kb:.1f} KB"
                print(f"   {file}: {size_str}")
        break
    
    print(f"\n{'=' * 70}")
    print("✓ UPDATE COMPLETED!")
    print("=" * 70)
    
    return True

if __name__ == "__main__":
    main()

