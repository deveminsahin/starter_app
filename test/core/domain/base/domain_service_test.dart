// ignore_for_file: prefer_const_constructors - we want to test the constructor

import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/domain/base/domain_service.dart';

class TestDomainService extends DomainService {
  const TestDomainService();
}

void main() {
  group('DomainService', () {
    test('should be instantiable', () {
      final service = TestDomainService();
      expect(service, isA<DomainService>());
    });
  });
}
