import 'package:dio/dio.dart';
import '../../core/network/release_json.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_endpoints.dart';
import '../../domain/aadhaar_kyc_models.dart';

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
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  @override
  Future<AadhaarExistResponse> checkAadhaarExists(String aadhaarNo, {String? mobileNo}) async {
    try {
      final url = ApiEndpoints.getCheckAadhaarExistsUrl(aadhaarNo, mobileNo: mobileNo);
      final response = await _dio.get(url);

      final data = asResponseMap(response.data);

      if (data != null) {
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
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
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

      final data = asResponseMap(response.data);

      if (data != null) {
        return GenerateAadhaarOtpResponse.fromJson(data);
      }

      return const GenerateAadhaarOtpResponse(
        statusCode: '500',
        statusMessage: 'Unexpected format from OTP service.',
        isSuccess: false,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
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

      final data = asResponseMap(response.data);

      if (data != null) {
        return VerifyAadhaarOtpResponse.fromJson(data);
      }

      return const VerifyAadhaarOtpResponse(
        statusCode: '0',
        statusMessage: 'Unexpected format from verification service.',
        isSuccess: false,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
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

      final data = asResponseMap(response.data);

      if (data != null) {
        return AadhaarDocumentUploadResponse.fromJson(data);
      }

      return const AadhaarDocumentUploadResponse(
        statusCode: '500',
        statusMessage: 'Unexpected format returned from document upload API.',
        isSuccess: false,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 413) {
        return const AadhaarDocumentUploadResponse(
          statusCode: '413',
          statusMessage: 'Unsupported file format. Please upload a valid PDF or Image file.',
          isSuccess: false,
        );
      } else if (e.response?.statusCode == 415) {
        return const AadhaarDocumentUploadResponse(
          statusCode: '415',
          statusMessage: '',
          isSuccess: false,
        );
      }
      
      if (e.response?.data != null) {
        try {
          final errData = asResponseMap(e.response!.data);
          if (errData != null) {
            return AadhaarDocumentUploadResponse.fromJson(errData);
          }
        } catch (_) {}
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
