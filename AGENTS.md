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

## Documentation Maintenance

**Critical Principle**: Documentation must evolve with code. Stale docs are worse than no docs.

### When to Update Documentation

**1. General Rules (Update Root `AGENTS.md`)**

If a user's instruction can be generalized into a **project-wide pattern**, add it to this file:
- Architectural decisions (e.g., "delegate cleanup to language modules")
- Global workflow patterns (e.g., "add language = modify ONE variable")
- Project-wide conventions (e.g., "never add language-specific rules to root .gitignore")
- Common pitfalls and anti-patterns
- New global commands or workflows

**Examples**:
- User: "Don't hardcode cleanup rules in global Justfile" → Add to anti-patterns section
- User: "Use language-level .gitignore" → Add to mandatory files section
- User: "Add single-language commands for verification" → Update command reference

**2. Language-Specific Rules (Create/Update `<language>/AGENTS.md`)**

If a user's instruction is **specific to one language**, document it in that language's directory:
- Language-specific build quirks (e.g., "Gradle needs --no-daemon flag")
- Special testing requirements (e.g., "MIPS auto-downloads MARS simulator")
- Language ecosystem conventions (e.g., "WASM uses npm workspaces")
- Toolchain-specific issues (e.g., "Swift requires manual installation on Linux")
- Language-specific debugging tips

**File structure**:
```
<language>/
├── AGENTS.md          # Language-specific guide for AI agents
├── flake.nix
├── Justfile
└── .gitignore
```

**Examples**:
- User: "Kotlin Gradle daemon causes issues in CI" → `kotlin/AGENTS.md`
- User: "Python pytest needs specific markers for async tests" → `python/AGENTS.md`
- User: "Rust exercises should use workspace members" → `rust/AGENTS.md`

**3. Configuration Changes (Update Relevant Docs)**

When project structure or language settings change, update documentation:

**Global changes** → Update root `AGENTS.md` and `README.md`:
- Adding new global commands
- Changing LANGUAGES variable format
- Modifying global Justfile delegation pattern
- Updating verification checklist

**Language changes** → Update `<language>/AGENTS.md`:
- New testing framework
- Different build tool
- Changed dependency management
- New environment requirements

### Documentation Update Checklist

When implementing user instructions:

- [ ] **Identify scope**: General rule or language-specific?
- [ ] **Extract principle**: What's the underlying pattern?
- [ ] **Update docs**: Add to appropriate AGENTS.md
- [ ] **Verify consistency**: Does it contradict existing rules?
- [ ] **Update examples**: Reflect new patterns in examples

### Meta-Rule: Self-Improvement

**This section itself follows the principle**: If you discover a new category of documentation maintenance, add it here.

**Living document**: AGENTS.md should be the **source of truth** for how AI agents work with this codebase. When you learn something new about the project, capture it.

## Project Structure

```
exercism/
├── Justfile                 # Global management (SINGLE SOURCE OF TRUTH)
├── README.md                # User documentation
├── AGENTS.md                # This file (global rules for AI agents)
├── .gitignore               # Universal patterns only
│
├── python/                  # Independent environment
│   ├── flake.nix            # Python toolchain
│   ├── Justfile             # Python commands (setup/clean/test/test-all)
│   ├── .gitignore           # Python-specific artifacts
│   ├── AGENTS.md            # (Optional) Python-specific AI guide
│   └── leap/                # Exercise
│
├── rust/                    # Independent environment
│   ├── flake.nix
│   ├── Justfile
│   ├── .gitignore
│   ├── AGENTS.md            # (Optional) Rust-specific AI guide
│   └── hello-world/
│
└── [11 more languages...]   # Each completely isolated
```

**Documentation Hierarchy**:
- Root `AGENTS.md`: Project-wide patterns and architecture
- `<language>/AGENTS.md`: Language-specific quirks and conventions (optional, create when needed)

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
setup:
    @nix develop --command echo "<Language> environment ready"

clean:
    @find . -type d -name "<build-dir>" -exec rm -rf {} + 2>/dev/null || true
    @find . -name "<lock-file>" -type f -delete 2>/dev/null || true

test project:
    nix develop --command sh -c "cd {{project}} && <test-command>"

test-all:
    #!/usr/bin/env bash
    set -e
    for dir in */; do
        # Add logic to detect and test projects
    done
