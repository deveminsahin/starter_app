import 'package:injectable/injectable.dart';
import 'package:starter_app/core/domain/ports/i_data_filter.dart';

/// Implementation of [IDataFilter] for filtering sensitive data.
///
/// Filters common sensitive fields like passwords, tokens, etc.
/// before data is sent to external systems.
///
/// **Sensitive keys detected:**
/// - password, token, authorization, auth
/// - api_key, apikey, secret, credential
/// - credit_card, creditcard, ssn, social_security
/// - pin, cvv, card_number, cardnumber
@LazySingleton(as: IDataFilter)
class SensitiveDataFilter implements IDataFilter {
  /// Creates a SensitiveDataFilter.
  const SensitiveDataFilter();

  /// List of terms that indicate sensitive data.
  ///
  /// Keys containing any of these terms (case-insensitive) will be redacted.
  static const List<String> sensitiveTerms = [
    'password',
    'token',
    'authorization',
    'auth',
    'api_key',
    'apikey',
    'secret',
    'credential',
    'credit_card',
    'creditcard',
    'ssn',
    'social_security',
    'pin',
    'cvv',
    'card_number',
    'cardnumber',
  ];

  /// The string used to replace sensitive values.
  static const String redactedValue = '***REDACTED***';

  @override
  Map<String, dynamic> filter(Map<String, dynamic> data) {
    final filtered = <String, dynamic>{};

    for (final entry in data.entries) {
      if (shouldFilter(entry.key)) {
        filtered[entry.key] = redactedValue;
      } else if (entry.value is Map<String, dynamic>) {
        // Recursively filter nested maps
        filtered[entry.key] = filter(entry.value as Map<String, dynamic>);
      } else if (entry.value is List) {
        // Recursively filter lists that may contain maps
        filtered[entry.key] = _filterList(entry.value as List<dynamic>);
      } else {
        filtered[entry.key] = entry.value;
      }
    }

    return filtered;
  }

  /// Recursively filters a list, handling nested maps and lists.
  List<dynamic> _filterList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return filter(item);
      } else if (item is List) {
        return _filterList(item);
      }
      return item;
    }).toList();
  }

  @override
  bool shouldFilter(String key) {
    final lowerKey = key.toLowerCase();
    return sensitiveTerms.any(lowerKey.contains);
  }
}
