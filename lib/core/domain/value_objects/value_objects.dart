/// Domain-specific value objects.
///
/// This folder contains value objects that are shared across multiple features.
/// Feature-specific value objects should
/// remain in their respective feature folders.
///
/// Each value object should:
/// - Encapsulate its own validation logic
/// - Define its own specific failure types
/// (if needed beyond generic ValueFailure)
/// - Be immutable
/// - Extend the [ValueObject] base class
library;

import 'package:starter_app/core/domain/base/value_object.dart';

export 'email_address.dart';
export 'image_url.dart';
export 'name.dart';
export 'password.dart';
