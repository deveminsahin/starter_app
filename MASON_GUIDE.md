# Mason Brick Guide

Turn your architecture into reusable templates for every project.

---

## What You Can Create

| Brick Type | Purpose |
|------------|---------|
| **Feature Brick** | Generate new features with proper structure |
| **Entity Brick** | Generate domain entities with ID types |
| **Use Case Brick** | Generate use cases with DI setup |
| **Bloc Brick** | Generate BLoC with events, states, and freezed |
| **Repository Brick** | Generate repository interface + implementation |
| **Value Object Brick** | Generate validated value objects |

---

## Getting Started

```bash
# Install Mason CLI
dart pub global activate mason_cli

# Initialize Mason in your project
mason init

# Create a new brick
mason new starter_app_template
```

---

## Available Bricks

```text
bricks/
├── feature/                  # Complete feature with all layers
│   ├── brick.yaml
│   ├── hooks/post_gen.dart   # Runs build_runner after generation
│   └── __brick__/
│       └── {{feature_name.snakeCase()}}/
│           ├── application/
│           ├── domain/
│           ├── infrastructure/
│           ├── presentation/
│           └── l10n/
│
├── entity/                   # Domain entity with ID extension type
│   ├── brick.yaml
│   └── __brick__/
│       └── {{name.snakeCase()}}.dart
│
├── use_case/                 # Application layer use case
│   ├── brick.yaml
│   └── __brick__/
│       └── {{name.snakeCase()}}.dart
│
├── bloc/                     # BLoC with events and states
│   ├── brick.yaml
│   └── __brick__/
│       └── {{name.snakeCase()}}_bloc.dart
│
├── repository/               # Repository interface + implementation
│   ├── brick.yaml
│   └── __brick__/
│       ├── i_{{name.snakeCase()}}_repository.dart
│       └── {{name.snakeCase()}}_repository.dart
│
└── value_object/             # Validated value object
    ├── brick.yaml
    └── __brick__/
        └── {{name.snakeCase()}}.dart
```

---

## Example: brick.yaml for Project Template

```yaml
name: starter_app
description: Clean Architecture Flutter starter with Hexagonal patterns
version: 0.1.0
environment:
  mason: ">=0.1.0-dev.52 <0.1.0"

vars:
  project_name:
    type: string
    description: The project name (e.g., my_finance_app)
    prompt: What is the project name?
  
  org_name:
    type: string
    description: Organization name for bundle ID
    default: com.deveminsahin
    prompt: What is your organization name?
  
  include_auth:
    type: boolean
    description: Include auth feature
    default: true
    prompt: Include authentication feature?
  
  include_websocket:
    type: boolean
    description: Include WebSocket support
    default: true
    prompt: Include WebSocket support?
```

---

## Example: Feature Brick

### brick.yaml

```yaml
name: feature
description: Generate a new feature following Clean Architecture
version: 0.1.0

vars:
  feature_name:
    type: string
    description: Feature name (e.g., payments, transactions)
    prompt: What is the feature name?
  
  include_bloc:
    type: boolean
    default: true
    prompt: Include Bloc/Cubit?
  
  include_repository:
    type: boolean
    default: true
    prompt: Include repository?
```

### Generated Structure

```text
__brick__/
└── {{feature_name.snakeCase()}}/
    ├── application/
    │   └── usecases/
    │       └── .gitkeep
    ├── domain/
    │   ├── entities/
    │   │   └── .gitkeep
    │   ├── failures/
    │   │   └── {{feature_name.snakeCase()}}_failure.dart
    │   └── repositories/
    │       └── i_{{feature_name.snakeCase()}}_repository.dart
    ├── infrastructure/
    │   ├── datasources/
    │   │   └── {{feature_name.snakeCase()}}_remote_data_source.dart
    │   ├── mappers/
    │   │   └── .gitkeep
    │   ├── models/
    │   │   └── .gitkeep
    │   └── repositories/
    │       └── {{feature_name.snakeCase()}}_repository_impl.dart
    └── presentation/
        ├── bloc/
        │   ├── {{feature_name.snakeCase()}}_bloc.dart
        │   ├── {{feature_name.snakeCase()}}_event.dart
        │   └── {{feature_name.snakeCase()}}_state.dart
        ├── failure_message/
        │   └── {{feature_name.snakeCase()}}_failure_mapper.dart
        ├── pages/
        │   └── {{feature_name.snakeCase()}}_page.dart
        └── widgets/
            └── .gitkeep
```

---

## Example: Failure Mapper Template

```dart
// {{feature_name.snakeCase()}}_failure_mapper.dart
import 'package:injectable/injectable.dart';

import '../../../../core/presentation/failure_message/failure_mapper_registry.dart';
import '../../../../core/presentation/failure_message/failure_message_mapper.dart';
import '../../domain/failures/{{feature_name.snakeCase()}}_failure.dart';

@injectable
class {{feature_name.pascalCase()}}FailureMessageMapper extends FailureMessageMapper {
  {{feature_name.pascalCase()}}FailureMessageMapper(super.registry);

  @override
  String? mapFailureToMessage(failure, context) {
    if (failure is! {{feature_name.pascalCase()}}Failure) return null;

    return failure.map(
      // TODO: Add failure mappings
      unexpected: (_) => 'An unexpected error occurred',
    );
  }
}
```

---

## Example: Failure Class Template

