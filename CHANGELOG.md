# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
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

