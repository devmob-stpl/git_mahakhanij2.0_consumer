import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final int notificationCount;
  final VoidCallback? onNotificationClick;

  const HomeHeader({
    super.key,
    required this.userName,
    this.notificationCount = 4,
    this.onNotificationClick,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Light icons for dark navy header on Android
        statusBarBrightness: Brightness.dark,       // Light text for iOS status bar
      ),
      child: Container(
        color: const Color(0xFF2563EB), // Institutional navy matching React tokens
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: topPadding + 8,
          bottom: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/mahakhanij-emblem.png',
                  height: 36,
                  width: 36,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFD4D4D4),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
