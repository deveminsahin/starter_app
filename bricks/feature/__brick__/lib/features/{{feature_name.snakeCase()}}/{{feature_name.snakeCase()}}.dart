/// {{feature_name.titleCase()}} feature module.
///
/// This feature handles all {{feature_name.snakeCase()}}-related functionality.
///
/// ## Structure
///
/// Following the feature-first architecture:
/// - `domain/` - Business entities and repository interfaces
/// - `application/` - Use cases
/// - `infrastructure/` - Repository and data source implementations
/// - `presentation/` - UI (BLoC, pages, widgets)
library;

// Application
// export 'application/usecases/...';

// Domain
export 'domain/entities/{{feature_name.snakeCase()}}.dart';
export 'domain/entities/{{feature_name.snakeCase()}}_id.dart';
export 'domain/events/{{feature_name.snakeCase()}}_events.dart';
export 'domain/failure/{{feature_name.snakeCase()}}_failure.dart';
export 'domain/repositories/i_{{feature_name.snakeCase()}}_repository.dart';

// Infrastructure
export 'infrastructure/repositories/{{feature_name.snakeCase()}}_repository_impl.dart';

// Presentation
export 'presentation/bloc/{{feature_name.snakeCase()}}_bloc.dart';
export 'presentation/bloc/{{feature_name.snakeCase()}}_event.dart';
export 'presentation/bloc/{{feature_name.snakeCase()}}_state.dart';
export 'presentation/pages/{{feature_name.snakeCase()}}_page.dart';
