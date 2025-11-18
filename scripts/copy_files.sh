#!/bin/bash

# Script to copy PDF and DOC files from WordPress uploads to Flutter web assets

SOURCE="/Users/macbookpro/Downloads/admin-1_full-2025-11-01/www/opad.com.ua/wp-content/uploads"
TARGET="/Users/macbookpro/Git Actions/flutter-opad/web/assets/uploads"

echo "=========================================="
echo "Copying files from WordPress to Flutter"
echo "=========================================="
echo ""
echo "Source: $SOURCE"
echo "Target: $TARGET"
echo ""

# Check if source exists
if [ ! -d "$SOURCE" ]; then
    echo "ERROR: Source directory does not exist!"
    echo "Please check: $SOURCE"
    exit 1
fi

# Create target directory
mkdir -p "$TARGET"
echo "✓ Target directory created"

# Copy PDF and DOC files
echo ""
echo "Copying files..."
count=0

find "$SOURCE" -type f \( -name "*.pdf" -o -name "*.doc" -o -name "*.docx" \) | while read file; do
    rel_path="${file#$SOURCE/}"
    target_file="$TARGET/$rel_path"
    target_dir=$(dirname "$target_file")
    
    mkdir -p "$target_dir"
    cp "$file" "$target_file"
    count=$((count + 1))
    
    if [ $count -le 5 ]; then
        echo "  ✓ Copied: $rel_path"
    fi
done

echo ""
echo "=========================================="
echo "✓ Copying completed!"
echo ""
echo "Next steps:"
echo "  1. Restart Flutter app: flutter run -d chrome"
echo "  2. Try downloading a file"
echo "  3. Check browser console (F12) for errors"
echo "=========================================="

