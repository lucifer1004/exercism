# Root Justfile - Manage all language projects

# Centralized list of all supported languages
LANGUAGES := "python racket raku zig ocaml clojure wasm mips julia go haskell rust elixir kotlin crystal"
MANUAL_LANGUAGES := "swift"  # Languages that require manual installation

# List all available commands
default:
    @just --list

# List all supported languages
languages:
    @echo "Nix-managed languages:"
    @echo "{{LANGUAGES}}" | tr ' ' '\n' | sed 's/^/  - /'
    @echo ""
    @echo "Manual installation required:"
    @echo "{{MANUAL_LANGUAGES}}" | tr ' ' '\n' | sed 's/^/  - /'

# Test all projects in all languages
test-all:
    #!/usr/bin/env bash
    set -e
    
    echo "🧪 Testing all Exercism projects..."
    echo ""
    
    for lang in {{LANGUAGES}} {{MANUAL_LANGUAGES}}; do
        if [ -d "$lang" ] && [ -f "$lang/Justfile" ]; then
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📦 Testing $lang projects..."
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            if grep -q "test-all" "$lang/Justfile" 2>/dev/null; then
                (cd "$lang" && just test-all) || echo "⚠️  Some $lang tests failed"
            else
                echo "ℹ️  No test-all command for $lang (run tests individually)"
            fi
            echo ""
        fi
    done
    
    echo "✅ All tests completed!"

# Test specific language
test-lang lang:
    @cd {{lang}} && just test-all

# Setup specific language environment
setup lang:
    @echo "🔧 Setting up {{lang}} environment..."
    @cd {{lang}} && just setup

# Setup all development environments
setup-all:
    #!/usr/bin/env bash
    echo "🔧 Setting up all development environments..."
    for lang in {{LANGUAGES}} {{MANUAL_LANGUAGES}}; do
        if [ -d "$lang" ] && [ -f "$lang/Justfile" ]; then
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Setting up $lang..."
            (cd "$lang" && just setup) || echo "⚠️  Setup for $lang had issues"
        fi
    done
    echo "✅ All environments set up!"

# Update all flake locks
update-all:
    #!/usr/bin/env bash
    echo "🔄 Updating all flake locks..."
    for lang in {{LANGUAGES}}; do
        if [ -d "$lang" ] && [ -f "$lang/flake.nix" ]; then
            echo "Updating $lang..."
            (cd "$lang" && nix flake update)
        fi
    done
    echo "✅ All flakes updated!"

# Clean specific language build artifacts
clean-lang lang:
    @echo "🧹 Cleaning {{lang}} build artifacts..."
    @cd {{lang}} && just clean

# Clean all build artifacts
clean:
    #!/usr/bin/env bash
    echo "🧹 Cleaning build artifacts..."
    for lang in {{LANGUAGES}} {{MANUAL_LANGUAGES}}; do
        if [ -d "$lang" ] && [ -f "$lang/Justfile" ]; then
            echo "Cleaning $lang..."
            (cd "$lang" && just clean) || true
        fi
    done
    echo "✅ Cleanup complete!"

# Update specific language flake lock
update lang:
    @echo "🔄 Updating {{lang}} flake lock..."
    @cd {{lang}} && nix flake update

# Show project statistics
stats:
    #!/usr/bin/env bash
    echo "📊 Project Statistics"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    for lang in {{LANGUAGES}} {{MANUAL_LANGUAGES}}; do
        if [ -d "$lang" ]; then
            count=$(find "$lang" -mindepth 1 -maxdepth 1 -type d \
                    ! -name "node_modules" \
                    ! -name "_build" \
                    ! -name "target" \
                    ! -name ".*" \
                    | wc -l)
            printf "%-12s : %2d exercises\n" "$lang" "$count"
        fi
    done
    
    echo ""
    total=$(find . -maxdepth 2 -type d \
            ! -path "./.*" \
            ! -path "./node_modules" \
            ! -path "./_build" \
            ! -path "./target" \
            | wc -l)
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Total directories: $total"

