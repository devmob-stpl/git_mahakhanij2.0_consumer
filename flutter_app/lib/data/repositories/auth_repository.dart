import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/user.dart';
import '../../domain/auth_api_models.dart';
import '../../l10n/app_localizations.dart';
import '../../core/utils/api_error_localizer.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_checker.dart';
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
  Future<String?> getAuthToken();
  Future<bool> validateUserSession();
  Future<List<User>> getAllUsersForPersonaSwitch();
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

  final MockDb _db;
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;

  AuthRepositoryImpl({
    MockDb? db,
    FlutterSecureStorage? secureStorage,
    Dio? dio,
  })  : _db = db ?? MockDb(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _dio = dio ??
            DioClient.createDio(
              options: BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  AppLocalizations get _l10n => ApiErrorLocalizer.currentLocalizations;

  static User? cachedUser;
  User? get _currentUser => cachedUser;
  set _currentUser(User? user) => cachedUser = user;

  static const String _userStorageKey = 'auth_user';
  static const String _tokenStorageKey = 'auth_token';
  static const String _hasRunBeforeKey = 'has_run_before';

  /// Ensures that on a fresh install or reinstall on iOS, any stale Keychain data
  /// persisting from a previously uninstalled installation is purged.
  Future<void> _ensureFreshInstallSanitized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasRunBefore = prefs.getBool(_hasRunBeforeKey) ?? false;
      if (!hasRunBefore) {
        await _secureStorage.deleteAll();
        await prefs.setBool(_hasRunBeforeKey, true);
        _currentUser = null;
      }
    } catch (_) {}
  }

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
      await prefs.setBool(_hasRunBeforeKey, true);
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
    if (!await NetworkChecker.checkOrNotify()) {
      return LogoutApiResponse(
        statusCode: 'NoInternet',
        statusMessage: _l10n.noInternetConnection,
      );
    }

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
        return LogoutApiResponse(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: parsed.statusMessage),
          responseData: parsed.responseData,
        );
      }

      return LogoutApiResponse(
        statusCode: '500',
        statusMessage: _l10n.invalidResponseFromServer,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = LogoutApiResponse.fromJson(errData);
          if (parsed.isSuccess) {
            await clearSession();
          }
          return LogoutApiResponse(
            statusCode: parsed.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.logoutFailedMsg),
            responseData: parsed.responseData,
          );
        }
      }
      return LogoutApiResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: _l10n.noInternetConnection,
      );
    } catch (e) {
      return LogoutApiResponse(
        statusCode: '500',
        statusMessage: _l10n.logoutFailedMsg,
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
    if (!await NetworkChecker.checkOrNotify()) {
      return UserKeyApiResponse(
        statusCode: 'NoInternet',
        statusMessage: _l10n.noInternetConnection,
      );
    }

    try {
      final url = ApiEndpoints.getUserKeyUrl(mobileNumber);
      final response = await _dio.get(url);

      final data = asResponseMap(response.data);

      if (data != null) {
        final parsed = UserKeyApiResponse.fromJson(data);
        return UserKeyApiResponse(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.serverErrorTryAgain),
          responseData: parsed.responseData,
          responseData1: parsed.responseData1,
        );
      }

      return UserKeyApiResponse(
        statusCode: '500',
        statusMessage: _l10n.invalidResponseFromServer,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = UserKeyApiResponse.fromJson(errData);
          return UserKeyApiResponse(
            statusCode: parsed.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.serverErrorTryAgain),
            responseData: parsed.responseData,
            responseData1: parsed.responseData1,
          );
        }
      }
      return UserKeyApiResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: _l10n.noInternetConnection,
      );
    } catch (e) {
      return UserKeyApiResponse(
        statusCode: '500',
        statusMessage: _l10n.serverErrorTryAgain,
      );
    }
  }

  @override
  Future<VerifyCodeApiResponse> verifyMobileCode({
    required String mobileNumber,
    required String key,
  }) async {
    if (!await NetworkChecker.checkOrNotify()) {
      return VerifyCodeApiResponse(
        statusCode: 'NoInternet',
        statusMessage: _l10n.noInternetConnection,
      );
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final url = ApiEndpoints.getLoginMobileUrl(
          mobileNo: mobileNumber, key: key, version: packageInfo.version);

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
        return VerifyCodeApiResponse(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.loginFailedMsg),
          responseData: parsed.responseData,
          responseData1: parsed.responseData1,
          responseData6: parsed.responseData6,
          responseData7: parsed.responseData7,
        );
      }

      return VerifyCodeApiResponse(
        statusCode: '409',
        statusMessage: _l10n.loginFailedMsg,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = VerifyCodeApiResponse.fromJson(errData);
          return VerifyCodeApiResponse(
            statusCode: parsed.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.loginFailedMsg),
            responseData: parsed.responseData,
            responseData1: parsed.responseData1,
            responseData6: parsed.responseData6,
            responseData7: parsed.responseData7,
          );
        }
      }
      return VerifyCodeApiResponse(
        statusCode: e.response?.statusCode?.toString() ?? '409',
        statusMessage: _l10n.noInternetConnection,
      );
    } catch (e) {
      return VerifyCodeApiResponse(
        statusCode: '409',
        statusMessage: _l10n.loginFailedMsg,
      );
    }
  }
  @override
  Future<ConsumerSignUpResponse> consumerSignUp(Map<String, dynamic> signUpData) async {
    if (!await NetworkChecker.checkOrNotify()) {
      return ConsumerSignUpResponse(
        statusCode: 'NoInternet',
        statusMessage: _l10n.noInternetConnection,
      );
    }

    try {
      final url = ApiEndpoints.consumerSignUp;

      final response = await _dio.post(
        url,
        data: signUpData,
      );

      final data = asResponseMap(response.data);

      if (data != null) {
        final parsed = ConsumerSignUpResponse.fromJson(data);
        return ConsumerSignUpResponse(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.registrationFailed),
          responseData: parsed.responseData,
        );
      }

      return ConsumerSignUpResponse(
        statusCode: '500',
        statusMessage: _l10n.invalidResponseFromServer,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = ConsumerSignUpResponse.fromJson(errData);
          return ConsumerSignUpResponse(
            statusCode: parsed.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.registrationFailed),
            responseData: parsed.responseData,
          );
        }
      }
      return ConsumerSignUpResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: ApiErrorLocalizer.localizeCurrent(e.message, defaultMessage: _l10n.registrationFailed),
      );
    } catch (e) {
      return ConsumerSignUpResponse(
        statusCode: '500',
        statusMessage: _l10n.registrationFailed,
      );
    }
  }
  @override
  Future<ConsumerSignUpResponse> saveUpdateConsumerDetails(Map<String, dynamic> data) async {
    if (!await NetworkChecker.checkOrNotify()) {
      return ConsumerSignUpResponse(
        statusCode: 'NoInternet',
        statusMessage: _l10n.noInternetConnection,
      );
    }

    try {
      final url = ApiEndpoints.saveUpdateConsumerDetails;

      final response = await _dio.post(
        url,
        data: data,
      );

      final respData = asResponseMap(response.data);

      if (respData != null) {
        final parsed = ConsumerSignUpResponse.fromJson(respData);
        return ConsumerSignUpResponse(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.somethingWentWrong),
          responseData: parsed.responseData,
        );
      }

      return ConsumerSignUpResponse(
        statusCode: '500',
        statusMessage: _l10n.invalidResponseFromServer,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = ConsumerSignUpResponse.fromJson(errData);
          return ConsumerSignUpResponse(
            statusCode: parsed.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.somethingWentWrong),
            responseData: parsed.responseData,
          );
        }
      }
      return ConsumerSignUpResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: ApiErrorLocalizer.localizeCurrent(e.message, defaultMessage: _l10n.somethingWentWrong),
      );
    } catch (e) {
      return ConsumerSignUpResponse(
        statusCode: '500',
        statusMessage: _l10n.somethingWentWrong,
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
    if (cachedUser != null) {
      _currentUser = cachedUser;
      return _currentUser;
    }

    await _ensureFreshInstallSanitized();

    if (_currentUser != null) return _currentUser;

    String? userJsonStr;

    try {
      final prefs = await SharedPreferences.getInstance();
      userJsonStr = prefs.getString(_userStorageKey);
    } catch (_) {}

    if (userJsonStr == null || userJsonStr.isEmpty) {
      try {
        userJsonStr = await _secureStorage.read(key: _userStorageKey);
        if (userJsonStr != null && userJsonStr.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userStorageKey, userJsonStr);
        }
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
  Future<String?> getAuthToken() async {
    await _ensureFreshInstallSanitized();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenStorageKey);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}

    try {
      final secureToken = await _secureStorage.read(key: _tokenStorageKey);
      if (secureToken != null && secureToken.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenStorageKey, secureToken);
        return secureToken;
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<bool> validateUserSession() async {
    if (cachedUser != null) {
      _currentUser = cachedUser;
      return true;
    }

    // 1. Sanitize storage on fresh install / reinstall on iOS
    await _ensureFreshInstallSanitized();

    // 2. Retrieve local session
    final user = await getCurrentUser();
    final token = await getAuthToken();

    if (user == null || token == null || token.trim().isEmpty) {
      await clearSession();
      return false;
    }

    if (user.id.isEmpty || user.id == '0') {
      await clearSession();
      return false;
    }

    // 3. Validate user status with backend
    try {
      if (!await NetworkChecker.isConnected()) {
        return true; // Gracefully keep existing session offline
      }
      final appId = user.appId ?? 1;
      final url = ApiEndpoints.getUserAppDetailsUrl(userId: user.id, appId: appId);
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = asResponseMap(response.data);
        if (data != null) {
          final statusCode = data['statusCode']?.toString();
          if (statusCode == '401' || statusCode == '403') {
            await clearSession();
            return false;
          }

          final respData = data['responseData'];
          if (respData is Map<String, dynamic>) {
            final isBlock = respData['isBlock'] == true;
            if (isBlock) {
              await clearSession();
              return false;
            }
          }
        }
        return true;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await clearSession();
        return false;
      }

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        await clearSession();
        return false;
      }
      // If network is offline / connection timeout, allow existing valid session to proceed
      return true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<List<User>> getAllUsersForPersonaSwitch() async {
    return _db.users;
  }

  @override
  Future<ExistenceCheckResult> checkGstExists({
    required String gstNo,
    required String mobileNo,
    int id = 0,
    int userCategory = 2,
  }) async {
    if (!await NetworkChecker.checkOrNotify()) {
      return ExistenceCheckResult(
        statusCode: 'NoInternet',
        statusMessage: _l10n.noInternetConnection,
        exists: false,
      );
    }

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
        final parsed = ExistenceCheckResult.fromJson(data);
        return ExistenceCheckResult(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.gstVerificationFailed),
          exists: parsed.exists,
        );
      }
      return ExistenceCheckResult(
        statusCode: '500',
        statusMessage: _l10n.invalidResponseFromServer,
        exists: false,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = ExistenceCheckResult.fromJson(errData);
          return ExistenceCheckResult(
            statusCode: parsed.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.gstVerificationFailed),
            exists: parsed.exists,
          );
        }
      }
      return ExistenceCheckResult(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: _l10n.noInternetConnection,
        exists: false,
      );
    } catch (e) {
      return ExistenceCheckResult(
        statusCode: '500',
        statusMessage: _l10n.gstVerificationFailed,
        exists: false,
      );
    }
  }

  @override
  Future<GstVerificationResponse> verifyGstin({required String gstNo}) async {
    if (!await NetworkChecker.checkOrNotify()) {
      return GstVerificationResponse(
        statusCode: 'NoInternet',
        statusMessage: _l10n.noInternetConnection,
        isSuccess: false,
      );
    }

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
        final parsed = GstVerificationResponse.fromJson(data, expectedGstin: gstNo);
        return GstVerificationResponse(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.gstVerificationFailed),
          isSuccess: parsed.isSuccess,
          clientId: parsed.clientId,
          gstin: parsed.gstin,
          legalName: parsed.legalName,
          tradeName: parsed.tradeName,
          currentStatus: parsed.currentStatus,
          rawData: parsed.rawData,
        );
      }
      return GstVerificationResponse(
        statusCode: '500',
        statusMessage: _l10n.invalidResponseFromServer,
        isSuccess: false,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = GstVerificationResponse.fromJson(errData, expectedGstin: gstNo);
          return GstVerificationResponse(
            statusCode: parsed.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.gstVerificationFailed),
            isSuccess: parsed.isSuccess,
            clientId: parsed.clientId,
            gstin: parsed.gstin,
            legalName: parsed.legalName,
            tradeName: parsed.tradeName,
            currentStatus: parsed.currentStatus,
            rawData: parsed.rawData,
          );
        }
      }
      return GstVerificationResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: _l10n.noInternetConnection,
        isSuccess: false,
      );
    } catch (e) {
      return GstVerificationResponse(
        statusCode: '500',
        statusMessage: _l10n.gstVerificationFailed,
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
    if (!await NetworkChecker.checkOrNotify()) {
      return ExistenceCheckResult(
        statusCode: 'NoInternet',
        statusMessage: _l10n.noInternetConnection,
        exists: false,
      );
    }

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
        final parsed = ExistenceCheckResult.fromJson(data);
        return ExistenceCheckResult(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.panVerificationFailed),
          exists: parsed.exists,
        );
      }
      return ExistenceCheckResult(
        statusCode: '500',
        statusMessage: _l10n.invalidResponseFromServer,
        exists: false,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = ExistenceCheckResult.fromJson(errData);
          return ExistenceCheckResult(
            statusCode: parsed.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.panVerificationFailed),
            exists: parsed.exists,
          );
        }
      }
      return ExistenceCheckResult(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: _l10n.noInternetConnection,
        exists: false,
      );
    } catch (e) {
      return ExistenceCheckResult(
        statusCode: '500',
        statusMessage: _l10n.panVerificationFailed,
        exists: false,
      );
    }
  }

  @override
  Future<PanVerificationResponse> verifyPan({required String panNo, int userId = 0}) async {
    if (!await NetworkChecker.checkOrNotify()) {
      return PanVerificationResponse(
        statusCode: 'NoInternet',
        statusMessage: _l10n.noInternetConnection,
        isSuccess: false,
      );
    }

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
        final parsed = PanVerificationResponse.fromJson(data, expectedPan: panNo);
        return PanVerificationResponse(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.panVerificationFailed),
          isSuccess: parsed.isSuccess,
          clientId: parsed.clientId,
          panNumber: parsed.panNumber,
          clientName: parsed.clientName,
          clientStatus: parsed.clientStatus,
          rawData: parsed.rawData,
        );
      }
      return PanVerificationResponse(
        statusCode: '500',
        statusMessage: _l10n.invalidResponseFromServer,
        isSuccess: false,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = PanVerificationResponse.fromJson(errData, expectedPan: panNo);
          return PanVerificationResponse(
            statusCode: parsed.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.panVerificationFailed),
            isSuccess: parsed.isSuccess,
            clientId: parsed.clientId,
            panNumber: parsed.panNumber,
            clientName: parsed.clientName,
            clientStatus: parsed.clientStatus,
            rawData: parsed.rawData,
          );
        }
      }
      return PanVerificationResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: _l10n.noInternetConnection,
        isSuccess: false,
      );
    } catch (e) {
      return PanVerificationResponse(
        statusCode: '500',
        statusMessage: _l10n.panVerificationFailed,
        isSuccess: false,
      );
    }
  }
}