```dart
// {{feature_name.snakeCase()}}_failure.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{{feature_name.snakeCase()}}_failure.freezed.dart';

@freezed
class {{feature_name.pascalCase()}}Failure with _${{feature_name.pascalCase()}}Failure {
  const factory {{feature_name.pascalCase()}}Failure.unexpected() = _Unexpected;
  // TODO: Add more failure cases
}
```

---

## Example: Repository Interface Template

```dart
// i_{{feature_name.snakeCase()}}_repository.dart
import 'package:fpdart/fpdart.dart';

import '../failures/{{feature_name.snakeCase()}}_failure.dart';

abstract interface class I{{feature_name.pascalCase()}}Repository {
  // TODO: Add repository methods
  // Example:
  // Future<Either<{{feature_name.pascalCase()}}Failure, List<Entity>>> getAll();
}
```

---

## Example: Repository Implementation Template

```dart
// {{feature_name.snakeCase()}}_repository_impl.dart
import 'package:injectable/injectable.dart';

import '../../domain/repositories/i_{{feature_name.snakeCase()}}_repository.dart';
import '../datasources/{{feature_name.snakeCase()}}_remote_data_source.dart';

@Injectable(as: I{{feature_name.pascalCase()}}Repository)
class {{feature_name.pascalCase()}}RepositoryImpl implements I{{feature_name.pascalCase()}}Repository {
  const {{feature_name.pascalCase()}}RepositoryImpl(this._remoteDataSource);

  final {{feature_name.pascalCase()}}RemoteDataSource _remoteDataSource;

  // TODO: Implement repository methods
}
```

---

## Example: Bloc Template

```dart
// {{feature_name.snakeCase()}}_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '{{feature_name.snakeCase()}}_event.dart';
import '{{feature_name.snakeCase()}}_state.dart';

@injectable
class {{feature_name.pascalCase()}}Bloc extends Bloc<{{feature_name.pascalCase()}}Event, {{feature_name.pascalCase()}}State> {
  {{feature_name.pascalCase()}}Bloc() : super(const {{feature_name.pascalCase()}}State.initial()) {
    on<{{feature_name.pascalCase()}}Started>(_onStarted);
  }

  Future<void> _onStarted(
    {{feature_name.pascalCase()}}Started event,
    Emitter<{{feature_name.pascalCase()}}State> emit,
  ) async {
    // TODO: Implement
  }
}
```

```dart
// {{feature_name.snakeCase()}}_event.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{{feature_name.snakeCase()}}_event.freezed.dart';

@freezed
class {{feature_name.pascalCase()}}Event with _${{feature_name.pascalCase()}}Event {
  const factory {{feature_name.pascalCase()}}Event.started() = {{feature_name.pascalCase()}}Started;
}
```

```dart
// {{feature_name.snakeCase()}}_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{{feature_name.snakeCase()}}_state.freezed.dart';

@freezed
class {{feature_name.pascalCase()}}State with _${{feature_name.pascalCase()}}State {
  const factory {{feature_name.pascalCase()}}State.initial() = _Initial;
  const factory {{feature_name.pascalCase()}}State.loading() = _Loading;
  const factory {{feature_name.pascalCase()}}State.loaded() = _Loaded;
  const factory {{feature_name.pascalCase()}}State.error(String message) = _Error;
}
```

---

## Post-Generation Hook

**hooks/post_gen.dart:**

```dart
import 'package:mason/mason.dart';
import 'dart:io';

Future<void> run(HookContext context) async {
  final progress = context.logger.progress('Running flutter pub get');
  
  await Process.run(
    'flutter',
    ['pub', 'get'],
    workingDirectory: '{{project_name}}',
  );
  
  progress.complete('Dependencies installed');
  
  // Run build_runner
  final buildProgress = context.logger.progress('Running build_runner');
  
  await Process.run(
    'dart',
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    workingDirectory: '{{project_name}}',
  );
  
  buildProgress.complete('Code generation complete');
}
```

---

## Usage After Creation

```bash
# Add your brick locally
mason add starter_app --path ./bricks/starter_app

# Or publish to BrickHub
mason publish

# Generate new project
mason make starter_app

# Generate new feature in existing project
mason make feature --feature_name payments

# Generate with specific options
mason make feature --feature_name transactions --include_bloc true --include_repository true
```

---

## Included Bricks

```text
┌────────────────────────────────────────────────────────────────┐
│                    INCLUDED MASON BRICKS                       │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  📦  feature          → New feature with all layers + l10n    │
│  📋  entity           → Domain entity with ID extension type  │
│  🔧  use_case         → Application layer use case with DI    │
│  🎨  bloc             → BLoC with events, states, freezed     │
│  🗄️  repository       → Repository interface + implementation │
│  🔒  value_object     → Validated value object with failure   │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## Useful Mason Commands

```bash
# List all installed bricks
mason list

# Get info about a brick
mason info feature

# Update all bricks
mason upgrade

# Remove a brick
mason remove feature

# Bundle brick for distribution
mason bundle --type dart

# Publish to BrickHub (requires account)
mason login
mason publish
```

---

## Resources

- [Mason Documentation](https://docs.brickhub.dev/)
- [BrickHub - Browse Public Bricks](https://brickhub.dev/)
- [Mason GitHub Repository](https://github.com/felangel/mason)
- [Very Good CLI (uses Mason)](https://github.com/VeryGoodOpenSource/very_good_cli)
