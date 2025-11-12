# Swift AI Agent Guide

Language-specific rules and quirks for working with Swift in this project.

## Special Status: Manual Installation Required

**Critical**: Swift is NOT managed by Nix. It requires manual installation on the host system.

**Why**: Swift's Linux toolchain has fundamental integration issues with Nix isolation:
- Dynamic library loading conflicts
- LLDB debugger incompatibilities
- Foundation framework linking issues

**Pragmatic Decision**: "Talk is cheap. Show me the code." A working manual installation beats a theoretically pure but broken Nix setup.

## Installation

See `swift/README.md` for detailed installation instructions.

**Verification**:
```bash
swift --version  # Should show Swift 5.x+
```

## Justfile Pattern

**Setup command** (differs from Nix languages):
```justfile
setup:
    @swift --version || (echo "❌ Swift not installed. See README.md" && exit 1)
```

**Purpose**: Verify Swift is installed, fail fast with helpful error message.

**Contrast with Nix languages**:
```justfile
# Nix languages
setup:
    @nix develop --command echo "Rust environment ready"

# Swift (manual)
setup:
    @swift --version || (echo "❌ Swift not installed" && exit 1)
```

## Testing Pattern

**No nix develop wrapper**:
```justfile
test project:
    cd {{project}} && swift test  # Direct invocation

# NOT: nix develop --command sh -c "cd {{project}} && swift test"
```

**Why**: Swift runs directly on host system.

## Common Issues

### Issue: "swift: command not found"

**Problem**: Swift not installed or not in PATH.

**Solution**:
1. Install Swift following `swift/README.md`
2. Verify: `swift --version`
3. Add to PATH if needed

### Issue: "just setup" fails

**Expected behavior**: If Swift isn't installed, setup command fails with clear error.

**Solution**: Install Swift first, then run `just setup`.

### Issue: Package resolution errors

**Problem**: `Package.swift` dependencies can't be resolved.

**Solution**:
```bash
cd <exercise>
swift package resolve        # Explicit resolution
swift package update         # Update dependencies
```

## Build System Quirks

### Swift Package Manager

**Standard structure**:
```
exercise/
├── Package.swift           # Manifest
├── Sources/               # Implementation
│   └── Exercise/
└── Tests/                 # Tests
    └── ExerciseTests/
```

**Build artifacts**: `.build/` directory (cleaned by `just clean`)

**Package.resolved**: Lock file (cleaned by `just clean`)

### Testing

**Test framework**: XCTest (built-in)

**Running tests**:
```bash
swift test                  # All tests
swift test --filter <name>  # Specific test
```

## Cleanup

**What gets cleaned**:
```bash
just clean  # Removes:
            # - .build/ directories
            # - Package.resolved files
```

**Why remove Package.resolved**: Prevents lock file drift between machines.

## Integration with Global Commands

**Works identically** to Nix languages from root:
```bash
just setup swift           # Verifies Swift installed
just test-lang swift       # Runs all tests
just clean-lang swift      # Cleans artifacts
```

**Implementation detail**: Global Justfile calls `cd swift && just setup`, which runs Swift's version check.

## Design Decisions

### Why manual installation?

**Attempted**: Nix flake with Swift toolchain.

**Result**: 
- Foundation framework linking errors
- LLDB crashes
- Dynamic library resolution failures

**Lesson**: "Theory and practice sometimes clash. Theory loses. Every single time." (Linus)

**Pragmatic solution**: Document manual installation, provide clean error messages, maintain consistency with global commands.

### Why not Docker/containerized Swift?

**Tradeoff analysis**:
- Docker: Adds complexity (image builds, volume mounts)
- Nix: Doesn't work (fundamental incompatibilities)
- Manual: Simple, works, clear error messages

**Choice**: Manual installation wins on pragmatism.

## References

- **Swift.org**: https://swift.org/download/
- **Swift Package Manager**: https://swift.org/package-manager/
- **swift/README.md**: Installation instructions
- **Root AGENTS.md**: See "Special Cases" section

## Future Improvements

**If Swift/Nix integration improves**:
1. Test with latest Nix/Swift versions
2. Verify Foundation framework linking
3. Test LLDB functionality
4. If ALL work: migrate to Nix flake

**Until then**: Manual installation is the right pragmatic choice.

---

**Last Updated**: November 2025 (Added after Nix integration attempts)