```

4. **Create `<language>/.gitignore`**: Language-specific build artifacts
   ```gitignore
   # <Language> build artifacts
   <build-dir>/
   <cache-dir>/
   # Language-specific patterns
   ```
   **CRITICAL**: Never add language-specific patterns to root `.gitignore`.
   Root `.gitignore` is ONLY for universal patterns (editor, Nix, direnv).

5. **Update `Justfile` line 4**: Add language to `LANGUAGES` variable
   (No need to update `clean` command - it automatically delegates!)

6. **Update `README.md`**:
   - Add to architecture diagram (line ~10)
   - Add usage example (line ~80)
   - Add to technology stack table (line ~185)
   - Increment language count (line ~201)
   - Add to recent upgrades (line ~295)

7. **Test**: 
   ```bash
   just setup <language>      # Verify environment builds
   just clean-lang <language> # Verify cleanup works
   just test-lang <language>  # Verify tests run
   ```

### Testing Strategy

**Single language operations**:
```bash
# From root directory
just setup <language>         # Setup environment
just test-lang <language>     # Run all tests
just clean-lang <language>    # Clean artifacts
just update <language>        # Update flake lock

# From language directory
cd <language>
just setup                    # Setup environment
just test <project>           # Test one project
just test-all                 # Test all projects
just clean                    # Clean artifacts
```

**Global operations**:
```bash
just setup-all   # Setup all environments
just test-all    # Test everything
just clean       # Clean everything
just update-all  # Update all flake locks
```

**Before committing**:
```bash
just test-all   # Verify all tests pass
just clean      # Remove build artifacts
```

### Clean-up Rules

**Critical**: Each language manages its own cleanup via `just clean` in its Justfile.
The global `just clean` automatically delegates to all languages.

**No need to update global Justfile** - it uses delegation pattern:
```justfile
clean:
    for lang in {{LANGUAGES}} {{MANUAL_LANGUAGES}}; do
        (cd "$lang" && just clean) || true
    done
```

**Language Justfile must implement**:
```justfile
clean:
    @find . -type d -name "<build-dir>" -exec rm -rf {} + 2>/dev/null || true
```

**Common build artifacts to clean**:
- Python: `__pycache__/`, `.pytest_cache/`
- Rust: `target/`, `Cargo.lock`
- Haskell: `.stack-work/`, `dist-newstyle/`
- Go: `go.sum`
- OCaml: `_build/`
- Zig: `zig-cache/`
- Clojure: `target/`
- WASM: `node_modules/`
- Julia: `.julia/`
- Kotlin: `build/`, `.gradle/`
- Elixir: `_build/`, `deps/`, `*.beam`

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
| Kotlin | `gradle test --no-daemon` | `build.gradle.kts` or `build.gradle` |
| Elixir | `mix test` | `mix.exs` |

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
| Kotlin | `kotlin-language-server` | Kotlin LSP |
| Elixir | `elixir-ls` | ElixirLS |

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
✅ **Add setup/clean/test-all to language Justfile**: Standard interface for all languages
✅ **Create `<language>/.gitignore`**: Each language manages its own build artifacts
✅ **Update LANGUAGES variable**: Single line change in root Justfile
✅ **Update README.md**: Document the new language
✅ **Update AGENTS.md**: Capture general patterns and language-specific quirks
✅ **Test before committing**: `just test-all`

### DON'T

❌ **Don't create a monolithic flake.nix**: Defeats the purpose of isolation
❌ **Don't hardcode paths**: Use `{{project}}` variables in Justfiles
❌ **Don't skip the LANGUAGES variable**: All commands depend on it
❌ **Don't add global dependencies**: Each language manages its own
❌ **Don't mix language concerns**: Python code in Rust directory, etc.
❌ **Don't add language-specific patterns to root `.gitignore`**: Use `<language>/.gitignore` instead
❌ **Don't let documentation drift**: Update AGENTS.md when patterns change
❌ **Don't commit build artifacts**: Use `just clean` first

## Common Tasks for AI Agents

### Task 1: Add a New Language

```bash
# 1. Create structure
mkdir <language>
# 2. Write flake.nix (use template above)
# 3. Write Justfile with setup/clean/test/test-all
# 4. Write <language>/.gitignore (language-specific artifacts)
# 5. Update LANGUAGES variable in root Justfile (ONE line!)
# 6. Update README.md (5 locations)
# 7. Test: just setup <language> && just clean-lang <language> && just test-lang <language>
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

**Single language**:
```bash
just update <language>      # Update flake lock
just test-lang <language>   # Verify no breakage
```

**All languages**:
```bash
just update-all   # Update all languages
just test-all     # Verify everything still works
```

### Task 4: Debug Environment Issues

```bash
# Check language is in LANGUAGES variable
just languages

# Verify environment builds
just setup <language>

# Run full verification
just setup <language>
just clean-lang <language>
just test-lang <language>

# Manual inspection (if needed)
cd <language>
ls -la flake.lock              # Check lock file exists
nix develop --command echo "OK" # Test environment
nix flake update               # Force update
```

