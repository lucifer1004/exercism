# AI Agent Development Guide

This document provides essential context for AI agents working on this Exercism solutions repository.

## Core Architecture

### Design Philosophy

This project follows **Linus Torvalds' "good taste" principles**:

1. **Data structures over code**: Clear language → config mapping eliminates complexity
2. **Single source of truth**: All languages defined in one place (`LANGUAGES` variable)
3. **Eliminate special cases**: No global state, no cross-dependencies
4. **Pragmatism over theory**: Solve real problems (dependency conflicts, disk waste)
5. **Never break userspace**: All changes must pass existing tests

### Key Principle: ONE LANGUAGE = ONE ENVIRONMENT

```
language/
├── flake.nix      # Nix environment (toolchain, LSP, tools)
├── flake.lock     # Locked dependencies
├── Justfile       # Language-specific commands
└── projects/      # Exercise solutions
```

**Critical**: Each language is **completely isolated**. No shared dependencies, no global state.

## Project Structure

```
exercism/
├── Justfile                 # Global management (SINGLE SOURCE OF TRUTH)
├── README.md                # User documentation
├── AGENTS.md                # This file
├── .gitignore               # Ignore build artifacts
│
├── python/                  # Independent environment
│   ├── flake.nix
│   ├── Justfile
│   └── leap/
│
├── rust/                    # Independent environment
│   ├── flake.nix
│   ├── Justfile
│   └── hello-world/
│
└── [10 more languages...]   # Each completely isolated
```

## The LANGUAGES Variable - Single Source of Truth

**Location**: `Justfile` line 4

```justfile
LANGUAGES := "python racket zig ocaml clojure wasm mips julia go haskell rust"
```

**Critical**: This variable controls ALL global operations:
- `just test-all`
- `just setup-all`
- `just update-all`
- `just clean`
- `just stats`

**Adding a new language**: Modify this ONE line. All commands automatically support it.

## Standard Operations

### Adding a New Language

**Step-by-step**:

1. **Create directory**: `mkdir <language>`

2. **Create `flake.nix`** (template):
```nix
{
  description = "<Language> environment for Exercism";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let pkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [
          pkgs.<language>
          pkgs.<language-server>  # LSP for editor support
          # Add language-specific tools
        ];
      };
    };
}
```

3. **Create `Justfile`**:
```justfile
test project:
    nix develop --command sh -c "cd {{project}} && <test-command>"

test-all:
    #!/usr/bin/env bash
    set -e
    for dir in */; do
        # Add logic to detect and test projects
    done
```

4. **Update `Justfile` line 4**: Add language to `LANGUAGES` variable

5. **Update `README.md`**:
   - Add to architecture diagram (line ~10)
   - Add usage example (line ~80)
   - Add to technology stack table (line ~185)
   - Increment language count (line ~201)
   - Add to recent upgrades (line ~295)

6. **Add to `.gitignore`** if needed for language-specific artifacts

7. **Test**: `just setup-all` to verify the environment

### Testing Strategy

**Per-language testing**:
```bash
cd <language>
just test <project>
```

**Global testing**:
```bash
just test-all        # Test everything
just test-lang rust  # Test specific language
```

**Before committing**:
```bash
just test-all   # Verify all tests pass
just clean      # Remove build artifacts
```

### Clean-up Rules

When adding a language, update the `clean` command in root `Justfile` (line ~60):

```justfile
# <Language>
find <language> -type d -name "<build-dir>" -exec rm -rf {} + 2>/dev/null || true
find <language> -name "<lock-file>" -type f -delete 2>/dev/null || true
```

**Common build artifacts**:
- Python: `__pycache__/`, `.pytest_cache/`
- Rust: `target/`, `Cargo.lock`
- Haskell: `.stack-work/`, `dist-newstyle/`
- Go: `go.sum`
- OCaml: `_build/`
- Zig: `zig-cache/`
- Clojure: `target/`
- WASM: `node_modules/`
- Julia: `.julia/`

