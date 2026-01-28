# Mason Bricks - Code Generation Rules

## Overview

This project uses **Mason** for template-based code generation to ensure consistent architecture compliance across all features. See ADR-017 for the decision rationale.

## Available Bricks

| Brick | Purpose | ADRs Applied |
|-------|---------|--------------|
| `feature` | Complete feature scaffold with all layers | ADR-001, ADR-002, ADR-008, ADR-010 |
| `use_case` | CQRS Command/Query use cases | ADR-010 |
| `bloc` | BLoC with freezed events/states | ADR-002, ADR-008 |
| `entity` | Domain entity with AggregateRoot | ADR-008 (NOT freezed) |
| `value_object` | ValueObject with Either validation | ADR-003 |
| `repository` | Repository interface + implementation | ADR-001, ADR-005 |

## Usage

### Initialization

```bash
# First time: install mason_cli globally
dart pub global activate mason_cli

# In project root: get bricks defined in mason.yaml
mason get
```

### Generating Code

```bash
# Generate a complete feature
mason make feature --feature_name payments

# Generate a use case (query or command)
mason make use_case --name GetPayments --feature_name payments --type query
mason make use_case --name ProcessPayment --feature_name payments --type command

# Generate a BLoC
mason make bloc --name payment_list --feature_name payments

# Generate an entity (AggregateRoot)
mason make entity --name Payment --feature_name payments --is_aggregate_root true

# Generate a value object
mason make value_object --name Currency --feature_name payments --value_type String

# Generate a repository
mason make repository --name Payment --feature_name payments --entity_name Payment
```

## Pattern Enforcement

Each brick enforces architectural patterns from ADRs:

### Entity Brick (ADR-008)

Generates **plain Dart class** extending AggregateRoot - NOT freezed:

```dart
class {{name.pascalCase()}} extends AggregateRoot {
  {{name.pascalCase()}}({required this.id});
  
  @override
  final {{name.pascalCase()}}Id id;
  
  // Manual copyWith for domain behavior
  {{name.pascalCase()}} copyWith({
    {{name.pascalCase()}}Id? id,
  }) {
    return {{name.pascalCase()}}(id: id ?? this.id);
  }
}
```

### Use Case Brick (ADR-010 - CQRS)

Generates Command or Query based on `type` variable:

```dart
// Command (write operation)
@injectable
class {{name.pascalCase()}} extends Command<{{params_type.pascalCase()}}, {{output_type.pascalCase()}}> {
  const {{name.pascalCase()}}(this._repository);
  final I{{feature_name.pascalCase()}}Repository _repository;

  @override
  FutureResult<{{output_type.pascalCase()}}> call({{params_type.pascalCase()}} params) {
    // TODO: Implement command logic
    throw UnimplementedError();
  }
}

// Query (read operation)
@injectable
class {{name.pascalCase()}} extends Query<{{params_type.pascalCase()}}, {{output_type.pascalCase()}}> {
  // ...
}
```

### BLoC Brick (ADR-002, ADR-008)

Generates BLoC with freezed events and states:

```dart
// BLoC
@injectable
class {{name.pascalCase()}}Bloc extends Bloc<{{name.pascalCase()}}Event, {{name.pascalCase()}}State> {
  {{name.pascalCase()}}Bloc() : super(const {{name.pascalCase()}}State.initial()) {
    on<{{name.pascalCase()}}Started>(_onStarted);
  }
}

// Events (freezed)
@freezed
abstract class {{name.pascalCase()}}Event with _${{name.pascalCase()}}Event {
  const factory {{name.pascalCase()}}Event.started() = {{name.pascalCase()}}Started;
}

// States (freezed)
@freezed
abstract class {{name.pascalCase()}}State with _${{name.pascalCase()}}State {
  const factory {{name.pascalCase()}}State.initial() = {{name.pascalCase()}}Initial;
  const factory {{name.pascalCase()}}State.loading() = {{name.pascalCase()}}Loading;
  const factory {{name.pascalCase()}}State.loaded() = {{name.pascalCase()}}Loaded;
  const factory {{name.pascalCase()}}State.error(String message) = {{name.pascalCase()}}Error;
}
```

### Value Object Brick (ADR-003)

Generates ValueObject with Either-based validation:

```dart
class {{name.pascalCase()}} extends ValueObject<{{value_type}}> {
  factory {{name.pascalCase()}}({{value_type}}? input) {
    return {{name.pascalCase()}}._(_validate(input));
  }

  const {{name.pascalCase()}}._(this.value);

  @override
  final Either<List<ValueFailure>, {{value_type}}> value;

  static Either<List<ValueFailure>, {{value_type}}> _validate({{value_type}}? input) {
    if (input == null || input.isEmpty) {
      return left([const ValueFailure.empty()]);
    }
    // TODO: Add validation logic
    return right(input);
  }
}
```

## Post-Generation Steps

After using any brick:

1. **Run build_runner** to generate freezed/injectable code:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Review generated TODO comments** and implement feature-specific logic

3. **Write tests** - brick generates test scaffolds in `test/` directory

4. **Update DI module** if using repository brick:
   ```dart
   // lib/core/di/injection_container.dart
   @InjectableInit(preferRelativeImports: true)
   void configureDependencies() => getIt.init();
   ```

## Rules

- ✅ **DO**: Use bricks for new features/components
- ✅ **DO**: Run `mason get` after pulling changes with new bricks
- ✅ **DO**: Update template variables before generation
- ✅ **DO**: Run build_runner after generation
- ✅ **DO**: Review and customize generated TODO comments
- ❌ **DON'T**: Manually create boilerplate that bricks can generate
- ❌ **DON'T**: Modify files in `bricks/` without updating all templates
- ❌ **DON'T**: Forget to run code generation after using bricks

## Brick Directory Structure

```text
bricks/
├── feature/
│   ├── brick.yaml           # Brick configuration
│   ├── hooks/
│   │   ├── post_gen.dart    # Post-generation hook (runs build_runner)
│   │   └── pubspec.yaml
│   └── __brick__/           # Template files with Mustache syntax
├── use_case/
├── bloc/
├── entity/
├── value_object/
└── repository/
```

## Modifying Bricks

When architecture patterns evolve:

1. Update the relevant ADR in `docs/adr/`
2. Update corresponding brick templates in `bricks/`
3. Update this rule file if needed
4. Test with `mason make <brick> --dry-run`

**Note**: The `bricks/` directory is excluded from Dart analysis because Mustache template syntax (`{{}}`) is not valid Dart.

## References

- [ADR-017: Mason Bricks for Code Generation](../docs/adr/0017-mason-bricks-code-generation.md)
- [Mason Documentation](https://docs.brickhub.dev/)
- [mason.yaml](../mason.yaml) - Project brick configuration
