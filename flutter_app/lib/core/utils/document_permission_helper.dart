import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';

/// Source options for document uploads
enum DocumentUploadSource {
  camera,
  gallery,
  file,
}

/// Helper utility for handling permissions for Aadhaar and PAN document uploads
/// across Camera, Gallery (Photo Picker), and File Manager (Storage Access Framework).
///
/// Architecture & Android Permission Design:
/// 1. Camera:
///    - Requires `android.permission.CAMERA` in `AndroidManifest.xml`.
///    - Has a dedicated toggle in Android App Settings.
///    - If denied twice or permanently denied, displays a user-friendly dialog with
///      an "Open Settings" action directing the user to the app's settings where the
///      Camera toggle is genuinely present.
/// 2. Gallery (Android Photo Picker) & File Manager (Storage Access Framework - SAF):
///    - As per Google Play policies and strict user requirements, NO storage permissions
///      (`READ_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES`) are added to `AndroidManifest.xml`.
///    - Because storage permissions are NOT in `AndroidManifest.xml`, Android OS does NOT
///      display a Gallery or File permission toggle in the app's system Settings screen.
///    - Directing users to Android Settings for Gallery or File access causes dead-end confusion
///      where options are missing.
///    - Instead, Gallery and File Manager utilize Android's official permission-free system
///      pickers (Photo Picker and Storage Access Framework), allowing users to select
///      Aadhaar and PAN documents directly without permission obstacles.
class DocumentPermissionHelper {
  DocumentPermissionHelper._();

  static const String prefCameraDenialCount = 'pref_permission_denial_count_camera';
  static const String prefGalleryDenialCount = 'pref_permission_denial_count_gallery';
  static const String prefFileDenialCount = 'pref_permission_denial_count_file';

  static const String prefCameraGranted = 'pref_permission_granted_camera';
  static const String prefGalleryGranted = 'pref_permission_granted_gallery';
  static const String prefFileGranted = 'pref_permission_granted_file';

  // Test injection hooks for unit tests
  @visibleForTesting
  static Future<PermissionStatus> Function(Permission permission)? testStatusChecker;

  @visibleForTesting
  static Future<PermissionStatus> Function(Permission permission)? testRequestRunner;

  @visibleForTesting
  static Future<bool> Function()? testOpenSettingsRunner;

  @visibleForTesting
  static bool? testPermissionDialogResult;

  /// Returns the storage key for tracking denials by source
  static String getDenialKey(DocumentUploadSource source) {
    switch (source) {
      case DocumentUploadSource.camera:
        return prefCameraDenialCount;
      case DocumentUploadSource.gallery:
        return prefGalleryDenialCount;
      case DocumentUploadSource.file:
        return prefFileDenialCount;
    }
  }

  /// Returns the storage key for tracking granted status by source
  static String getGrantedKey(DocumentUploadSource source) {
    switch (source) {
      case DocumentUploadSource.camera:
        return prefCameraGranted;
      case DocumentUploadSource.gallery:
        return prefGalleryGranted;
      case DocumentUploadSource.file:
        return prefFileGranted;
    }
  }

