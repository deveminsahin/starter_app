import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/base/specification.dart';

class GreaterThanSpecification extends Specification<int> {
  GreaterThanSpecification(this.threshold);
  final int threshold;

  @override
  bool isSatisfiedBy(int candidate) => candidate > threshold;
}

void main() {
  group('Specification', () {
    final gt5 = GreaterThanSpecification(5);
    final gt10 = GreaterThanSpecification(10);

    test('isSatisfiedBy returns correct result', () {
      expect(gt5.isSatisfiedBy(6), isTrue);
      expect(gt5.isSatisfiedBy(4), isFalse);
    });

    test('and() combines specifications with AND logic', () {
      final spec = gt5.and(gt10);

      expect(spec.isSatisfiedBy(11), isTrue); // > 5 AND > 10
      expect(spec.isSatisfiedBy(6), isFalse); // > 5 but NOT > 10
      expect(spec.isSatisfiedBy(4), isFalse); // Neither
    });

    test('or() combines specifications with OR logic', () {
      // Note: This specific example
      // (x > 5 OR x > 10) is logically equivalent to x > 5,
      // but let's test a disjoint case for clarity, e.g. < 5 OR > 10.

      final spec = gt5.or(gt10);

      expect(
        spec.isSatisfiedBy(6),
        isTrue,
      ); // > 5 (True) OR > 10 (False) -> True
      expect(spec.isSatisfiedBy(11), isTrue); // True OR True -> True
      expect(spec.isSatisfiedBy(4), isFalse); // False OR False -> False
    });

    test('toNot() inverts specification logic', () {
      final notGt5 = gt5.toNot();

      expect(notGt5.isSatisfiedBy(4), isTrue);
      expect(notGt5.isSatisfiedBy(6), isFalse);
    });

    test('complex chaining', () {
      // (x > 5 AND x < 10) OR x == 20
      // We don't have equals, so let's use:
      // (x > 5 AND NOT x > 10)

      final range5to10 = gt5.and(gt10.toNot());

      expect(range5to10.isSatisfiedBy(7), isTrue);
      expect(range5to10.isSatisfiedBy(4), isFalse);
      expect(range5to10.isSatisfiedBy(11), isFalse);
    });
  });
}
