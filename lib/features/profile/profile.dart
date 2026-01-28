/// Profile feature module.
///
/// This feature handles all profile-related functionality including:
/// - User profile display
/// - Profile editing
/// - Avatar/photo management
/// - Account information
///
/// ## Structure
///
/// Following the feature-first architecture:
/// - `domain/` - Profile business entities and repository interfaces
/// - `application/` - Profile use cases (GetProfile, UpdateProfile)
/// - `infrastructure/` - Profile repository and data source implementations
/// - `presentation/` - Profile UI (BLoC, pages, widgets)
library;

// Application
export 'application/usecases/get_profile.dart';
// Domain
export 'domain/entities/profile_id.dart';
export 'domain/entities/user_profile.dart';
export 'domain/events/profile_events.dart';
export 'domain/failure/profile_failure.dart';
export 'domain/repositories/i_user_profile_repository.dart';
// Infrastructure
export 'infrastructure/repositories/user_profile_repository_impl.dart';
// Presentation
export 'presentation/bloc/profile_bloc.dart';
export 'presentation/bloc/profile_event.dart';
export 'presentation/bloc/profile_state.dart';
export 'presentation/pages/profile_page.dart';
export 'presentation/widgets/login_button.dart';
