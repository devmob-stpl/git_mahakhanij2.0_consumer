import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/user.dart';
import '../../domain/auth_api_models.dart';
import '../../core/config/app_config.dart';
import '../../core/network/api_endpoints.dart';
import '../mock_db.dart';

abstract class AuthRepository {
  Future<UserKeyApiResponse> sendVerificationCode(String mobileNumber);
  Future<VerifyCodeApiResponse> verifyMobileCode({required String mobileNumber, required String key});
  Future<ConsumerSignUpResponse> consumerSignUp(Map<String, dynamic> signUpData);
  Future<bool> sendOtp(String mobileNumber);
  Future<User?> verifyOtp(String mobileNumber, String otp);
  Future<User?> getCurrentUser();
  Future<List<User>> getAllUsersForPersonaSwitch();
  Future<void> saveSession(User user, [String? token]);
  Future<void> clearSession();
  Future<LogoutApiResponse> logoutUser(String userId);
}


class AuthRepositoryImpl implements AuthRepository {
  final MockDb _db = MockDb();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  User? _currentUser;

  static const String _userStorageKey = 'auth_user';
  static const String _tokenStorageKey = 'auth_token';

  @override
  Future<void> saveSession(User user, [String? token]) async {
    _currentUser = user;
    final userJson = jsonEncode(user.toJson());

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStorageKey, userJson);
      if (token != null && token.isNotEmpty) {
        await prefs.setString(_tokenStorageKey, token);
      }
    } catch (_) {}

    try {
      await _secureStorage.write(key: _userStorageKey, value: userJson);
      if (token != null && token.isNotEmpty) {
        await _secureStorage.write(key: _tokenStorageKey, value: token);
      }
    } catch (_) {}
  }

  @override
  Future<LogoutApiResponse> logoutUser(String userId) async {
    try {
      final appId = _currentUser?.appId ?? 1;
      final url = ApiEndpoints.getLogoutUserUrl(userId: userId, appId: appId);
      final response = await _dio.get(url);

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic>) {
        final parsed = LogoutApiResponse.fromJson(data);
        if (parsed.isSuccess) {
          await clearSession();
        }
        return parsed;
      }

      return const LogoutApiResponse(
        statusCode: '500',
        statusMessage: 'Unexpected response from logout server.',
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        dynamic errData = e.response!.data;
        if (errData is String) {
          try {
            errData = jsonDecode(errData);
          } catch (_) {}
        }
        if (errData is Map<String, dynamic>) {
          final parsed = LogoutApiResponse.fromJson(errData);
          if (parsed.isSuccess) {
            await clearSession();
          }
          return parsed;
        }
      }
      return LogoutApiResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: 'Unable to complete logout. Please check network connection.',
      );
    } catch (e) {
      return LogoutApiResponse(
        statusCode: '500',
        statusMessage: 'Logout failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearSession() async {
    _currentUser = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userStorageKey);
      await prefs.remove(_tokenStorageKey);
    } catch (_) {}

    try {
      await _secureStorage.delete(key: _userStorageKey);
      await _secureStorage.delete(key: _tokenStorageKey);
    } catch (_) {}
  }

  @override
  Future<UserKeyApiResponse> sendVerificationCode(String mobileNumber) async {
    try {
      final url = ApiEndpoints.getUserKeyUrl(mobileNumber);
      final response = await _dio.get(url);

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic>) {
        return UserKeyApiResponse.fromJson(data);
      }

      return const UserKeyApiResponse(
        statusCode: '500',
        statusMessage: 'Unexpected format returned from server.',
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        dynamic errData = e.response!.data;
        if (errData is String) {
          try {
            errData = jsonDecode(errData);
          } catch (_) {}
        }
        if (errData is Map<String, dynamic>) {
          return UserKeyApiResponse.fromJson(errData);
        }
      }
      return UserKeyApiResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: 'Unable to connect to Mahakhanij server. Please check network connection.',
      );
    } catch (e) {
      return UserKeyApiResponse(
        statusCode: '500',
        statusMessage: 'An error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<VerifyCodeApiResponse> verifyMobileCode({
    required String mobileNumber,
    required String key,
  }) async {
    try {
      final url = ApiEndpoints.getLoginMobileUrl(
          mobileNo: mobileNumber, key: key);
      final response = await _dio.get(url);

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic>) {
        final parsed = VerifyCodeApiResponse.fromJson(data);
        if (parsed.isSuccess && parsed.responseData != null &&
            parsed.responseData!.isNotEmpty) {
          final loginData = parsed.responseData!.first;
          final userData = parsed.responseData7!.first;
          final resolvedConsumerId = loginData.consumerId > 0 ? loginData.consumerId : loginData.userId;
          
          int? extractedAppId;
          if (parsed.responseData1 != null && parsed.responseData1 is List && (parsed.responseData1 as List).isNotEmpty) {
            final firstItem = (parsed.responseData1 as List).first;
            if (firstItem is Map<String, dynamic> && firstItem['appId'] != null) {
              extractedAppId = firstItem['appId'] is int ? firstItem['appId'] as int : int.tryParse(firstItem['appId'].toString());
            }
          }

          _currentUser = User(
            id: loginData.userId.toString(),
            consumerId: resolvedConsumerId > 0 ? resolvedConsumerId : null,
            fullName: userData.name,
            mobileNumber: userData.mobileNo,
            userType: (!AppConfig.enableOrganizationFlow ||
                loginData.isConsumer) ? UserType.normalConsumer : UserType
                .organization,
            createdAt: DateTime.now().toIso8601String(),
            appId: extractedAppId,
          );
          await saveSession(_currentUser!, key);
        }
        return parsed;
      }

      return VerifyCodeApiResponse(
        statusCode: '409',
        statusMessage: 'Login Failed with MobileNo: $mobileNumber',
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        dynamic errData = e.response!.data;
        if (errData is String) {
          try {
            errData = jsonDecode(errData);
          } catch (_) {}
        }
        if (errData is Map<String, dynamic>) {
          return VerifyCodeApiResponse.fromJson(errData);
        }
      }
      return VerifyCodeApiResponse(
        statusCode: e.response?.statusCode?.toString() ?? '409',
        statusMessage: 'Login Failed with MobileNo: $mobileNumber',
      );
    } catch (e) {
      return VerifyCodeApiResponse(
        statusCode: '409',
        statusMessage: 'Login Failed with MobileNo: $mobileNumber',
      );
    }
  }
  @override
  Future<ConsumerSignUpResponse> consumerSignUp(Map<String, dynamic> signUpData) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.consumerSignUp,
        data: signUpData,
      );

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic>) {
        final parsed = ConsumerSignUpResponse.fromJson(data);
        if (parsed.isSuccess) {
          // Do not save session or auto-login on signup. 
          // The user must explicitly login afterwards.
        }
        return parsed;
      }

      return const ConsumerSignUpResponse(
        statusCode: '500',
        statusMessage: 'Unexpected response from registration server.',
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        dynamic errData = e.response!.data;
        if (errData is String) {
          try {
            errData = jsonDecode(errData);
          } catch (_) {}
        }
        if (errData is Map<String, dynamic>) {
          return ConsumerSignUpResponse.fromJson(errData);
        }
      }
      return ConsumerSignUpResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: 'Registration failed: ${e.message}',
      );
    } catch (e) {
      return ConsumerSignUpResponse(
        statusCode: '500',
        statusMessage: 'An error occurred during registration: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> sendOtp(String mobileNumber) async {

    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<User?> verifyOtp(String mobileNumber, String otp) async {
    final response = await verifyMobileCode(mobileNumber: mobileNumber, key: otp);
    if (response.isSuccess && _currentUser != null) {
      await saveSession(_currentUser!, otp);
      return _currentUser;
    }

    // Fallback logic for mock users if API response is negative
    try {
      _currentUser = _db.users.firstWhere((u) => u.mobileNumber == mobileNumber);
      await saveSession(_currentUser!, otp);
      return _currentUser;
    } catch (_) {
      _currentUser = _db.users.first;
      await saveSession(_currentUser!, otp);
      return _currentUser;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    String? userJsonStr;

    try {
      final prefs = await SharedPreferences.getInstance();
      userJsonStr = prefs.getString(_userStorageKey);
    } catch (_) {}

    if (userJsonStr == null || userJsonStr.isEmpty) {
      try {
        userJsonStr = await _secureStorage.read(key: _userStorageKey);
      } catch (_) {}
    }

    if (userJsonStr != null && userJsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(userJsonStr);
        _currentUser = User.fromJson(jsonMap);
        return _currentUser;
      } catch (_) {}
    }

    return null;
  }

  @override
  Future<List<User>> getAllUsersForPersonaSwitch() async {
    return _db.users;
  }
}
