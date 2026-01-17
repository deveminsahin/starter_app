/// Generic interface for secure key-value storage.
///
/// This is a **port** in hexagonal architecture - it defines the contract
/// that the application expects from secure storage infrastructure.
///
/// Implementations (adapters) handle the actual secure storage mechanism
/// (e.g., Keychain on iOS, EncryptedSharedPreferences on Android).
///
/// Usage:
/// ```dart
/// // Write a value
/// await secureStorage.write(key: 'api_key', value: 'secret123');
///
/// // Read a value
/// final apiKey = await secureStorage.read(key: 'api_key');
///
/// // Delete a value
/// await secureStorage.delete(key: 'api_key');
/// ```
abstract interface class ISecureStorage {
  /// Writes a [value] to secure storage, associated with a [key].
  Future<void> write({required String key, required String value});

  /// Reads the value from secure storage for the given [key].
  ///
  /// Returns the value if it exists, otherwise returns null.
  Future<String?> read({required String key});

  /// Deletes the value from secure storage for the given [key].
  Future<void> delete({required String key});

  /// Deletes all keys and values from secure storage.
  ///
  /// Use with caution.
  Future<void> deleteAll();
}
