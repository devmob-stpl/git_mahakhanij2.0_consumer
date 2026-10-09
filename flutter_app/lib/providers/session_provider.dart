import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user.dart';
import '../domain/auth_api_models.dart';
import '../data/repositories/auth_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

class SessionState {
  final User? currentUser;
  final bool isLoading;
  final String? error;

  const SessionState({
    this.currentUser,
    this.isLoading = false,
    this.error,
  });

  SessionState copyWith({
    User? currentUser,
    bool? isLoading,
    String? error,
  }) {
    return SessionState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  final AuthRepository _authRepository;

  SessionNotifier(this._authRepository) : super(const SessionState(isLoading: true)) {
    _initSession();
  }

  Future<void> _initSession() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = SessionState(currentUser: user, isLoading: false);
    } catch (e) {
      state = SessionState(isLoading: false, error: e.toString());
    }
  }

  Future<void> switchPersona(User user) async {
    state = state.copyWith(currentUser: user);
    await _authRepository.saveSession(user);
  }

  Future<VerifyCodeApiResponse> loginWithVerificationCode(String mobile, String code) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _authRepository.verifyMobileCode(mobileNumber: mobile, key: code);
      if (response.isSuccess) {
        final user = await _authRepository.getCurrentUser();
        state = SessionState(currentUser: user, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: response.statusMessage);
      }
      return response;
    } catch (e) {
      final errResponse = VerifyCodeApiResponse(
        statusCode: '409',
        statusMessage: 'Login Failed with MobileNo: $mobile',
      );
      state = state.copyWith(isLoading: false, error: errResponse.statusMessage);
      return errResponse;
    }
  }

  Future<bool> login(String mobile, String otp) async {
    final response = await loginWithVerificationCode(mobile, otp);
    return response.isSuccess;
  }

  Future<LogoutApiResponse> logout() async {
    final currentUser = state.currentUser;
    final userId = (currentUser?.id != null && currentUser!.id.isNotEmpty)
        ? currentUser.id
        : '0';

    state = state.copyWith(isLoading: true);
    try {
      final response = await _authRepository.logoutUser(userId);
      // Always clear local session even if API fails
      await _authRepository.clearSession();
      state = const SessionState(currentUser: null, isLoading: false);
      
      // Force success so the UI navigates away
      return const LogoutApiResponse(
        statusCode: '200',
        statusMessage: 'Logged out successfully',
      );
    } catch (e) {
      await _authRepository.clearSession();
      state = const SessionState(currentUser: null, isLoading: false);
      return LogoutApiResponse(
        statusCode: '200',
        statusMessage: 'Logged out successfully (Offline)',
      );
    }
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return SessionNotifier(authRepo);
});
