import 'package:flutter_bloc/flutter_bloc.dart';

/// Test Cubit implementation for testing BLoC observer.
///
/// Simple test implementation used in BLoC observer tests
/// to verify logging and state management behavior.
class TestCubit extends Cubit<String> {
  TestCubit() : super('initial');
}