  /// Checks if permission has been granted
  static Future<bool> isPermissionGranted(DocumentUploadSource source) async {
    try {
      if (source == DocumentUploadSource.camera) {
        if (testStatusChecker != null) {
          final s = await testStatusChecker!(Permission.camera);
          if (s.isGranted || s.isLimited) return true;
        } else {
          final status = await Permission.camera.status;
          if (status.isGranted || status.isLimited) return true;
        }
      }
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(getGrantedKey(source)) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Sets permission granted status in SharedPreferences
  static Future<void> setPermissionGranted(DocumentUploadSource source, bool granted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(getGrantedKey(source), granted);
    } catch (_) {}
  }

  /// Gets current denial count from SharedPreferences
  static Future<int> getDenialCount(DocumentUploadSource source) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(getDenialKey(source)) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Increments denial count and returns the updated count
  static Future<int> incrementDenialCount(DocumentUploadSource source) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(getDenialKey(source)) ?? 0;
      final updated = current + 1;
      await prefs.setInt(getDenialKey(source), updated);
      return updated;
    } catch (_) {
      return 1;
    }
  }

  /// Resets denial count to 0 (called when permission is granted)
  static Future<void> resetDenialCount(DocumentUploadSource source) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(getDenialKey(source), 0);
    } catch (_) {}
  }

  /// Unified permission request entry point.
  /// Returns `true` if document picking may proceed, or `false` if permission was denied.
  static Future<bool> requestUploadPermission({
    required BuildContext context,
    required DocumentUploadSource source,
    String? documentType,
  }) async {
    switch (source) {
      case DocumentUploadSource.camera:
        return _handleCameraPermission(context, documentType: documentType);
      case DocumentUploadSource.gallery:
        return _handleGalleryPermission(context, documentType: documentType);
      case DocumentUploadSource.file:
        return _handleFilePermission(context, documentType: documentType);
    }
  }

  /// Handles Camera permission workflow.
  /// Camera is declared in AndroidManifest.xml and exists in Android App Settings.
  static Future<bool> _handleCameraPermission(
    BuildContext context, {
    String? documentType,
  }) async {
    final denialCount = await getDenialCount(DocumentUploadSource.camera);

    // 1. Check existing permission status
    final PermissionStatus status;
    if (testStatusChecker != null) {
      status = await testStatusChecker!(Permission.camera);
    } else {
      status = await Permission.camera.status;
    }

    if (status.isGranted || status.isLimited) {
      await resetDenialCount(DocumentUploadSource.camera);
      await setPermissionGranted(DocumentUploadSource.camera, true);
      return true;
    }

    // 2. If already permanently denied or denied twice before, prompt directly for Settings
    if (status.isPermanentlyDenied || denialCount >= 2) {
      if (context.mounted) {
        await showRepeatedDenialDialog(
          context: context,
          source: DocumentUploadSource.camera,
          documentType: documentType,
        );
      }
      return false;
    }

    // 3. Request system Camera permission
    final PermissionStatus requestResult;
    if (testRequestRunner != null) {
      requestResult = await testRequestRunner!(Permission.camera);
    } else {
      requestResult = await Permission.camera.request();
    }

    if (requestResult.isGranted || requestResult.isLimited) {
      await resetDenialCount(DocumentUploadSource.camera);
      await setPermissionGranted(DocumentUploadSource.camera, true);
      return true;
    }

    // 4. Handle rejection
    final updatedCount = await incrementDenialCount(DocumentUploadSource.camera);
    if (!context.mounted) return false;

    if (requestResult.isPermanentlyDenied || updatedCount >= 2) {
      await showRepeatedDenialDialog(
        context: context,
        source: DocumentUploadSource.camera,
        documentType: documentType,
      );
    } else {
      showFirstDenialNotice(
        context: context,
        source: DocumentUploadSource.camera,
        documentType: documentType,
      );
    }

    return false;
  }

  /// Handles Gallery permission workflow.
  /// On Android, Gallery selection utilizes the Android Photo Picker
  /// (PickVisualMedia / ACTION_PICK_IMAGES), which is the official permission-free
  /// standard recommended by Google. It does NOT declare or require storage permissions
  /// in AndroidManifest.xml.
  ///
  /// Because no storage permissions are declared in the manifest, Android Settings
  /// does not and cannot display a Gallery/Storage permission toggle for this app.
  /// Therefore, users must NEVER be directed to Settings for Gallery access.
  /// Instead, the app directly grants access to the Photo Picker, allowing users
  /// to select their Aadhaar or PAN photo smoothly without permission obstacles.
  static Future<bool> _handleGalleryPermission(
    BuildContext context, {
    String? documentType,
  }) async {
    // Clear any legacy denial count to unblock users who were previously trapped
    await resetDenialCount(DocumentUploadSource.gallery);
    await setPermissionGranted(DocumentUploadSource.gallery, true);

    if (testRequestRunner != null) {
      await testRequestRunner!(Permission.photos);
    }

    // Modern Android Photo Picker is completely permission-free.
    // Proceed directly with image picking.
    return true;
  }

  /// Handles File selection workflow.
  /// File selection utilizes the Storage Access Framework (SAF / ACTION_OPEN_DOCUMENT),
  /// which is Android's official permission-free standard for selecting documents.
  /// It does NOT declare or require storage permissions in AndroidManifest.xml.
  ///
  /// Because no storage permissions are declared in the manifest, Android Settings
  /// does not display a Files/Storage permission toggle for this app.
  /// Therefore, users must NEVER be directed to Settings for File access.
  /// Instead, the app directly launches the Storage Access Framework so users
  /// can select their Aadhaar or PAN PDF/document without permission obstacles.
  static Future<bool> _handleFilePermission(
    BuildContext context, {
    String? documentType,
  }) async {
    // Clear any legacy denial count to unblock users who were previously trapped
    await resetDenialCount(DocumentUploadSource.file);
    await setPermissionGranted(DocumentUploadSource.file, true);

    if (testRequestRunner != null) {
      await testRequestRunner!(Permission.storage);
    }

    // SAF is completely permission-free.
    // Proceed directly with file picking.
    return true;
  }

  /// Checks if an error caught during picker invocation is a permission/access rejection
  static bool isPermissionException(Object error) {
    if (error is PlatformException) {
      final code = error.code.toLowerCase();
      final msg = (error.message ?? '').toLowerCase();
      if (code.contains('denied') ||
          code.contains('permission') ||
          code.contains('access') ||
          msg.contains('permission') ||
          msg.contains('access_denied') ||
          msg.contains('denied')) {
        return true;
      }
    }
    final str = error.toString().toLowerCase();
    return str.contains('permission') || str.contains('access_denied');
  }

  /// Handles late permission exceptions during file or image picking
  static Future<void> handlePermissionException({
    required BuildContext context,
    required DocumentUploadSource source,
    required Object error,
    String? documentType,
  }) async {
    if (source == DocumentUploadSource.camera) {
      final updatedCount = await incrementDenialCount(source);
      if (!context.mounted) return;

      if (updatedCount >= 2) {
        await showRepeatedDenialDialog(
          context: context,
          source: source,
          documentType: documentType,
        );
      } else {
        showFirstDenialNotice(
          context: context,
          source: source,
          documentType: documentType,
        );
      }
    } else {
      if (!context.mounted) return;
      showFirstDenialNotice(
        context: context,
        source: source,
        documentType: documentType,
      );
    }
  }

  /// Displays user-friendly Repeated Denial Dialog explaining that Camera permission
  /// must be enabled from Settings, with an option to open Settings directly.
  /// (Strictly for Camera, since Camera is the only permission present in Android App Settings).
  static Future<void> showRepeatedDenialDialog({
    required BuildContext context,
    required DocumentUploadSource source,
    String? documentType,
  }) async {
    final l10n = AppLocalizations.of(context);
    final String title = l10n?.permissionRequiredTitle ?? 'Permission Required';

    final String message = l10n?.cameraPermissionDeniedTwice ??
        'Camera permission has been denied. To capture and upload documents, please enable Camera permission in the app\'s Settings.';

    final String cancelText = l10n?.cancel ?? 'Cancel';
    final String openSettingsText = l10n?.openSettings ?? 'Open Settings';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings_suggest_outlined,
                  color: Color(0xFFD97706),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                cancelText,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (testOpenSettingsRunner != null) {
                  await testOpenSettingsRunner!();
                } else {
                  await openAppSettings();
                }
              },
              child: Text(
                openSettingsText,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Displays first-time denial notice / hint
  static void showFirstDenialNotice({
    required BuildContext context,
    required DocumentUploadSource source,
    String? documentType,
  }) {
    final l10n = AppLocalizations.of(context);
    final String message;
    switch (source) {
      case DocumentUploadSource.camera:
        message = l10n?.cameraPermissionRequired ??
            'Camera permission is required to capture documents.';
        break;
      case DocumentUploadSource.gallery:
        message = l10n?.storagePhotosPermissionReq ??
            'Storage/Photos permission is required to select from gallery.';
        break;
      case DocumentUploadSource.file:
        message = l10n?.storagePermissionReq ??
            'Storage permission is required to pick documents.';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFB45309),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
