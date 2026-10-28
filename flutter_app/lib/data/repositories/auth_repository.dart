import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/globals.dart';
import '../../domain/user.dart';
import '../../domain/auth_api_models.dart';
import '../../l10n/app_localizations.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/release_json.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../mock_db.dart';

abstract class AuthRepository {
  Future<UserKeyApiResponse> sendVerificationCode(String mobileNumber);
  Future<VerifyCodeApiResponse> verifyMobileCode({required String mobileNumber, required String key});
  Future<ConsumerSignUpResponse> consumerSignUp(Map<String, dynamic> signUpData);
  Future<ConsumerSignUpResponse> consumerProfileUpdate(Map<String, dynamic> signUpData);
  Future<ConsumerSignUpResponse> saveUpdateConsumerDetails(Map<String, dynamic> data);
  Future<bool> sendOtp(String mobileNumber);
  Future<User?> verifyOtp(String mobileNumber, String otp);
  Future<User?> getCurrentUser();
  Future<void> saveSession(User user, [String? token]);
  Future<void> clearSession();
  Future<LogoutApiResponse> logoutUser(String userId);
  Future<ExistenceCheckResult> checkGstExists({
    required String gstNo,
    required String mobileNo,
    int id = 0,
    int userCategory = 2,
  });
  Future<GstVerificationResponse> verifyGstin({required String gstNo});
  Future<ExistenceCheckResult> checkPanExists({
    required String panNo,
    required String mobileNo,
    int id = 0,
    int userCategory = 2,
  });
  Future<PanVerificationResponse> verifyPan({required String panNo, int userId = 0});
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

  static User? cachedUser;

  User? get _currentUser => cachedUser;
  set _currentUser(User? user) => cachedUser = user;

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

      final data = asResponseMap(response.data);

      if (data != null) {
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
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
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

      // Pre-flight internet check
      try {
        final result = await InternetAddress.lookup(Uri.parse(url).host);
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw const SocketException('No Internet');
        }
      } on SocketException catch (_) {
        final ctx = scaffoldMessengerKey.currentContext;
        final msg = ctx != null ? AppLocalizations.of(ctx)?.noInternetConnection ?? 'No Internet Connection' : 'No Internet Connection';
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return UserKeyApiResponse(
          statusCode: 'NoInternet',
          statusMessage: msg,
        );
      }

      final response = await _dio.get(url);

      final data = asResponseMap(response.data);

      if (data != null) {
        return UserKeyApiResponse.fromJson(data);
      }

