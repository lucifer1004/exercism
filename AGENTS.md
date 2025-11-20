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

## Version Control

**This project uses Jujutsu (jj), not Git.**

### Nix Flake Compatibility

Nix requires files to be tracked by version control before evaluating flakes. When you see errors like:

```
error: Path 'crystal/flake.nix' in the repository is not tracked by Git.
```

**Solution**: Use `jj st` to refresh Jujutsu's working copy state:

```bash
cd /path/to/exercism
jj st  # Refreshes jj state, Nix will recognize tracked files
nix flake lock  # Now works
```

**Why this works**: Jujutsu automatically tracks all files in the working copy. Running `jj st` updates the internal state that Nix reads to determine tracked files.

**Do NOT use `git add`** - this project doesn't use Git for version control.

### Key Differences from Git

- **No explicit staging**: Jujutsu tracks changes automatically
- **No `git add` needed**: All new files are tracked by default
- **Refresh with `jj st`**: Updates state for tools like Nix that check VCS status

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

**High-level workflow** (see README "Contributing" section for detailed templates):

1. **Create language directory structure**:
   - `flake.nix` (Nix environment) or manual install docs
   - `Justfile` (MUST implement: `setup`, `clean`, `test`, `test-all`, `format`)
   - `.gitignore` (language-specific artifacts ONLY)

2. **Update `LANGUAGES` variable** (root `Justfile` line 4):
   - This ONE change enables all global commands (`setup-all`, `test-all`, `clean`, etc.)
   - No need to modify other parts of global Justfile (uses delegation pattern)

3. **Update `README.md`** (see "Adding a New Language" in README for locations):
   - **Standard pattern**: Add name to "Standard Pattern" list
   - **Special case**: Add subsection under "Special Cases" with explanation
   - Update architecture diagram, tech stack table, statistics, recent upgrades

4. **Verify**: Run `just setup <language>`, `just test-lang <language>`, `just clean-lang <language>`

### Testing Strategy

**See README "Quick Start" and "Global Project Management" sections for complete command reference.**

**Key workflow**:
- Test single language: `just test-lang <language>` (from root)
- Test everything: `just test-all` (always run before committing)
- Format single language: `just format-lang <language>` (from root)
- Format everything: `just format-all` (standardize code style)
- Clean artifacts: `just clean` (run before committing)

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

**Architecture principle**: Delegation over centralization. Each language knows how to clean itself.

## Language-Specific Patterns

**For language-specific details (test commands, build artifacts, LSP packages), see**:
- **README "Technology Stack" section**: Complete table of toolchains, test frameworks, language servers
- **Individual `<language>/Justfile`**: Test and clean command implementations
- **Individual `<language>/.gitignore`**: Build artifact patterns

## Special Cases

**See README "Language-Specific Usage → Special Cases" for usage details.**

### WASM (npm workspaces)

**Why special**: Uses npm workspaces to share dependencies (67% space saving: 330MB → 110MB)

**Architecture principle**: Use language ecosystem tools (npm workspaces) before inventing custom solutions.

### MIPS (auto-download MARS)

**Why special**: MARS simulator not in nixpkgs, Justfile auto-downloads on first run

**Architecture principle**: Pragmatism over purity. Auto-download > forcing manual installation.

### Swift (manual installation)

**Why special**: Swift's Linux toolchain has fundamental issues with Nix isolation

**Architecture principle**: "Talk is cheap. Show me the code." - Working solution > theoretical purity.

## Critical Rules

### DO