## Language-Specific Patterns

### Test Command Templates

| Language | Test Command | Detection |
|----------|-------------|-----------|
| Python | `pytest` | `*_test.py` |
| Rust | `cargo test` | `Cargo.toml` |
| Go | `go test` | `go.mod` or `*_test.go` |
| Haskell | `stack test` | `stack.yaml` |
| Julia | `julia runtests.jl` | `runtests.jl` |
| Racket | `raco test .` | `*-test.rkt` |
| Zig | `zig test test_*.zig` | `test_*.zig` |
| OCaml | `dune test` | `dune` |
| Clojure | `lein test` | `project.clj` |
| MIPS | `java -jar ../mars.jar nc runner.mips impl.mips` | `runner.mips` |
| WASM | `npm test` | `package.json` |

### Language Server Packages (for LSP support)

| Language | Package Name | Purpose |
|----------|-------------|---------|
| Python | Built-in | Type checking via mypy/pylance |
| Rust | `rust-analyzer` | Full IDE support |
| Go | `gopls` | Official language server |
| Haskell | `haskell-language-server` | HLS |
| OCaml | `ocamlPackages.lsp` | ocaml-lsp-server |
| Zig | `zls` | Zig Language Server |
| Clojure | Install via `clojure-lsp` | Via Clojure ecosystem |
| Racket | Install via `raco` | racket-langserver |
| Julia | Install via Julia pkg | LanguageServer.jl |

## Special Cases

### WASM (npm workspaces)

WASM uses a **shared dependency model** to save space (67% reduction):

```
wasm/
├── package.json       # Root with workspaces
├── node_modules/      # Shared (110MB instead of 330MB)
├── eslint.config.js   # Shared ESLint 9 config
└── [projects]/        # Minimal package.json each
```

**Key files**:
- Root `package.json` has all dependencies
- Sub-projects reference `../node_modules/.bin/`
- Use `npx` for automatic path resolution

### MIPS (auto-download MARS)

MIPS Justfile automatically downloads MARS simulator:

```justfile
setup:
    @test -f mars.jar || wget -O mars.jar <URL>

test project: setup
    # Uses mars.jar
```

**Pattern**: Dependencies that can't be in nixpkgs can be auto-downloaded.

## Critical Rules

### DO

✅ **Keep languages isolated**: No cross-language dependencies
✅ **Use the LANGUAGES variable**: Single source of truth
✅ **Include language server**: Essential for good DX
✅ **Add test-all to language Justfile**: For batch testing
✅ **Update all 3 files**: Justfile (line 4), README.md, language's own files
✅ **Test before committing**: `just test-all`
✅ **Clean build artifacts**: Add to `clean` command

### DON'T

❌ **Don't create a monolithic flake.nix**: Defeats the purpose of isolation
❌ **Don't hardcode paths**: Use `{{project}}` variables in Justfiles
❌ **Don't skip the LANGUAGES variable**: All commands depend on it
❌ **Don't add global dependencies**: Each language manages its own
❌ **Don't mix language concerns**: Python code in Rust directory, etc.
❌ **Don't commit build artifacts**: Use `just clean` first

## Common Tasks for AI Agents

### Task 1: Add a New Language

```bash
# 1. Create structure
mkdir <language>
# 2. Write flake.nix (use template above)
# 3. Write Justfile (use template above)
# 4. Update LANGUAGES variable in root Justfile
# 5. Update README.md (5 locations)
# 6. Test: just setup-all
```

### Task 2: Add a New Exercise

```bash
# 1. Download from exercism
cd <language>
exercism download --exercise=<name> --track=<language>

# 2. Test
just test <name>

# 3. Verify global stats
cd .. && just stats
```

### Task 3: Upgrade Dependencies

**Per-language**:
```bash
cd <language>
nix flake update
just test-all  # Verify no breakage
```

**Global**:
```bash
just update-all   # Update all languages
just test-all     # Verify everything still works
```

### Task 4: Debug Environment Issues

