import 'package:flutter/services.dart';

/// TextInputFormatter that strictly enforces Indian PAN (Permanent Account Number) rules:
/// 1. Maximum length of 10 characters.
/// 2. Automatically converts all alphabetic characters to UPPERCASE.
/// 3. Characters 1-5 (indices 0..4): Letters ONLY ([A-Z]).
/// 4. Characters 6-9 (indices 5..8): Digits ONLY ([0-9]).
/// 5. Character 10 (index 9): Letter ONLY ([A-Z]).
/// 6. Strictly rejects:
///    - Whitespace and spaces
///    - Emojis and unicode symbols
///    - Special characters and punctuation (e.g. , . - # @ &)
///    - Non-Latin characters (Devanagari, Marathi, Hindi, etc.)
///    - Digits in positions 1-5 or position 10
///    - Letters in positions 6-9
/// 7. Allows backspacing, deleting, and full clearing naturally.
class PanInputFormatter extends TextInputFormatter {
  const PanInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. If deleting / backspacing, allow unconditionally to maintain natural editing flow
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // 2. If completely empty, allow
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 3. Trim and uppercase raw text
    final rawText = newValue.text.toUpperCase();
    final buffer = StringBuffer();

    for (int i = 0; i < rawText.length; i++) {
      if (buffer.length >= 10) break;
      final char = rawText[i];
      final pos = buffer.length;

      if (pos < 5) {
        // Characters 1 to 5 (indices 0..4): Letters A-Z only
        if (RegExp(r'^[A-Z]$').hasMatch(char)) {
          buffer.write(char);
        }
      } else if (pos < 9) {
        // Characters 6 to 9 (indices 5..8): Digits 0-9 only
        if (RegExp(r'^[0-9]$').hasMatch(char)) {
          buffer.write(char);
        }
      } else if (pos == 9) {
        // Character 10 (index 9): Letter A-Z only
        if (RegExp(r'^[A-Z]$').hasMatch(char)) {
          buffer.write(char);
        }
      }
    }

    final formattedText = buffer.toString();

    // If no valid characters were found (e.g. user typed Marathi, emojis, or spaces)
    if (formattedText.isEmpty) {
      return oldValue.text.isEmpty ? TextEditingValue.empty : oldValue;
    }

    if (formattedText == oldValue.text) {
      return oldValue;
    }

    // Determine correct cursor position
    int selectionIndex = formattedText.length;
    if (newValue.selection.end <= formattedText.length) {
      selectionIndex = newValue.selection.end;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
