# Exercism Solutions

A multi-language monorepo for [Exercism](https://exercism.org) programming exercises with isolated development environments.

## Architecture

Each language has its own **independent development environment** using Nix flakes:

```
exercism/
├── Justfile     # Global project management
├── python/      # Python 3.14 + pytest
├── racket/      # Racket
├── zig/         # Zig + ZLS
├── ocaml/       # OCaml + Dune + LSP
├── clojure/     # Clojure + Leiningen
├── wasm/        # Node.js 24 + Jest 30 (npm workspaces)
├── mips/        # Java + MARS simulator
├── julia/       # Julia 1.12
├── go/          # Go + gopls
├── haskell/     # GHC + Stack + HLS
├── rust/        # Rust + Cargo + rust-analyzer
├── elixir/      # Elixir + Mix + ElixirLS
├── kotlin/      # Kotlin + Gradle + kotlin-language-server
├── crystal/     # Crystal + Crystalline
└── swift/       # Swift (manual installation required)
```

### Design Principles

- **Isolation**: Each language is self-contained with zero cross-dependencies
- **Reproducibility**: Nix ensures consistent environments across machines (where feasible)
- **Pragmatism**: When tools don't integrate cleanly, use them as intended
- **Automation**: Just recipes for common tasks
- **Modern tooling**: Latest stable versions with language servers

## Prerequisites

### For Nix-managed languages (Python, Rust, Go, etc.)

- [Nix](https://nixos.org/download.html) with flakes enabled
- [just](https://github.com/casey/just) (optional, for convenient commands)

Enable flakes in `~/.config/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

### For manually-installed languages

- **Swift**: See [swift/README.md](swift/README.md) for installation instructions

## Quick Start

### Global Commands (from root directory)

```bash
# List all supported languages
just languages

# Show project statistics
just stats

# Operations on all languages
just setup-all          # Setup all environments
just test-all           # Test all projects
just clean              # Clean all artifacts
just update-all         # Update all flake locks

# Operations on specific language
just setup <language>       # Setup environment
just test-lang <language>   # Test all projects
just clean-lang <language>  # Clean artifacts
just update <language>      # Update flake lock

# Examples
just setup python           # Setup Python environment
just test-lang rust         # Test all Rust projects
just clean-lang kotlin      # Clean Kotlin artifacts
```

### Per-Language Pattern

```bash
# Enter language environment
cd <language>
nix develop

# Run tests (with just)
just test <project>

# Or manually
cd <project> && <test-command>
```

### Language-Specific Usage

#### Standard Pattern (Python, Racket, Zig, OCaml, Clojure, Julia, Go, Haskell, Rust, Elixir, Kotlin, Crystal)

Most languages follow the same workflow:

```bash
cd <language>
nix develop
just test <project>    # Run specific exercise

# Examples:
just test leap         # Python/OCaml/Clojure
just test hello-world  # Rust/Go/Haskell/Zig/Kotlin/Crystal/Elixir
just test knapsack     # Racket
```

**Manual commands** (if you prefer not using `just`):
- **Python**: `cd <project> && pytest`
- **Racket**: `cd <project> && raco test .`
- **Zig**: `cd <project> && zig test test_*.zig`
- **OCaml**: `cd <project> && dune test`
- **Clojure**: `cd <project> && lein test`
- **Julia**: `cd <project> && julia runtests.jl`
- **Go**: `cd <project> && go test`
- **Haskell**: `cd <project> && stack test`
- **Rust**: `cd <project> && cargo test`
- **Elixir**: `cd <project> && mix test`
- **Kotlin**: `cd <project> && gradle test --no-daemon`
- **Crystal**: `cd <project> && crystal spec`

---

#### Special Cases

##### WASM (npm workspaces)

WASM uses **npm workspaces** to share dependencies across projects (67% space saving).

```bash
cd wasm
nix develop
npm install              # First time only
just test hello-world
just test darts
```

**Features:**
- Shared `node_modules/` (110MB instead of 330MB)
- Jest 30, ESLint 9 (latest major versions)
- Flat ESLint config for modern tooling

##### MIPS (auto-download MARS)

MIPS automatically downloads the MARS simulator on first run.

```bash
cd mips
nix develop
just test hello-world    # Downloads mars.jar automatically
# Manual: cd hello-world && java -jar ../mars.jar nc runner.mips impl.mips
```

##### Swift (manual installation)

**Note**: Swift requires manual installation. See [swift/README.md](swift/README.md) for setup instructions.

```bash
# After installing Swift on your system:
cd swift
just test hello-world
# Manual: cd hello-world && swift test
```

## Technology Stack

| Language | Toolchain | Test Framework | Language Server |
|----------|-----------|----------------|-----------------|
| Python   | Python 3.14 | pytest | Built-in |
| Racket   | Racket | rackunit | racket-langserver |
| Zig      | Zig | Built-in | ZLS |
| OCaml    | OCaml + Dune | OUnit2 | ocaml-lsp |
| Clojure  | Clojure + Leiningen | clojure.test | clojure-lsp |
| WASM     | Node.js 24 | Jest 30 | - |
| MIPS     | Java + MARS | MARS | - |
| Julia    | Julia 1.12 | Test stdlib | LanguageServer.jl |
| Go       | Go + gotools | testing | gopls |
| Haskell  | GHC + Stack | hspec/HUnit | HLS |
| Rust     | Cargo + Clippy | Built-in | rust-analyzer |
| Elixir   | Elixir + Mix | ExUnit | ElixirLS |
| Kotlin   | Gradle + JDK 21 | JUnit | kotlin-language-server |
| Crystal  | Crystal + Shards | Crystal Spec | Crystalline |
| Swift    | Swift Package Manager (manual) | XCTest | - |

## Project Statistics

- **Languages**: 15 (14 Nix-managed + 1 manual)
- **Exercises**: 21+ (run `just stats` for breakdown)
- **Lines of Config**: ~600
- **Space Saved (WASM)**: 220MB via npm workspaces
- **Global Commands**: 7 (`just --list` to see all)
- **Centralized Management**: All languages defined in one place (run `just languages`)

Run `just stats` for detailed per-language statistics.

## Global Project Management

The root `Justfile` provides commands to manage all languages as a whole:

### Available Commands

**Global operations**:
```bash
just languages           # List all supported languages
just stats              # Show exercise counts per language
just setup-all          # Setup all environments
just test-all           # Run all tests in all languages
just clean              # Remove all build artifacts
just update-all         # Update all flake locks
```

**Single language operations**:
```bash
just setup <language>        # Setup specific environment
just test-lang <language>    # Test all exercises in language
just clean-lang <language>   # Clean language artifacts
just update <language>       # Update language flake lock
```

### Example Workflow

```bash
# Initial setup
just setup-all

# Work on specific language
just setup python           # Setup Python environment
cd python && just test leap # Test one exercise

# Quick verification of one language
just test-lang python       # Test all Python exercises
just clean-lang python      # Clean Python artifacts

# Work on another language
just setup rust
cd rust && just test hello-world

# Before committing
just test-all      # Verify everything works
just clean         # Remove temporary files

# Update dependencies
just update python  # Update single language
just update-all     # Update all languages
```

## Development Philosophy

This project follows **Linus Torvalds' "good taste" principles**:

1. **Data structures over code**: Clear language → config mapping eliminates complexity
2. **Simplicity**: No special cases, no global state
3. **Pragmatism**: Solves real problems (dependency conflicts, disk waste)
4. **No breaking changes**: All tests pass, backward compatible

### Why Independent Environments?

**Before** (monolithic `flake.nix`):
- All languages in one file
- Dependency conflicts
- Updates affect everything
- Difficult to maintain

**After** (isolated environments):
- One language = One `flake.nix` (when tool integrates well)
- Zero conflicts
- Independent updates
- Clean 1:1 mapping

**Exception (Swift)**:
- Swift's Linux toolchain has fundamental issues with Nix isolation
- Pragmatic solution: require manual installation
- **"Talk is cheap. Show me the code."** - Working solution > theoretical purity

## Recent Upgrades

### November 2025 - Major Refactoring

**Architecture**:
- ✅ Migrated from monolithic to per-language flakes
- ✅ Added global project management (root `Justfile`)
- ✅ Isolated all 8 languages into independent environments

**WASM**:
- ✅ Jest 29 → 30
- ✅ ESLint 8 → 9 (flat config migration)
- ✅ npm workspaces (67% space reduction: 330MB → 110MB)
- ✅ @types/node 20 → 24
- ✅ All tests passing

**Python**:
- ✅ Python 3.11 → 3.14

**Julia**:
- ✅ Added Julia environment (Julia 1.12.1)

**Go**:
- ✅ Added Go environment with gopls and gotools

**Haskell**:
- ✅ Added Haskell environment with GHC, Stack, and HLS

**Rust**:
- ✅ Added Rust environment with Cargo, Clippy, and rust-analyzer

**Swift**:
- ✅ Added Swift support (requires manual installation)
- 📝 Pragmatic decision: Swift toolchain doesn't integrate cleanly with Nix on Linux
- 📖 See swift/README.md for installation guide

**Elixir**:
- ✅ Added Elixir environment with Mix and ElixirLS

**Kotlin**:
- ✅ Added Kotlin environment with JDK 21, Gradle, and kotlin-language-server

**Crystal**:
- ✅ Added Crystal environment with Crystalline language server

## Contributing

> **For AI Agents**: See [AGENTS.md](AGENTS.md) for detailed development guidelines, architecture decisions, and common patterns.

### Adding a New Exercise

Each language environment is self-contained. To add a new exercise:

1. Create the exercise directory in the appropriate language folder
2. Add test files following the language's conventions
3. Run `just test <project>` to verify

### Adding a New Language

To add support for a new language:

1. **Create language directory**:
   ```bash
   mkdir <language>
   ```

2. **Create `flake.nix`**:
   ```nix
   {
     description = "<Language> environment for Exercism";
     inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
     outputs = { self, nixpkgs }:
       let pkgs = import nixpkgs { system = "x86_64-linux"; };
       in {
         devShells.x86_64-linux.default = pkgs.mkShell {
           buildInputs = [ pkgs.<language> ];
         };
       };
   }
   ```

3. **Create `Justfile`**:
   ```justfile
   test project:
       nix develop --command sh -c "cd {{project}} && <test-command>"
   ```

4. **Update global `Justfile`**:
   - Add language to `LANGUAGES` variable (line 4)
   - That's it! All global commands automatically pick it up

5. **Run `nix flake lock`** in the language directory

6. **Update `README.md`**:
   - Add to architecture diagram
   - Add usage example
   - Add to technology stack table

The centralized `LANGUAGES` variable ensures consistency across all global commands.

## License

MIT

## Links

- [Exercism](https://exercism.org)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [Just Command Runner](https://github.com/casey/just)

