import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/core/infrastructure/storage/secure_storage_impl.dart';

import '../../helpers/mock_helpers.dart';

void main() {
  group('SecureStorageImpl', () {
    late MockFlutterSecureStorage mockStorage;
    late SecureStorageImpl secureStorage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      secureStorage = SecureStorageImpl(mockStorage);
    });

    group('write', () {
      test('writes value to secure storage with given key', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(
          () => mockStorage.write(key: key, value: value),
        ).thenAnswer((_) async {});

        // Act
        await secureStorage.write(key: key, value: value);

        // Assert
        verify(() => mockStorage.write(key: key, value: value)).called(1);
      });

      test('writes different key-value pairs', () async {
        // Arrange
        const key1 = 'user_id';
        const value1 = '12345';
        const key2 = 'auth_token';
        const value2 = 'eyJhbGc...';

        when(
          () => mockStorage.write(key: key1, value: value1),
        ).thenAnswer((_) async {});
        when(
          () => mockStorage.write(key: key2, value: value2),
        ).thenAnswer((_) async {});

        // Act
        await secureStorage.write(key: key1, value: value1);
        await secureStorage.write(key: key2, value: value2);

        // Assert
        verify(() => mockStorage.write(key: key1, value: value1)).called(1);
        verify(() => mockStorage.write(key: key2, value: value2)).called(1);
      });

      test('overwrites existing value for same key', () async {
        // Arrange
        const key = 'token';
        const oldValue = 'old_token';
        const newValue = 'new_token';

        when(
          () => mockStorage.write(
            key: key,
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        // Act
        await secureStorage.write(key: key, value: oldValue);
        await secureStorage.write(key: key, value: newValue);

        // Assert
        verify(() => mockStorage.write(key: key, value: oldValue)).called(1);
        verify(() => mockStorage.write(key: key, value: newValue)).called(1);
      });
    });

    group('read', () {
      test('reads value from secure storage with given key', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(() => mockStorage.read(key: key)).thenAnswer((_) async => value);

        // Act
        final result = await secureStorage.read(key: key);

        // Assert
        expect(result, value);
        verify(() => mockStorage.read(key: key)).called(1);
      });

      test('returns null when key does not exist', () async {
        // Arrange
        const key = 'nonexistent_key';
        when(() => mockStorage.read(key: key)).thenAnswer((_) async => null);

        // Act
        final result = await secureStorage.read(key: key);

        // Assert
        expect(result, null);
        verify(() => mockStorage.read(key: key)).called(1);
      });

      test('reads different keys independently', () async {
        // Arrange
        const key1 = 'key1';
        const value1 = 'value1';
        const key2 = 'key2';
        const value2 = 'value2';

        when(() => mockStorage.read(key: key1)).thenAnswer((_) async => value1);
        when(() => mockStorage.read(key: key2)).thenAnswer((_) async => value2);

        // Act
        final result1 = await secureStorage.read(key: key1);
        final result2 = await secureStorage.read(key: key2);

        // Assert
        expect(result1, value1);
        expect(result2, value2);
      });
    });

    group('delete', () {
      test('deletes value from secure storage with given key', () async {
        // Arrange
        const key = 'test_key';
        when(() => mockStorage.delete(key: key)).thenAnswer((_) async {});

        // Act
        await secureStorage.delete(key: key);

        // Assert
        verify(() => mockStorage.delete(key: key)).called(1);
      });

      test('deletes multiple keys independently', () async {
        // Arrange
        const key1 = 'key1';
        const key2 = 'key2';

        when(() => mockStorage.delete(key: key1)).thenAnswer((_) async {});
        when(() => mockStorage.delete(key: key2)).thenAnswer((_) async {});

        // Act
        await secureStorage.delete(key: key1);
        await secureStorage.delete(key: key2);

        // Assert
        verify(() => mockStorage.delete(key: key1)).called(1);
        verify(() => mockStorage.delete(key: key2)).called(1);
      });

      test('deleting non-existent key does not throw', () async {
        // Arrange
        const key = 'nonexistent_key';
        when(() => mockStorage.delete(key: key)).thenAnswer((_) async {});

        // Act & Assert
        await expectLater(
          secureStorage.delete(key: key),
          completes,
        );
        verify(() => mockStorage.delete(key: key)).called(1);
      });
    });

    group('deleteAll', () {
      test('deletes all values from secure storage', () async {
        // Arrange
        when(() => mockStorage.deleteAll()).thenAnswer((_) async {});

        // Act
        await secureStorage.deleteAll();

        // Assert
        verify(() => mockStorage.deleteAll()).called(1);
      });

      test('deleteAll can be called multiple times', () async {
        // Arrange
        when(() => mockStorage.deleteAll()).thenAnswer((_) async {});

        // Act
        await secureStorage.deleteAll();
        await secureStorage.deleteAll();

        // Assert
        verify(() => mockStorage.deleteAll()).called(2);
      });
    });

    group('integration scenarios', () {
      test('write then read returns the written value', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        String? storedValue;

        when(
          () => mockStorage.write(key: key, value: value),
        ).thenAnswer((_) async {
          storedValue = value;
        });
        when(() => mockStorage.read(key: key)).thenAnswer((_) async {
          return storedValue;
        });

        // Act
        await secureStorage.write(key: key, value: value);
        final result = await secureStorage.read(key: key);

        // Assert
        expect(result, value);
      });

      test('write then delete then read returns null', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        String? storedValue;

        when(
          () => mockStorage.write(key: key, value: value),
        ).thenAnswer((_) async {
          storedValue = value;
        });
        when(() => mockStorage.delete(key: key)).thenAnswer((_) async {
          storedValue = null;
        });
        when(() => mockStorage.read(key: key)).thenAnswer((_) async {
          return storedValue;
        });

        // Act
        await secureStorage.write(key: key, value: value);
        await secureStorage.delete(key: key);
        final result = await secureStorage.read(key: key);

        // Assert
        expect(result, null);
      });

      test('deleteAll removes all stored values', () async {
        // Arrange
        const key1 = 'key1';
        const value1 = 'value1';
        const key2 = 'key2';
        const value2 = 'value2';

        final storage = <String, String>{};

        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((invocation) async {
          final key = invocation.namedArguments[#key] as String;
          final value = invocation.namedArguments[#value] as String;
          storage[key] = value;
        });

        when(() => mockStorage.deleteAll()).thenAnswer((_) async {
          storage.clear();
        });

        when(() => mockStorage.read(key: any(named: 'key'))).thenAnswer((
          invocation,
        ) async {
          final key = invocation.namedArguments[#key] as String;
          return storage[key];
        });

        // Act
        await secureStorage.write(key: key1, value: value1);
        await secureStorage.write(key: key2, value: value2);
        await secureStorage.deleteAll();
        final result1 = await secureStorage.read(key: key1);
        final result2 = await secureStorage.read(key: key2);

        // Assert
        expect(result1, null);
        expect(result2, null);
      });
    });
  });
}
