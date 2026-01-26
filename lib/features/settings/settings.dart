/// Settings feature module.
///
/// This feature handles all settings-related functionality including:
/// - Theme preferences
/// - Language selection
/// - Notification settings
/// - Account settings
///
/// ## Structure
///
/// Following the feature-first architecture:
/// - `presentation/pages/` - Settings UI pages
/// - Future: `domain/` - Settings business logic
/// - Future: `application/` - Settings use cases
/// - Future: `infrastructure/` - Settings data persistence
library;

export 'presentation/pages/settings_page.dart';
