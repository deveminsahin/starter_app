import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/domain/base/domain_event.dart';
import 'package:starter_app/core/domain/base/event_dispatcher.dart';
import 'package:starter_app/core/domain/ports/i_secure_storage.dart';
import 'package:starter_app/core/domain/ports/i_session_manager.dart';
import 'package:starter_app/core/domain/ports/i_token_storage.dart';
import 'package:starter_app/core/logging/i_app_logger.dart';
import 'package:starter_app/core/navigation/app_router.dart';
import 'package:starter_app/core/navigation/auth_change_notifier.dart';
import 'package:starter_app/core/navigation/page_builder.dart';
import 'package:starter_app/core/presentation/bloc/bloc.dart';
import 'package:starter_app/core/presentation/failure_message/failure_mapper_registry.dart';
import 'package:starter_app/core/presentation/services/failure_message_service.dart';
import 'package:starter_app/core/theme/app_theme.dart';
import 'package:starter_app/features/auth/domain/entities/user.dart';
import 'package:starter_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:starter_app/features/auth/infrastructure/datasources/auth_api_service.dart';
import 'package:starter_app/features/auth/infrastructure/datasources/auth_remote_data_source.dart';
import 'package:starter_app/features/auth/infrastructure/datasources/auth_websocket_data_source.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:starter_app/features/profile/domain/repositories/i_user_profile_repository.dart';
import 'package:starter_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:starter_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:starter_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'test_data.dart';

class MockAppLogger extends Mock implements IAppLogger {}

class MockStorage extends Mock implements Storage {}

// Navigation mocks
class MockAppRouter extends Mock implements AppRouter {}

class MockPageBuilder extends Mock implements PageBuilder {}

class MockAuthChangeNotifier extends Mock implements AuthChangeNotifier {}

class MockGoRouterState extends Mock implements GoRouterState {
  @override
  final String name = 'mock_route';

  @override
  final ValueKey<String> pageKey = const ValueKey('mock_key');
}

class MockTokenStorage extends Mock implements ITokenStorage {}

class MockSecureStorage extends Mock implements ISecureStorage {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// Network mocks
class MockChain extends Mock implements Chain<dynamic> {}

class MockAuthApiService extends Mock implements AuthApiService {}

final class MockChopperClient extends ChopperClient with Mock {
  MockChopperClient() : super(baseUrl: Uri.parse('http://test.com'));
}

// Auth mocks
class MockAuthRepository extends Mock implements IAuthRepository {}

class MockAuthRemoteDataSource extends Mock implements IAuthRemoteDataSource {}

class MockAuthWebSocketDataSource extends Mock
    implements IAuthWebSocketDataSource {}

// Domain mocks
class MockEventDispatcher extends Mock implements IEventDispatcher {}

// Profile mocks
class MockUserProfileRepository extends Mock
    implements IUserProfileRepository {}

// User mocks
class MockUser extends Mock implements User {}

// BLoC / Cubit mocks
class MockThemeCubit extends MockCubit<AppThemeMode> implements ThemeCubit {}

class MockLocaleCubit extends MockCubit<AppLocale> implements LocaleCubit {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

// Presentation mocks
class MockAppTheme extends Mock implements AppTheme {}

class MockFailureMapperRegistry extends Mock implements FailureMapperRegistry {}

class MockFailureMessageService extends Mock implements FailureMessageService {}

class MockBuildContext extends Mock implements BuildContext {}

// WebSocket mocks
class MockWebSocketChannel extends Mock implements WebSocketChannel {}

class MockWebSocketSink extends Mock implements WebSocketSink {}

class MockSessionManager extends Mock implements ISessionManager {}

/// A fake WebSocket channel for testing that provides controllable streams.
class FakeWebSocketChannel extends Fake implements WebSocketChannel {
  FakeWebSocketChannel({
    this.shouldReadyComplete = true,
    this.readyDelay = Duration.zero,
    this.readyError,
    FakeWebSocketSink? customSink,
  }) : _sink = customSink ?? FakeWebSocketSink();

  final StreamController<dynamic> _streamController =
      StreamController<dynamic>.broadcast();
  final FakeWebSocketSink _sink;
  final bool shouldReadyComplete;
  final Duration readyDelay;
  final Object? readyError;

  @override
  Stream<dynamic> get stream => _streamController.stream;

  @override
  WebSocketSink get sink => _sink;

  @override
  Future<void> get ready async {
    if (readyDelay > Duration.zero) {
      await Future<void>.delayed(readyDelay);
    }
    if (readyError != null) {
      throw WebSocketChannelException();
    }
    if (!shouldReadyComplete) {
      await Completer<void>().future; // Never completes
    }
  }

  /// Add a message to the stream (simulates receiving a message)
  void addMessage(dynamic message) {
    if (!_streamController.isClosed) {
      _streamController.add(message);
    }
  }

  /// Add an error to the stream (simulates a WebSocket error)
  void addError(Object error, [StackTrace? stackTrace]) {
    if (!_streamController.isClosed) {
      _streamController.addError(error, stackTrace);
    }
  }

  /// Close the stream (simulates connection closed)
  Future<void> closeStream() async {
    await _streamController.close();
  }

  /// Get sent messages
  List<dynamic> get sentMessages => _sink.messages;
}

/// A fake WebSocket sink for testing.
class FakeWebSocketSink extends Fake implements WebSocketSink {
  FakeWebSocketSink({this.errorOnAdd});

  final List<dynamic> messages = [];
  bool isClosed = false;
  int? closeCode;
  String? closeReason;

  /// If set, calling add() will throw this exception
  final Exception? errorOnAdd;

  @override
  void add(dynamic data) {
    final error = errorOnAdd;
    if (error != null) {
      throw error;
    }
    if (!isClosed) {
      messages.add(data);
    }
  }

  @override
  Future<void> close([int? code, String? reason]) async {
    isClosed = true;
    closeCode = code;
    closeReason = reason;
  }
}

/// Fake domain event for testing event dispatcher.
class FakeDomainEvent extends Fake implements DomainEvent {}

/// Register fallback values for mocktail.
///
/// Call this once in `setUpAll()` of your test file.
/// This centralizes all common fallback value registrations.
///
/// Example:
/// ```dart
/// void main() {
///   setUpAll(() {
///     registerMockFallbackValues();
///   });
/// }
/// ```
void registerMockFallbackValues() {
  // Theme and locale
  registerFallbackValue(AppThemeMode.light);
  registerFallbackValue(AppLocale.en);

  // Auth state
  registerFallbackValue(AuthState.empty());

  // Auth credentials and params
  registerFallbackValue(TestData.loginCredentials());
  registerFallbackValue(TestData.emailAddress());
  registerFallbackValue(TestData.passwordVO());
  registerFallbackValue(TestData.nameVO());

  // Domain events
  registerFallbackValue(FakeDomainEvent());
}
