import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A global wrapper that displays a native iOS-style "Done" accessory toolbar
/// directly above the keyboard whenever a keyboard is open on iOS devices.
///
/// This provides iOS users with a convenient, native way to dismiss keyboards,
/// particularly for numeric, phone, and PIN keypads which lack a native return key.
class IosKeyboardDoneWrapper extends StatelessWidget {
  final Widget child;

  const IosKeyboardDoneWrapper({super.key, required this.child});

  /// Checks whether the current runtime environment is iOS.
  static bool get isIOS =>
      !kIsWeb && (Platform.isIOS || defaultTargetPlatform == TargetPlatform.iOS);

  static const double toolbarHeight = 44.0;

  @override
  Widget build(BuildContext context) {
    if (!isIOS) {
      return child;
    }

    final mediaQuery = MediaQuery.of(context);
    final double keyboardHeight = mediaQuery.viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 20.0;

    return Stack(
      children: [
        // Screen content with adjusted viewInsets so content is not obscured by the toolbar
        MediaQuery(
          data: isKeyboardOpen
              ? mediaQuery.copyWith(
            viewInsets: mediaQuery.viewInsets.copyWith(
              bottom: keyboardHeight + toolbarHeight,
            ),
          )
              : mediaQuery,
          child: child,
        ),

        // Native iOS "Done" accessory bar
        if (isKeyboardOpen)
          Positioned(
            left: 0,
            right: 0,
            bottom: keyboardHeight,
            child: const _IosKeyboardToolbar(height: toolbarHeight),
          ),
      ],
    );
  }
}

class _IosKeyboardToolbar extends StatelessWidget {
  final double height;

  const _IosKeyboardToolbar({required this.height});

  void _dismissKeyboard() {
    HapticFeedback.lightImpact();
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF6F6F6),
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD1D1D6),
              width: 0.5,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, -1),
              blurRadius: 2,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: Size(0, height),
                onPressed: _dismissKeyboard,
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
