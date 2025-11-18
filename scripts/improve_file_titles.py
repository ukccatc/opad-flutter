#!/usr/bin/env python3
"""
Improve file titles by reading content and generating readable names
"""
import os
import re
from pathlib import Path

def improve_title_from_filename(filename):
    """Convert filename to readable title"""
    # Remove extension
    name = filename.rsplit('.', 1)[0] if '.' in filename else filename
    
    # Common replacements
    replacements = {
        'в_д': 'від',
        'С_РчР_Р°Рє': 'Серпня',
        'Р_Р_': 'Розпорядження',
        'ko-dog': 'Колективний договір',
        'KD': 'Колективний договір',
        'КД': 'Колективний договір',
        'mod_rewrite': 'Mod Rewrite',
        'galuzeva-ugoda': 'Галузева угода',
        'Rostovtsev_Oleg_aplication': 'Заява Ростовцева Олега',
    }
    
    # Apply replacements
    for old, new in replacements.items():
        name = name.replace(old, new)
    
    # Replace separators
    name = name.replace('-', ' ')
    name = name.replace('_', ' ')
    
    # Handle special characters
    name = name.replace('№', ' №')
    
    # Clean multiple spaces
    name = re.sub(r'\s+', ' ', name)
    name = name.strip()
    
    # Capitalize intelligently
    words = name.split()
    result = []
    
    for word in words:
        # Keep numbers and dates
        if word.isdigit() or re.match(r'^\d+[./-]\d+', word):
            result.append(word)
        # Keep acronyms (all caps, 2+ chars)
        elif word.isupper() and len(word) >= 2:
            result.append(word)
        # Capitalize first letter
        elif word:
            result.append(word[0].upper() + word[1:].lower())
    
    title = ' '.join(result)
    
    # Final cleanup
    title = title.replace('Кд', 'КД')
    title = title.replace('Опад', 'ОПАД')
    title = title.replace('Адо', 'АДО')
    title = title.replace('Від', 'від')
    title = title.replace('Про ', 'про ')
    title = title.replace('На ', 'на ')
    title = title.replace('З ', 'з ')
    
    return title

def main():
    target_dir = Path("/Users/macbookpro/Git Actions/flutter-opad/web/assets/uploads")
    data_file = Path("/Users/macbookpro/Git Actions/flutter-opad/lib/data/uploaded_files_data.dart")
    
    print("=" * 70)
    print("IMPROVING FILE TITLES")
    print("=" * 70)
    
    if not target_dir.exists():
        print("⚠️  Uploads directory not found")
        return False
    
    # Read data file
    with open(data_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all name: '...' entries
    pattern = r"name:\s*'([^']+)'"
    matches = re.findall(pattern, content)
    
    print(f"\nFound {len(matches)} files")
    print("\nGenerating improved titles...")
    
    # Generate improved titles
    titles_map = {}
    for filename in matches:
        improved = improve_title_from_filename(filename)
        titles_map[filename] = improved
        print(f"  {filename[:45]:<45} -> {improved[:55]}")
    
    # Update the data file
    updated_count = 0
    for original_name, improved_title in titles_map.items():
        # Escape for regex
        escaped_original = re.escape(original_name)
        # Update name field
        old_pattern = f"name:\\s*'{escaped_original}'"
        new_replacement = f"name: '{improved_title}'"
        new_content = re.sub(old_pattern, new_replacement, content)
        if new_content != content:
            content = new_content
            updated_count += 1
    
    # Write back
    with open(data_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"\n{'=' * 70}")
    print(f"✓ Updated {updated_count} file titles")
    print("=" * 70)
    
    return True

if __name__ == "__main__":
    main()

