class UserKeyItem {
  final String id;
  final String? activationKey1;
  final String? activationKey2;
  final String? mobileNo1;
  final String? mobileNo2;
  final int? status;
  final String? emailId;

  const UserKeyItem({
    required this.id,
    this.activationKey1,
    this.activationKey2,
    this.mobileNo1,
    this.mobileNo2,
    this.status,
    this.emailId,
  });

  factory UserKeyItem.fromJson(Map<String, dynamic> json) {
    return UserKeyItem(
      id: json['id']?.toString() ?? '',
      activationKey1: json['acivationKey1']?.toString() ?? json['activationKey1']?.toString(),
      activationKey2: json['acivationKey2']?.toString() ?? json['activationKey2']?.toString(),
      mobileNo1: json['mobileNo1']?.toString(),
      mobileNo2: json['mobileNo2']?.toString(),
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? ''),
      emailId: json['emailId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'acivationKey1': activationKey1,
    'acivationKey2': activationKey2,
    'mobileNo1': mobileNo1,
    'mobileNo2': mobileNo2,
    'status': status,
    'emailId': emailId,
  };
}

class UserKeyApiResponse {
  final String statusCode;
  final String statusMessage;
  final List<UserKeyItem>? responseData;
  final dynamic responseData1;

  const UserKeyApiResponse({
    required this.statusCode,
    required this.statusMessage,
    this.responseData,
    this.responseData1,
  });

  /// OTP request is successful only if statusCode is 200 AND responseData contains a non-empty activationKey1.
  /// (acivationKey1 empty/null => OTP not sent; acivationKey1 has value => OTP sent successfully.
  /// Do NOT use status = 0 alone as failure indicator, as successful responses also contain status = 0).
  bool get isSuccess {
    if ((statusCode != '200' && statusCode != '200.0') ||
        responseData == null ||
        responseData!.isEmpty) {
      return false;
    }
    final key = responseData!.first.activationKey1;
    return key != null && key.trim().isNotEmpty;
  }

