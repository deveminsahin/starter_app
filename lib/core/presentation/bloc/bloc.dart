/// Core presentation BLoC/Cubit exports.
///
/// Provides centralized access to cross-cutting presentation state management:
/// - AppBlocObserver: Global BLoC event and state logging
/// - ThemeCubit: Dynamic theme switching with persistence
/// - LocaleCubit: Language/locale management with persistence
///
/// These cubits are in `core/presentation/` because:
/// 1. They manage presentation state (UI concerns)
/// 2. They are cross-cutting (used by all features)
/// 3. They have no domain logic (pure UI state)
///
/// Configuration data remains in their respective directories:
/// - Theme configuration → `core/theme/`
/// - Localization resources → `core/l10n/`
library;

export 'app_bloc_observer.dart';
export 'locale_cubit.dart';
export 'theme_cubit.dart';
