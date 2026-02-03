import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/di/modules/navigation_module.dart';
import 'package:starter_app/core/logging/i_app_logger.dart';
import 'package:starter_app/core/navigation/app_router.dart';
import 'package:starter_app/core/navigation/page_builder.dart';

import '../../../helpers/mock_helpers.dart';

class TestNavigationModule extends NavigationModule {}

void main() {
  group('NavigationModule', () {
    late TestNavigationModule module;
    late MockAppLogger mockLogger;

    setUp(() {
      module = TestNavigationModule();
      mockLogger = MockAppLogger();
      // Register mock logger because DashboardBranch accesses it via GetIt
      if (!GetIt.I.isRegistered<IAppLogger>()) {
        GetIt.I.registerSingleton<IAppLogger>(mockLogger);
      }
    });

    tearDown(() async {
      await GetIt.I.reset();
    });

    group('providePageBuilder', () {
      test('should return CustomTransitionPageBuilder', () {
        final builder = module.providePageBuilder();
        expect(builder, isA<CustomTransitionPageBuilder>());
        expect(builder, isA<PageBuilder>());
      });
    });

    group('provideGoRouter', () {
      test('should return GoRouter from AppRouter', () {
        const pageBuilder = CustomTransitionPageBuilder();
        final mockAuthChangeNotifier = MockAuthChangeNotifier();

        when(() => mockAuthChangeNotifier.isAuthenticated).thenReturn(false);

        final router = AppRouter(pageBuilder, mockAuthChangeNotifier);

        final goRouter = module.provideGoRouter(router);
        expect(goRouter, isA<GoRouter>());
        expect(goRouter, router.routerConfig);
      });
    });
  });
}
