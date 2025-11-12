# Root Justfile - Manage all language projects

# List all available commands
default:
    @just --list

# Test all projects in all languages
test-all:
    #!/usr/bin/env bash
    set -e
    
    echo "🧪 Testing all Exercism projects..."
    echo ""
    
    for lang in python racket zig ocaml clojure wasm mips julia; do
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

# Setup all development environments
setup-all:
    #!/usr/bin/env bash
    echo "🔧 Setting up all development environments..."
    for lang in python racket zig ocaml clojure wasm mips julia; do
        if [ -d "$lang" ] && [ -f "$lang/flake.nix" ]; then
            echo "Setting up $lang..."
            (cd "$lang" && nix develop --command echo "✓ $lang environment ready")
        fi
    done
    echo "✅ All environments set up!"

# Update all flake locks
update-all:
    #!/usr/bin/env bash
    echo "🔄 Updating all flake locks..."
    for lang in python racket zig ocaml clojure wasm mips julia; do
        if [ -d "$lang" ] && [ -f "$lang/flake.nix" ]; then
            echo "Updating $lang..."
            (cd "$lang" && nix flake update)
        fi
    done
    echo "✅ All flakes updated!"

# Clean all build artifacts
clean:
    #!/usr/bin/env bash
    echo "🧹 Cleaning build artifacts..."
    
    # Python
    find python -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find python -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
    
    # OCaml
    find ocaml -type d -name "_build" -exec rm -rf {} + 2>/dev/null || true
    
    # Zig
    find zig -name "zig-cache" -type d -exec rm -rf {} + 2>/dev/null || true
    
    # Clojure
    find clojure -type d -name "target" -exec rm -rf {} + 2>/dev/null || true
    
    # WASM
    rm -rf wasm/node_modules wasm/package-lock.json 2>/dev/null || true
    find wasm -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
    
    # MIPS
    rm -f mips/mars.jar 2>/dev/null || true
    
    echo "✅ Cleanup complete!"

# Show project statistics
stats:
    #!/usr/bin/env bash
    echo "📊 Project Statistics"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    for lang in python racket zig ocaml clojure wasm mips julia; do
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