```bash
# Check language is in LANGUAGES variable
just languages

# Verify environment builds
cd <language>
nix develop --command echo "OK"

# Check flake.lock exists
ls -la flake.lock

# Rebuild environment
nix flake update
nix develop
```

## File Naming Conventions

### Mandatory Files (per language)

- `flake.nix` - Nix environment definition
- `flake.lock` - Locked dependency versions
- `Justfile` - Language-specific commands

### Standard File Patterns

- Test files: Language-specific (`*_test.py`, `*_test.go`, `test_*.zig`, etc.)
- Config files: `package.yaml`, `Cargo.toml`, `go.mod`, etc.
- README files: Keep exercism's original `README.md` and `HELP.md`

## Verification Checklist

Before considering a change complete:

- [ ] `just languages` shows the new language
- [ ] `just stats` counts exercises correctly
- [ ] `just setup-all` verifies all environments
- [ ] `just test-all` passes (or shows expected failures for incomplete exercises)
- [ ] `just clean` removes all build artifacts
- [ ] README.md updated in all 5 locations
- [ ] No uncommitted generated files (run `just clean` first)

## Troubleshooting

### "Path not tracked by Git" error

When running `nix flake lock`:
```bash
git add <language>/flake.nix <language>/Justfile
nix flake lock
```

Nix requires files to be tracked before evaluating flakes.

### Language not showing in `just languages`

Check `Justfile` line 4. The LANGUAGES variable must include the language name.

### Environment not building

```bash
cd <language>
nix flake check   # Validate flake syntax
nix develop       # Attempt to build
```

Common issues:
- Package name typo in `buildInputs`
- Missing `system = "x86_64-linux"` specification
- Syntax errors in nix expressions

### Tests not running

Check language's `Justfile`:
- Correct test command for the language
- Proper use of `nix develop --command`
- Project directory navigation with `cd {{project}}`

## Code Quality Standards

### Simplicity

- Functions should be < 20 lines
- Max 2-3 levels of nesting
- One concept per function

### Comments

- Comment **why**, not **what**
- Explain non-obvious design decisions
- Reference exercism requirements when relevant

### Configuration

- Prefer convention over configuration
- Use language ecosystem defaults
- Only override when necessary

## Performance Considerations

### Nix Builds

- Lock files enable binary cache usage
- Don't `nix flake update` unnecessarily
- Each language caches independently (fast!)

### Shared Dependencies (WASM model)

- Use npm/yarn workspaces for Node.js projects
- Saves 67% space (330MB → 110MB)
- Pattern: Root `package.json` with `workspaces` field

### Build Artifacts

- Always add to `clean` command
- Add to `.gitignore`
- Don't commit them

## Success Metrics

A well-integrated language should:

1. **Work immediately**: `just test <project>` runs without extra setup
2. **Be isolated**: Other languages unaffected by changes
3. **Be documented**: README shows usage example
4. **Be automated**: Included in `just test-all`, `just setup-all`, etc.
5. **Be clean**: `just clean` removes all artifacts
6. **Be discoverable**: Shows in `just languages` and `just stats`

## Example: Adding TypeScript

```bash
# 1. Create structure
mkdir typescript
cd typescript

# 2. Create flake.nix
cat > flake.nix << 'EOF'
{
  description = "TypeScript environment for Exercism";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let pkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [
          pkgs.nodejs_24
          pkgs.typescript
        ];
      };
    };
}
EOF

# 3. Create Justfile
cat > Justfile << 'EOF'
test project:
    nix develop --command sh -c "cd {{project}} && npm test"
EOF

# 4. Update LANGUAGES in root Justfile
# Change line 4 to:
# LANGUAGES := "python racket ... rust typescript"

# 5. Update README.md
# Add to architecture, usage, tech stack, stats, upgrades

# 6. Verify
cd ..
just setup-all
just languages  # Should show typescript
```

## Anti-Patterns to Avoid

### ❌ Monolithic flake.nix

