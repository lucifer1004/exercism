# Exercism Solutions

A multi-language monorepo for [Exercism](https://exercism.org) programming exercises with isolated development environments.

## Architecture

Each language has its own **independent development environment** using Nix flakes:

```
exercism/
├── python/      # Python 3.14 + pytest
├── racket/      # Racket
├── zig/         # Zig + ZLS
├── ocaml/       # OCaml + Dune + LSP
├── clojure/     # Clojure + Leiningen
├── wasm/        # Node.js 22 + Jest 30 (npm workspaces)
└── mips/        # Java + MARS simulator
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

### General Pattern

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

## Project Statistics

- **Languages**: 7
- **Exercises**: 20+
- **Lines of Config**: ~500 (down from 700+)
- **Space Saved (WASM)**: 220MB via npm workspaces

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

### WASM (November 2025)
- ✅ Jest 29 → 30
- ✅ ESLint 8 → 9 (flat config migration)
- ✅ npm workspaces (67% space reduction)
- ✅ @types/node 20 → 24
- ✅ All tests passing

### Python (November 2025)
- ✅ Python 3.11 → 3.14

## Contributing

Each language environment is self-contained. To add a new exercise:

1. Create the exercise directory in the appropriate language folder
2. Add test files following the language's conventions
3. Run `just test <project>` to verify

## License

MIT

## Links

- [Exercism](https://exercism.org)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [Just Command Runner](https://github.com/casey/just)

