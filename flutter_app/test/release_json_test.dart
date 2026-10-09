import 'package:flutter_test/flutter_test.dart';
import 'package:mahakhanij_consumer/core/network/release_json.dart';
import 'package:mahakhanij_consumer/domain/aadhaar_kyc_models.dart';
import 'package:mahakhanij_consumer/domain/auth_api_models.dart';
import 'package:mahakhanij_consumer/domain/consumer_dashboard_count_models.dart';
import 'package:mahakhanij_consumer/domain/consumer_digitp_models.dart';
import 'package:mahakhanij_consumer/domain/consumer_profile_models.dart';
import 'package:mahakhanij_consumer/domain/consumer_project_models.dart';
import 'package:mahakhanij_consumer/domain/report_models.dart';

/// Simulates a Dio background-isolate payload: every object is
/// `Map<dynamic, dynamic>`, which is what release AOT returns.
Map<dynamic, dynamic> _releaseMap(Map<String, dynamic> source) {
  dynamic convert(dynamic value) {
    if (value is Map) {
      return <dynamic, dynamic>{
        for (final entry in value.entries) entry.key: convert(entry.value),
      };
    }
    if (value is List) {
      return <dynamic>[for (final item in value) convert(item)];
    }
    return value;
  }

  return convert(source) as Map<dynamic, dynamic>;
}

void main() {
  test('release isolate maps are not Map<String, dynamic>', () {
    final raw = _releaseMap({
      'statusCode': '200',
      'responseData': {'id': 9, 'name': 'Asha'},
    });

    expect(raw is Map<String, dynamic>, isFalse);
    expect(raw['responseData'] is Map<String, dynamic>, isFalse);
  });

  test('profile object payload parses after release normalization', () {
    final raw = _releaseMap({
      'statusCode': 200,
      'statusMessage': 'Success',
      'responseData': {
        'id': 42,
        'consumerType': 1,
        'name': 'Asha Patil',
        'mobileNo': '9876543210',
        'isTown': false,
        'districtId': 3,
        'address': 'Plot 4',
        'isAadharVerified': true,
      },
    });

    final parsed = ConsumerProfileApiResponse.fromJson(asResponseMap(raw)!);

    expect(parsed.isSuccess, isTrue);
    expect(parsed.responseData?.id, 42);
    expect(parsed.responseData?.name, 'Asha Patil');
    expect(parsed.responseData?.mobileNo, '9876543210');
    expect(parsed.responseData?.isAadharVerified, isTrue);
    expect(parsed.responseData?.address, 'Plot 4');
  });

  test('profile list payload parses when responseData is not a typed map', () {
    final top = <String, dynamic>{
      'statusCode': '200',
      'statusMessage': 'Success',
      'responseData': <dynamic>[
        <dynamic, dynamic>{
          'id': 7,
          'consumerType': 1,
          'name': 'Ramesh',
          'mobileNo': '9000000001',
          'isTown': 'true',
        },
      ],
    };

    final parsed = ConsumerProfileApiResponse.fromJson(top);

    expect(parsed.isSuccess, isTrue);
    expect(parsed.responseData?.name, 'Ramesh');
    expect(parsed.responseData?.isTown, isTrue);
  });

  test('profile JSON string body parses', () {
    const body = '''
      {"statusCode":"200","statusMessage":"Success","responseData":{
        "id":5,"consumerType":1,"name":"Meera","mobileNo":"9123456780","isTown":false
      }}
    ''';

    final parsed = ConsumerProfileApiResponse.fromJson(asResponseMap(body)!);
    expect(parsed.responseData?.name, 'Meera');
  });

  test('login, digitp, aadhaar, dashboard, project, and report maps parse', () {
    final login = VerifyCodeApiResponse.fromJson(asResponseMap(_releaseMap({
      'statusCode': '200',
      'statusMessage': 'Success',
      'responseData': [
        {
          'userId': 11,
          'consumerId': 22,
          'isConsumer': true,
          'token': 't',
        },
      ],
      'responseData7': [
        {'id': 22, 'name': 'Asha', 'mobileNo': '9876543210'},
      ],
      'responseData1': [
        {'appId': 3},
      ],
    }))!);
    expect(login.isSuccess, isTrue);
    expect(login.responseData?.first.consumerId, 22);
    expect(login.responseData7?.first.name, 'Asha');

    final digitp = ConsumerDigiTpApiResponse.fromJson(asResponseMap(_releaseMap({
      'statusCode': '200',
      'statusMessage': 'Success',
      'responseData': {
        'data': [
          {'invoiceNo': 'INV-1', 'vehicleNo': 'MH12AB1234'},
        ],
        'count': {'totalCount': 1, 'inTransitCount': 1},
      },
    }))!);
    expect(digitp.items, isNotEmpty);
    expect(digitp.items.first.invoiceNo, 'INV-1');
    expect(digitp.responseData?.count?.totalCount, 1);

    final otp = GenerateAadhaarOtpResponse.fromJson(asResponseMap(_releaseMap({
      'statusCode': '200',
      'statusMessage': 'Success',
      'responseData': {
        'success': true,
        'data': {'client_id': 'cid-9'},
      },
    }))!);
    expect(otp.isSuccess, isTrue);
    expect(otp.clientId, 'cid-9');

    final dashboard = ConsumerDashboardCountApiResponse.fromJson(asResponseMap(_releaseMap({
      'statusCode': '200',
      'statusMessage': 'Success',
      'responseData': {'totalCount': 4, 'inTransitCount': 1},
    }))!);
    expect(dashboard.responseData?.totalCount, 4);

    final projects = ConsumerProjectApiResponse.fromJson(asResponseMap(_releaseMap({
      'statusCode': '200',
      'statusMessage': 'Success',
      'responseData': {
        'data': [
          {'id': 8, 'name': 'Road work', 'projectCode': 'P1'},
        ],
        'pageno': 1,
        'pageCount': 1,
        'totalCount': '1',
      },
    }))!);
    expect(projects.projects.single.name, 'Road work');

    final report = ConsumerReportResponse.fromJson(asResponseMap(_releaseMap({
      'statusCode': '200',
      'statusMessage': 'Success',
      'responseData': {
        'summary': {'totalReceivedQuantity': 2.5, 'totalDigiTPReceived': 1},
        'materialWiseData': [
          {'materialId': 1, 'materialName': 'Sand'},
        ],
      },
    }))!);
    expect(report.responseData?.summary?.totalDigiTPReceived, 1);
    expect(report.responseData?.materialWiseData.single.materialName, 'Sand');
  });
}
