import 'package:flutter/widgets.dart';

import '../unified_date_picker_types.dart';
import '../unified_fields_typography.dart';
import '../phone/unified_country.dart';
import '../phone/unified_phone_format.dart';
import '../phone/unified_phone_models.dart';
import 'base_unified_field_controller.dart';

/// Controller for [UnifiedPhoneField].
class UnifiedPhoneFieldController extends BaseUnifiedFieldController<UnifiedPhoneNumber> {
  /// Creates a phone field controller.
  UnifiedPhoneFieldController({
    UnifiedPhoneNumber? initialValue,
    UnifiedCountry? initialCountry,
    super.validator,
    FocusNode? focusNode,
    TextEditingController? nationalController,
    TextEditingController? dialCodeController,
    List<UnifiedCountry>? countries,
  }) : countries = countries ?? UnifiedCountries.defaults,
       nationalController = nationalController ?? TextEditingController(),
       dialCodeController = dialCodeController ?? TextEditingController(text: '+'),
       _ownsNational = nationalController == null,
       _ownsDial = dialCodeController == null,
       super(
         initialValue: initialValue,
         focusNode: focusNode,
       ) {
    country = initialValue?.country ??
        initialCountry ??
        UnifiedCountries.defaultCountry;
    if (initialValue != null) {
      this.nationalController.text = useUnifiedTextEntry
          ? _displayUnifiedRaw(
              '${initialValue.country.dialCode}${initialValue.nationalDigits}',
            )
          : _displayNational(initialValue.nationalDigits);
      this.dialCodeController.text = unifiedPhoneLocalizeDisplay(
        initialValue.country.dialCode,
        usePersianDigits: usePersianDigits,
        digitCalendarKind: digitCalendarKind,
      );
    } else if (initialCountry != null) {
      this.dialCodeController.text = unifiedPhoneLocalizeDisplay(
        initialCountry.dialCode,
        usePersianDigits: usePersianDigits,
        digitCalendarKind: digitCalendarKind,
      );
      if (useUnifiedTextEntry) {
        this.nationalController.text = _displayUnifiedRaw(initialCountry.dialCode);
      }
    }
    this.nationalController.addListener(_onNationalChanged);
    this.dialCodeController.addListener(_onDialChanged);
    _syncValueFromControllers();
  }

  /// Country list used for matching and pickers.
  final List<UnifiedCountry> countries;

  /// National number entry.
  final TextEditingController nationalController;

  /// Dial code entry (`+` …) when the code section is editable.
  final TextEditingController dialCodeController;

  final bool _ownsNational;
  final bool _ownsDial;

  /// Currently selected country.
  late UnifiedCountry country;

  /// When true, [nationalController] stores `+` + dial + national in one string.
  bool useUnifiedTextEntry = false;

  /// When `true`, display uses Persian digits; when `false`, ASCII. Null uses [digitCalendarKind] / global typography.
  bool? usePersianDigits;

  /// Jalali calendar fields use Persian digits when [usePersianDigits] is null.
  UnifiedFieldsCalendarKind? digitCalendarKind;

  /// National mask for display formatting (`#` = digit).
  String? nationalMask;

  String get _effectiveMask => nationalMask ?? kUnifiedPhoneDefaultNationalMask;

  String _displayNational(String asciiDigits) => unifiedPhoneLocalizeDisplay(
        applyUnifiedPhoneMask(asciiDigits, _effectiveMask),
        usePersianDigits: usePersianDigits,
        digitCalendarKind: digitCalendarKind,
      );

  String _displayUnifiedFull(String asciiAfterPlus) => formatUnifiedFullPhoneText(
        asciiAfterPlus,
        nationalMask: _effectiveMask,
        countries: countries,
        usePersianDigits: usePersianDigits,
        digitCalendarKind: digitCalendarKind,
      );

  String _displayUnifiedRaw(String asciiWithPlus) {
    if (!unifiedPhoneUsePersianDigits(
      usePersianDigits: usePersianDigits,
      digitCalendarKind: digitCalendarKind,
    )) {
      return asciiWithPlus;
    }
    final digits = unifiedPhoneDigitsOnly(asciiWithPlus);
    return _displayUnifiedFull(digits);
  }

  void _onNationalChanged() => _syncValueFromControllers();
  void _onDialChanged() => _syncValueFromControllers();

