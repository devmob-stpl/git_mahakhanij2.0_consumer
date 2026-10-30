import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

/// Centralized utility to ensure that raw API error messages, exception strings,
/// and backend status codes are translated and displayed in the user's selected language.
class ApiErrorLocalizer {
  ApiErrorLocalizer._();

  /// Gets the currently active [AppLocalizations] based on the app's selected locale,
  /// without requiring a [BuildContext].
  static AppLocalizations get currentLocalizations => LocaleNotifier.currentLocalizations;

  /// Translates a given [rawMessage] using the currently active locale without needing [BuildContext].
  static String localizeCurrent(
    String? rawMessage, {
    String? defaultMessage,
  }) {
    return localizeWithL10n(currentLocalizations, rawMessage, defaultMessage: defaultMessage);
  }

  /// Translates a given [rawMessage] using the [context]'s current [AppLocalizations].
  /// If [defaultMessage] is supplied, it serves as the fallback when [rawMessage] is empty
  /// or represents a generic error.
  static String localize(
    BuildContext context,
    String? rawMessage, {
    String? defaultMessage,
  }) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return localizeCurrent(rawMessage, defaultMessage: defaultMessage);
    return localizeWithL10n(l10n, rawMessage, defaultMessage: defaultMessage);
  }

  /// Translates a given [rawMessage] using [l10n].
  static String localizeWithL10n(
    AppLocalizations l10n,
    String? rawMessage, {
    String? defaultMessage,
  }) {
    if (rawMessage == null || rawMessage.trim().isEmpty) {
      return defaultMessage ?? l10n.somethingWentWrong;
    }

    String msg = rawMessage.trim();
    if (msg.startsWith('Exception: ')) {
      msg = msg.substring(11).trim();
    }
    if (msg.startsWith('Error: ')) {
      msg = msg.substring(7).trim();
    }

    final lower = msg.toLowerCase();

    // 1. Internet / Connectivity
    if (lower.contains('no internet') ||
        lower.contains('socketexception') ||
        lower.contains('network error') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection refused') ||
        lower.contains('network is unreachable')) {
      return l10n.noInternetConnection;
    }

    // 2. Timeout
    if (lower.contains('timeout') ||
        lower.contains('timed out') ||
        lower.contains('connection timeout') ||
        lower.contains('receive timeout') ||
        lower.contains('send timeout') ||
        lower.contains('gateway timeout') ||
        lower == '408' ||
        lower == '504') {
      return l10n.connectionTimeout;
    }

    // 3. User / Account Availability
    if (lower.contains('user not available') ||
        lower.contains('user not found') ||
        lower.contains('consumer not found') ||
        lower.contains('user does not exist') ||
        lower.contains('account not found') ||
        lower.contains('consumer not registered') ||
        lower.contains('not registered') ||
        lower == 'user not available') {
      return l10n.userNotAvailable;
    }

    // 4. Duplicate / Exists checks
    if (lower.contains('already exists') ||
        lower.contains('already registered') ||
        lower.contains('already exist')) {
      if (lower.contains('aadhaar') || lower.contains('aadhar')) {
        return l10n.aadhaarAlreadyRegistered;
      }
      if (lower.contains('pan')) {
        return l10n.panAlreadyRegistered;
      }
      if (lower.contains('mobile') || lower.contains('phone')) {
        return l10n.mobileAlreadyRegistered;
      }
      return l10n.recordAlreadyExists;
    }

    // 5. File format / upload errors
    if (lower.contains('unsupported file format') ||
        lower.contains('unsupported media type') ||
        lower.contains('valid pdf or image') ||
        lower == '415') {
      return l10n.unsupportedFileFormat;
    }

    if (lower.contains('file size is too large') ||
        lower.contains('size is too large') ||
        lower.contains('payload too large') ||
        lower.contains('content too large') ||
        lower.contains('smaller file (under 5mb)') ||
        lower.contains('file too large') ||
        lower == '413') {
      return l10n.fileSizeTooLarge;
    }

    if (lower.contains('pan document upload failed') || lower.contains('pan doc upload failed')) {
      return l10n.panDocUploadFailed;
    }

    if (lower.contains('document upload failed') || lower.contains('doc upload failed')) {
      return l10n.docUploadFailed;
    }

    // 6. Aadhaar & PAN verification
    if (lower.contains('invalid aadhaar') || lower.contains('invalid aadhar') || lower.contains('verification_failed')) {
      return l10n.invalidAadhaarNumber;
    }

    if (lower.contains('aadhaar server error') || lower.contains('aadhar server error')) {
      return l10n.aadhaarServerError;
    }

    if (lower.contains('invalid pan') || lower.contains('record_not_found') || (lower.contains('pan') && lower.contains('not found'))) {
      return l10n.invalidPanNumber;
    }

    if (lower.contains('pan verification failed')) {
      return l10n.panVerificationFailed;
    }

    // 7. OTP Errors
    if (lower.contains('session expired') || lower.contains('client session')) {
      return l10n.clientSessionExpired;
    }

    if (lower.contains('invalid otp') ||
        lower.contains('incorrect otp') ||
        lower.contains('wrong otp') ||
        lower.contains('otp does not match') ||
        lower.contains('otp mismatch') ||
        lower.contains('invalid_otp')) {
      if (lower.contains('aadhaar') || lower.contains('aadhar')) {
        return l10n.invalidAadhaarOtp;
      }
      return l10n.invalidOtpServer;
    }

    // 8. DigiTP Received
    if (lower.contains('digitp is already received') ||
        lower.contains('invoice is already received') ||
        lower.contains('already received')) {
      return l10n.digitpAlreadyReceived;
    }

    // 9. Project & Site Registration Messages
    if (lower.contains('project registered successfully')) {
      return l10n.projectRegisteredSuccess;
    }
    if (lower.contains('failed to register project')) {
      return l10n.projectRegisterFailed;
    }
    if (lower.contains('private delivery site registered')) {
      return l10n.deliverySiteRegisteredSuccess;
    }
    if (lower.contains('failed to register site')) {
      return l10n.deliverySiteRegisterFailed;
    }

    // 10. Profile Update & Registration
    if (lower.contains('failed to update consumer profile') || lower.contains('failed to update profile')) {
      return l10n.failedToUpdateProfile;
    }

    if (lower.contains('registration failed') || lower.contains('registration failure')) {
      return l10n.registrationFailed;
    }

    if (lower.contains('login failed')) {
      return l10n.loginFailedMsg;
    }

    if (lower.contains('logout failed')) {
      return l10n.logoutFailedMsg;
    }

    // 11. Vehicle Tracking Errors
    if (lower.contains('vehicle number cannot be empty') ||
        lower.contains('vehicle number is required') ||
        lower.contains('enter vehicle no')) {
      return l10n.errVehicleNoRequired;
    }

    // 12. GST Verification
    if (lower.contains('gst verification') ||
        lower.contains('verifying gstin') ||
        lower.contains('gst existence')) {
      return l10n.gstVerificationFailed;
    }

    // 13. Dashboard Counts
    if (lower.contains('dashboard count')) {
      return l10n.failedToFetchDashboardCounts;
    }

    // 14. Delivery & Inventory Not Found
    if (lower.contains('delivery not found')) {
      return l10n.deliveryNotFound;
    }
    if (lower.contains('inventory balance not found')) {
      return l10n.inventoryBalanceNotFound;
    }

    // 15. Invalid / Unexpected Response Formats
    if (lower.contains('invalid response') ||
        lower.contains('invalid profile response') ||
        lower.contains('unexpected response') ||
        lower.contains('unexpected format')) {
      return l10n.invalidResponseFromServer;
    }

    // 16. Generic Server Errors
    if (lower.contains('server error') ||
        lower.contains('internal server error') ||
        lower.contains('service unavailable') ||
        lower.contains('bad gateway') ||
        lower == '500' ||
        lower == '502' ||
        lower == '503' ||
        lower == '0') {
      return l10n.serverErrorTryAgain;
    }

    // If a default message was supplied and the message is generic/cryptic, prefer defaultMessage
    if (defaultMessage != null && defaultMessage.isNotEmpty) {
      if (lower.contains('error') || lower.contains('failed') || lower.contains('dioexception')) {
        return defaultMessage;
      }
    }

    // If message is in Hindi / Marathi or cannot be mapped, return as is (trimmed)
    return msg;
  }
}
