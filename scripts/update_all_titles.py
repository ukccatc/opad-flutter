#!/usr/bin/env python3
"""
Update all file titles in uploaded_files_data.dart with improved readable names
"""
import re
from pathlib import Path

def improve_title(filename):
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
        'ПРОТОКОЛ': 'Протокол',
        'Св_дотство': 'Свідотство',
        'Сп_льне': 'Спільне',
        'р_шення': 'рішення',
        'Стратег_чний': 'Стратегічний',
        'Генер.': 'Генеральний',
        'дог.': 'договір',
        'сканкоп_я': 'сканкопія',
        'Обєднання': 'Об\'єднання',
        'Реквизиты': 'Реквізити',
        'счета': 'рахунку',
        'Устав': 'Статут',
        'Украэрорух': 'Украерорух',
        'Страховка': 'Страхування',
        'Гендоговір': 'Генеральний договір',
        'Нафтогазстрах': 'Нафтогазстрах',
    }
    
    for old, new in replacements.items():
        name = name.replace(old, new)
    
    # Replace separators
    name = name.replace('-', ' ')
    name = name.replace('_', ' ')
    
    # Handle special characters
    name = name.replace('№', ' №')
    name = name.replace('..', '.')
    
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
            # Handle Ukrainian/Russian capitalization
            if len(word) > 1:
                result.append(word[0].upper() + word[1:].lower())
            else:
                result.append(word.upper())
    
    title = ' '.join(result)
    
    # Final cleanup
    title = title.replace('Кд', 'КД')
    title = title.replace('Опад', 'ОПАД')
    title = title.replace('Адо', 'АДО')
    title = title.replace('Втр', 'ВТР')
    title = title.replace('Орсп', 'ОРСП')
    title = title.replace('Міу', 'МІУ')
    title = title.replace('Ат', 'АТ')
    title = title.replace('Ск', 'СК')
    
    # Handle common patterns
    title = re.sub(r'(\d+)-(\d+)', r'\1-\2', title)  # Keep dates with dashes
    title = re.sub(r'№\s*(\d+)', r'№\1', title)  # Remove space after №
    
    # Remove trailing dots
    title = title.rstrip('.')
    
    return title

def main():
    data_file = Path("/Users/macbookpro/Git Actions/flutter-opad/lib/data/uploaded_files_data.dart")
    
    print("=" * 70)
    print("UPDATING ALL FILE TITLES")
    print("=" * 70)
    
    # Read file
    with open(data_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all name entries
    pattern = r"name:\s*'([^']+)'"
    matches = re.findall(pattern, content)
    
    print(f"\nFound {len(matches)} files to process\n")
    
    # Generate improved titles
    titles_map = {}
    for original in matches:
        improved = improve_title(original)
        titles_map[original] = improved
        if improved != original:
            print(f"  {original[:45]:<45} -> {improved[:55]}")
    
    # Update the data file
    updated_count = 0
    for original_name, improved_title in titles_map.items():
        if improved_title != original_name:
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

