import 'dart:async';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_checker.dart';
import '../../core/network/release_json.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_endpoints.dart';
import '../../domain/aadhaar_kyc_models.dart';
import '../../l10n/app_localizations.dart';
import '../../core/utils/api_error_localizer.dart';

abstract class AadhaarKycRepository {
  Future<AadhaarExistResponse> checkAadhaarExists(String aadhaarNo, {String? mobileNo});
  Future<GenerateAadhaarOtpResponse> generateAadhaarOtp(String aadhaarNo, {int createdBy = 0});
  Future<VerifyAadhaarOtpResponse> submitAadhaarOtp({
    required String clientId,
    required String otp,
    required String mobileNumber,
    int createdBy = 0,
  });
  Future<AadhaarDocumentUploadResponse> uploadAadhaarDocument({
    required String filePath,
    String? fileName,
    List<int>? bytes,
  });
}

class AadhaarKycRepositoryImpl implements AadhaarKycRepository {
  final Dio _dio;

  AadhaarKycRepositoryImpl({Dio? dio})
      : _dio = dio ??
            DioClient.createDio(
              options: BaseOptions(
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            );

  AppLocalizations get _l10n => ApiErrorLocalizer.currentLocalizations;

  @override
  Future<AadhaarExistResponse> checkAadhaarExists(String aadhaarNo, {String? mobileNo}) async {
    if (!await NetworkChecker.checkOrNotify()) {
      return AadhaarExistResponse(
        statusCode: 'NoInternet',
        statusMessage: _l10n.noInternetConnection,
        exists: false,
        id: 0,
      );
    }

    try {
      final url = ApiEndpoints.getCheckAadhaarExistsUrl(aadhaarNo, mobileNo: mobileNo);
      final response = await _dio.get(url);

      final data = asResponseMap(response.data);

      if (data != null) {
        final parsed = AadhaarExistResponse.fromJson(data);
        return AadhaarExistResponse(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.aadhaarServerError),
          exists: parsed.exists,
          id: parsed.id,
        );
      }

      return AadhaarExistResponse(
        statusCode: '500',
        statusMessage: _l10n.aadhaarServerError,
        exists: false,
        id: 0,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.response?.statusCode == 408 ||
          e.response?.statusCode == 504 ||
          (e.response?.statusCode != null && e.response!.statusCode! >= 500)) {
        return AadhaarExistResponse(
          statusCode: '408',
          statusMessage: _l10n.connectionTimeout,
          exists: false,
          id: 0,
        );
      }
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = AadhaarExistResponse.fromJson(errData);
          return AadhaarExistResponse(
            statusCode: parsed.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.aadhaarServerError),
            exists: parsed.exists,
            id: parsed.id,
          );
        }
      }
      return AadhaarExistResponse(
        statusCode: '500',
        statusMessage: _l10n.aadhaarServerError,
        exists: false,
        id: 0,
      );
    } catch (e) {
      return AadhaarExistResponse(
        statusCode: '500',
        statusMessage: _l10n.aadhaarServerError,
        exists: false,
        id: 0,
      );
    }
  }

  @override
  Future<GenerateAadhaarOtpResponse> generateAadhaarOtp(String aadhaarNo, {int createdBy = 0}) async {
    if (!await NetworkChecker.checkOrNotify()) {
      return GenerateAadhaarOtpResponse(
        statusCode: 'NoInternet',
        statusMessage: _l10n.noInternetConnection,
        message: _l10n.noInternetConnection,
        isSuccess: false,
      );
    }

    try {
      final url = ApiEndpoints.generateAadhaarOtp;
      final response = await _dio.post(
        url,
        data: {
          'id_number': aadhaarNo,
          'createdBy': createdBy,
        },
      );

      final data = asResponseMap(response.data);

      if (data != null) {
        final parsed = GenerateAadhaarOtpResponse.fromJson(data);
        return GenerateAadhaarOtpResponse(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.aadhaarServerError),
          message: ApiErrorLocalizer.localizeCurrent(parsed.message, defaultMessage: _l10n.aadhaarServerError),
          isSuccess: parsed.isSuccess,
          clientId: parsed.clientId,
        );
      }

      return GenerateAadhaarOtpResponse(
        statusCode: '500',
        statusMessage: _l10n.aadhaarServerError,
        message: _l10n.aadhaarServerError,
        isSuccess: false,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.response?.statusCode == 408 ||
          e.response?.statusCode == 504 ||
          (e.response?.statusCode != null && e.response!.statusCode! >= 500)) {
        return GenerateAadhaarOtpResponse(
          statusCode: '408',
          statusMessage: _l10n.connectionTimeout,
          message: _l10n.connectionTimeout,
          isSuccess: false,
        );
      }
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = GenerateAadhaarOtpResponse.fromJson(errData);
          return GenerateAadhaarOtpResponse(
            statusCode: parsed.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.aadhaarServerError),
            message: ApiErrorLocalizer.localizeCurrent(parsed.message, defaultMessage: _l10n.aadhaarServerError),
            isSuccess: parsed.isSuccess,
            clientId: parsed.clientId,
          );
        }
      }
      return GenerateAadhaarOtpResponse(
        statusCode: '500',
        statusMessage: _l10n.aadhaarServerError,
        message: _l10n.aadhaarServerError,
        isSuccess: false,
      );
    } catch (e) {
      return GenerateAadhaarOtpResponse(
        statusCode: '500',
        statusMessage: _l10n.aadhaarServerError,
        message: _l10n.aadhaarServerError,
        isSuccess: false,
      );
    }
  }

  @override
  Future<VerifyAadhaarOtpResponse> submitAadhaarOtp({
    required String clientId,
    required String otp,
    required String mobileNumber,
    int createdBy = 0,
  }) async {
    if (!await NetworkChecker.checkOrNotify()) {
      return VerifyAadhaarOtpResponse(
        statusCode: 'NoInternet',
        statusMessage: _l10n.noInternetConnection,
        message: _l10n.noInternetConnection,
        isSuccess: false,
      );
    }

    try {
      final url = ApiEndpoints.verifyAadhaarOtp;
      final response = await _dio.post(
        url,
        data: {
          'client_id': clientId,
          'otp': otp,
          'mobile_number': mobileNumber,
          'createdBy': createdBy,
        },
      );

      final data = asResponseMap(response.data);

      if (data != null) {
        final parsed = VerifyAadhaarOtpResponse.fromJson(data);
        return VerifyAadhaarOtpResponse(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.aadhaarServerError),
          message: ApiErrorLocalizer.localizeCurrent(parsed.message, defaultMessage: _l10n.aadhaarServerError),
          isSuccess: parsed.isSuccess,
          id: parsed.id,
          fullName: parsed.fullName,
          aadharNumber: parsed.aadharNumber,
          dob: parsed.dob,
          gender: parsed.gender,
          country: parsed.country,
          dist: parsed.dist,
          state: parsed.state,
          loc: parsed.loc,
          zip: parsed.zip,
        );
      }

      return VerifyAadhaarOtpResponse(
        statusCode: '500',
        statusMessage: _l10n.aadhaarServerError,
        message: _l10n.aadhaarServerError,
        isSuccess: false,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.response?.statusCode == 408 ||
          e.response?.statusCode == 504 ||
          (e.response?.statusCode != null && e.response!.statusCode! >= 500)) {
        return VerifyAadhaarOtpResponse(
          statusCode: '408',
          statusMessage: _l10n.connectionTimeout,
          message: _l10n.connectionTimeout,
          isSuccess: false,
        );
      }
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = VerifyAadhaarOtpResponse.fromJson(errData);
          return VerifyAadhaarOtpResponse(
            statusCode: parsed.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.aadhaarServerError),
            message: ApiErrorLocalizer.localizeCurrent(parsed.message, defaultMessage: _l10n.aadhaarServerError),
            isSuccess: parsed.isSuccess,
            id: parsed.id,
            fullName: parsed.fullName,
            aadharNumber: parsed.aadharNumber,
            dob: parsed.dob,
            gender: parsed.gender,
            country: parsed.country,
            dist: parsed.dist,
            state: parsed.state,
            loc: parsed.loc,
            zip: parsed.zip,
          );
        }
      }
      return VerifyAadhaarOtpResponse(
        statusCode: '500',
        statusMessage: _l10n.aadhaarServerError,
        message: _l10n.aadhaarServerError,
        isSuccess: false,
      );
    } catch (e) {
      return VerifyAadhaarOtpResponse(
        statusCode: '500',
        statusMessage: _l10n.aadhaarServerError,
        message: _l10n.aadhaarServerError,
        isSuccess: false,
      );
    }
  }

  @override
  Future<AadhaarDocumentUploadResponse> uploadAadhaarDocument({
    required String filePath,
    String? fileName,
    List<int>? bytes,
  }) async {
    if (!await NetworkChecker.checkOrNotify()) {
      return AadhaarDocumentUploadResponse(
        statusCode: 'NoInternet',
        statusMessage: _l10n.noInternetConnection,
        isSuccess: false,
      );
    }

    try {
      final url = ApiEndpoints.uploadPhoto;
      final String name = fileName ?? (filePath.isNotEmpty ? filePath.split('/').last.split('\\').last : 'document.pdf');

      final MultipartFile filePart = (bytes != null && bytes.isNotEmpty)
          ? MultipartFile.fromBytes(bytes, filename: name)
          : await MultipartFile.fromFile(filePath, filename: name);

      final formData = FormData.fromMap({
        'DirName': 'Consumer',
        'files': filePart,
      });

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final data = asResponseMap(response.data);

      if (data != null) {
        final parsed = AadhaarDocumentUploadResponse.fromJson(data);
        return AadhaarDocumentUploadResponse(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.docUploadFailed),
          isSuccess: parsed.isSuccess,
          responseData: parsed.responseData,
        );
      }

      return AadhaarDocumentUploadResponse(
        statusCode: '500',
        statusMessage: _l10n.invalidResponseFromServer,
        isSuccess: false,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 413 || e.response?.statusCode == 415) {
        return AadhaarDocumentUploadResponse(
          statusCode: e.response!.statusCode.toString(),
          statusMessage: _l10n.unsupportedFileFormat,
          isSuccess: false,
        );
      }
      
      if (e.response?.data != null) {
        try {
          final errData = asResponseMap(e.response!.data);
          if (errData != null) {
            final parsed = AadhaarDocumentUploadResponse.fromJson(errData);
            return AadhaarDocumentUploadResponse(
              statusCode: parsed.statusCode,
              statusMessage: ApiErrorLocalizer.localizeCurrent(parsed.statusMessage, defaultMessage: _l10n.docUploadFailed),
              isSuccess: parsed.isSuccess,
              responseData: parsed.responseData,
            );
          }
        } catch (_) {}
      }
      return AadhaarDocumentUploadResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: ApiErrorLocalizer.localizeCurrent(e.message, defaultMessage: _l10n.docUploadFailed),
        isSuccess: false,
      );
    } catch (e) {
      return AadhaarDocumentUploadResponse(
        statusCode: '500',
        statusMessage: _l10n.docUploadFailed,
        isSuccess: false,
      );
    }
  }
}

final aadhaarKycRepositoryProvider = Provider<AadhaarKycRepository>((ref) {
  return AadhaarKycRepositoryImpl();
});