✅ **Keep languages isolated**: No cross-language dependencies
✅ **Use the LANGUAGES variable**: Single source of truth
✅ **Include language server**: Essential for good DX
✅ **Add setup/clean/test-all/format to language Justfile**: Standard interface for all languages
✅ **Add formatter to flake.nix**: Use language's standard formatter (black, rustfmt, gofmt, etc.)
✅ **Create `<language>/.gitignore`**: Each language manages its own build artifacts
✅ **Update LANGUAGES variable**: Single line change in root Justfile
✅ **Update README.md**: Document the new language
✅ **Update AGENTS.md**: Capture general patterns and language-specific quirks
✅ **Test before committing**: `just test-all`
✅ **Format before committing**: `just format-all` (optional but recommended)

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
# 2. Write flake.nix (include formatter if available)
# 3. Write Justfile with setup/clean/test/test-all/format
# 4. Write <language>/.gitignore (language-specific artifacts)
# 5. Update LANGUAGES variable in root Justfile (ONE line!)
# 6. Update documentation (CRITICAL - 6 locations):
#    a) README.md - Architecture diagram (~line 10): Add <language>/ directory with description
#    b) README.md - Standard Pattern list (~line 100): Add language name to parentheses
#       - If special case: create new subsection under "Special Cases" instead
#    c) README.md - Manual commands (~line 115-130): Add test command for the language
#    d) README.md - Technology Stack table (~line 176): Add row with toolchain/test framework/LSP
#    e) README.md - Project Statistics (~line 196-199): Update language count and exercise count
#    f) CHANGELOG.md - Add entry in "Unreleased" section documenting the addition
# 7. Test: just setup <language> && just format-lang <language> && just test-lang <language> && just clean-lang <language>
```

**CRITICAL**: Step 6 is NOT optional. Documentation must be updated whenever adding a language.
Forgetting documentation creates confusion for users and future AI agents.

**Documentation structure**:
- README.md: User-facing overview (architecture, usage, tech stack, statistics)
- CHANGELOG.md: Historical record of all changes (follows Keep a Changelog format)
- AGENTS.md: AI agent guidelines (patterns, workflows, success stories)

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
just format-lang <language>
just test-lang <language>
just clean-lang <language>

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

### Project-Level Documentation Files

- **README.md** - User-facing overview (architecture, quick start, usage patterns, tech stack)
- **CHANGELOG.md** - Historical record following [Keep a Changelog](https://keepachangelog.com/) format
  - Categories: Added, Changed, Deprecated, Removed, Fixed, Security
  - Use "Unreleased" section for ongoing work
  - When adding a language: add entry under "Unreleased → Added"
- **AGENTS.md** - AI agent guidelines (this file)

### Standard File Patterns

- Test files: Language-specific (`*_test.py`, `*_test.go`, `test_*.zig`, etc.)
- Config files: `package.yaml`, `Cargo.toml`, `go.mod`, etc.
- README files: Keep exercism's original `README.md` and `HELP.md`

## Verification Checklist

Before considering a change complete:

- [ ] `just languages` shows the new language
- [ ] `just stats` counts exercises correctly
- [ ] `just setup <language>` verifies environment builds
- [ ] `just format-lang <language>` runs without errors
- [ ] `just test-lang <language>` passes (or shows expected failures)
- [ ] `just clean-lang <language>` removes artifacts correctly
- [ ] `just setup-all` verifies all environments still work
- [ ] `just format-all` runs on all languages
- [ ] `just test-all` passes (or shows expected failures for incomplete exercises)
- [ ] **Documentation updated**:
  - [ ] README.md: architecture, pattern list, manual commands, tech stack, statistics
  - [ ] CHANGELOG.md: entry in "Unreleased" section with language details
- [ ] No uncommitted generated files (run `just clean` first)

## Troubleshooting

### "Path not tracked by Git/VCS" error

**This project uses Jujutsu (jj), not Git.**

When running `nix flake lock`, you might see:
```
error: Path 'language/flake.nix' is not tracked by Git
```

**Solution** - Refresh Jujutsu state:
```bash
jj st  # Refresh working copy state
nix flake lock  # Now works
```

**Why**: Nix checks VCS status before evaluating flakes. Jujutsu automatically tracks files, but `jj st` updates the state Nix reads.

**Do NOT** use `git add` - this project uses Jujutsu for version control.

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

### ❌ Duplicating language examples in documentation

```markdown
# BAD - separate example for each language
#### Python
cd python && just test leap

#### Rust
cd rust && just test hello-world

#### Go
cd go && just test hello-world
... (12 more identical patterns)

# GOOD - one pattern + exceptions
#### Standard Pattern (Python, Rust, Go, ...)
cd <language> && just test <project>

#### Special Cases
##### WASM (npm workspaces)
cd wasm && npm install && just test <project>
```

**Why pattern-based documentation is better**:
- Add new language: add name to parentheses (0 lines of duplication)
- Reader sees the pattern, not 15 examples
- Special cases stand out instead of being buried
- "Good taste": 12 identical examples = 1 pattern

## Quick Reference

**For complete command reference, see README "Quick Start" and "Global Project Management" sections.**

**Most critical commands for AI agents**:
- `just test-all` - Always run before finishing a task
- `just format-all` - Standardize code style across all languages
- `just clean` - Always run before committing
- `just languages` - Verify language added to LANGUAGES variable
- `just stats` - Verify exercise counts after changes

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

### README documentation deduplication

**Problem**: README had 15 separate language examples, 12 were identical (137 lines of repetition)

**Solution**: Restructured to 1 standard pattern + 3 special cases

**Result**: 
- 46% reduction in documentation size (137 → 73 lines)
- Adding new language: add name to parentheses (zero code duplication)
- Special cases clearly separated from standard workflow

**Lesson**: "Good taste" applies to documentation too. Eliminate special cases by identifying the underlying pattern. When you have 12 identical examples, you don't have 12 examples—you have 1 pattern.

## Final Notes

This project demonstrates that **good architecture scales effortlessly**:

- Started with 1 language → Now 17 languages (16 Nix + 1 manual)
- Complexity remained **linear** (not exponential)
- Adding language #17 takes same effort as adding language #2

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
