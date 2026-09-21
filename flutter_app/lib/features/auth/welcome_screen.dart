import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/prototype_bar.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          const PrototypeBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  Image.asset(
                    'assets/images/mahakhanij-logo.png',
                    height: 72,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Revenue Department, Government of Maharashtra',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.inkMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    'Mineral, from source to site',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Find a mineral place, raise an enquiry, track the vehicle, verify what arrives, and manage what you use.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.inkSecondary,
                      height: 1.45,
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Sign in',
                    fullWidth: true,
                    size: AppButtonSize.large,
                    onPressed: () => context.push('/login'),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Create account',
                    fullWidth: true,
                    size: AppButtonSize.large,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.push('/register'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
