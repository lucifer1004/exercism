#!/usr/bin/env python3
"""
Ensure all text files in the repository end with exactly one newline.

Usage:
    ./fix-eol.py          # Fix all files
    ./fix-eol.py --check  # Check only (dry run)
"""

import subprocess
import sys
from pathlib import Path

# Colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[0;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'

def is_text_file(filepath):
    """Check if file is a text file using 'file' command."""
    try:
        result = subprocess.run(
            ['file', '--brief', '--mime-type', str(filepath)],
            capture_output=True,
            text=True,
            check=True
        )
        mime_type = result.stdout.strip()
        return (mime_type.startswith('text/') or 
                mime_type in ['application/json', 'application/x-empty', 'inode/x-empty'])
    except subprocess.CalledProcessError:
        return False

def check_file_ending(filepath):
    """
    Check if file ends with exactly one newline.
    Returns: (needs_fix: bool, reason: str)
    """
    try:
        with open(filepath, 'rb') as f:
            content = f.read()
            
        if not content:
            return False, "empty"
            
        # Count trailing newlines
        trailing_newlines = 0
        for i in range(len(content) - 1, -1, -1):
            if content[i:i+1] == b'\n':
                trailing_newlines += 1
            else:
                break
        
        if trailing_newlines == 0:
            return True, "missing newline"
        elif trailing_newlines > 1:
            return True, "multiple newlines"
        else:
            return False, "ok"
            
    except Exception as e:
        return False, f"error: {e}"

def fix_file_ending(filepath):
    """Remove all trailing newlines and add exactly one."""
    try:
        with open(filepath, 'rb') as f:
            content = f.read()
        
        # Remove all trailing newlines
        content = content.rstrip(b'\n')
        
        # Add exactly one newline
        content += b'\n'
        
        with open(filepath, 'wb') as f:
            f.write(content)
        
        return True
    except Exception as e:
        print(f"{RED}Error fixing {filepath}: {e}{NC}")
        return False

def main():
    dry_run = '--check' in sys.argv
    
    print(f"{BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{NC}")
    if dry_run:
        print(f"{YELLOW}🔍 Checking end-of-line in all text files (dry run){NC}")
    else:
        print(f"{GREEN}🔧 Fixing end-of-line in all text files{NC}")
    print(f"{BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{NC}")
    print()
    
    # Get all tracked files from jj
    try:
        result = subprocess.run(
            ['jj', 'file', 'list'],
            capture_output=True,
            text=True
        )
        files = [line.strip() for line in result.stdout.splitlines() 
                 if line.strip() and not line.startswith('Working copy changes:')]
    except subprocess.CalledProcessError:
        print(f"{RED}Error: Could not get file list from jj{NC}")
        return 1
    
    fixed = 0
    skipped = 0
    already_ok = 0
    
    for filepath_str in files:
        filepath = Path(filepath_str)
        
        # Skip if doesn't exist
        if not filepath.exists() or not filepath.is_file():
            continue
        
        # Check if text file
        if not is_text_file(filepath):
            skipped += 1
            continue
        
        # Check if empty
        if filepath.stat().st_size == 0:
            skipped += 1
            continue
        
        # Check file ending
        needs_fix, reason = check_file_ending(filepath)
        
        if needs_fix:
            if dry_run:
                print(f"{YELLOW}Would fix:{NC} {filepath} ({reason})")
                fixed += 1
            else:
                if fix_file_ending(filepath):
                    print(f"{GREEN}Fixed:{NC} {filepath} ({reason})")
                    fixed += 1
                else:
                    skipped += 1
        else:
            already_ok += 1
    
    # Summary
    print()
    print(f"{BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{NC}")
    print(f"{GREEN}✅ Already OK:{NC} {already_ok} files")
    if dry_run:
        print(f"{YELLOW}⚠️  Would fix:{NC} {fixed} files")
    else:
        print(f"{GREEN}🔧 Fixed:{NC} {fixed} files")
    print(f"{BLUE}⏭️  Skipped:{NC} {skipped} files (binary/empty)")
    print(f"{BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{NC}")
    
    if fixed > 0 and dry_run:
        print()
        print(f"{YELLOW}Run without --check to apply fixes.{NC}")
        return 1
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
