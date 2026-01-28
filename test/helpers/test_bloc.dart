import 'package:flutter_bloc/flutter_bloc.dart';

/// Test Bloc implementation for testing BLoC observer.
///
/// Simple test implementation used in BLoC observer tests
/// to verify logging and state management behavior.
class TestBloc extends Bloc<String, String> {
  TestBloc() : super('initial') {
    on<String>((event, emit) => emit('updated'));
  }
}
