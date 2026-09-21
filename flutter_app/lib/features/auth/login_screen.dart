import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/prototype_bar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _mobileController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _fillNumber(String num) {
    setState(() {
      _mobileController.text = num;
      _error = null;
    });
  }

  void _handleSubmit() {
    final mobile = _mobileController.text.trim();
    if (mobile.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      setState(() {
        _error = 'Enter a valid 10-digit Indian mobile number.';
      });
      return;
    }

    context.push('/otp', extra: mobile);
  }

  @override
  Widget build(BuildContext context) {
    final hasInput = _mobileController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          const PrototypeBar(),
          // Auth Header Bar with Back Button
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
                    'Sign in',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We will send a 6-digit verification code to this number.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.inkSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mobile Number Field
                  const Text(
                    'Mobile number',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _error != null ? AppColors.danger700 : AppColors.line,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            '+91',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkSecondary,
                            ),
                          ),
                        ),
                        Container(width: 1, height: 24, color: AppColors.line),
                        Expanded(
                          child: TextField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            autofocus: true,
                            onChanged: (_) {
                              if (_error != null) setState(() => _error = null);
                              setState(() {});
                            },
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
                            decoration: const InputDecoration(
                              hintText: '10-digit number',
                              counterText: '',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _error!,
                      style: const TextStyle(fontSize: 12, color: AppColors.danger700),
                    ),
                  ],

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text(
                        'New to Mahakhanij? ',
                        style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: const Text(
                          'Create account',
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

                  const SizedBox(height: 32),
                  // Prototype Quick Fill Demo Numbers Card
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
                              '⚡ Quick Fill Demo Numbers:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF78350F)),
                            ),
                            Text(
                              'Tap to fill',
                              style: TextStyle(fontSize: 10, color: Color(0xFFB45309)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            InkWell(
                              onTap: () => _fillNumber('9822014576'),
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
                                      '9822014576',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF78350F)),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '(Organization)',
                                      style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _fillNumber('9730845120'),
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
                                      '9730845120',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF78350F)),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '(Individual)',
                                      style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
              label: 'Continue',
              fullWidth: true,
              size: AppButtonSize.large,
              onPressed: hasInput ? _handleSubmit : null,
            ),
          ),
        ],
      ),
    );
  }
}
