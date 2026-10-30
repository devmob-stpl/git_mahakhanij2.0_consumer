import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import 'network_checker.dart';

/// Interceptor that verifies mobile network or internet connectivity before making every API call.
/// If the device is offline, prevents the request from reaching the network and displays
/// an appropriate error message in the currently selected language.
class ConnectivityInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final isOnline = await NetworkChecker.isConnected(options.uri.host);
    if (!isOnline) {
      NetworkChecker.showOfflineMessage();
      return handler.reject(
        DioException(
          requestOptions: options,
          error: NetworkChecker.offlineMessage,
          message: NetworkChecker.offlineMessage,
          type: DioExceptionType.connectionError,
        ),
      );
    }
    return handler.next(options);
  }
}

/// Production-ready Dio HTTP Client
/// Handles JWT Bearer token attachment, request timeouts, pre-flight connectivity checks, and error handling.
class DioClient {
  late final Dio dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  DioClient() {
    dio = createDio(
      options: BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach Bearer Token if user is authenticated
          final token = await _secureStorage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
            await _secureStorage.delete(key: 'auth_user');
            await _secureStorage.delete(key: 'auth_token');
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Creates a standard Dio instance configured with [ConnectivityInterceptor]
  /// to ensure connectivity is checked before every API request.
  static Dio createDio({BaseOptions? options, List<Interceptor>? extraInterceptors}) {
    final instance = Dio(
      options ??
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
    );
    instance.interceptors.add(ConnectivityInterceptor());
    if (extraInterceptors != null && extraInterceptors.isNotEmpty) {
      instance.interceptors.addAll(extraInterceptors);
    }
    return instance;
  }
}
