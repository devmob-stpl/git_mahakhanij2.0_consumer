import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../config/globals.dart';
import '../../providers/locale_provider.dart';

/// Centralized utility for checking network/internet connectivity
/// before making any API requests, and displaying localized error messages.
class NetworkChecker {
  NetworkChecker._();

  /// Testing override to simulate online or offline environments in unit/widget tests.
  static bool? testOverrideIsConnected;

  /// Returns the current localized offline message based on the active app language.
  static String get offlineMessage => LocaleNotifier.currentLocalizations.noInternetConnection;

  /// Checks if the device has an active mobile network or internet connection.
  /// If [host] is provided, attempts DNS lookup for that host. Otherwise, checks a reliable DNS target.
  static Future<bool> isConnected([String? host]) async {
    if (testOverrideIsConnected != null) {
      return testOverrideIsConnected!;
    }

    String targetHost = 'google.com';
    if (host != null && host.trim().isNotEmpty) {
      String cleaned = host.trim();
      if (cleaned.contains('://')) {
        try {
          cleaned = Uri.parse(cleaned).host;
        } catch (_) {}
      }
      if (cleaned.contains(':')) {
        cleaned = cleaned.split(':').first;
      }
      if (cleaned.isNotEmpty) {
        targetHost = cleaned;
      }
    }

    try {
      final result = await InternetAddress.lookup(targetHost).timeout(
        const Duration(seconds: 3),
      );
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      // Fallback check to 1.1.1.1 in case DNS resolution of target host stalled
      try {
        final fallback = await InternetAddress.lookup('1.1.1.1').timeout(
          const Duration(seconds: 2),
        );
        return fallback.isNotEmpty && fallback[0].rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  /// Displays the localized offline error message in the currently selected language
  /// via the application's root [scaffoldMessengerKey].
  static void showOfflineMessage() {
    try {
      final messenger = scaffoldMessengerKey.currentState;
      if (messenger == null) return;

      final msg = offlineMessage;
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      // Safely ignore if WidgetsBinding is uninitialized (e.g. CLI or unit test)
    }
  }

  /// Convenience pre-flight helper: checks connectivity, and if offline,
  /// immediately displays the localized offline error message and returns false.
  static Future<bool> checkOrNotify([String? host]) async {
    final online = await isConnected(host);
    if (!online) {
      showOfflineMessage();
      return false;
    }
    return true;
  }
}
