# signals_watch Release Verification Checklist

Use this checklist every time before committing, tagging, and publishing a new version of the `signals_watch` package. This ensures all code, documentation, and metadata are correct and production-ready.

---

## 1. Version Consistency
- [ ] `pubspec.yaml` version matches intended release
- [ ] `README.md` install snippet uses correct version
- [ ] `PACKAGE_SUMMARY.md` version is up to date
- [ ] `CHANGELOG.md` has a section for the new version and date

## 2. Documentation
- [ ] `README.md` documents all new features and API changes
- [ ] All code examples in `README.md` are updated and accurate
- [ ] `PACKAGE_SUMMARY.md` reflects new features and correct version
- [ ] Migration guides and usage examples are current
 - [ ] Example app reflects all new features introduced in this release (computed, async, lifecycle callbacks, overrides, reset, shouldRebuild/shouldNotify, equals, error/loading builders, debug observer)
 - [ ] Example app sections are updated or added to demonstrate new APIs and patterns

## 3. Code & Tests
- [ ] All code changes are committed
- [ ] All tests pass (`flutter test`)
- [ ] No analyzer issues (`flutter analyze`)
- [ ] Code is formatted (`dart format .`)
- [ ] Example app runs without errors

## 4. Metadata & Safety
- [ ] Homepage, repository, and issue tracker URLs in `pubspec.yaml` are correct
- [ ] `.gitignore` blocks private keys and sensitive files
- [ ] No sensitive files (e.g., SSH keys) are present or tracked by git

## 5. Publishing Preparation
- [ ] Run `flutter pub get` in package root
- [ ] Run `flutter pub publish --dry-run` and resolve any issues
- [ ] Review all documentation for typos and outdated info

## 6. Commit & Tag
- [ ] Commit all changes with a clear message (e.g., "Release vX.Y.Z")
- [ ] Tag the commit with the version (e.g., `v0.2.0`)
- [ ] Push commits and tags to GitHub

## 7. Publish
- [ ] Run `dart pub publish` to publish to pub.dev

---

**Tip:** Run through this checklist with your AI assistant before every release for a smooth, error-free publish!
