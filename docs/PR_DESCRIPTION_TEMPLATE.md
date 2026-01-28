# PR Description Template

Copy this template when creating a new Pull Request.

```markdown
# PR: [Feature/Bug/Refactor Name]

## Description

[Brief description of changes. What does this PR do?]

## Type of Change

- [ ] New feature (non-breaking change which adds functionality)
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] Refactoring (non-breaking change that improves code quality)
- [ ] Documentation update
- [ ] Test update
- [ ] Chore (tooling, config, etc.)

---

## Changes

### Tests (Commit 1)
| Directory | Files | Description |
|-----------|-------|-------------|
| `test/features/...` | X | [Description of tests] |
| **Total** | **X files** | X tests |

### Implementation (Commit 2+)
| Layer | Files | Key Components |
|-------|-------|----------------|
| Domain | X | Entities, Failures |
| Presentation | X | Widgets, Pages |
| Infrastructure | X | Repositories |
| Docs | X | README.md |
| **Total** | **X files** |

---

## Testing

| Test Type | Count | Status |
|-----------|-------|--------|
| Unit/Widget tests | X | ✅ Pass |
| Flutter analyze | - | ✅ No issues |

```bash
flutter analyze lib/features/[feature]/
very_good test test/features/[feature]/
```

---

## Architecture Compliance

| Rule | Status |
|------|--------|
| Feature-first structure | ✅ |
| 100% Test Coverage | ✅ |
| Linter pass | ✅ |
| Proper dartdoc | ✅ |

---

## Key Features/Changes

- **[Feature 1]**: [Description]
- **[Feature 2]**: [Description]
```
