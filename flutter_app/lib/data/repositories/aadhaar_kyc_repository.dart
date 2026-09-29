import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_endpoints.dart';
import '../../domain/aadhaar_kyc_models.dart';

abstract class AadhaarKycRepository {
  Future<AadhaarExistResponse> checkAadhaarExists(String aadhaarNo);
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
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  @override
  Future<AadhaarExistResponse> checkAadhaarExists(String aadhaarNo) async {
    try {
      final url = ApiEndpoints.getCheckAadhaarExistsUrl(aadhaarNo);
      final response = await _dio.get(url);

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic>) {
        return AadhaarExistResponse.fromJson(data);
      }

      return const AadhaarExistResponse(
        statusCode: '500',
        statusMessage: 'Unexpected format returned from server.',
        exists: false,
        id: 0,
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
          return AadhaarExistResponse.fromJson(errData);
        }
      }
      return AadhaarExistResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: 'Network error checking Aadhaar card existence.',
        exists: false,
        id: 0,
      );
    } catch (e) {
      return AadhaarExistResponse(
        statusCode: '500',
        statusMessage: 'Error checking Aadhaar existence: ${e.toString()}',
        exists: false,
        id: 0,
      );
    }
  }

  @override
  Future<GenerateAadhaarOtpResponse> generateAadhaarOtp(String aadhaarNo, {int createdBy = 0}) async {
    try {
      final url = ApiEndpoints.generateAadhaarOtp;
      final response = await _dio.post(
        url,
        data: {
          'id_number': aadhaarNo,
          'createdBy': createdBy,
        },
      );

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic>) {
        return GenerateAadhaarOtpResponse.fromJson(data);
      }

      return const GenerateAadhaarOtpResponse(
        statusCode: '500',
        statusMessage: 'Unexpected format from OTP service.',
        isSuccess: false,
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
          return GenerateAadhaarOtpResponse.fromJson(errData);
        }
      }
      return GenerateAadhaarOtpResponse(
        statusCode: e.response?.statusCode?.toString() ?? '422',
        statusMessage: 'Failed to generate Aadhaar OTP.',
        isSuccess: false,
      );
    } catch (e) {
      return GenerateAadhaarOtpResponse(
        statusCode: '500',
        statusMessage: 'Error generating Aadhaar OTP: ${e.toString()}',
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

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic>) {
        return VerifyAadhaarOtpResponse.fromJson(data);
      }

      return const VerifyAadhaarOtpResponse(
        statusCode: '0',
        statusMessage: 'Unexpected format from verification service.',
        isSuccess: false,
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
          return VerifyAadhaarOtpResponse.fromJson(errData);
        }
      }
      return VerifyAadhaarOtpResponse(
        statusCode: e.response?.statusCode?.toString() ?? '0',
        statusMessage: 'Aadhaar OTP verification failed.',
        isSuccess: false,
      );
    } catch (e) {
      return VerifyAadhaarOtpResponse(
        statusCode: '0',
        statusMessage: 'Error verifying Aadhaar OTP: ${e.toString()}',
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

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic>) {
        return AadhaarDocumentUploadResponse.fromJson(data);
      }

      return const AadhaarDocumentUploadResponse(
        statusCode: '500',
        statusMessage: 'Unexpected format returned from document upload API.',
        isSuccess: false,
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
          return AadhaarDocumentUploadResponse.fromJson(errData);
        }
      }
      return AadhaarDocumentUploadResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: e.message ?? 'Document upload failed. Please try again.',
        isSuccess: false,
      );
    } catch (e) {
      return AadhaarDocumentUploadResponse(
        statusCode: '500',
        statusMessage: 'Error uploading Aadhaar document: ${e.toString()}',
        isSuccess: false,
      );
    }
  }
}

final aadhaarKycRepositoryProvider = Provider<AadhaarKycRepository>((ref) {
  return AadhaarKycRepositoryImpl();
});
