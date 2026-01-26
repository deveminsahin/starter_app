import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:starter_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:starter_app/features/settings/presentation/widgets/logout_button.dart';

import '../../../../helpers/mock_helpers.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(const AuthEvent.logoutRequested());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget buildLogoutButton() {
    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: const LogoutButton(),
    );
  }

  group('LogoutButton', () {
    testWidgets('renders nothing when unauthenticated', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthState.empty());

      await tester.pumpApp(buildLogoutButton());

      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('renders button when authenticated', (tester) async {
      final user = TestData.user();
      when(() => mockAuthBloc.state).thenReturn(AuthState.authenticated(user));

      await tester.pumpApp(buildLogoutButton());

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('displays localized logout text', (tester) async {
      final user = TestData.user();
      when(() => mockAuthBloc.state).thenReturn(AuthState.authenticated(user));

      await tester.pumpApp(buildLogoutButton());

      expect(find.widgetWithText(ElevatedButton, 'Log out'), findsOneWidget);
    });

    testWidgets('dispatches logout event when tapped', (tester) async {
      final user = TestData.user();
      when(() => mockAuthBloc.state).thenReturn(AuthState.authenticated(user));

      await tester.pumpApp(buildLogoutButton());

      final logoutButton = find.widgetWithText(ElevatedButton, 'Log out');
      await tester.tap(logoutButton);
      await tester.pump();

      verify(
        () => mockAuthBloc.add(any(that: isA<AuthLogoutRequested>())),
      ).called(1);
    });
  });
}
