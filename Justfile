# Root Justfile - Manage all language projects

# Centralized list of all supported languages
LANGUAGES := "python racket zig ocaml clojure wasm mips julia go haskell rust elixir"
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

# Setup all development environments
setup-all:
    #!/usr/bin/env bash
    echo "🔧 Setting up all development environments..."
    for lang in {{LANGUAGES}}; do
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
    for lang in {{LANGUAGES}}; do
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
    
    # Haskell
    find haskell -type d -name ".stack-work" -exec rm -rf {} + 2>/dev/null || true
    find haskell -type d -name "dist-newstyle" -exec rm -rf {} + 2>/dev/null || true
    
    # Go
    find go -name "go.sum" -type f -delete 2>/dev/null || true
    
    # Julia
    find julia -type d -name ".julia" -exec rm -rf {} + 2>/dev/null || true
    
    # Rust
    find rust -type d -name "target" -exec rm -rf {} + 2>/dev/null || true
    find rust -name "Cargo.lock" -type f -delete 2>/dev/null || true
    
    # Swift
    find swift -type d -name ".build" -exec rm -rf {} + 2>/dev/null || true
    find swift -name "Package.resolved" -type f -delete 2>/dev/null || true
    
    # Elixir
    find elixir -type d -name "_build" -exec rm -rf {} + 2>/dev/null || true
    find elixir -type d -name "deps" -exec rm -rf {} + 2>/dev/null || true
    find elixir -name "*.beam" -type f -delete 2>/dev/null || true
    
    echo "✅ Cleanup complete!"

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

