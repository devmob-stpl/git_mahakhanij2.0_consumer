import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/locale_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../l10n/app_localizations.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen> {
  String _selectedLocale = 'en';
  bool _isLoading = false;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'localName': 'English'},
    {'code': 'mr', 'name': 'Marathi', 'localName': 'मराठी'},
    {'code': 'hi', 'name': 'Hindi', 'localName': 'हिंदी'},
  ];

  @override
  void initState() {
    super.initState();
    // Use read outside of build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedLocale = ref.read(localeProvider).languageCode;
        });
      }
    });
  }

  Future<void> _saveAndContinue() async {
    setState(() => _isLoading = true);
    await ref.read(localeProvider.notifier).setLocale(Locale(_selectedLocale));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_selected_language', true);
    
    if (!mounted) return;
    
    // Instead of login directly, go to welcome screen first, or login depending on flow
    // Welcome screen is a better intro for a first-time user
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 40),
              const Text(
                'Choose your language\nतुमची भाषा निवडा',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You can always change this later in settings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.inkSecondary,
                ),
              ),
              const SizedBox(height: 40),
              ..._languages.map((lang) {
                final isSelected = _selectedLocale == lang['code'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLocale = lang['code']!;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary700 : AppColors.line,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang['localName']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppColors.primary800 : AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lang['name']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected ? AppColors.primary600 : AppColors.inkSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary700,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              AppButton(
                label: lookupAppLocalizations(Locale(_selectedLocale)).continueBtn,
                isLoading: _isLoading,
                fullWidth: true,
                size: AppButtonSize.large,
                onPressed: _saveAndContinue,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
