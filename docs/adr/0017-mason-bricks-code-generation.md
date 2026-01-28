# ADR-0017: Mason Bricks for Code Generation

## Status

Accepted

## Context

As the codebase grows, developers need to create new features, use cases, entities, and other components frequently. Manual creation leads to:
- Inconsistent structure across features
- Missed patterns (e.g., forgetting failure mappers)
- Copy-paste errors from existing code
- Time spent on boilerplate instead of business logic

I needed a code generation solution that:
1. Enforces architectural patterns documented in ADRs
2. Generates all necessary files for a component
3. Includes test scaffolding
4. Is easy to use and customize

## Decision

I adopt **Mason** for template-based code generation with 6 specialized bricks.

### Brick Architecture

| Brick | Purpose | Templates Generated |
|-------|---------|---------------------|
| `feature` | Complete feature scaffold | Entity, failure, repo interface, datasource, model, repo impl, bloc, events, states, page, routes, failure mapper |
| `use_case` | CQRS use cases | Command, Query, CommandNoParams, QueryNoParams + tests |
| `bloc` | BLoC with freezed | BLoC, event, state + bloc_test tests |
| `entity` | Domain entities | Entity/AggregateRoot, EntityId + tests |
| `value_object` | Value objects | ValueObject with Either-based validation + tests |
| `repository` | Repository pattern | Interface + @Injectable implementation + tests |

### Directory Structure

```
bricks/
├── feature/
│   ├── brick.yaml
│   ├── hooks/
│   │   ├── post_gen.dart      # Runs build_runner
│   │   └── pubspec.yaml
│   └── __brick__/lib/features/{{feature_name}}/
│       ├── domain/            # Entity, failure, repo interface
│       ├── application/       # Use cases placeholder
│       ├── infrastructure/    # Datasource, model, repo impl
│       └── presentation/      # BLoC, page, routes, failure mapper
├── use_case/
│   ├── brick.yaml
│   └── __brick__/
├── bloc/
│   ├── brick.yaml
│   └── __brick__/
├── entity/
│   ├── brick.yaml
│   └── __brick__/
├── value_object/
│   ├── brick.yaml
│   └── __brick__/
└── repository/
    ├── brick.yaml
    └── __brick__/
```

### Pattern Enforcement

Each brick template encodes architectural decisions from ADRs:

#### Entity Pattern (ADR-008)

Entities extend base classes - they are **NOT** freezed:

```dart
// entity brick template - follows ADR-008
class {{name.pascalCase()}} extends AggregateRoot {
  {{name.pascalCase()}}({required this.id});
  
  @override
  final {{name.pascalCase()}}Id id;
  
  // TODO: Add domain properties
  
  // Manual copyWith for full control over domain behavior
  {{name.pascalCase()}} copyWith({
    {{name.pascalCase()}}Id? id,
  }) {
    return {{name.pascalCase()}}(id: id ?? this.id);
  }
}
```

#### CQRS Pattern (ADR-010)

Use cases are classified as Commands (write) or Queries (read):

```dart
// use_case brick template - follows ADR-010
@injectable
class {{name.pascalCase()}} extends Query<{{params_type.pascalCase()}}, {{output_type.pascalCase()}}> {
  const {{name.pascalCase()}}(this._repository);
  final I{{feature_name.pascalCase()}}Repository _repository;

  @override
  FutureResult<{{output_type.pascalCase()}}> call({{params_type.pascalCase()}} params) {
    // TODO: Implement query logic
    throw UnimplementedError();
  }
}
```

#### BLoC Pattern (ADR-002, ADR-008)

Events and states use freezed for discriminated unions:

```dart
// bloc brick template - follows ADR-002, ADR-008
@freezed
abstract class {{name.pascalCase()}}Event with _${{name.pascalCase()}}Event {
  const factory {{name.pascalCase()}}Event.started() = {{name.pascalCase()}}Started;
  // TODO: Add more events
}

@freezed
abstract class {{name.pascalCase()}}State with _${{name.pascalCase()}}State {
  const factory {{name.pascalCase()}}State.initial() = {{name.pascalCase()}}Initial;
  const factory {{name.pascalCase()}}State.loading() = {{name.pascalCase()}}Loading;
  const factory {{name.pascalCase()}}State.loaded() = {{name.pascalCase()}}Loaded;
  const factory {{name.pascalCase()}}State.error(String message) = {{name.pascalCase()}}Error;
}
```

#### Value Object Pattern (ADR-003)

Value objects use Either-based validation:

```dart
// value_object brick template - follows ADR-003
class {{name.pascalCase()}} extends ValueObject<{{value_type}}> {
  factory {{name.pascalCase()}}({{value_type}}? input) {
    return {{name.pascalCase()}}._(
      _validate(input),
    );
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

### Configuration

Root `mason.yaml` registers all bricks:

```yaml
bricks:
  feature:
    path: bricks/feature
  use_case:
    path: bricks/use_case
  bloc:
    path: bricks/bloc
  entity:
    path: bricks/entity
  value_object:
    path: bricks/value_object
  repository:
    path: bricks/repository
```

### Post-Generation Hooks

The `feature` brick includes a post-generation hook that runs `build_runner`:

```dart
// hooks/post_gen.dart
Future<void> run(HookContext context) async {
  await Process.run('dart', ['run', 'build_runner', 'build', '--delete-conflicting-outputs']);
}
```

### Usage

```bash
# Initialize Mason in project
mason get

# Generate a new feature
mason make feature --feature_name payments

# Generate individual components
mason make use_case --name GetPayments --feature_name payments --type query
mason make bloc --name payment_list --feature_name payments
mason make entity --name Payment --feature_name payments --is_aggregate_root true
mason make value_object --name Currency --feature_name payments --value_type String
mason make repository --name Payment --feature_name payments --entity_name Payment
```

## Consequences

### Positive

- **Consistency**: All generated code follows ADR patterns
- **Speed**: Create complete features in seconds
- **Correctness**: Includes tests, failure mappers, DI annotations
- **Onboarding**: New developers learn patterns through templates
- **Maintenance**: Update template once, all future code benefits

### Negative

- **Learning curve**: Developers must learn Mason CLI
- **Template maintenance**: Must update bricks when patterns evolve
- **Analysis noise**: `bricks/` directory excluded from Dart analysis (Mustache syntax)

### Neutral

- Templates include `TODO` comments for customization points
- Post-generation hooks run `build_runner` automatically for freezed code

## References

- [Mason Documentation](https://docs.brickhub.dev/)
- [mason.yaml](../../mason.yaml) - Project brick configuration
- [ADR-001: Clean Architecture + DDD](0001-clean-architecture-ddd.md)
- [ADR-002: flutter_bloc State Management](0002-flutter-bloc-state-management.md)
- [ADR-003: fpdart Error Handling](0003-fpdart-error-handling.md)
- [ADR-005: injectable + get_it DI](0005-injectable-dependency-injection.md)
- [ADR-008: freezed for Immutable Classes](0008-freezed-immutable-classes.md)
- [ADR-010: CQRS Command/Query](0010-cqrs-command-query.md)
