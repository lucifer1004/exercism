# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- **Unison**: Added Unison environment (content-addressed functional programming language)
  - Toolchain: UCM (Unison Codebase Manager) 1.0.1
  - Testing: Built-in via `.test.u` files loaded in UCM
  - Note: Unison uses interactive UCM for testing
  - 1 exercise: hello-world
- **Idris**: Added Idris 2 environment (dependent type functional programming language)
  - Standard toolchain: idris2 compiler
  - Testing: Built-in compilation and type checking
  - Standard pattern: follows conventional setup/clean/test/test-all/format workflow
  - Build system: .ipkg package files
- **Dart**: Added Dart environment (Dart SDK with pub package manager)
  - Standard toolchain: dart SDK, pub, dart format, dart analyze
  - Testing: package:test
  - Built-in language server support
  - Standard pattern: follows conventional setup/clean/test/test-all/format workflow
- **Code Formatting**: Added `format` command to all 21 languages
  - Standard formatters: black (Python), rustfmt (Rust), gofmt (Go), elm-format (Elm), mix format (Elixir), crystal tool format (Crystal), cljfmt (Clojure), ormolu (Haskell), nimpretty (Nim), ocamlformat (OCaml), ktlint (Kotlin), php-cs-fixer (PHP), zig fmt (Zig), prettier (WASM)
  - Special handling: JuliaFormatter.jl via Project.toml for Julia
  - Global commands: `just format-all`, `just format-lang <language>`
  - Languages without standard formatters provide helpful messages (AWK, MIPS, Prolog, Raku, Racket, Swift)
- **Prolog**: Added Prolog environment (SWI-Prolog 9.2.9 with PLUnit)
  - 1 exercise: hello-world
  - Special handling: directory names use hyphens, file names use underscores
- **Elm**: Added Elm environment (Elm 0.19.1 with elm-test, elm-format, elm-language-server)
  - 1 exercise: hello-world
- **AWK**: Added AWK environment (GNU AWK with Bats testing framework)
  - 1 exercise: hello-world
- **Raku**: Added Raku environment (Rakudo)
  - 2 exercises: hello-world, leap
- **Nim**: Added Nim environment (Nim 2.2)
  - 2 exercises: hello-world, bob

## November 2025 - Major Refactoring

### Architecture Changes
- ✅ Migrated from monolithic to per-language flakes
- ✅ Added global project management (root `Justfile`)
- ✅ Isolated all languages into independent environments

### Language Additions

#### Crystal
- ✅ Added Crystal environment with Crystalline language server

#### Kotlin
- ✅ Added Kotlin environment with JDK 21, Gradle, and kotlin-language-server

#### Elixir
- ✅ Added Elixir environment with Mix and ElixirLS

#### Swift
- ✅ Added Swift support (requires manual installation)
- 📝 Pragmatic decision: Swift toolchain doesn't integrate cleanly with Nix on Linux
- 📖 See swift/README.md for installation guide

#### Rust
- ✅ Added Rust environment with Cargo, Clippy, and rust-analyzer

#### Haskell
- ✅ Added Haskell environment with GHC, Stack, and HLS

#### Go
- ✅ Added Go environment with gopls and gotools

#### Julia
- ✅ Added Julia environment (Julia 1.12.1)

### Language Upgrades

#### Python
- ✅ Python 3.11 → 3.14

#### WASM
- ✅ Jest 29 → 30
- ✅ ESLint 8 → 9 (flat config migration)
- ✅ npm workspaces (67% space reduction: 330MB → 110MB)
- ✅ @types/node 20 → 24
- ✅ All tests passing

---

## Format Guidelines

When adding entries to this changelog:

### Categories
- **Added**: New languages, features, or files
- **Changed**: Changes to existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security fixes

### Language Additions
For new languages, include:
- Language name and version
- Key toolchain components
- Number of exercises
- Any special considerations

### Architecture Changes
For major refactoring:
- What changed and why
- Impact on existing code
- Benefits gained

### Example Entry Format
```markdown
## YYYY-MM - Brief Description

### Added
- **Language**: Description
  - Details
  - Exercise count

### Changed
- **Component**: Old → New
  - Reason
  - Benefits
```
