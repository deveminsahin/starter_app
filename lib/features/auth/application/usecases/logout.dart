import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import 'package:starter_app/core/domain/base/command.dart';
import 'package:starter_app/core/types/types.dart';
import 'package:starter_app/features/auth/domain/repositories/i_auth_repository.dart';

/// Command for ending the current user session.
///
/// This is a **write operation** (Command) that mutates application state
/// by invalidating the authenticated session.
///
/// Invalidates tokens on backend and clears local session.
/// No validation needed as logout is always allowed.
///
/// ## Flow
/// 1. Call repository to invalidate session on backend
/// 2. Repository clears stored tokens locally
/// 3. Repository disposes WebSocket connection
///
/// **Note:** Auth state changes are communicated via WebSocket events
/// (session_expired, user_logged_out) which the BLoC handles.
///
/// Example:
/// ```dart
/// final result = await logout();
/// result.fold(
///   (failure) => emit(AuthState.error(failure)),
///   (_) => emit(AuthState.unauthenticated()),
/// );
/// ```
@injectable
class Logout extends CommandNoParams<Unit> {
  const Logout(this._repository);

  final IAuthRepository _repository;

  /// Ends the current user session.
  ///
  /// Returns:
  /// - [Right(Unit)] on successful logout
  /// - [Left(Failure)] if logout fails
  @override
  FutureResult<Unit> call() => _repository.logout();
}