```nix
# DON'T DO THIS
buildInputs = [
  pkgs.python314
  pkgs.rustc
  pkgs.go
  # ... mixing all languages
];
```

**Why**: Breaks isolation, causes conflicts, defeats Nix's purpose.

### ❌ Hardcoded paths

```justfile
# BAD
test:
    cd /home/user/exercism/rust && cargo test

# GOOD
test project:
    nix develop --command sh -c "cd {{project}} && cargo test"
```

### ❌ Duplicating LANGUAGES list

```justfile
# BAD - defined in multiple places
test-all: for lang in python rust go
setup-all: for lang in python rust go

# GOOD - use variable
test-all: for lang in {{LANGUAGES}}
setup-all: for lang in {{LANGUAGES}}
```

### ❌ Language-specific logic in root Justfile

```justfile
# BAD - root Justfile knows about Python internals
test-all:
    cd python && pytest

# GOOD - delegate to language Justfile
test-all:
    for lang in {{LANGUAGES}}; do
        cd $lang && just test-all
    done
```

## Quick Reference

### Most Common Commands

```bash
just languages     # List all languages
just stats         # Show exercise counts
just test-all      # Run all tests
just clean         # Remove build artifacts
just setup-all     # Verify environments
```

### Per-Language Commands

```bash
cd <language>
just test <project>    # Test one project
just test-all          # Test all projects in language
nix develop            # Enter development shell
nix flake update       # Update dependencies
```

### Debugging

```bash
# Check language configuration
cat <language>/flake.nix

# Verify Justfile syntax
just --list --justfile <language>/Justfile

# Test environment manually
cd <language>
nix develop --command <language-command> --version
```

## Maintenance Tasks

### Weekly

- `just test-all` - Ensure all exercises still pass
- Check for new exercises on exercism.org

### Monthly

- `just update-all` - Update all flake locks
- `just test-all` - Verify no breakage
- Review and update outdated packages (especially WASM/npm)

### As Needed

- `just clean` before committing
- Update README.md when adding exercises
- Update this file when patterns change

## Context for AI Agents

### What This Project Is

- A **multi-language monorepo** for Exercism programming exercises
- **11 languages** with completely independent environments
- **Nix flakes** for reproducible development environments
- **Just** for task automation
- **Designed for scalability**: Can easily support 20+ languages

### What This Project Is NOT

- Not a polyglot application (languages don't interact)
- Not a build system (just development environments)
- Not a package to be published (it's a learning repository)

### When Making Changes

**Always ask**:
1. Does this break isolation between languages?
2. Is the LANGUAGES variable updated?
3. Do all global commands still work?
4. Are tests passing?
5. Is documentation updated?

### Communication with User

When suggesting changes:
- Explain the "why" (design rationale)
- Show the data structure impact
- Verify with tests
- Be direct about tradeoffs

## Success Stories

### WASM npm workspaces

**Problem**: 3 projects × 110MB = 330MB of duplicated dependencies

**Solution**: npm workspaces with shared `node_modules/`

**Result**: 67% space saving, zero functionality loss

**Lesson**: Use language ecosystem tools (npm workspaces) before inventing custom solutions.

### MIPS auto-download

**Problem**: MARS simulator not in nixpkgs

**Solution**: Justfile auto-downloads on first use

**Result**: Zero manual setup, works everywhere

**Lesson**: Pragmatism over purity. Auto-download > forcing users to manually install.

### Centralized LANGUAGES variable

**Problem**: Adding language required changing 4+ places

**Solution**: Single `LANGUAGES` variable, all commands reference it

**Result**: Add language = change 1 line

**Lesson**: Single source of truth eliminates inconsistency.

## Final Notes

This project demonstrates that **good architecture scales effortlessly**:

- Started with 1 language → Now 11 languages
- Complexity remained **linear** (not exponential)
- Adding language #12 takes same effort as adding language #2

**The data structure does the work. The code just follows the structure.**

That's "good taste" in action.

