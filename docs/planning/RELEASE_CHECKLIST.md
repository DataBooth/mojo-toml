# Release Checklist for v0.1.0-alpha

Follow these steps to release mojo-toml v0.1.0-alpha.

## Pre-Release Verification

- [x] All 79 tests passing (`pixi run test-all`)
- [x] Examples working (`pixi run example-simple`, `pixi run example-pixi`)
- [x] Documentation updated (README.md, CHANGELOG.md)
- [x] CI workflows updated (test.yml, build-package.yml)
- [x] Release notes prepared (.github/RELEASE_NOTES_v0.1.0-alpha.md)

## Files Changed

### Core Implementation
- [x] `src/toml/parser.mojo` - Table header implementation with flat key storage
- [x] `tests/test_tables.mojo` - Updated for flat key access (8 tests passing)

### Documentation
- [x] `README.md` - Updated status, installation, contributing sections
- [x] `CHANGELOG.md` - Complete v0.1.0-alpha entry
- [x] `docs/TABLE_HEADERS_BLOCKER.md` - Technical documentation
- [x] `docs/DISCORD_POST.md` - Community discussion draft

### Infrastructure
- [x] `.github/workflows/test.yml` - Run full test suite and examples
- [x] `.github/workflows/build-package.yml` - Build .mojopkg on release
- [x] `.github/RELEASE_NOTES_v0.1.0-alpha.md` - Release notes template
- [x] `pixi.toml` - Updated test-all task (79 tests)

### Examples
- [x] `examples/parse_pixi.mojo` - Demonstrates flat key access

## Release Steps

### 1. Final Test Run
```bash
cd /Users/mjboothaus/code/github/databooth/mojo-toml
pixi run test-all          # Should show: All 79 Tests Complete!
pixi run example-simple    # Should run without errors
pixi run example-pixi      # Should parse pixi.toml successfully
```

### 2. Build Package (Optional - test locally)
```bash
pixi run build-package     # Creates dist/toml.mojopkg
```

### 3. Commit All Changes
```bash
git add -A
git status  # Review changes

git commit -m "Release v0.1.0-alpha

- Implement table header parsing with flat key storage
- Add 8 table header tests (79 total tests passing)
- Update documentation for alpha release
- Add CI workflows for testing and package building
- Create CHANGELOG.md and release notes

Co-Authored-By: Warp <agent@warp.dev>"
```

### 4. Create and Push Tag
```bash
git tag -a v0.1.0-alpha -m "Release v0.1.0-alpha

First alpha release of mojo-toml - the first native TOML parser for Mojo!

- 79 tests passing
- Parses most common TOML files
- Uses flat key storage as interim solution
- Zero Python dependencies

See CHANGELOG.md for full details."

git push origin main
git push origin v0.1.0-alpha
```

### 5. Create GitHub Release

1. Go to https://github.com/databooth/mojo-toml/releases/new
2. Select tag: `v0.1.0-alpha`
3. Release title: `v0.1.0-alpha - First Alpha Release 🔥`
4. Copy content from `.github/RELEASE_NOTES_v0.1.0-alpha.md`
5. Check "Set as a pre-release" (this is an alpha)
6. Click "Publish release"

The `build-package.yml` workflow will automatically:
- Build the .mojopkg
- Attach it to the release
- Add compatibility notes

### 6. Verify Release

- [ ] Release appears at https://github.com/databooth/mojo-toml/releases
- [ ] Tag is visible in GitHub
- [ ] CI workflows ran successfully
- [ ] .mojopkg is attached to release (may take a few minutes)

## Post-Release

### Update Version References (for next release)
- Update CHANGELOG.md `[Unreleased]` section for v0.2.0 planning
- Consider updating README roadmap based on feedback

### Announce (Optional)
- Share on Modular Discord #mojo channel
- Post on social media if desired
- Link from databooth.com.au/mojo section

### Monitor
- Watch for GitHub issues
- Respond to community feedback
- Note any Mojo language updates that might help with nested tables

## Troubleshooting

**If tests fail:**
```bash
pixi run test-basic      # Test individually
pixi run test-tables     # Focus on problem area
```

**If commit fails:**
- Check that all files are staged: `git status`
- Ensure no uncommitted changes in submodules

**If tag already exists:**
```bash
git tag -d v0.1.0-alpha              # Delete local tag
git push origin :refs/tags/v0.1.0-alpha  # Delete remote tag
# Then recreate tag
```

**If CI fails:**
- Check workflow logs on GitHub Actions
- Test locally first: `pixi run test-all`
- Ensure pixi.toml is correct

## Notes

**Alpha Release Expectations:**
- This is an alpha release - breaking changes expected in v0.2.0
- Flat key storage is clearly documented as interim
- Users are warned about API changes coming
- Focus is on getting feedback and proving concept

**Version Numbering:**
- Using `-alpha` suffix to signal pre-release
- Follows semantic versioning
- v0.2.0 will be next with nested tables (if possible)
- v1.0.0 will signal production-ready and API stability

---

Created: 2026-01-07
Updated: 2026-01-07
