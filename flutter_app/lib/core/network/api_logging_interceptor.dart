import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that displays the API URL, request body, and API response
/// in debug logs for every API call to simplify debugging and troubleshooting.
///
/// Features:
/// - Displays HTTP method, sanitized URL, headers, and request body on request.
/// - Displays HTTP status code, elapsed time, sanitized URL, and response body on response.
/// - Displays status code, error type, message, and error response body on failure.
/// - Recursively masks sensitive fields (passwords, tokens, OTPs, Aadhaar, PAN, keys, secrets, etc.)
///   in URLs, query parameters, request headers, request bodies, and responses.
/// - Handles [FormData] gracefully without dumping binary streams.
/// - Strictly disabled in production builds ([kReleaseMode] == true or [kDebugMode] == false).
class ApiLoggingInterceptor extends Interceptor {
  /// Whether logging is enabled. Defaults to [kDebugMode].
  final bool enabled;

  /// Custom log printer callback. Defaults to [debugPrint].
  final void Function(String message) logPrint;

  /// For testing purposes to simulate debug mode in test environments.
  @visibleForTesting
  final bool forceEnableForTesting;

  /// Maximum characters to print for body payloads to prevent console buffer overflows.
  final int maxPayloadLength;

  ApiLoggingInterceptor({
    this.enabled = true,
    void Function(String message)? logPrint,
    this.forceEnableForTesting = false,
    this.maxPayloadLength = 20000,
  }) : logPrint = logPrint ?? debugPrint;

  /// Determines if logging should execute.
  /// Always returns false in production/release builds unless explicitly forced in unit tests.
  bool get shouldLog {
    if (kReleaseMode && !forceEnableForTesting) {
      return false;
    }
    if (!kDebugMode && !forceEnableForTesting) {
      return false;
    }
    return enabled;
  }

  // Set of normalized sensitive keys that must always be masked
  static const Set<String> _exactSensitiveKeys = {
    'password',
    'confirmpassword',
    'oldpassword',
    'newpassword',
    'currentpassword',
    'passcode',
    'pin',
    'mpin',
    'otp',
    'smsotp',
    'emailotp',
    'otpcode',
    'token',
    'authtoken',
    'accesstoken',
    'refreshtoken',
    'idtoken',
    'sessiontoken',
    'sessionid',
    'authorization',
    'secret',
    'clientsecret',
    'apikey',
    'key',
    'userkey',
    'activationkey',
    'activationkey1',
    'activationkey2',
    'acivationkey1',
    'acivationkey2',
    'privatekey',
    'aadhaar',
    'aadhaarno',
    'aadhaarcardno',
    'aadhaarnumber',
    'aadhar',
    'aadharno',
    'aadharcardno',
    'aadharnumber',
    'idnumber',
    'uid',
    'pan',
    'panno',
    'pancard',
    'pancardno',
    'pannumber',
    'gstin',
    'gstno',
    'cvv',
    'cvv2',
    'cvc',
    'cardnumber',
    'accountnumber',
    'accountno',
    'bankaccount',
    'cookie',
    'setcookie',
  };

  static const List<String> _sensitiveSubstrings = [
    'password',
    'passcode',
    'mpin',
    'token',
    'secret',
    'aadhaar',
    'aadhar',
    'otp',
    'cvv',
    'apikey',
    'activationkey',
    'acivationkey',
  ];

