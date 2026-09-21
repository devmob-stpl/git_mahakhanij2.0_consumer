import '../../domain/user.dart';
import '../../core/config/app_config.dart';
import '../mock_db.dart';

abstract class AuthRepository {
  Future<bool> sendOtp(String mobileNumber);
  Future<User?> verifyOtp(String mobileNumber, String otp);
  Future<User?> getCurrentUser();
  Future<List<User>> getAllUsersForPersonaSwitch();
}

class AuthRepositoryImpl implements AuthRepository {
  final MockDb _db = MockDb();
  User? _currentUser;

  @override
  Future<bool> sendOtp(String mobileNumber) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    return true;
  }

  @override
  Future<User?> verifyOtp(String mobileNumber, String otp) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    try {
      _currentUser = _db.users.firstWhere((u) => u.mobileNumber == mobileNumber);
    } catch (_) {
      _currentUser = _db.users.first;
    }
    return _currentUser;
  }

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    return _currentUser;
  }

  @override
  Future<List<User>> getAllUsersForPersonaSwitch() async {
    return _db.users;
  }
}