  factory UserKeyApiResponse.fromJson(Map<String, dynamic> json) {
    List<UserKeyItem>? items;
    if (json['responseData'] != null && json['responseData'] is List) {
      items = (json['responseData'] as List)
          .map((item) => UserKeyItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    String msg = json['statusMessage']?.toString() ?? 'Unknown response from server';

    if (items != null && items.isNotEmpty) {
      final firstItem = items.first;
      final key1 = firstItem.activationKey1;
      if (key1 == null || key1.trim().isEmpty) {
        if (firstItem.id.trim().isNotEmpty) {
          msg = firstItem.id.trim();
        }
      }
    }

    return UserKeyApiResponse(
      statusCode: json['statusCode']?.toString() ?? '500',
      statusMessage: msg,
      responseData: items,
      responseData1: json['responseData1'],
    );
  }

  Map<String, dynamic> toJson() => {
    'statusCode': statusCode,
    'statusMessage': statusMessage,
    'responseData': responseData?.map((x) => x.toJson()).toList(),
    'responseData1': responseData1,
  };
}

class LoginResponseData {
  final String app;
  final String token;
  final String longcodeNo;
  final bool isConsumer;
  final int userId;
  final int consumerId;
  final bool isAadharVerified;
  final int isCompulsoryVerification;
  final bool isPanVerified;

  const LoginResponseData({
    required this.app,
    required this.token,
    required this.longcodeNo,
    required this.isConsumer,
    required this.userId,
    required this.consumerId,
    required this.isAadharVerified,
    required this.isCompulsoryVerification,
    required this.isPanVerified,
  });

  factory LoginResponseData.fromJson(Map<String, dynamic> json) {
    return LoginResponseData(
      app: json['app']?.toString() ?? 'Consumer',
      token: json['token']?.toString() ?? '',
      longcodeNo: json['longcodeNo']?.toString() ?? '',
      isConsumer: json['isConsumer'] == true || json['isConsumer']?.toString().toLowerCase() == 'true',
      userId: json['userId'] is int ? json['userId'] as int : int.tryParse(json['userId']?.toString() ?? '') ?? 0,
      consumerId: json['consumerId'] is int ? json['consumerId'] as int : int.tryParse(json['consumerId']?.toString() ?? '') ?? 0,
      isAadharVerified: json['isAadharVerified'] == true || json['isAadharVerified']?.toString().toLowerCase() == 'true',
      isCompulsoryVerification: json['isCompulsoryVerification'] is int ? json['isCompulsoryVerification'] as int : int.tryParse(json['isCompulsoryVerification']?.toString() ?? '') ?? 0,
      isPanVerified: json['isPanVerified'] == true || json['isPanVerified']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
    'app': app,
    'token': token,
    'longcodeNo': longcodeNo,
    'isConsumer': isConsumer,
    'userId': userId,
    'consumerId': consumerId,
    'isAadharVerified': isAadharVerified,
    'isCompulsoryVerification': isCompulsoryVerification,
    'isPanVerified': isPanVerified,
  };
}

class LoginConsumerProfileSummary {
  final int id;
  final String name;
  final String mobileNo;
  final bool isCompleteDetails;
  final bool isPanKycRequired;
  final bool isAdharKycRequired;
  final bool isGstKycRequired;
  final bool isKycRequired;

  const LoginConsumerProfileSummary({
    required this.id,
    required this.name,
    required this.mobileNo,
    this.isCompleteDetails = false,
    this.isPanKycRequired = false,
    this.isAdharKycRequired = false,
    this.isGstKycRequired = false,
    this.isKycRequired = false,
  });

  factory LoginConsumerProfileSummary.fromJson(Map<String, dynamic> json) {
    return LoginConsumerProfileSummary(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      mobileNo: json['mobileNo']?.toString() ?? '',
      isCompleteDetails: json['isCompleteDetails'] == true || json['isCompleteDetails']?.toString().toLowerCase() == 'true',
      isPanKycRequired: json['isPanKycRequired'] == true || json['isPanKycRequired']?.toString().toLowerCase() == 'true',
      isAdharKycRequired: json['isAdharKycRequired'] == true || json['isAdharKycRequired']?.toString().toLowerCase() == 'true',
      isGstKycRequired: json['isGSTKycRequired'] == true || json['isGSTKycRequired']?.toString().toLowerCase() == 'true',
      isKycRequired: json['isKycRequired'] == true || json['isKycRequired']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mobileNo': mobileNo,
    'isCompleteDetails': isCompleteDetails,
    'isPanKycRequired': isPanKycRequired,
    'isAdharKycRequired': isAdharKycRequired,
    'isGSTKycRequired': isGstKycRequired,
    'isKycRequired': isKycRequired,
  };
}

class VerifyCodeApiResponse {
  final String statusCode;
  final String statusMessage;
  final List<LoginResponseData>? responseData;
  final dynamic responseData1;
  final dynamic responseData6;
  final List<LoginConsumerProfileSummary>? responseData7;

  const VerifyCodeApiResponse({
    required this.statusCode,
    required this.statusMessage,
    this.responseData,
    this.responseData1,
    this.responseData6,
    this.responseData7,
  });

  bool get isSuccess =>
      (statusCode == '200' || statusCode == '200.0') &&
      responseData != null &&
      responseData!.isNotEmpty;

  factory VerifyCodeApiResponse.fromJson(Map<String, dynamic> json) {
    List<LoginResponseData>? items;
    if (json['responseData'] != null && json['responseData'] is List) {
      items = (json['responseData'] as List)
          .map((item) => LoginResponseData.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    List<LoginConsumerProfileSummary>? items7;
    if (json['responseData7'] != null && json['responseData7'] is List) {
      items7 = (json['responseData7'] as List)
          .map((item) => LoginConsumerProfileSummary.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return VerifyCodeApiResponse(
      statusCode: json['statusCode']?.toString() ?? '500',
      statusMessage: json['statusMessage']?.toString() ?? 'Login failed. Please check your verification code.',
      responseData: items,
      responseData1: json['responseData1'],
      responseData6: json['responseData6'],
      responseData7: items7,
    );
  }

  Map<String, dynamic> toJson() => {
    'statusCode': statusCode,
    'statusMessage': statusMessage,
    'responseData': responseData?.map((x) => x.toJson()).toList(),
    'responseData1': responseData1,
    'responseData6': responseData6,
    'responseData7': responseData7?.map((x) => x.toJson()).toList(),
  };
}

class ConsumerSignUpResponse {
  final String statusCode;
  final String statusMessage;
  final dynamic responseData;

  const ConsumerSignUpResponse({
    required this.statusCode,
    required this.statusMessage,
    this.responseData,
  });

  bool get isSuccess =>
      statusCode == '200' ||
      statusCode == '200.0' ||
      (responseData != null && responseData is Map && (responseData['isSuccess'] == true || responseData['isSuccess']?.toString() == 'true'));

  factory ConsumerSignUpResponse.fromJson(Map<String, dynamic> json) {
    return ConsumerSignUpResponse(
      statusCode: json['statusCode']?.toString() ?? '500',
      statusMessage: json['statusMessage']?.toString() ?? 'Registration failed',
      responseData: json['responseData'],
    );
  }
}


class LogoutApiResponse {
  final String statusCode;
  final String statusMessage;
  final dynamic responseData;
  final dynamic responseData1;

  const LogoutApiResponse({
    required this.statusCode,
    required this.statusMessage,
    this.responseData,
    this.responseData1,
  });

  bool get isSuccess =>
      statusCode == '200' ||
      statusCode == '200.0';

  factory LogoutApiResponse.fromJson(Map<String, dynamic> json) {
    return LogoutApiResponse(
      statusCode: json['statusCode']?.toString() ?? '500',
      statusMessage: json['statusMessage']?.toString() ?? 'Logout failed',
      responseData: json['responseData'],
      responseData1: json['responseData1'],
    );
  }

  Map<String, dynamic> toJson() => {
    'statusCode': statusCode,
    'statusMessage': statusMessage,
    'responseData': responseData,
    'responseData1': responseData1,
  };
}
