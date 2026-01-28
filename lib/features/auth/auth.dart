/// Authentication feature module.
///
/// Provides authentication functionality including login, registration,
/// token management, and user profile operations.
///
/// This feature follows the feature-first architecture pattern with
/// all layers co-located in the auth directory.
library;

// Application
export 'application/usecases/check_user_exists.dart';
export 'application/usecases/get_current_user.dart';
export 'application/usecases/login.dart';
export 'application/usecases/logout.dart';
export 'application/usecases/refresh_token.dart';
export 'application/usecases/register.dart';
export 'application/usecases/watch_auth_changes.dart';
export 'application/usecases/watch_session_expired.dart';
// Domain
export 'domain/entities/auth_credentials.dart';
export 'domain/entities/user.dart';
export 'domain/entities/user_id.dart';
export 'domain/events/auth_events.dart';
export 'domain/failure/auth_failure.dart';
export 'domain/repositories/i_auth_repository.dart';
export 'domain/services/user_registration_service.dart';
export 'domain/value_objects/auth_token.dart';
export 'domain/value_objects/refresh_token.dart';
export 'domain/value_objects/token_failure.dart';
// Infrastructure
export 'infrastructure/datasources/auth_api_service.dart';
export 'infrastructure/datasources/auth_endpoints.dart';
export 'infrastructure/models/auth_response_model.dart';
export 'infrastructure/models/auth_tokens_model.dart';
export 'infrastructure/models/check_user_exists_request_model.dart';
export 'infrastructure/models/check_user_exists_response_model.dart';
export 'infrastructure/models/login_request_model.dart';
export 'infrastructure/models/register_request_model.dart';
export 'infrastructure/models/user_model.dart';
