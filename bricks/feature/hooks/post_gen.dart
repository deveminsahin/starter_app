import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final featureName = context.vars['feature_name'] as String;
  final logger = context.logger;

  logger.info('');
  logger.info('🎉 Feature "$featureName" created successfully!');
  logger.info('');

  // Run code generation
  final buildRunnerProgress = logger.progress('Running build_runner...');

  try {
    final result = await Process.run(
      'dart',
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      runInShell: true,
    );

    if (result.exitCode == 0) {
      buildRunnerProgress.complete('Code generation complete');
    } else {
      buildRunnerProgress.fail('Code generation failed');
      logger.err(result.stderr.toString());
    }
  } catch (e) {
    buildRunnerProgress.fail('Failed to run build_runner: $e');
  }

  // Print next steps
  logger.info('');
  logger.info('📋 Next steps:');
  logger.info('');
  logger.info('1. Add the route to your app_router.dart:');
  logger.info(
    '   import \'package:starter_app/features/$featureName/presentation/routes/${featureName}_routes.dart\';',
  );
  logger.info('');
  logger.info('2. Register the failure mapper in your DI module');
  logger.info('');
  logger.info('3. Implement your use cases in:');
  logger.info('   lib/features/$featureName/application/usecases/');
  logger.info('');
  logger.info('4. Customize the entity properties and repository methods');
  logger.info('');
  logger.info('5. Run tests:');
  logger.info('   very_good test --coverage');
  logger.info('');
}
