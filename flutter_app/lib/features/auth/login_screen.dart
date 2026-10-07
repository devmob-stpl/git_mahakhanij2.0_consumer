import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/session_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? initialMobile;
  const LoginScreen({super.key, this.initialMobile});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _mobileController;
  final FocusNode _mobileFocusNode = FocusNode();
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());
  final List<TextEditingController> _digitControllers = List.generate(5, (_) => TextEditingController());

  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _error;
  int _secondsLeft = 30;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _mobileController = TextEditingController();
    _mobileFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _mobileFocusNode.removeListener(_onFocusChange);
    _mobileFocusNode.dispose();
    _mobileController.dispose();
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final controller in _digitControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _secondsLeft = 30;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        if (mounted) setState(() => _secondsLeft = 0);
      } else {
        if (mounted) setState(() => _secondsLeft--);
      }
    });
  }

  void _resetOtpState() {
    _countdownTimer?.cancel();
    setState(() {
      _isOtpSent = false;
      _mobileController.clear();
      _error = null;
      for (final c in _digitControllers) {
        c.clear();
      }
    });
  }

  String _getEnteredCode() {
    return _digitControllers.map((c) => c.text).join();
  }

  Future<void> _handleSendOtp() async {
    final mobile = _mobileController.text.trim();
    if (mobile.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      setState(() {
        _error = AppLocalizations.of(context)!.invalidMobileError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authRepo = ref.read(authRepositoryProvider);
    final response = await authRepo.sendVerificationCode(mobile);

    if (!mounted) return;

    if (response.isSuccess) {
      setState(() {
        _isLoading = false;
        _isOtpSent = true;
      });
      _startTimer();
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    } else {
      setState(() {
        _isLoading = false;
        _error = response.statusMessage.isNotEmpty
            ? response.statusMessage
            : 'User Not Available';
      });
    }
  }

  Future<void> _handleVerifyOtp() async {
    final code = _getEnteredCode().trim();
    if (code.length != 5) {
      setState(() {
        _error = AppLocalizations.of(context)!.invalidOtpError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final mobile = _mobileController.text.trim();
    final response = await ref.read(sessionProvider.notifier).loginWithVerificationCode(
      mobile,
      code,
    );

    if (!mounted) return;

    if (response.isSuccess) {
      setState(() => _isLoading = false);
      context.go('/home');
    } else {
      setState(() {
        _isLoading = false;
        _error = (response.statusMessage.isNotEmpty && !response.statusMessage.startsWith('Login Failed'))
            ? response.statusMessage
            : AppLocalizations.of(context)!.invalidOtpServer;
        for (final c in _digitControllers) {
          c.clear();
        }
        if (_focusNodes.isNotEmpty) {
          _focusNodes[0].requestFocus();
        }
      });
    }
  }

  Future<void> _handleResendOtp() async {
    final mobile = _mobileController.text.trim();
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await ref.read(authRepositoryProvider).sendVerificationCode(mobile);

    if (!mounted) return;

    if (response.isSuccess) {
      setState(() {
        _isLoading = false;
        for (final c in _digitControllers) {
          c.clear();
        }
      });
      _startTimer();
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    } else {
      setState(() {
        _isLoading = false;
        _error = response.statusMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // App Title: Mahakhanij 2•0
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Mahakhanij ',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: '2•0',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Section Header: LOGIN
                      Text(
                        l10n.loginHeading,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Mobile Number Input Box
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: _isOtpSent
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _mobileController.text,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B), // AppColors.ink equivalent
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _resetOtpState,
                                      child: const Text(
                                        'Change',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: primaryBlue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F5F8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _error != null
                                        ? AppColors.danger700
                                        : (_mobileFocusNode.hasFocus
                                            ? primaryBlue
                                            : const Color(0xFFCBD5E1)),
                                    width: (_mobileFocusNode.hasFocus && _error == null) ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [

                                    Expanded(
                                      child: TextField(
                                        controller: _mobileController,
                                        focusNode: _mobileFocusNode,
                                        keyboardType: TextInputType.phone,
                                        maxLength: 10,
                                        enabled: !_isLoading,
                                        onChanged: (_) {
                                          if (_error != null) setState(() => _error = null);
                                        },
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1E293B),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: l10n.mobileNumberHint,
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 15,
                                          ),
                                          counterText: '',
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),

                      // OTP Boxes Row (visible when OTP is sent)
                      if (_isOtpSent) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(5, (index) {
                                  return SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: TextField(
                                      controller: _digitControllers[index],
                                      focusNode: _focusNodes[index],
                                      textCapitalization: TextCapitalization.characters,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                                      ],
                                      textAlign: TextAlign.center,
                                      enabled: !_isLoading,
                                      maxLength: 1,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        filled: true,
                                        fillColor: const Color(0xFFF3F5F8),
                                        contentPadding: EdgeInsets.zero,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: primaryBlue,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        if (_error != null) setState(() => _error = null);
                                        if (val.isNotEmpty) {
                                          if (index < 4) {
                                            _focusNodes[index + 1].requestFocus();
                                          } else {
                                            _focusNodes[index].unfocus();
                                          }
                                        } else {
                                          if (index > 0) {
                                            _focusNodes[index - 1].requestFocus();
                                          }
                                        }
                                        setState(() {});
                                      },
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),

                              // Timer / Resend OTP text
                              _secondsLeft > 0
                                  ? Text(
                                      l10n.waitSeconds(_secondsLeft.toString()),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: primaryBlue,
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: _isLoading ? null : _handleResendOtp,
                                      child: Text(
                                        l10n.resendOtp,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: primaryBlue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],

                      // Error message if any
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.danger700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Button: Get OTP / Login
                      SizedBox(
                        width: 150,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : (_isOtpSent ? _handleVerifyOtp : _handleSendOtp),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isOtpSent ? l10n.loginBtn : l10n.getOtpBtn,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sub-link: New Member? Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.newMemberMsg,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF334155),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/register'),
                            child: Text(
                              l10n.signUpLink,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primaryBlue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(flex: 3),

                      // Bottom Mining Banner Illustration
                      Image.asset(
                        'assets/images/img.png',
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.bottomCenter,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


