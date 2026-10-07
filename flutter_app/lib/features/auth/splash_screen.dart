import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/session_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Brief splash screen delay for brand logo display
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    // Check whether a valid local login session exists
    final user = await ref.read(authRepositoryProvider).getCurrentUser();

    if (!mounted) return;

    if (user != null) {
      // Valid session exists -> navigate directly to Dashboard
      context.go('/home');
    } else {
      // No session -> Check if it's the first time launch
      final prefs = await SharedPreferences.getInstance();
      final hasSelectedLanguage = prefs.getBool('has_selected_language') ?? false;
      
      if (!hasSelectedLanguage) {
        context.go('/language-selection');
      } else {
        context.go('/login');
      }
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
                      const Spacer(flex: 3),

                      // Maharashtra State Seal & Marathi Header
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/maharashtra_seal.png',
                            height: 64,
                            width: 64,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.govtOfMaharashtra,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.revenueDepartment,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.minorMineralTransportSystem,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(flex: 4),

                      // Center Title: Mahakhanij 2•0
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

                      const Spacer(flex: 5),

                      // Bottom Mining Landscape Banner Illustration
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

