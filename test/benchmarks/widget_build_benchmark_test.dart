import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/value_objects/email_address.dart';
import 'package:starter_app/core/domain/value_objects/password.dart';
import 'package:starter_app/core/presentation/widgets/app_text_field.dart';
import 'package:starter_app/core/presentation/widgets/email_text_field.dart';
import 'package:starter_app/core/presentation/widgets/password_text_field.dart';

/// Widget build performance benchmarks.
///
/// These tests measure the time taken to build key widgets.
/// The first test serves as a warm-up for the Flutter framework.
/// Run with: `flutter test test/benchmarks/widget_build_benchmark_test.dart`
void main() {
  group('Widget Build Benchmarks', () {
    Widget buildTestApp(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      );
    }

    // This test runs first to warm up the Flutter framework
    // Its timing should be ignored - it absorbs the JIT compilation cost
    testWidgets('warm-up: framework initialization (ignore timing)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          const AppTextField(
            label: 'Warm-up',
            hint: 'This run is for framework warm-up',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify warm-up completed
      expect(find.byType(AppTextField), findsOneWidget);
    });

    testWidgets('benchmark: AppTextField build (post-warmup)', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        buildTestApp(
          const AppTextField(
            label: 'Email',
            hint: 'Enter your email',
          ),
        ),
      );

      stopwatch.stop();

      // Benchmark output for CI tracking
      // ignore: avoid_print
      print(
        'BENCHMARK: app_text_field_build = '
        '${stopwatch.elapsedMilliseconds}ms',
      );

      // Post-warmup build should be much faster (< 50ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      expect(find.byType(AppTextField), findsOneWidget);
    });

    testWidgets('benchmark: EmailTextField build', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        buildTestApp(
          const EmailTextField(
            email: EmailAddress.empty,
            showError: false,
          ),
        ),
      );

      stopwatch.stop();

      // Benchmark output for CI tracking
      // ignore: avoid_print
      print(
        'BENCHMARK: email_text_field_build = '
        '${stopwatch.elapsedMilliseconds}ms',
      );

      // Widget should build in < 50ms
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      expect(find.byType(EmailTextField), findsOneWidget);
    });

    testWidgets('benchmark: PasswordTextField build', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        buildTestApp(
          const PasswordTextField(
            password: Password.empty,
            showError: false,
            obscureText: true,
          ),
        ),
      );

      stopwatch.stop();

      // Benchmark output for CI tracking
      // ignore: avoid_print
      print(
        'BENCHMARK: password_text_field_build = '
        '${stopwatch.elapsedMilliseconds}ms',
      );

      // Widget should build in < 50ms
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      expect(find.byType(PasswordTextField), findsOneWidget);
    });

    testWidgets('benchmark: form with 4 fields build', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        buildTestApp(
          const Column(
            children: [
              AppTextField(label: 'Name', hint: 'Enter name'),
              SizedBox(height: 8),
              EmailTextField(
                email: EmailAddress.empty,
                showError: false,
              ),
              SizedBox(height: 8),
              PasswordTextField(
                password: Password.empty,
                showError: false,
                obscureText: true,
              ),
              SizedBox(height: 8),
              AppTextField(label: 'Phone', hint: 'Enter phone'),
            ],
          ),
        ),
      );

      stopwatch.stop();

      // Benchmark output for CI tracking
      // ignore: avoid_print
      print(
        'BENCHMARK: form_with_4_fields_build = '
        '${stopwatch.elapsedMilliseconds}ms',
      );

      // Form should build in < 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      // 2 explicit AppTextField + 2 from Email/PasswordTextField
      expect(find.byType(AppTextField), findsNWidgets(4));
      expect(find.byType(EmailTextField), findsOneWidget);
      expect(find.byType(PasswordTextField), findsOneWidget);
    });

    testWidgets('benchmark: widget rebuild x10', (tester) async {
      var counter = 0;
      late StateSetter setState;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setStateLocal) {
              setState = setStateLocal;
              return Scaffold(
                body: AppTextField(
                  label: 'Counter: $counter',
                  hint: 'Value will change',
                ),
              );
            },
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Trigger 10 rebuilds
      for (var i = 0; i < 10; i++) {
        setState(() => counter++);
        await tester.pump();
      }

      stopwatch.stop();

      // Benchmark output for CI tracking
      // ignore: avoid_print
      print(
        'BENCHMARK: widget_rebuild_x10 = ${stopwatch.elapsedMilliseconds}ms',
      );

      // 10 rebuilds should be fast (< 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(counter, equals(10));
    });

    testWidgets('benchmark: widget tree depth', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const Column(
            children: [
              AppTextField(label: 'Field 1', hint: 'Hint 1'),
              SizedBox(height: 8),
              EmailTextField(
                email: EmailAddress.empty,
                showError: false,
              ),
              SizedBox(height: 8),
              PasswordTextField(
                password: Password.empty,
                showError: false,
                obscureText: true,
              ),
            ],
          ),
        ),
      );

      // Count widgets in tree
      var widgetCount = 0;
      for (final _ in tester.allWidgets) {
        widgetCount++;
      }

      // Benchmark output for CI tracking
      // ignore: avoid_print
      print('BENCHMARK: form_widget_count = $widgetCount widgets');

      // Form should have reasonable widget count (< 500)
      expect(widgetCount, lessThan(500));
    });
  });
}
