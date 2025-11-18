#!/usr/bin/env python3
"""
Script to copy PDF and DOC files from WordPress uploads to Flutter web assets
"""
import os
import shutil
from pathlib import Path

def main():
    # Paths
    source_dir = Path("/Users/macbookpro/Downloads/admin-1_full-2025-11-01/www/opad.com.ua/wp-content/uploads")
    target_dir = Path("/Users/macbookpro/Git Actions/flutter-opad/web/assets/uploads")
    
    print("=" * 70)
    print("COPYING FILES FROM WORDPRESS TO FLUTTER PROJECT")
    print("=" * 70)
    print(f"\nSource: {source_dir}")
    print(f"Target: {target_dir}")
    
    # Check source
    if not source_dir.exists():
        print(f"\n❌ ERROR: Source directory not found!")
        print(f"   {source_dir}")
        return False
    
    print(f"✓ Source directory exists")
    
    # Create target
    target_dir.mkdir(parents=True, exist_ok=True)
    print(f"✓ Target directory created: {target_dir}")
    
    # Find and copy files
    pdf_count = 0
    doc_count = 0
    errors = []
    
    print("\nCopying files...")
    for root, dirs, files in os.walk(source_dir):
        for file in files:
            if file.lower().endswith(('.pdf', '.doc', '.docx')):
                src_path = Path(root) / file
                rel_path = src_path.relative_to(source_dir)
                dst_path = target_dir / rel_path
                
                try:
                    dst_path.parent.mkdir(parents=True, exist_ok=True)
                    if not dst_path.exists():
                        shutil.copy2(src_path, dst_path)
                        if file.lower().endswith('.pdf'):
                            pdf_count += 1
                        else:
                            doc_count += 1
                        if (pdf_count + doc_count) <= 10:
                            print(f"  ✓ {rel_path}")
                except Exception as e:
                    errors.append(f"{file}: {e}")
    
    print(f"\n{'=' * 70}")
    print(f"SUMMARY:")
    print(f"  PDF files: {pdf_count}")
    print(f"  DOC files: {doc_count}")
    print(f"  Total: {pdf_count + doc_count}")
    
    if errors:
        print(f"\nErrors: {len(errors)}")
        for e in errors[:5]:
            print(f"  - {e}")
    
    # Verify
    total = len(list(target_dir.rglob('*.pdf'))) + len(list(target_dir.rglob('*.doc'))) + len(list(target_dir.rglob('*.docx')))
    print(f"\nTotal files in target: {total}")
    
    # Check samples
    samples = [
        "2016/10/Статут-ОПАД.pdf",
        "2016/11/Памятка.docx",
        "2016/12/ПРОТОКОЛ-№1.pdf",
    ]
    
    print(f"\nVerification:")
    for sample in samples:
        sample_path = target_dir / sample
        if sample_path.exists():
            size = sample_path.stat().st_size
            print(f"  ✓ {sample} ({size:,} bytes)")
        else:
            print(f"  ✗ {sample} (not found)")
    
    print(f"\n{'=' * 70}")
    print("✓ COPYING COMPLETED!")
    print(f"\nFiles location: {target_dir}")
    print("=" * 70)
    
    return True

if __name__ == "__main__":
    main()