  /// Checks if a key name corresponds to sensitive information that must be masked.
  static bool isSensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (normalized.isEmpty) return false;
    if (_exactSensitiveKeys.contains(normalized)) return true;
    for (final sub in _sensitiveSubstrings) {
      if (normalized.contains(sub)) return true;
    }
    // PAN variations (e.g. panNo, panNumber, userPan, panCard)
    if (normalized == 'pan' ||
        normalized.startsWith('pan') ||
        normalized.endsWith('pan') ||
        normalized.contains('panno') ||
        normalized.contains('pannumber')) {
      return true;
    }
    // Key variations (e.g. userKey, secretKey, authKey)
    if (normalized == 'key' || normalized.endsWith('key')) {
      return true;
    }
    // ID number (Aadhaar / PAN id_number / idNo)
    if (normalized == 'idnumber' || normalized == 'idno') {
      return true;
    }
    // Authorization header/tokens
    if (normalized == 'authorization' || normalized.contains('authtoken')) {
      return true;
    }
    return false;
  }

  /// Sanitizes a URI by masking sensitive query parameter values.
  static Uri sanitizeUri(Uri uri) {
    if (!uri.hasQuery) return uri;
    final sanitizedParams = <String, List<String>>{};
    uri.queryParametersAll.forEach((key, values) {
      if (isSensitiveKey(key)) {
        sanitizedParams[key] = values.map((_) => '[MASKED]').toList();
      } else {
        sanitizedParams[key] = values;
      }
    });
    return uri.replace(queryParameters: sanitizedParams);
  }

  /// Formats a sanitized URI as a human-readable URL string.
  static String sanitizeUrlString(Uri uri) {
    final sanitized = sanitizeUri(uri);
    return Uri.decodeFull(sanitized.toString());
  }

  /// Sanitizes request/response headers by masking sensitive values.
  static Map<String, dynamic> sanitizeHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      final lowerKey = key.toLowerCase();
      if (isSensitiveKey(key) ||
          lowerKey == 'authorization' ||
          lowerKey == 'cookie' ||
          lowerKey == 'set-cookie') {
        if (value is List) {
          return MapEntry(
            key,
            value.map((v) {
              final str = v.toString();
              return str.toLowerCase().startsWith('bearer ')
                  ? 'Bearer [MASKED]'
                  : '[MASKED]';
            }).toList(),
          );
        }
        final strVal = value.toString();
        if (strVal.toLowerCase().startsWith('bearer ')) {
          return MapEntry(key, 'Bearer [MASKED]');
        }
        return MapEntry(key, '[MASKED]');
      }
      return MapEntry(key, value);
    });
  }

  /// Recursively sanitizes data (Map, List, FormData, JSON String, primitives)
  /// by masking sensitive keys.
  static dynamic sanitizeData(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      return data.map((key, value) {
        final keyStr = key.toString();
        if (isSensitiveKey(keyStr)) {
          return MapEntry(key, '[MASKED]');
        }
        return MapEntry(key, sanitizeData(value));
      });
    }

    if (data is List) {
      return data.map((item) => sanitizeData(item)).toList();
    }

    if (data is FormData) {
      final fields = <String, dynamic>{};
      for (final field in data.fields) {
        fields[field.key] =
            isSensitiveKey(field.key) ? '[MASKED]' : field.value;
      }
      final files = <String, dynamic>{};
      for (final file in data.files) {
        files[file.key] =
            '[File: ${file.value.filename ?? 'unknown'}, ${file.value.length} bytes]';
      }
      return {
        'type': 'FormData',
        'fields': fields,
        'files': files,
      };
    }

    if (data is String) {
      final trimmed = data.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          final decoded = jsonDecode(trimmed);
          return sanitizeData(decoded);
        } catch (_) {
          // Not valid JSON, keep as string
        }
      }
    }

    return data;
  }

  /// Formats data into a formatted, readable JSON or string representation.
  String formatPayload(dynamic data) {
    if (data == null) return '(empty)';
    final sanitized = sanitizeData(data);
    String result;
    if (sanitized is Map || sanitized is List) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        result = encoder.convert(sanitized);
      } catch (_) {
        result = sanitized.toString();
      }
    } else {
      result = sanitized.toString();
    }
    if (result.length > maxPayloadLength) {
      return '${result.substring(0, maxPayloadLength)}\n... [truncated, total ${result.length} characters]';
    }
    return result;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!shouldLog) {
      return handler.next(options);
    }

    try {
      options.extra['_api_log_start_time'] =
          DateTime.now().millisecondsSinceEpoch;

      final method = options.method.toUpperCase();
      final url = sanitizeUrlString(options.uri);
      final sanitizedHeaders = sanitizeHeaders(options.headers);
      final body = formatPayload(options.data);

      final buffer = StringBuffer();
      buffer.writeln('┌── [HTTP Request] $method $url');
      if (sanitizedHeaders.isNotEmpty) {
        buffer.writeln('│ Headers: $sanitizedHeaders');
      }
      if (options.queryParameters.isNotEmpty) {
        final sanitizedQueryParams = sanitizeData(options.queryParameters);
        buffer.writeln('│ Query Parameters: $sanitizedQueryParams');
      }
      buffer.writeln('│ Body:');
      for (final line in body.split('\n')) {
        buffer.writeln('│   $line');
      }
      buffer.write('└── [END HTTP Request]');

      logPrint(buffer.toString());
    } catch (e) {
      // Logging should never crash or interrupt the network request
      logPrint('[HTTP Request Logging Error] $e');
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!shouldLog) {
      return handler.next(response);
    }

    try {
      final startTime =
          response.requestOptions.extra['_api_log_start_time'] as int?;
      final duration = startTime != null
          ? '${DateTime.now().millisecondsSinceEpoch - startTime} ms'
          : 'unknown ms';

      final statusCode = response.statusCode ?? 0;
      final statusMessage = response.statusMessage ?? '';
      final method = response.requestOptions.method.toUpperCase();
      final url = sanitizeUrlString(response.requestOptions.uri);
      final body = formatPayload(response.data);

      final buffer = StringBuffer();
      buffer.writeln(
          '┌── [HTTP Response] $statusCode $statusMessage ($duration) $method $url');
      buffer.writeln('│ Body:');
      for (final line in body.split('\n')) {
        buffer.writeln('│   $line');
      }
      buffer.write('└── [END HTTP Response]');

      logPrint(buffer.toString());
    } catch (e) {
      // Logging should never crash or interrupt the response flow
      logPrint('[HTTP Response Logging Error] $e');
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!shouldLog) {
      return handler.next(err);
    }

    try {
      final startTime = err.requestOptions.extra['_api_log_start_time'] as int?;
      final duration = startTime != null
          ? '${DateTime.now().millisecondsSinceEpoch - startTime} ms'
          : 'unknown ms';

      final statusCode = err.response?.statusCode;
      final statusText = statusCode != null ? '$statusCode ' : '';
      final method = err.requestOptions.method.toUpperCase();
      final url = sanitizeUrlString(err.requestOptions.uri);
      final errorType = err.type.name;
      final errorMessage =
          err.message ?? err.error?.toString() ?? 'Unknown error';

      final buffer = StringBuffer();
      buffer.writeln('┌── [HTTP Error] $statusText($duration) $method $url');
      buffer.writeln('│ Type: $errorType');
      buffer.writeln('│ Message: $errorMessage');
      if (err.response?.data != null) {
        final body = formatPayload(err.response!.data);
        buffer.writeln('│ Response Body:');
        for (final line in body.split('\n')) {
          buffer.writeln('│   $line');
        }
      }
      buffer.write('└── [END HTTP Error]');

      logPrint(buffer.toString());
    } catch (e) {
      // Logging should never crash or interrupt the error flow
      logPrint('[HTTP Error Logging Error] $e');
    }

    return handler.next(err);
  }
}
