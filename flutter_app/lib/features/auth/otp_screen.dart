import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../providers/session_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String mobileNumber;
  final Map<String, dynamic>? signUpData;

  const OtpScreen({
    super.key,
    required this.mobileNumber,
    this.signUpData,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());
  final List<TextEditingController> _digitControllers = List.generate(5, (_) => TextEditingController());

  bool _isLoading = false;
  String? _error;
  String? _notice;
  int _secondsLeft = 30;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 30;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final controller in _digitControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getEnteredCode() {
    return _digitControllers.map((c) => c.text).join();
  }

  void _handleVerify([String? codeToUse]) async {
    final code = codeToUse ?? _getEnteredCode();
    if (code.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _notice = null;
    });

    if (widget.signUpData != null) {
      final Map<String, dynamic> activePayload = Map.from(widget.signUpData!);
      activePayload['otp'] = code.trim();

      final signUpResponse = await ref.read(authRepositoryProvider).consumerSignUp(activePayload);

      if (mounted) {
        setState(() => _isLoading = false);
        if (signUpResponse.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please sign in with your mobile number.'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/login', extra: widget.mobileNumber);
        } else {
          setState(() {
            _error = signUpResponse.statusMessage.isNotEmpty
                ? signUpResponse.statusMessage
                : 'Registration failed. Invalid OTP or details.';
            for (final c in _digitControllers) {
              c.clear();
            }
            if (_focusNodes.isNotEmpty) {
              _focusNodes[0].requestFocus();
            }
          });
        }
      }
      return;
    }

    final response = await ref.read(sessionProvider.notifier).loginWithVerificationCode(
      widget.mobileNumber,
      code.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (response.isSuccess) {
        context.go('/home');
      } else {
        setState(() {
          _error = response.statusMessage.isNotEmpty
              ? response.statusMessage
              : 'Login Failed with MobileNo: ${widget.mobileNumber}';
          for (final c in _digitControllers) {
            c.clear();
          }
          if (_focusNodes.isNotEmpty) {
            _focusNodes[0].requestFocus();
          }
        });
      }
    }
  }


  void _handleResend() async {
    setState(() {
      _isLoading = true;
      _notice = null;
      _error = null;
    });

    final response = await ref.read(authRepositoryProvider).sendVerificationCode(widget.mobileNumber);

    if (mounted) {
      setState(() => _isLoading = false);
      if (response.isSuccess) {
        setState(() {
          _notice = 'A new verification code has been sent.';
          _secondsLeft = 30;
          for (final c in _digitControllers) {
            c.clear();
          }
        });
        _startTimer();
      } else {
        setState(() {
          _error = response.statusMessage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enteredCode = _getEnteredCode();
    final isComplete = enteredCode.length == 5;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar with Back Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.ink),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verify your number',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the verification code sent to',
                    style: TextStyle(fontSize: 14, color: AppColors.inkSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '+91 ${widget.mobileNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text(
                          'Change',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_notice != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Color(0xFF15803D)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _notice!,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF166534), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // 5 Digit Input Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      return SizedBox(
                        width: 54,
                        height: 56,
                        child: TextField(
                          controller: _digitControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.center,
                          enabled: !_isLoading,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: _error != null ? AppColors.danger700 : AppColors.line,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: _error != null ? AppColors.danger700 : AppColors.line,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.primary700,
                                width: 2,
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
                                _handleVerify();
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

                  // Error Banner
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.danger700, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.danger700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Resend affordance
                  Center(
                    child: _secondsLeft > 0
                        ? Text(
                            'Resend code in 0:${_secondsLeft.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
                          )
                        : TextButton(
                            onPressed: _isLoading ? null : _handleResend,
                            child: const Text(
                              'Resend code',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary700,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: AppButton(
              label: 'Verify Code & Sign In',
              fullWidth: true,
              size: AppButtonSize.large,
              isLoading: _isLoading,
              onPressed: (isComplete && !_isLoading) ? () => _handleVerify() : null,
            ),
          ),
        ],
      ),
    ),
    );
  }
}
