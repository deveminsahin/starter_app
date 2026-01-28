import 'package:starter_app/core/domain/value_objects/email_address.dart';
import 'package:starter_app/features/auth/domain/entities/user.dart';
import 'package:starter_app/features/auth/domain/entities/user_id.dart';

/// Test data constants for integration tests.
class IntegrationTestData {
  /// Test email address.
  static const email = 'test@example.com';

  /// Test password.
  static const password = 'Test123!@#';

  /// Test user name.
  static const name = 'John Doe';

  /// Test user ID.
  static const userId = 'user-123';

  /// Creates a test User entity.
  static User get user => User(
    id: UserId.fromString(userId),
    email: EmailAddress.fromTrustedSource(email),
  );
}
