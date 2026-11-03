import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/api_error_localizer.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../providers/session_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoggingOut = false;
  bool _isDeletingAccount = false;

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      final response = await ref.read(sessionProvider.notifier).logout();

      if (!mounted) return;

      if (response.isSuccess) {
        final successMsg = (response.responseData != null && response.responseData.toString().trim().isNotEmpty)
            ? response.responseData.toString().trim()
            : response.statusMessage;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            backgroundColor: const Color(0xFF2563EB),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/login');
      } else {
        setState(() {
          _isLoggingOut = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.statusMessage.isNotEmpty
                  ? ApiErrorLocalizer.localize(context, response.statusMessage, defaultMessage: AppLocalizations.of(context)!.logoutFailedMsg)
                  : AppLocalizations.of(context)!.logoutFailedMsg,
            ),
            backgroundColor: AppColors.danger600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoggingOut = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ApiErrorLocalizer.localize(
              context,
              e.toString(),
              defaultMessage: AppLocalizations.of(context)!.logoutFailedMsg,
            ),
          ),
          backgroundColor: AppColors.danger600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDeleteAccount() async {
    setState(() {
      _isDeletingAccount = true;
    });

    try {
      final response = await ref.read(sessionProvider.notifier).deleteAccount();

      debugPrint("_handleDeleteAccount response $response");
      debugPrint("DELETE SUCCESS: ${response.isSuccess}");
      debugPrint("DELETE STATUS CODE: ${response.statusCode}");
      debugPrint("DELETE STATUS MESSAGE: ${response.statusMessage}");
      debugPrint("DELETE RESPONSE DATA: ${response.responseData}");

      if (!mounted) return;

      if (response.isSuccess) {
        final successMsg = (response.responseData != null && response.responseData.toString().trim().isNotEmpty)
            ? response.responseData.toString().trim()
            : response.statusMessage;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg.isNotEmpty ? successMsg : 'Account deleted successfully'),
            backgroundColor: AppColors.danger600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/login');
      } else {
        setState(() {
          _isDeletingAccount = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.statusMessage.isNotEmpty
                ? response.statusMessage
                : 'Failed to delete account.'),
            backgroundColor: AppColors.danger600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDeletingAccount = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting account: ${e.toString()}'),
          backgroundColor: AppColors.danger600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.settingsScreenTitle,
      showBackButton: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSectionHeader(l10n.preferencesHeader),
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language, color: AppColors.primary700, size: 24),
                      const SizedBox(width: 14),
                      Text(
                        l10n.changeLanguageLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    value: locale.languageCode,
                    underline: const SizedBox(),
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary700,
                    ),
                    onChanged: (String? newLocale) {
                      if (newLocale != null) {
                        ref.read(localeProvider.notifier).setLocale(Locale(newLocale));
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English (EN)')),
                      DropdownMenuItem(value: 'hi', child: Text('हिंदी (HI)')),
                      DropdownMenuItem(value: 'mr', child: Text('मराठी (MR)')),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            const SizedBox(height: 32),

            // Sign Out Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger600,
                  side: const BorderSide(color: AppColors.danger200),
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: (_isLoggingOut || _isDeletingAccount) ? null : _handleLogout,
                child: _isLoggingOut
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.danger600,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, size: 18, color: AppColors.danger600),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.logoutBtn,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.danger600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

          if (Platform.isIOS) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: (_isLoggingOut || _isDeletingAccount) ? null : _showDeleteAccountDialog,
                  icon: _isDeletingAccount
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                        )
                      : const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  label: Text(
                    _isDeletingAccount ? 'Deleting Account...' : 'Delete Account',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ],

          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.canvas,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Account?'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _handleDeleteAccount();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

}