  void _syncValueFromControllers() {
    final raw = nationalController.text.replaceAll(RegExp(r'\s'), '');
    UnifiedPhoneNumber? next;
    if (useUnifiedTextEntry && raw.startsWith('+')) {
      final matched = UnifiedCountries.matchDialCode(raw, countries);
      if (matched != null) {
        country = matched;
        final national = unifiedPhoneDigitsOnly(
          raw.substring(matched.dialCode.length),
        );
        next = national.isEmpty
            ? null
            : UnifiedPhoneNumber(country: matched, nationalDigits: national);
      }
    } else {
      final national = unifiedPhoneDigitsOnly(raw);
      next = national.isEmpty
          ? null
          : UnifiedPhoneNumber(country: country, nationalDigits: national);
    }
    if (value == next) return;
    silentSetValue(next);
    notifyListeners();
  }

  /// Updates [country] and controllers.
  ///
  /// When [unifiedTextField] is true, [nationalController] holds `+` + dial + national
  /// and [dialCodeController] is kept in sync for compatibility.
  void setCountry(
    UnifiedCountry next, {
    bool updateDialController = true,
    bool? unifiedTextField,
  }) {
    country = next;
    final unified = unifiedTextField ?? useUnifiedTextEntry;
    if (unified) {
      var nationalPart = value?.nationalDigits ?? '';
      final raw = nationalController.text;
      if (raw.startsWith('+')) {
        final prev = UnifiedCountries.matchDialCode(raw, countries);
        if (prev != null) {
          nationalPart = unifiedPhoneDigitsOnly(
            raw.substring(prev.dialCode.length),
          );
        }
      }
      nationalController.text = _displayUnifiedRaw('${next.dialCode}$nationalPart');
      if (updateDialController) {
        dialCodeController.text = unifiedPhoneLocalizeDisplay(
          next.dialCode,
          usePersianDigits: usePersianDigits,
          digitCalendarKind: digitCalendarKind,
        );
      }
    } else if (updateDialController) {
      dialCodeController.text = unifiedPhoneLocalizeDisplay(
        next.dialCode,
        usePersianDigits: usePersianDigits,
        digitCalendarKind: digitCalendarKind,
      );
    }
    _syncValueFromControllers();
  }

  @override
  set value(UnifiedPhoneNumber? next) {
    if (next == null) {
      nationalController.clear();
      dialCodeController.text = unifiedPhoneLocalizeDisplay(
        '+',
        usePersianDigits: usePersianDigits,
        digitCalendarKind: digitCalendarKind,
      );
      if (useUnifiedTextEntry) {
        nationalController.text = dialCodeController.text;
      }
    } else {
      country = next.country;
      dialCodeController.text = unifiedPhoneLocalizeDisplay(
        next.country.dialCode,
        usePersianDigits: usePersianDigits,
        digitCalendarKind: digitCalendarKind,
      );
      nationalController.text = useUnifiedTextEntry
          ? _displayUnifiedRaw(
              '${next.country.dialCode}${next.nationalDigits}',
            )
          : _displayNational(next.nationalDigits);
    }
    silentSetValue(next);
    notifyListeners();
  }

  /// Sets the full `+…` text used in single-field entry mode.
  void setFullPhoneText(String text) {
    final ascii = UnifiedFieldsTypography.fromPersianDigits(
      text.startsWith('+') ? text : '+$text',
    );
    nationalController.text = _displayUnifiedRaw(ascii);
    dialCodeController.text = unifiedPhoneLocalizeDisplay(
      _matchedDialPrefix(ascii) ?? '+',
      usePersianDigits: usePersianDigits,
      digitCalendarKind: digitCalendarKind,
    );
    _syncValueFromControllers();
  }

  String? _matchedDialPrefix(String raw) {
    if (!raw.startsWith('+')) return null;
    final matched = UnifiedCountries.matchDialCode(raw, countries);
    return matched?.dialCode;
  }

  @override
  String? validate() {
    final err = validator?.call(value);
    if (err != null && err.isNotEmpty) {
      setError(err);
      return err;
    }
    clearError();
    return null;
  }

  @override
  void dispose() {
    nationalController.removeListener(_onNationalChanged);
    dialCodeController.removeListener(_onDialChanged);
    if (_ownsNational) nationalController.dispose();
    if (_ownsDial) dialCodeController.dispose();
    super.dispose();
  }
}
