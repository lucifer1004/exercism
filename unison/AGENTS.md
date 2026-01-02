# Unison AI Agent Guide

Language-specific rules and quirks for working with Unison in this project.

## Best Practice: Use with IDE Plugin

Unison works best with an **IDE plugin** (e.g., VS Code Unison extension). The plugin integrates with UCM for a seamless experience.

## Environment Setup

Unison is a **content-addressed functional programming language** with a unique workflow:

1. **UCM (Unison Codebase Manager)**: All code lives in a local codebase, not files
2. **Files are scratch pads**: `.u` files are temporary - code is `add`ed to the codebase
3. **Dependencies from Unison Share**: Libraries are pulled from the cloud

### First-Time Setup

```bash
cd unison
nix develop --command ucm
```

In UCM (first time only - create a project to get standard library):
```
scratch/main> project.create exercism
```

This automatically loads the standard library. No need to manually install `@unison/base`.

## Workflow with IDE + UCM

### File Loading Behavior

| File Location | IDE Save Action | UCM Response |
|--------------|-----------------|--------------|
| Direct directory (where UCM started) | Auto-triggers UCM | Immediate feedback |
| Subdirectory / other paths | No auto-trigger | Must manually `load path/to/file.u` |

### Testing Workflow

1. **Implementation file** (e.g., `hello.u`):
   - Edit in IDE, save
   - UCM auto-detects changes (if in direct directory)
   - Run `update` in UCM to update codebase

2. **Test file** (e.g., `hello.test.u`):
   - **Direct directory**: Save in IDE → UCM auto-runs tests
   - **Other locations**: Must manually `load hello.test.u` in UCM

### Typical Session

```bash
# Terminal 1: Start UCM in project directory
cd unison/hello-world
nix develop --command ucm

# In UCM (first time):
scratch/main> project.create exercism

# Now edit hello.u in IDE...
# UCM auto-detects, shows type errors or success

# After fixing implementation:
exercism/main> update

# For direct test files, just save and UCM runs them
# For other test files:
exercism/main> load hello.test.u
```

## Build Artifacts

- `.unison/` - Local codebase (can be deleted and recreated)
- `.unisonHistory` - Command history

## Common Issues

### "I couldn't resolve any of these names: Text"

**Problem**: No project created, still in scratch environment without standard library

**Solution**: Create a project in UCM:
```
scratch/main> project.create myproject
```

### Code Changes Not Reflected

**Problem**: Edited file but didn't `update` in UCM

**Solution**: After editing `.u` files, run `update` in UCM before testing

### Tests Not Running After Save

**Problem**: Test file is not in the direct directory where UCM started

**Solution**: Manually load the test file:
```
exercism/main> load path/to/file.test.u
```

### Code Not Found After Restart

**Problem**: Code was in scratch file but never `add`ed to codebase

**Solution**: Always `add` or `update` after editing `.u` files

## References

- [Unison Documentation](https://www.unison-lang.org/learn/)
- [Unison Share](https://share.unison-lang.org/) - Package registry
- [Exercism Unison Track](https://exercism.org/tracks/unison)
