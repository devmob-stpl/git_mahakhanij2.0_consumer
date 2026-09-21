import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user.dart';
import '../data/repositories/auth_repository.dart';

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
  }

  Future<bool> login(String mobile, String otp) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authRepository.verifyOtp(mobile, otp);
      state = SessionState(currentUser: user, isLoading: false);
      return user != null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void logout() {
    state = const SessionState(currentUser: null);
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return SessionNotifier(authRepo);
});
