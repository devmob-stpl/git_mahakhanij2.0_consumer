import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/prototype_bar.dart';
import '../../providers/session_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String mobileNumber;

  const OtpScreen({super.key, required this.mobileNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _digitControllers = List.generate(6, (_) => TextEditingController());

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
    if (code.length != 6) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _notice = null;
    });

    final success = await ref.read(sessionProvider.notifier).login(
      widget.mobileNumber,
      code,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.go('/home');
      } else {
        setState(() {
          _error = 'That code is not correct. Please try again.';
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

  void _handleResend() {
    setState(() {
      _notice = 'A new code has been sent.';
      _error = null;
      _secondsLeft = 30;
      for (final c in _digitControllers) {
        c.clear();
      }
    });
    _startTimer();
  }

  void _handleQuickFill() {
    const code = '123456';
    for (var i = 0; i < 6; i++) {
      _digitControllers[i].text = code[i];
    }
    setState(() {
      _error = null;
    });
    _handleVerify(code);
  }

  @override
  Widget build(BuildContext context) {
    final enteredCode = _getEnteredCode();
    final isComplete = enteredCode.length == 6;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          const PrototypeBar(),
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
                    'Enter the 6-digit code sent to',
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
                          Text(
                            _notice!,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF166534), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // 6 Digit Input Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 46,
                        height: 54,
                        child: TextField(
                          controller: _digitControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
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
                              if (index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else {
                                _focusNodes[index].unfocus();
                                // Auto-verify on 6th digit
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

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(fontSize: 13, color: AppColors.danger700, fontWeight: FontWeight.w500),
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
                            onPressed: _handleResend,
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

                  const SizedBox(height: 32),

                  // Prototype Quick Fill Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCD34D)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '⚡ Quick Fill Demo OTP:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF78350F)),
                            ),
                            Text(
                              'Tap to verify',
                              style: TextStyle(fontSize: 10, color: Color(0xFFB45309)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _handleQuickFill,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFCD34D)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '123456',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF78350F), letterSpacing: 2),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '(Tap to verify)',
                                  style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: AppButton(
              label: 'Verify OTP',
              fullWidth: true,
              size: AppButtonSize.large,
              isLoading: _isLoading,
              onPressed: isComplete ? () => _handleVerify() : null,
            ),
          ),
        ],
      ),
    );
  }
}