### Task 5: Document New Patterns

**Scenario**: User provides instruction that reveals a new pattern or convention.

**Decision Tree**:

```
User instruction received
    ↓
Is it project-wide?
    ↓ YES → Update root AGENTS.md
    |       - Add to appropriate section (DO/DON'T, Anti-Patterns, etc.)
    |       - Update examples if relevant
    |       - Update verification checklist if it's a new requirement
    |
    ↓ NO → Is it language-specific?
            ↓ YES → Update/Create <language>/AGENTS.md
                    - Document the quirk
                    - Explain why it's necessary
                    - Provide examples
```

**Examples**:

**Example 1: Global pattern**
```
User: "When adding a language, verify with single-language commands before running full setup-all"

Action:
1. Update "Verification Checklist" in root AGENTS.md
2. Update "Task 1: Add a New Language" with new verification steps
3. Update "Example: Adding Kotlin" to show the pattern
```

**Example 2: Language-specific quirk**
```
User: "Gradle daemon causes memory issues in CI, always use --no-daemon"

Action:
1. Create/Update kotlin/AGENTS.md:
   ## Gradle Configuration
   
   **Critical**: Always use `--no-daemon` flag to prevent memory leaks in CI environments.
   
   ```justfile
   test project:
       gradle test --no-daemon
   ```
   
   **Why**: Gradle daemon keeps JVM running, consuming memory even after tests complete.
```

**Example 3: Configuration change**
```
User: "Add single-language commands to global Justfile"

Action:
1. Implement the feature
2. Update root AGENTS.md:
   - "Testing Strategy" section (add single-language operations)
   - "Quick Reference" section (add new commands)
   - "Verification Checklist" (add verification steps)
3. Update README.md:
   - "Quick Start" section (add usage examples)
   - "Global Project Management" (add command reference)
```

**Template for Language-Specific AGENTS.md**:

```markdown
# [Language] AI Agent Guide

Language-specific rules and quirks for working with [Language] in this project.

## Environment Setup

[Any non-obvious setup steps]

## Build System Quirks

[Known issues with build tools]

## Testing Patterns

[Language-specific test conventions]

## Common Issues

### [Issue Name]

**Problem**: [Description]
**Solution**: [How to fix]
**Example**: [Code snippet]

## References

- Upstream docs: [link]
- Related root AGENTS.md sections: [links]
```

## File Naming Conventions

### Mandatory Files (per language)

- `flake.nix` - Nix environment definition (or manual install docs for Swift-like cases)
- `flake.lock` - Locked dependency versions (for Nix-managed languages)
- `Justfile` - **MUST** implement: `setup`, `clean`, `test`, `test-all`
- `.gitignore` - Language-specific build artifacts (NEVER add to root)

### Optional Files (per language)

- `AGENTS.md` - Language-specific guide for AI agents (create when needed)
  - Use when: Language has unique quirks, non-obvious toolchain issues, or special conventions
  - Don't use when: Language follows standard patterns already documented in root AGENTS.md

### Standard File Patterns

- Test files: Language-specific (`*_test.py`, `*_test.go`, `test_*.zig`, etc.)
- Config files: `package.yaml`, `Cargo.toml`, `go.mod`, etc.
- README files: Keep exercism's original `README.md` and `HELP.md`

## Verification Checklist

Before considering a change complete:

- [ ] `just languages` shows the new language
- [ ] `just stats` counts exercises correctly
- [ ] `just setup <language>` verifies environment builds
- [ ] `just test-lang <language>` passes (or shows expected failures)
- [ ] `just clean-lang <language>` removes artifacts correctly
- [ ] `just setup-all` verifies all environments still work
- [ ] `just test-all` passes (or shows expected failures for incomplete exercises)
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

- Implement `clean` command in `<language>/Justfile` (global delegates automatically)
- Add patterns to `<language>/.gitignore` (per-language, NOT root `.gitignore`)
- Don't commit them

## Success Metrics

A well-integrated language should:

1. **Work immediately**: `just test <project>` runs without extra setup
2. **Be isolated**: Other languages unaffected by changes
3. **Be documented**: README shows usage example
4. **Be automated**: Included in `just test-all`, `just setup-all`, etc.
5. **Be clean**: `just clean` removes all artifacts
6. **Be discoverable**: Shows in `just languages` and `just stats`

## Example: Adding Kotlin

