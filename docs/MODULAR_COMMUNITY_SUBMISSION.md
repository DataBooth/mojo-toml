# Modular Community Submission Guide

This document outlines the steps to submit mojo-toml to the modular-community channel and announce it on the forum.

## 📦 Step 1: Submit to modular-community

### 1.1 Fork the Repository
1. Go to https://github.com/modular/modular-community
2. Click "Fork" to create your own copy

### 1.2 Create Package Recipe
1. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/modular-community.git
   cd modular-community
   ```

2. Create the package directory:
   ```bash
   mkdir -p recipes/mojo-toml
   ```

3. Copy files from mojo-toml repo:
   ```bash
   cp /path/to/mojo-toml/packaging/recipe.yaml recipes/mojo-toml/
   cp /path/to/mojo-toml/packaging/test_package.mojo recipes/mojo-toml/
   ```

4. Commit and push:
   ```bash
   git add recipes/mojo-toml/
   git commit -m "Add mojo-toml v0.3.0 - Native TOML parser for Mojo"
   git push origin main
   ```

### 1.3 Create Pull Request
1. Go to your fork on GitHub
2. Click "Contribute" → "Open pull request"
3. Title: `Add mojo-toml v0.3.0 - Native TOML parser`
4. Description:
   ```markdown
   ## Package: mojo-toml v0.3.0
   
   A native TOML 1.0 parser for Mojo with zero Python dependencies.
   
   ### Features
   - Complete TOML 1.0 syntax support
   - 96 comprehensive tests
   - Performance: 26μs for simple parses, 2ms for real files
   - Nested tables, dotted keys, duplicate detection
   - Clear error messages with line/column context
   
   ### Repository
   - GitHub: https://github.com/DataBooth/mojo-toml
   - Release: https://github.com/DataBooth/mojo-toml/releases/tag/v0.3.0
   - License: MIT
   
   ### Testing
   Package includes test_package.mojo which validates:
   - Simple key-value parsing
   - Integer and array parsing
   - Nested table structures
   - Dotted key functionality
   
   All 96 tests pass in the source repository.
   ```

5. Submit the PR and wait for review

## 📢 Step 2: Post on Modular Forum

### 2.1 Navigate to Community Showcase
1. Go to https://forum.modular.com
2. Navigate to the "Community Showcase" category
3. Click "New Topic"

### 2.2 Create Forum Post
Use the content from `FORUM_ANNOUNCEMENT.md`:

**Title**: 🔥 Announcing mojo-toml v0.3.0 - Native TOML Parser for Mojo

**Category**: Community Showcase

**Tags**: mojo, toml, parser, library, configuration

**Content**: Copy the entire content from FORUM_ANNOUNCEMENT.md

### 2.3 Engage with Community
- Respond to questions and feedback
- Share updates on the PR status
- Consider creating a follow-up post when package is available via pixi

## 📝 Files Created

The following files have been created in your mojo-toml repository:

1. **packaging/recipe.yaml** - Rattler-build recipe for conda packaging
   - Defines package metadata, dependencies, build steps
   - Includes comprehensive description and links
   
2. **packaging/test_package.mojo** - Installation verification tests
   - Tests basic parsing functionality
   - Validates arrays, tables, and dotted keys
   - Ensures package is properly installed

3. **FORUM_ANNOUNCEMENT.md** - Forum post content
   - Comprehensive announcement with examples
   - Feature highlights and performance metrics
   - Installation instructions and roadmap

4. **MODULAR_COMMUNITY_SUBMISSION.md** - This guide

## ✅ Checklist

### Before Submission
- [x] v0.3.0 released and tagged on GitHub
- [x] recipe.yaml created with correct version
- [x] test_package.mojo created and validated
- [x] Forum announcement prepared
- [ ] License file exists (MIT) - verify this
- [ ] Fork modular-community repo

### During Submission  
- [ ] Create recipes/mojo-toml/ directory
- [ ] Copy recipe.yaml and test_package.mojo
- [ ] Commit and push to fork
- [ ] Create pull request
- [ ] Post on forum

### After Submission
- [ ] Monitor PR for feedback
- [ ] Respond to forum comments
- [ ] Update documentation when package is available
- [ ] Consider blog post or tutorial

## 🔗 Important Links

- **modular-community repo**: https://github.com/modular/modular-community
- **Modular Forum**: https://forum.modular.com
- **Community Showcase**: https://forum.modular.com/c/community-showcase
- **mojo-toml GitHub**: https://github.com/DataBooth/mojo-toml
- **v0.3.0 Release**: https://github.com/DataBooth/mojo-toml/releases/tag/v0.3.0

## 💡 Tips

1. **Respond quickly** to PR feedback - the Modular team is responsive
2. **Be active** on the forum - engage with people trying your package
3. **Update** the recipe when you release new versions
4. **Document** usage examples in your README
5. **Consider** writing a blog post or tutorial once accepted

## 🎯 Expected Timeline

- PR review: 1-5 business days
- Package availability: Shortly after PR merge
- Community feedback: Immediate on forum

Good luck with the submission! 🚀
