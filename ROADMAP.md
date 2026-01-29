# mojo-toml Roadmap

## Package Distribution Improvements

### High Priority

#### 🎯 Move to `noarch: generic` Build
**Goal:** Make package platform-independent for faster builds and smaller footprint

**Current:** Package builds separately for each platform (Linux, macOS, ARM64)  
**Target:** Single build works everywhere

**Rationale:**
- mojo-toml ships pure Mojo source code (no binaries)
- No platform-specific dependencies
- No compilation during installation (just file copying)
- Build time: Reduced from 3x to 1x
- Storage: ~66% reduction on conda servers

**Implementation:**
```yaml
build:
  number: 0
  noarch: generic  # Add this line
  script:
    - mkdir -p $PREFIX/lib/mojo/toml
    - cp -r src/toml/* $PREFIX/lib/mojo/toml/
```

**Blocked by:** None - ready to implement  
**References:** 
- [docs/PLATFORM_BUILDS.md](docs/PLATFORM_BUILDS.md#noarch-packages)
- [Conda noarch docs](https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html#noarch)

**Issue:** Track at [#TBD](.) - Create issue when ready

---

### Medium Priority

#### 📦 Publish to conda-forge
Once established in modular-community, consider publishing to conda-forge for wider reach.

**Benefits:**
- Larger user base
- Automatic CI/CD
- Community maintenance

**Requirements:**
- Stable modular-community presence
- Active maintenance commitment
- conda-forge submission PR

---

### Low Priority

#### 🔄 Automated Version Bumps
Automate version updates across:
- `src/toml/__init__.mojo` version string
- `recipe.yaml` version context
- Git tags

**Tools to evaluate:**
- bump2version / bump-my-version
- GitHub Actions automation

---

## Feature Roadmap

Tracked in main [README.md](README.md) Future Plans section:
- Type-safe config deserialization (blocked on Mojo reflection)
- TOML 1.1 full compliance
- Enhanced error messages with suggestions

---

## Maintenance

### Recipe Validation
✅ **Completed (2026-01-29)**
- Local validation with rattler-build
- GitHub Actions automation
- Pre-commit hook integration

### Mojo Version Management
✅ **Completed (2026-01-29)**
- Standardized to `mojo_version: "=0.25.7"` context variable
- Using `pin_compatible()` for runtime

### Pre-commit Enforcement
✅ **Completed (2026-01-29)**
- Trailing whitespace checks
- YAML/TOML validation
- Recipe validation on changes

---

## Updates

**Last updated:** 2026-01-29  
**Next review:** When Mojo 1.0 releases (H1 2026)