      return const UserKeyApiResponse(
        statusCode: '500',
        statusMessage: 'Unexpected format returned from server.',
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          return UserKeyApiResponse.fromJson(errData);
        }
      }
      return UserKeyApiResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: 'Unable to login. Please check internet connection.',
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
      final packageInfo = await PackageInfo.fromPlatform();
      final url = ApiEndpoints.getLoginMobileUrl(
          mobileNo: mobileNumber, key: key, version: packageInfo.version);
          
      // Pre-flight internet check
      try {
        final result = await InternetAddress.lookup(Uri.parse(url).host);
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw const SocketException('No Internet');
        }
      } on SocketException catch (_) {
        final ctx = scaffoldMessengerKey.currentContext;
        final msg = ctx != null ? AppLocalizations.of(ctx)?.noInternetConnection ?? 'No Internet Connection' : 'No Internet Connection';
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return VerifyCodeApiResponse(
          statusCode: 'NoInternet',
          statusMessage: msg,
        );
      }

      final response = await _dio.get(url);

      final data = asResponseMap(response.data);

      if (data != null) {
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
            userType: loginData.isConsumer ? UserType.normalConsumer : UserType.organization,
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
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
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
      final url = ApiEndpoints.consumerSignUp;

      // Pre-flight internet check
      try {
        final result = await InternetAddress.lookup(Uri.parse(url).host);
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw const SocketException('No Internet');
        }
      } on SocketException catch (_) {
        final ctx = scaffoldMessengerKey.currentContext;
        final msg = ctx != null ? AppLocalizations.of(ctx)?.noInternetConnection ?? 'No Internet Connection' : 'No Internet Connection';
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return ConsumerSignUpResponse(
          statusCode: 'NoInternet',
          statusMessage: msg,
        );
      }

      final response = await _dio.post(
        url,
        data: signUpData,
      );

      final data = asResponseMap(response.data);

      if (data != null) {
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
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
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
  Future<ConsumerSignUpResponse> saveUpdateConsumerDetails(Map<String, dynamic> data) async {
    try {
      final url = ApiEndpoints.saveUpdateConsumerDetails;

      // Pre-flight internet check
      try {
        final result = await InternetAddress.lookup(Uri.parse(url).host);
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw const SocketException('No Internet');
        }
      } on SocketException catch (_) {
        final ctx = scaffoldMessengerKey.currentContext;
        final msg = ctx != null ? AppLocalizations.of(ctx)?.noInternetConnection ?? 'No Internet Connection' : 'No Internet Connection';
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return ConsumerSignUpResponse(
          statusCode: 'NoInternet',
          statusMessage: msg,
        );
      }

      final response = await _dio.post(
        url,
        data: data,
      );

      final respData = asResponseMap(response.data);

      if (respData != null) {
        final parsed = ConsumerSignUpResponse.fromJson(respData);
        return parsed;
      }

      return const ConsumerSignUpResponse(
        statusCode: '500',
        statusMessage: 'Unexpected response from server.',
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          return ConsumerSignUpResponse.fromJson(errData);
        }
      }
      return ConsumerSignUpResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: 'Operation failed: ${e.message}',
      );
    } catch (e) {
      return ConsumerSignUpResponse(
        statusCode: '500',
        statusMessage: 'An error occurred during operation: ${e.toString()}',
      );
    }
  }

  @override
  Future<ConsumerSignUpResponse> consumerProfileUpdate(Map<String, dynamic> signUpData) async {
    return saveUpdateConsumerDetails(signUpData);
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
  Future<ExistenceCheckResult> checkGstExists({
    required String gstNo,
    required String mobileNo,
    int id = 0,
    int userCategory = 2,
  }) async {
    try {
      final url = ApiEndpoints.getCheckGstExistsUrl(
        gstNo: gstNo,
        mobileNo: mobileNo,
        id: id,
        userCategory: userCategory,
      );
      final response = await _dio.get(url);
      final data = asResponseMap(response.data);
      if (data != null) {
        return ExistenceCheckResult.fromJson(data);
      }
      return const ExistenceCheckResult(
        statusCode: '500',
        statusMessage: 'Invalid response from GST verification service.',
        exists: false,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          return ExistenceCheckResult.fromJson(errData);
        }
      }
      return ExistenceCheckResult(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: 'Network error checking GST existence.',
        exists: false,
      );
    } catch (e) {
      return ExistenceCheckResult(
        statusCode: '500',
        statusMessage: 'Failed to check GST existence: ${e.toString()}',
        exists: false,
      );
    }
  }

  @override
  Future<GstVerificationResponse> verifyGstin({required String gstNo}) async {
    try {
      final url = ApiEndpoints.verifyGstin;
      final response = await _dio.post(
        url,
        data: {
          'id_number': gstNo,
        },
      );
      final data = asResponseMap(response.data);
      if (data != null) {
        return GstVerificationResponse.fromJson(data, expectedGstin: gstNo);
      }
      return const GstVerificationResponse(
        statusCode: '500',
        statusMessage: 'Invalid response from GST verification service.',
        isSuccess: false,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          return GstVerificationResponse.fromJson(errData, expectedGstin: gstNo);
        }
      }
      return GstVerificationResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: 'Network error verifying GSTIN.',
        isSuccess: false,
      );
    } catch (e) {
      return GstVerificationResponse(
        statusCode: '500',
        statusMessage: 'GST verification failed: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  @override
  Future<ExistenceCheckResult> checkPanExists({
    required String panNo,
    required String mobileNo,
    int id = 0,
    int userCategory = 2,
  }) async {
    try {
      final url = ApiEndpoints.getCheckPanExistsUrl(
        panNo: panNo,
        mobileNo: mobileNo,
        id: id,
        userCategory: userCategory,
      );
      final response = await _dio.get(url);
      final data = asResponseMap(response.data);
      if (data != null) {
        return ExistenceCheckResult.fromJson(data);
      }
      return const ExistenceCheckResult(
        statusCode: '500',
        statusMessage: 'Invalid response from PAN verification service.',
        exists: false,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          return ExistenceCheckResult.fromJson(errData);
        }
      }
      return ExistenceCheckResult(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: 'Network error checking PAN existence.',
        exists: false,
      );
    } catch (e) {
      return ExistenceCheckResult(
        statusCode: '500',
        statusMessage: 'Failed to check PAN existence: ${e.toString()}',
        exists: false,
      );
    }
  }

  @override
  Future<PanVerificationResponse> verifyPan({required String panNo, int userId = 0}) async {
    try {
      final url = ApiEndpoints.verifyPan;
      final response = await _dio.post(
        url,
        data: {
          'id_number': panNo,
          'userId': userId,
        },
      );
      final data = asResponseMap(response.data);
      if (data != null) {
        return PanVerificationResponse.fromJson(data, expectedPan: panNo);
      }
      return const PanVerificationResponse(
        statusCode: '500',
        statusMessage: 'Invalid response from PAN verification service.',
        isSuccess: false,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          return PanVerificationResponse.fromJson(errData, expectedPan: panNo);
        }
      }
      return PanVerificationResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: 'Network error verifying PAN.',
        isSuccess: false,
      );
    } catch (e) {
      return PanVerificationResponse(
        statusCode: '500',
        statusMessage: 'PAN verification failed: ${e.toString()}',
        isSuccess: false,
      );
    }
  }
}