```bash
# 1. Create structure
mkdir kotlin
cd kotlin

# 2. Create flake.nix
cat > flake.nix << 'EOF'
{
  description = "Kotlin environment for Exercism";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let pkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [
          pkgs.jdk21
          pkgs.kotlin
          pkgs.gradle
          pkgs.kotlin-language-server
        ];
      };
    };
}
EOF

# 3. Create Justfile
cat > Justfile << 'EOF'
setup:
    @nix develop --command echo "Kotlin environment ready"

clean:
    @find . -type d -name "build" -exec rm -rf {} + 2>/dev/null || true
    @find . -type d -name ".gradle" -exec rm -rf {} + 2>/dev/null || true

test project:
    nix develop --command sh -c "cd {{project}} && gradle test --no-daemon"

test-all:
    #!/usr/bin/env bash
    set -e
    for dir in */; do
        if [ -f "$dir/build.gradle.kts" ] || [ -f "$dir/build.gradle" ]; then
            echo "Testing ${dir%/}..."
            nix develop --command sh -c "cd $dir && gradle test --no-daemon"
        fi
    done
EOF

# 4. Create .gitignore
cat > .gitignore << 'EOF'
# Gradle build artifacts
build/
.gradle/
gradle.properties

# Kotlin compiled files
*.class
*.jar
*.war
*.ear

# Local configuration
local.properties

# IntelliJ IDEA
.idea/
*.iml
*.ipr
*.iws
out/

# Kotlin specific
.kotlin/
EOF

# 5. Update LANGUAGES in root Justfile
# Change line 4 to:
# LANGUAGES := "python racket ... rust elixir kotlin"
# (No need to update clean command - automatic delegation!)

# 6. Update README.md
# Add to architecture, usage, tech stack, stats, upgrades

# 7. Verify
cd ..
just setup kotlin       # Verify environment
just clean-lang kotlin  # Verify cleanup
just test-lang kotlin   # Verify tests
just languages          # Should show kotlin
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

### ❌ Hardcoding cleanup rules in global Justfile

```justfile
# BAD - special cases for each language
clean:
    find python -type d -name "__pycache__" -exec rm -rf {} +
    find rust -type d -name "target" -exec rm -rf {} +
    find kotlin -type d -name "build" -exec rm -rf {} +
    # ... 40+ lines of hardcoded patterns

# GOOD - delegate to language modules
clean:
    for lang in {{LANGUAGES}}; do
        (cd "$lang" && just clean) || true
    done
```

**Why delegation is better**:
- Add new language: 0 lines changed in global Justfile
- Language owns its cleanup logic
- No central bottleneck

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

**Global commands** (from root):
```bash
just languages           # List all languages
just stats              # Show exercise counts
just setup-all          # Setup all environments
just test-all           # Run all tests
just clean              # Remove all build artifacts
just update-all         # Update all flake locks
```

**Single language commands** (from root):
```bash
just setup <language>        # Setup environment
just test-lang <language>    # Test all projects
just clean-lang <language>   # Clean artifacts
just update <language>       # Update flake lock
```

**Per-project commands** (from language directory):
```bash
cd <language>
just setup             # Setup environment
just test <project>    # Test one project
just test-all          # Test all projects
just clean             # Clean artifacts
nix develop            # Enter development shell (Nix-managed only)
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
5. **Is documentation updated?**
   - If general pattern: Update root AGENTS.md
   - If language-specific: Update/create `<language>/AGENTS.md`
   - If user-facing: Update README.md

**Documentation is code**: Stale docs are worse than no docs. Every change that introduces a new pattern or convention MUST be documented.

### Communication with User

When suggesting changes:
- Explain the "why" (design rationale)
- Show the data structure impact
- Verify with tests
- Be direct about tradeoffs
- **Document the pattern** (add to AGENTS.md if generalizable)

## Success Stories

### Documentation-driven evolution

**Problem**: AI agents forget patterns between sessions, leading to inconsistent implementations.

**Solution**: Self-documenting codebase with living AGENTS.md files.

**Result**: 
- New patterns captured immediately
- Language quirks documented at source
- Zero knowledge loss between sessions
- AI agents learn from past decisions

**Lesson**: Documentation is not overhead—it's **knowledge infrastructure**. When documentation evolves with code, it becomes a force multiplier.

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

- Started with 1 language → Now 14 languages (13 Nix + 1 manual)
- Complexity remained **linear** (not exponential)
- Adding language #15 takes same effort as adding language #2

**The data structure does the work. The code just follows the structure.**

That's "good taste" in action.

### Three Pillars of Scalability

1. **Data structures**: LANGUAGES variable controls everything
2. **Delegation**: Each module manages its own concerns (setup/clean/test)
3. **Documentation**: Patterns captured at source, never forgotten

**When all three work together**, you get a system that:
- Scales to any number of languages
- Maintains itself through documentation
- Improves with every change

**This AGENTS.md file is a living document**. It should grow smarter with every user instruction. Treat documentation as infrastructure, not afterthought.

