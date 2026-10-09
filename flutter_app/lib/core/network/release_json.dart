import 'dart:convert';

/// Dio 5 decodes JSON bodies at or above 50 KB with `compute(jsonDecode)`.
/// In a release (AOT) build, maps that cross that isolate come back as
/// `Map<dynamic, dynamic>`. `is Map<String, dynamic>` is then false, so
/// profile and other large responses are discarded. Debug (JIT) keeps the
/// generic type, which is why the same call succeeds there.
///
/// Rebuild every map and list on this isolate so model `fromJson` checks
/// see `Map<String, dynamic>` in both build modes. Values are unchanged.
dynamic normalizeJson(dynamic value) {
  if (value is Map) {
    return <String, dynamic>{
      for (final entry in value.entries)
        entry.key.toString(): normalizeJson(entry.value),
    };
  }
  if (value is List) {
    return <dynamic>[for (final item in value) normalizeJson(item)];
  }
  return value;
}

/// Accepts a Dio `response.data` value: a JSON string, or a map produced
/// either on the main isolate or by the background transformer.
Map<String, dynamic>? asResponseMap(dynamic data) {
  var value = data;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    try {
      value = jsonDecode(trimmed);
    } catch (_) {
      return null;
    }
  }
  final normalized = normalizeJson(value);
  if (normalized is Map<String, dynamic>) return normalized;
  return null;
}
