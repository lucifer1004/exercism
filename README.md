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
└── rust/        # Rust + Cargo + rust-analyzer
```

### Design Principles

- **Isolation**: Each language is self-contained with zero cross-dependencies
- **Reproducibility**: Nix ensures consistent environments across machines
- **Automation**: Just recipes for common tasks
- **Modern tooling**: Latest stable versions with language servers

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [just](https://github.com/casey/just) (optional, for convenient commands)

Enable flakes in `~/.config/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

## Quick Start

### Global Commands (from root directory)

```bash
# Test all projects in all languages
just test-all

# Setup all development environments
just setup-all

# Update all flake locks
just update-all

# Clean all build artifacts
just clean

# Show project statistics
just stats

# Test specific language
just test-lang python
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

#### Python
```bash
cd python
nix develop
just test leap           # Run specific exercise
# or: cd leap && pytest
```

#### Racket
```bash
cd racket
nix develop
just test knapsack       # Run specific exercise
# or: cd knapsack && raco test .
```

#### Zig
```bash
cd zig
nix develop
just test hello-world    # Run specific exercise
# or: cd hello-world && zig test test_hello_world.zig
```

#### OCaml
```bash
cd ocaml
nix develop
just test leap           # Run specific exercise
# or: cd leap && dune test
```

#### Clojure
```bash
cd clojure
nix develop
just test leap           # Run specific exercise
# or: cd leap && lein test
```

#### WASM

WASM uses **npm workspaces** to share dependencies across projects (67% space saving).

```bash
cd wasm
nix develop
npm install              # First time only
just test hello-world    # Run specific exercise
just test darts
# or: cd hello-world && npm test
```

**Features:**
- Shared `node_modules/` (110MB instead of 330MB)
- Jest 30, ESLint 9 (latest major versions)
- Flat ESLint config for modern tooling

#### MIPS

MIPS automatically downloads the MARS simulator on first run.

```bash
cd mips
nix develop
just test hello-world    # Downloads mars.jar automatically
# or: cd hello-world && java -jar ../mars.jar nc runner.mips impl.mips
```

#### Julia
```bash
cd julia
nix develop
just test rna-transcription  # Run specific exercise
# or: cd rna-transcription && julia runtests.jl
```

#### Go
```bash
cd go
nix develop
just test hello-world    # Run specific exercise
# or: cd hello-world && go test
```

#### Haskell
```bash
cd haskell
nix develop
just test hello-world    # Run specific exercise
# or: cd hello-world && stack test
```

#### Rust
```bash
cd rust
nix develop
just test hello-world    # Run specific exercise
# or: cd hello-world && cargo test
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

## Project Statistics

- **Languages**: 11
- **Exercises**: 21+ (run `just stats` for breakdown)
- **Lines of Config**: ~800
- **Space Saved (WASM)**: 220MB via npm workspaces
- **Global Commands**: 7 (`just --list` to see all)
- **Centralized Management**: All languages defined in one place (run `just languages`)

Run `just stats` for detailed per-language statistics.

## Global Project Management

The root `Justfile` provides commands to manage all languages as a whole:

### Available Commands

```bash
just languages     # List all supported languages
just test-all      # Run all tests in all languages
just setup-all     # Verify all environments
just update-all    # Update all flake locks
just clean         # Remove all build artifacts
just stats         # Show exercise counts per language
just test-lang <lang>  # Test all exercises in specific language
```

### Example Workflow

```bash
# Initial setup
just setup-all

# Work on exercises
cd python && just test leap
cd racket && just test knapsack

# Before committing
just test-all      # Verify everything works
just clean         # Remove temporary files

# Update dependencies
just update-all
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
- One language = One `flake.nix`
- Zero conflicts
- Independent updates
- Clean 1:1 mapping

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

