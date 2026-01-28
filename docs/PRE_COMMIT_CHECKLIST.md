# Pre-Commit Checklist

General verification checklist before committing any changes.

---

## Before Making Edits

### 1. View Source Files First
- Don't rely on memory from earlier in the session
- Open actual files and cross-reference
- Verify patterns against real implementation

### 2. Search for Patterns
```bash
# Find all occurrences before editing
grep -r "pattern" lib/ test/
```

### 3. Map Dependencies
- What files import this?
- What tests cover this?
- What barrel files export this?

---

## Architecture Principles

### SOLID
- [ ] **S** - Single Responsibility: One reason to change?
- [ ] **O** - Open/Closed: Extensible without modification?
- [ ] **L** - Liskov Substitution: Subtypes substitutable?
- [ ] **I** - Interface Segregation: No fat interfaces?
- [ ] **D** - Dependency Inversion: Depends on abstractions?

### DDD
- [ ] Entities have identity?
- [ ] Value Objects are immutable with validation?
- [ ] Aggregate Roots manage consistency?
- [ ] Domain events capture state changes?
- [ ] Ubiquitous language in naming?

### Clean Architecture
- [ ] No UI framework imports in domain layer?
- [ ] No infrastructure dependencies in domain?
- [ ] Ports define contracts, not implementations?
- [ ] Dependencies point inward only?

### Hexagonal Architecture
- [ ] Ports are in domain layer?
- [ ] No adapter logic in ports?
- [ ] No platform-specific imports in domain?

### Clean Code
- [ ] Meaningful names?
- [ ] Small, focused methods?
- [ ] Comprehensive documentation comments?
- [ ] No magic values?

### DRY
- [ ] No duplicated logic?
- [ ] Base classes used for shared behavior?

---

## TDD Commit Order

When committing new features:
1. **Commit tests first** - `test(scope): add tests for feature`
2. **Commit implementation** - `feat(scope): add feature implementation`

This demonstrates TDD practice and shows tests came before implementation in git history.

---

## Before Committing

### Code Quality
```bash
# Install dependencies
very_good packages get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run static analysis
flutter analyze

# Format code
dart format .

# Run tests with coverage
very_good test --coverage
```

### Build Verification
```bash
# Development build
flutter run \
  --flavor development \
  --target lib/main_development.dart \
  --dart-define-from-file=config/development.json

# Or quick build check
flutter build apk --flavor development --target lib/main_development.dart
```

### Documentation
- [ ] Code examples match actual implementation
- [ ] No duplicate examples
- [ ] No outdated patterns

### Validation
- [ ] Input validation covers edge cases
- [ ] Null handling checked
- [ ] Empty input handling checked

---

## Bug Analysis

Review all changed files and actively look for:
- Potential runtime errors
- Logic flaws
- Resource leaks
- Race conditions
- Unhandled edge cases
- Incorrect or outdated inline comments

For each file changed, analyze the code and identify any possible bugs before committing.

---

## Final Verification

- [ ] `flutter analyze` passes with no errors
- [ ] `very_good test` passes
- [ ] Local build succeeds
- [ ] Viewed all changed files
- [ ] Searched for all modified patterns
- [ ] Reviewed for duplicates and consistency
