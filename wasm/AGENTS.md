# WASM (WebAssembly) AI Agent Guide

Language-specific rules and quirks for working with WebAssembly/JavaScript in this project.

## Architecture: npm Workspaces

**Special Design**: WASM uses npm workspaces to share dependencies across all exercises.

```
wasm/
├── package.json           # Root workspace config
├── node_modules/          # Shared (110MB instead of 330MB)
├── eslint.config.js       # Shared ESLint 9 flat config
└── [exercises]/           # Individual projects
    └── package.json       # Minimal, references workspace
```

**Space Saving**: 67% reduction (330MB → 110MB) by sharing node_modules.

## Setup Requirements

**First-time setup**:
```bash
cd wasm
nix develop --command npm install  # Install shared dependencies
```

**Why**: All exercises share the same dependencies (Jest, Babel, ESLint).

## Testing Pattern

**Individual exercise**:
```bash
cd wasm/hello-world
npm test  # Uses ../node_modules/.bin/jest
```

**All exercises**:
```bash
cd wasm
just test-all  # Runs npm test in each exercise
```

**Important**: `just test-all` depends on `setup` target, which runs `npm install` automatically.

## Common Issues

### Issue: "Cannot find module 'jest'"

**Problem**: `node_modules` not installed at workspace root.

**Solution**:
```bash
cd wasm
npm install  # Or: just setup
```

### Issue: ESLint config not found

**Problem**: Exercise trying to use local ESLint config instead of workspace config.

**Solution**: Ensure exercise `package.json` doesn't have `eslintConfig` field. All config is in `wasm/eslint.config.js`.

### Issue: Dependency version mismatch

**Problem**: Exercise has different version than workspace root.

**Solution**: Dependencies should ONLY be in root `package.json`. Remove from exercise-level `package.json`.

## Build System Quirks

### npm workspaces

**Root package.json structure**:
```json
{
  "workspaces": [
    "hello-world",
    "darts",
    "difference-of-squares"
  ],
  "devDependencies": {
    "@babel/core": "^7.x",
    "jest": "^30.x",
    "eslint": "^9.x"
  }
}
```

**Exercise package.json structure** (minimal):
```json
{
  "name": "@exercism/hello-world",
  "scripts": {
    "test": "jest"
  }
}
```

**Note**: No dependencies listed in exercise package.json—all come from workspace root.

### ESLint 9 Flat Config

**Migration**: Upgraded from ESLint 8 (`.eslintrc.js`) to ESLint 9 (`eslint.config.js`).

**Flat config location**: `wasm/eslint.config.js` (shared by all exercises).

**Why flat config**: 
- Simpler configuration
- Better IDE integration
- Required for ESLint 9+

## Testing Patterns

### Jest configuration

**Location**: Each exercise has `babel.config.js` for transpilation.

**Standard pattern**:
```javascript
// babel.config.js
module.exports = {
  presets: [
    ['@babel/preset-env', { targets: { node: 'current' } }]
  ]
};
```

**Test file naming**: `*.spec.js` (e.g., `hello-world.spec.js`)

### Running specific tests

```bash
# In exercise directory
npm test                    # All tests
npm test -- --watch         # Watch mode
npm test -- --coverage      # With coverage
```

## Cleanup

**What gets cleaned**:
```bash
just clean  # Removes:
            # - wasm/node_modules
            # - wasm/package-lock.json
            # - Any stray node_modules in exercises
```

**Rebuilding**: After `just clean`, run `just setup` (or `npm install`) before testing.

## References

- **npm workspaces**: https://docs.npmjs.com/cli/v10/using-npm/workspaces
- **Jest 30**: https://jestjs.io/docs/getting-started
- **ESLint 9 flat config**: https://eslint.org/docs/latest/use/configure/configuration-files-new
- **Root AGENTS.md**: See "Special Cases / WASM (npm workspaces)" section

## Design Decisions

### Why not independent node_modules per exercise?

**Problem**: 3 exercises × 110MB = 330MB of duplicated dependencies.

**Solution**: Shared workspace → 110MB total.

**Tradeoff**: Exercises must use same dependency versions. For Exercism (learning environment), consistency is a feature, not a bug.

### Why shared ESLint config?

**Problem**: Maintaining identical ESLint config across N exercises.

**Solution**: Single `eslint.config.js` at workspace root.

**Benefit**: Update config once, applies everywhere.

---

**Last Updated**: November 2025 (ESLint 8→9 migration, Jest 29→30 upgrade)

