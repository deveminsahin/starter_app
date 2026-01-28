# Performance Benchmarks

This directory contains performance benchmarks for critical operations.

## Running Benchmarks

```bash
# Run all benchmarks
flutter test test/benchmarks/ --reporter expanded

# Run specific benchmark
flutter test test/benchmarks/startup_benchmark_test.dart --reporter expanded

# Run with timing details
flutter test test/benchmarks/ --reporter expanded 2>&1 | grep -E "(benchmark|ms|μs)"
```

## Benchmark Categories

### 1. Startup Benchmark (`startup_benchmark_test.dart`)
Measures app initialization time including:
- Dependency injection setup
- Router initialization
- Initial BLoC creation

### 2. Widget Build Benchmark (`widget_build_benchmark_test.dart`)
Measures widget build performance for:
- Auth page (complex form)
- Home page (dashboard)
- Settings page (list items)

### 3. Repository Operations (`repository_benchmark_test.dart`)
Measures data layer performance:
- Token storage read/write
- JSON serialization/deserialization
- Model transformations

## Baseline Metrics

| Operation | Target | Acceptable |
|-----------|--------|------------|
| DI Setup | < 100ms | < 200ms |
| Auth Page Build | < 16ms | < 32ms |
| Token Read | < 5ms | < 10ms |
| JSON Parse | < 1ms | < 5ms |

## Adding New Benchmarks

Follow this pattern:

```dart
test('benchmark: operation name', () async {
  final stopwatch = Stopwatch()..start();
  
  // Operation to benchmark
  await operation();
  
  stopwatch.stop();
  
  // Log for CI tracking
  // ignore: avoid_print
  print('BENCHMARK: operation_name = ${stopwatch.elapsedMilliseconds}ms');
  
  // Assert performance threshold
  expect(stopwatch.elapsedMilliseconds, lessThan(100));
});
```

## CI Integration

Add to `.github/workflows/main.yaml`:

```yaml
benchmark:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
    - run: flutter test test/benchmarks/ --reporter expanded
```
