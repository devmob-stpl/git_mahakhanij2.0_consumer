/// Utility to localize measurement and mineral units according to selected locale.
class UnitLocalizer {
  /// Returns the localized string for a quantity unit (e.g. 'Brass' -> 'ब्रास').
  static String localize(String? unit, String localeName) {
    if (unit == null || unit.trim().isEmpty) return '';
    final trimmed = unit.trim();
    final lower = trimmed.toLowerCase();

    if (localeName == 'hi' || localeName == 'mr') {
      if (lower == 'brass') {
        return 'ब्रास';
      } else if (lower == 'ton' || lower == 'tons' || lower == 'tonne' || lower == 'tonnes' || lower == 'mt') {
        return 'टन';
      } else if (lower == 'cum' || lower == 'm3') {
        return 'घन मीटर';
      } else if (lower == 'kg' || lower == 'kgs') {
        return 'किग्रा';
      }
    }
    return trimmed;
  }
}
