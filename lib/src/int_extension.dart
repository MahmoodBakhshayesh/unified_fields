/// Small numeric helpers used by the unified fields.
extension IntUtils on int? {
  /// Returns `null` for `null`, otherwise a zero-padded two-character string for values < 10.
  String? get withTwoNumberFormat {
    final value = this;
    if (value == null) return null;

    if (value < 10) return '0$value';
    return '$value';
  }
}
