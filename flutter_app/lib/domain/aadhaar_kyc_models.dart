class AadhaarExistResponse {
  final String statusCode;
  final String statusMessage;
  final bool exists; // true if responseData.isSuccess == true
  final int id;

  const AadhaarExistResponse({
    required this.statusCode,
    required this.statusMessage,
    required this.exists,
    required this.id,
  });

  factory AadhaarExistResponse.fromJson(Map<String, dynamic> json) {
    final resData = json['responseData'];
    bool isSuccess = false;
    int idVal = 0;
    if (resData is Map<String, dynamic>) {
      isSuccess = resData['isSuccess'] == true || resData['isSuccess']?.toString().toLowerCase() == 'true' || resData['isAadharVerified'] == true;
      idVal = resData['id'] is int ? resData['id'] as int : int.tryParse(resData['id']?.toString() ?? '') ?? 0;
    }
    return AadhaarExistResponse(
      statusCode: json['statusCode']?.toString() ?? '500',
      statusMessage: json['statusMessage']?.toString() ?? '',
      exists: isSuccess,
      id: idVal,
    );
  }
}

class GenerateAadhaarOtpResponse {
  final String statusCode;
  final String statusMessage;
  final bool isSuccess;
  final String? clientId;
  final String? message;

  const GenerateAadhaarOtpResponse({
    required this.statusCode,
    required this.statusMessage,
    required this.isSuccess,
    this.clientId,
    this.message,
  });

  factory GenerateAadhaarOtpResponse.fromJson(Map<String, dynamic> json) {
    final resData = json['responseData'];
    String? clientId;
    bool success = false;
    String? msg;

    if (resData is Map<String, dynamic>) {
      success = resData['success'] == true || resData['success']?.toString().toLowerCase() == 'true';
      msg = resData['message']?.toString();

      final dataMap = resData['data'];
      if (dataMap is Map<String, dynamic>) {
        clientId = dataMap['client_id']?.toString();
      }
    }

    final topCode = json['statusCode']?.toString() ?? '500';
    return GenerateAadhaarOtpResponse(
      statusCode: topCode,
      statusMessage: json['statusMessage']?.toString() ?? '',
      isSuccess: (topCode == '200' || topCode == '200.0') && success && clientId != null,
      clientId: clientId,
      message: msg ?? json['statusMessage']?.toString(),
    );
  }
}

class VerifyAadhaarOtpResponse {
  final String statusCode;
  final String statusMessage;
  final bool isSuccess;
  final int? id;
  final String? fullName;
  final String? aadharNumber;
  final String? dob;
  final String? gender;
  final String? country;
  final String? dist;
  final String? state;
  final String? loc;
  final String? zip;
  final String? message;

  const VerifyAadhaarOtpResponse({
    required this.statusCode,
    required this.statusMessage,
    required this.isSuccess,
    this.id,
    this.fullName,
    this.aadharNumber,
    this.dob,
    this.gender,
    this.country,
    this.dist,
    this.state,
    this.loc,
    this.zip,
    this.message,
  });

  factory VerifyAadhaarOtpResponse.fromJson(Map<String, dynamic> json) {
    final resData = json['responseData'];
    bool success = false;
    int? idVal;
    String? fullName;
    String? aadharNumber;
    String? dob;
    String? gender;
    String? country;
    String? dist;
    String? state;
    String? loc;
    String? zip;
    String? msg;

    if (resData is Map<String, dynamic>) {
      success = resData['success'] == true || resData['success']?.toString().toLowerCase() == 'true';
      idVal = resData['id'] is int ? resData['id'] as int : int.tryParse(resData['id']?.toString() ?? '');
      fullName = resData['full_name']?.toString();
      aadharNumber = resData['aadhar_Number']?.toString();
      dob = resData['dob']?.toString();
      gender = resData['gender']?.toString().trim();
      country = resData['country']?.toString();
      dist = resData['dist']?.toString();
      state = resData['state']?.toString();
      loc = resData['loc']?.toString();
      zip = resData['zip']?.toString();
      msg = resData['message']?.toString();
    }

    final topCode = json['statusCode']?.toString() ?? '500';
    return VerifyAadhaarOtpResponse(
      statusCode: topCode,
      statusMessage: json['statusMessage']?.toString() ?? '',
      isSuccess: (topCode == '200' || topCode == '200.0') && success,
      id: idVal,
      fullName: fullName,
      aadharNumber: aadharNumber,
      dob: dob,
      gender: gender,
      country: country,
      dist: dist,
      state: state,
      loc: loc,
      zip: zip,
      message: msg ?? json['statusMessage']?.toString(),
    );
  }
}

class AadhaarDocumentUploadResponse {
  final String statusCode;
  final String statusMessage;
  final String? responseData;
  final bool isSuccess;

  const AadhaarDocumentUploadResponse({
    required this.statusCode,
    required this.statusMessage,
    this.responseData,
    required this.isSuccess,
  });

  factory AadhaarDocumentUploadResponse.fromJson(Map<String, dynamic> json) {
    final code = json['statusCode']?.toString() ?? '500';
    final msg = json['statusMessage']?.toString() ?? '';
    final url = json['responseData']?.toString();
    final success = (code == '200' || code == '200.0') && (url != null && url.trim().isNotEmpty);

    return AadhaarDocumentUploadResponse(
      statusCode: code,
      statusMessage: msg,
      responseData: url,
      isSuccess: success,
    );
  }
}
