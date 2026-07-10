import 'package:flutter/material.dart';

/// Static design palette used by `unified_fields` for default field chrome
/// (label color, hint color, borders, sheets) and for several semantic accents
/// that internal widgets reuse.
///
/// Most consumers should override colors via [UnifiedInputDecoration],
/// [UnifiedInputPalette], or a wrapping [Theme] rather than reading from this
/// class directly — these tokens are kept public mainly because the unified
/// inputs themselves reference them at default-style positions.
class UnifiedColors {
  UnifiedColors._();

  /// Default brand primary.
  static const primaryColor = Color.fromRGBO(50, 118, 177, 1);

  /// Dark variant of [primaryColor].
  static const primaryColorDark = Color(0xff312D2A);

  /// Secondary accent.
  static const secondaryColor = Color(0xFFF2C94C);

  /// Light scaffold background.
  static const scaffoldBackgroundColor = Color(0xFFF5F7FA);

  /// Dark scaffold background.
  static const scaffoldBackgroundColorDark = Color(0xff312D2A);

  /// Default surface for cards.
  static const cardColor = Colors.white;

  /// Default divider color.
  static const dividerColor = Color.fromRGBO(62, 57, 52, 1);

  /// Body text on light surfaces.
  static const textColor = Color(0xFF333333);

  /// Body text on dark / tinted surfaces (also used by field labels in dark mode).
  static const textColorDark = Color(0xFFE3DACF);

  /// Default label / field text for [Brightness.light] (see [fieldTextFor]).
  static Color fieldTextFor(Brightness brightness) =>
      brightness == Brightness.dark ? textColorDark : textColor;

  /// Same as [fieldTextFor] — semantic alias for labels.
  static Color fieldLabelFor(Brightness brightness) => fieldTextFor(brightness);

  /// Disabled variant of [textColorDark].
  static const textColorDarkDisable = Color.fromRGBO(227, 218, 207, 0.16);

  /// Soft neutral used for "unreached" steps / progress.
  static const unreached = Color.fromRGBO(120, 114, 108, 1);

  /// Border for unselected list items / chips.
  static const unSelectedBorder = Color.fromRGBO(61, 59, 58, 1);

  /// Hint / placeholder text color.
  static const hintColor = Color(0xFF736E6B);

  /// Headline text color.
  static const headlineColor = Color(0xFF1A1A1A);

  /// Subhead text color.
  static const subheadColor = Color(0xFF666666);

  /// Default disabled control color.
  static final disabledColor = Colors.grey.shade400;

  /// Light border.
  static const borderColor = Color(0xFFE0E0E0);

  /// Lighter border variant.
  static const borderColor1 = Color(0xFFE9E9E9);

  /// Darker border variant.
  static const borderColor2 = Color(0xFF6C6C6C);

  /// Default error color.
  static const errorColor = Color(0xFFB00020);

  /// Success / confirmation green.
  static const mainGreen = Color(0xFF08AB7D);
}
