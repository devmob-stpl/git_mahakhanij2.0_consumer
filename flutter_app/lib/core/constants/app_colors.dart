import 'package:flutter/material.dart';

/// Mahakhanij Consumer App 2.0 - Core Color Tokens
/// Directly mapped from `src/design-system/tokens.css`
class AppColors {
  AppColors._();

  // Neutral Scale
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral25 = Color(0xFFF8FAFC);
  static const Color neutral50 = Color(0xFFF1F5F9);
  static const Color neutral100 = Color(0xFFEFF2F7);
  static const Color neutral200 = Color(0xFFDDE3EE); // Hairline separator (line)
  static const Color neutral300 = Color(0xFFCBD5E1); // Emphasized border (line-strong)
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569); // Supporting text
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A); // Primary ink

  // Primary Institutional Blue Scale
  static const Color primary50 = Color(0xFFEEF4FE);
  static const Color primary100 = Color(0xFFDCE8FD);
  static const Color primary200 = Color(0xFFBFD5FB);
  static const Color primary300 = Color(0xFF91B9F8);
  static const Color primary400 = Color(0xFF5A91F0);
  static const Color primary500 = Color(0xFF1A5FE8);
  static const Color primary600 = Color(0xFF1550CC);
  static const Color primary700 = Color(0xFF1241A6); // Primary Brand & Active CTA
  static const Color primary800 = Color(0xFF123788);
  static const Color primary900 = Color(0xFF132F6D);

  // Success Green Scale
  static const Color success50 = Color(0xFFDCFCE7);
  static const Color success100 = Color(0xFFBBF7D0);
  static const Color success200 = Color(0xFF86EFAC);
  static const Color success500 = Color(0xFF16A34A);
  static const Color success600 = Color(0xFF15803D);
  static const Color success700 = Color(0xFF166534);

  // Warning Amber Scale
  static const Color warning50 = Color(0xFFFEF3C7);
  static const Color warning100 = Color(0xFFFDE68A);
  static const Color warning200 = Color(0xFFFCD34D);
  static const Color warning500 = Color(0xFFD97706);
  static const Color warning600 = Color(0xFFB45309);
  static const Color warning700 = Color(0xFF92400E);

  // Danger Red Scale
  static const Color danger50 = Color(0xFFFEE2E2);
  static const Color danger100 = Color(0xFFFECACA);
  static const Color danger200 = Color(0xFFFCA5A5);
  static const Color danger500 = Color(0xFFDC2626);
  static const Color danger600 = Color(0xFFB91C1C);
  static const Color danger700 = Color(0xFF991B1B);

  // Semantic Surface & Ink Aliases
  static const Color canvas = neutral25;
  static const Color surface = neutral0;
  static const Color surfaceSunken = neutral100;
  static const Color line = neutral200;
  static const Color lineStrong = neutral300;
  static const Color ink = neutral900;
  static const Color inkSecondary = neutral600;
  static const Color inkMuted = neutral400;
}
