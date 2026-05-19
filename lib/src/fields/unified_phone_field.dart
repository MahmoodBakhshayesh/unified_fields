import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/unified_phone_field_controller.dart';
import '../phone/unified_country.dart';
import '../phone/unified_flag.dart';
import '../phone/unified_phone_country_picker_sheet.dart';
import '../phone/unified_phone_format.dart';
import '../phone/unified_phone_models.dart';
import '../unified_date_picker_types.dart';
import '../unified_fields_typography.dart';
import 'unified_field_label_mode.dart';
import 'unified_input_brightness.dart';
import 'unified_field_decoration_context.dart';
import 'unified_input_decoration.dart';
import 'unified_input_palette.dart';
import 'unified_input_theme.dart';

/// Phone input with country flag prefix, optional dial-code section, phone suffix, and mask.
///
/// - Set [fixedCountry] to lock the dial code and edit national digits only.
/// - When [showCountryCodeSection] and [editableCountryCode] are true, one field accepts
///   `+` plus country-code and national digits (no second dial-code text field).
/// - When the code section is shown but not editable, dial code is a label + national field.
/// - Tap the flag prefix to open the country picker (unless [fixedCountry] is set).
///
/// Chrome is controlled by [phoneStyle] and [UnifiedInputThemeData.phoneStyle].
class UnifiedPhoneField extends StatefulWidget {
  /// Creates a unified phone field.
  const UnifiedPhoneField({
    super.key,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.phoneStyle,
    this.fieldController,
    this.onChanged,
    this.validator,
    this.disabled = false,
    this.isDisabled = false,
    this.readOnly = false,
    this.locked = false,
    this.autofocus = false,
    this.label,
    this.placeholder,
    this.isRequired = false,
    this.fixedCountry,
    this.showCountryCodeSection,
    this.editableCountryCode = true,
    this.countries,
    this.nationalMask,
    this.invalidDialCodeMessage = 'Invalid country code',
    this.invalidDialCodeDisplay,
    this.countryPickerTitle = 'Country',
    this.textInputAction,
    this.suffixIcon,
    this.labelMode,
    this.height,
    this.width,
    this.usePersianDigits,
    this.digitCalendarKind,
    this.style,
  });

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

  /// Override palette brightness.
  final UnifiedInputBrightness? brightness;

  /// Phone-specific chrome (dial-code box, flag, invalid-code display).
  final UnifiedInputPhoneStyle? phoneStyle;

  /// Imperative value + controllers.
  final UnifiedPhoneFieldController? fieldController;

  /// Called when the parsed phone changes.
  final ValueChanged<UnifiedPhoneNumber?>? onChanged;

  /// Validator on [UnifiedPhoneNumber?].
  final String? Function(UnifiedPhoneNumber? value)? validator;

  /// Disables editing and mutes chrome.
  final bool disabled;

  /// Disabled styling with forbid icon.
  final bool isDisabled;

  /// Read-only national segment.
  final bool readOnly;

  /// Locked styling.
  final bool locked;

  /// Autofocus national field.
  final bool autofocus;

  /// Field label.
  final String? label;

  /// Hint for the national segment (or full field in prefix-only mode).
  final String? placeholder;

  /// Required marker.
  final bool isRequired;

  /// When set, dial code is fixed and only national digits are edited.
  final UnifiedCountry? fixedCountry;

  /// Shows a dial-code segment before national digits. Defaults to `fixedCountry == null`.
  final bool? showCountryCodeSection;

  /// When the code section is shown, type dial + national in one field (not a second input).
  final bool editableCountryCode;

  /// Countries for picker / prefix validation.
  final List<UnifiedCountry>? countries;

  /// National digit mask (`#` = digit). Defaults to [kUnifiedPhoneDefaultNationalMask].
  final String? nationalMask;

  /// Shown when invalid and [invalidDialCodeDisplay] is [UnifiedInvalidDialCodeDisplay.message].
  final String invalidDialCodeMessage;

  /// Overrides theme invalid dial-code display mode.
  final UnifiedInvalidDialCodeDisplay? invalidDialCodeDisplay;

  /// Country picker sheet title.
  final String countryPickerTitle;

  /// Keyboard action on the national field.
  final TextInputAction? textInputAction;

  /// Extra suffix after the default phone icon.
  final Widget? suffixIcon;

  /// Label placement override.
  final UnifiedFieldLabelMode? labelMode;

  /// Minimum height of the inner phone row. Overrides [UnifiedInputDecoration.height].
  final double? height;

  /// Fixed width of the whole field (label + editor). Overrides decoration width if added later.
  final double? width;

  /// When `true`, shows Persian digits (۰–۹) and numeral font; when `false`, ASCII only.
  ///
  /// When null, follows [UnifiedFieldsTypography] and [digitCalendarKind]
  /// (Jalali uses Persian digits when [UnifiedFieldsTypography.usePersianDigitsInShamsi] is true).
  final bool? usePersianDigits;

  /// Jalali (`digitCalendarKind: jalali`) enables Persian digits unless [usePersianDigits] overrides.
  final UnifiedFieldsCalendarKind? digitCalendarKind;

  /// Value text style; overrides theme [UnifiedInputFieldDefaults.textStyle] when set.
  final TextStyle? style;

  @override
  State<UnifiedPhoneField> createState() => _UnifiedPhoneFieldState();
}

class _UnifiedPhoneFieldState extends State<UnifiedPhoneField> {
  late UnifiedPhoneFieldController _fc;
  bool _ownsController = false;
  bool _dialCodeInvalid = false;

  List<UnifiedCountry> get _countries =>
      widget.countries ?? widget.fieldController?.countries ?? UnifiedCountries.defaults;

  bool get _showCodeSection =>
      widget.showCountryCodeSection ?? widget.fixedCountry == null;

  /// One `CupertinoTextField`: `+` + dial digits + national digits.
  bool get _unifiedEntryMode =>
      widget.fixedCountry == null &&
      (!_showCodeSection ||
          (widget.editableCountryCode && _showCodeSection));

  /// Fixed or picker-only dial label beside national-only input.
  bool get _splitDialLabelMode =>
      widget.fixedCountry != null ||
      (_showCodeSection && !widget.editableCountryCode);

  String get _mask => widget.nationalMask ?? kUnifiedPhoneDefaultNationalMask;

  bool get _persianDigits => unifiedPhoneUsePersianDigits(
        usePersianDigits: widget.usePersianDigits,
        digitCalendarKind: widget.digitCalendarKind,
      );

  void _syncPersianConfigToController() {
    _fc.usePersianDigits = widget.usePersianDigits;
    _fc.digitCalendarKind = widget.digitCalendarKind;
    _fc.nationalMask = _mask;
  }

  TextStyle _mergeDigitStyle(TextStyle base) {
    if (!_persianDigits) return base;
    var style = UnifiedFieldsTypography.instance.mergeDigitStyle(
      base,
      calendarKind: widget.digitCalendarKind,
    );
    if (widget.usePersianDigits == true &&
        (style.fontFamily == null || style.fontFamily!.isEmpty)) {
      final family = UnifiedFieldsTypography.instance.persianFontFamily;
      if (family != null && family.isNotEmpty) {
        style = style.copyWith(fontFamily: family);
      }
    }
    return style;
  }

  bool get _blocksEdit =>
      widget.disabled || widget.isDisabled || widget.locked || widget.readOnly;

  bool get _canPickCountry => widget.fixedCountry == null && !_blocksEdit;

  UnifiedInputPhoneStyle _phoneStyle(UnifiedInputPalette palette) {
    final base = UnifiedInputThemeResolver.resolvePhoneStyle(
      context,
      overrides: widget.phoneStyle,
      palette: palette,
    );
    if (widget.invalidDialCodeDisplay == null) return base;
    return base.merge(
      UnifiedInputPhoneStyle(invalidDialCodeDisplay: widget.invalidDialCodeDisplay),
    );
  }

  UnifiedInvalidDialCodeDisplay _invalidDisplay(UnifiedInputPhoneStyle ps) =>
      widget.invalidDialCodeDisplay ??
      ps.invalidDialCodeDisplay ??
      UnifiedInvalidDialCodeDisplay.message;

  String? _dialCodeErrorMessage(UnifiedInputPhoneStyle ps) {
    if (!_dialCodeInvalid) return null;
    if (_invalidDisplay(ps) == UnifiedInvalidDialCodeDisplay.highlightText) {
      return null;
    }
    return widget.invalidDialCodeMessage;
  }

  @override
  void initState() {
    super.initState();
    if (widget.fieldController != null) {
      _fc = widget.fieldController!;
    } else {
      _fc = UnifiedPhoneFieldController(
        initialCountry: widget.fixedCountry,
        countries: widget.countries,
      );
      _ownsController = true;
    }
    _syncPersianConfigToController();
    _fc.useUnifiedTextEntry = _unifiedEntryMode;
    if (widget.fixedCountry != null) {
      _fc.setCountry(widget.fixedCountry!, unifiedTextField: false);
    } else if (_unifiedEntryMode && _fc.nationalController.text.isEmpty) {
      _fc.nationalController.text = unifiedPhoneLocalizeDisplay(
        '+',
        usePersianDigits: widget.usePersianDigits,
        digitCalendarKind: widget.digitCalendarKind,
      );
    }
    _fc.nationalController.addListener(_onControllersChanged);
    if (_splitDialLabelMode) {
      _fc.dialCodeController.addListener(_onControllersChanged);
    }
    _fc.addListener(_onControllersChanged);
    _fc.focusNode.addListener(_onFocusChanged);
    _fc.validator = widget.validator;
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant UnifiedPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPersianConfigToController();
    _fc.useUnifiedTextEntry = _unifiedEntryMode;
    if (widget.fixedCountry != null &&
        widget.fixedCountry != oldWidget.fixedCountry) {
      _fc.setCountry(widget.fixedCountry!, unifiedTextField: false);
    }
    _fc.validator = widget.validator;
  }

  void _onControllersChanged() {
    if (_unifiedEntryMode) {
      _validateDialPrefix(_fc.nationalController.text);
      final matched = UnifiedCountries.matchDialCode(
        _fc.nationalController.text,
        _countries,
      );
      if (matched != null && matched.isoCode != _fc.country.isoCode) {
        _fc.setCountry(
          matched,
          updateDialController: true,
          unifiedTextField: true,
        );
      }
    }
    widget.onChanged?.call(_fc.value);
    setState(() {});
  }

  void _validateDialPrefix(String raw) {
    final ascii = UnifiedFieldsTypography.fromPersianDigits(raw);
    final code = ascii.startsWith('+')
        ? ascii.replaceAll(RegExp(r'[^\d+]'), '')
        : UnifiedFieldsTypography.fromPersianDigits(_fc.dialCodeController.text);
    if (code.length <= 1) {
      setState(() => _dialCodeInvalid = false);
      return;
    }
    final valid = UnifiedCountries.isValidDialCodePrefix(code, _countries);
    setState(() => _dialCodeInvalid = !valid);
  }

  Future<void> _openCountryPicker() async {
    if (!_canPickCountry) return;
    final picked = await showUnifiedPhoneCountryPicker(
      context: context,
      countries: _countries,
      selected: _fc.country,
      title: widget.countryPickerTitle,
      usePersianDigits: widget.usePersianDigits,
      digitCalendarKind: widget.digitCalendarKind,
    );
    if (!mounted || picked == null) return;
    _fc.setCountry(
      picked,
      unifiedTextField: _unifiedEntryMode,
    );
    if (_unifiedEntryMode) {
      _validateDialPrefix(_fc.nationalController.text);
    }
  }

  @override
  void dispose() {
    _fc.nationalController.removeListener(_onControllersChanged);
    _fc.dialCodeController.removeListener(_onControllersChanged);
    _fc.removeListener(_onControllersChanged);
    _fc.focusNode.removeListener(_onFocusChanged);
    if (_ownsController) _fc.dispose();
    super.dispose();
  }

  TextStyle? _resolvedFieldTextStyle(UnifiedInputDecoration d) =>
      UnifiedInputThemeResolver.fieldTextStyle(
        context,
        calendarKind: widget.digitCalendarKind,
        usePersianDigits: _persianDigits,
        decorationStyle: d.fieldStyle,
        widgetStyle: widget.style,
      );

  TextStyle _fieldTextStyle(
    UnifiedInputDecoration d,
    UnifiedInputPalette palette,
    UnifiedInputPhoneStyle ps, {
    bool dialCode = false,
  }) {
    final resolved = _resolvedFieldTextStyle(d);
    var base = resolved ?? TextStyle(color: palette.fieldTextColor);
    if (resolved != null && base.color == null) {
      base = base.copyWith(color: palette.fieldTextColor);
    }
    if (dialCode && _dialCodeInvalid &&
        _invalidDisplay(ps) == UnifiedInvalidDialCodeDisplay.highlightText) {
      return base.copyWith(color: ps.invalidDialCodeTextColor);
    }
    return _mergeDigitStyle(base);
  }

  Widget _flagPrefix(UnifiedInputPhoneStyle ps) {
    final flag = UnifiedFlag(code: _fc.country.isoCode, style: ps);
    final child = _canPickCountry
        ? GestureDetector(
            onTap: _openCountryPicker,
            behavior: HitTestBehavior.opaque,
            child: flag,
          )
        : flag;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 10, end: 4),
      child: child,
    );
  }

  bool _showDialCodeChrome(UnifiedInputPhoneStyle ps) =>
      ps.dialCodeBackgroundColor != null ||
      ps.dialCodeBorderSide != null ||
      ps.dialCodeBorderRadius != null;

  BoxDecoration? _dialCodeBoxDecoration(UnifiedInputPhoneStyle ps) {
    if (!_showDialCodeChrome(ps)) return null;
    return BoxDecoration(
      color: ps.dialCodeBackgroundColor,
      borderRadius: ps.dialCodeBorderRadius,
      border: ps.dialCodeBorderSide != null
          ? Border.fromBorderSide(ps.dialCodeBorderSide!)
          : null,
    );
  }

  /// Non-editable dial code chip (fixed country or picker-only code section).
  Widget _dialCodeLabel(
    UnifiedInputDecoration d,
    UnifiedInputPalette palette,
    UnifiedInputPhoneStyle ps,
  ) {
    final style = _fieldTextStyle(d, palette, ps, dialCode: true);
    final country = widget.fixedCountry ?? _fc.country;
    final box = _dialCodeBoxDecoration(ps);
    final padding = box != null
        ? (ps.dialCodePadding ??
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8))
        : const EdgeInsetsDirectional.only(end: 6);

    Widget inner = UnifiedCountryWidget(
      country: country,
      showFlag: false,
      showName: false,
      showDialCode: true,
      dialCodeStyle: style,
      usePersianDigits: widget.usePersianDigits,
      digitCalendarKind: widget.digitCalendarKind,
    );
    if (widget.fixedCountry == null && _canPickCountry) {
      inner = InkWell(
        onTap: _openCountryPicker,
        child: inner,
      );
    }

    if (box == null) {
      return Padding(
        padding: padding,
        child: inner,
      );
    }

    return Container(
      margin: const EdgeInsetsDirectional.only(end: 6),
      padding: padding,
      decoration: box,
      alignment: Alignment.center,
      child: inner,
    );
  }

  Widget _phoneSuffix(UnifiedInputDecoration d, UnifiedInputPalette palette) {
    final extra = widget.suffixIcon ?? d.suffixIcon;
    final widgets = <Widget>[

      UnifiedInputThemeResolver.defaultSuffixIcon(
        context,
        UnifiedInputFieldSuffixKind.phone,
        palette,
      ),
      if (extra != null)
        UnifiedSuffixIconChrome.normalize(
          extra,
          width: d.suffixWidth,
          height: d.suffixHeight,
        ),
    ];
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widgets,
      ),
    );
  }

  List<TextInputFormatter> _inputFormatters() {
    if (_unifiedEntryMode) {
      return [
        UnifiedPhoneFullNumberFormatter(
          nationalMask: _mask,
          countries: _countries,
          usePersianDigits: widget.usePersianDigits,
          digitCalendarKind: widget.digitCalendarKind,
        ),
      ];
    }
    return [
      UnifiedPhoneNationalFormatter(
        mask: _mask,
        usePersianDigits: widget.usePersianDigits,
        digitCalendarKind: widget.digitCalendarKind,
      ),
    ];
  }

  double _fieldHeight(UnifiedInputDecoration d) => widget.height ?? d.height ?? 56;

  Border? _fieldBorder(UnifiedInputDecoration d, UnifiedInputPalette palette, String? error) {
    final hasError = error != null && error.isNotEmpty;
    final side = hasError
        ? BorderSide(color: d.validationColor ?? palette.validationColor, width: 1)
        : (d.borderSide ?? palette.defaultBorderSide);
    return Border.fromBorderSide(side);
  }

  String? _localizedPlaceholder(String? placeholder) {
    if (placeholder == null || placeholder.isEmpty) return placeholder;
    return unifiedPhoneLocalizeDisplay(
      placeholder,
      usePersianDigits: widget.usePersianDigits,
      digitCalendarKind: widget.digitCalendarKind,
    );
  }

  TextStyle _labelStyle(
    UnifiedInputDecoration d,
    UnifiedInputPalette palette,
    UnifiedFieldLabelMode labelMode,
  ) =>
      _mergeDigitStyle(
        UnifiedInputLabelModeStyle.resolveLabelStyle(
              mode: labelMode,
              decorationStyle: d.labelStyle,
              fieldDefaults: UnifiedInputThemeScope.themeDataOf(context)
                  .fieldDefaults,
            ) ??
            d.labelStyle ??
            TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: palette.labelColor,
            ),
      );

  EdgeInsetsGeometry _labelPadding(
    UnifiedInputDecoration d,
    UnifiedFieldLabelMode labelMode,
  ) =>
      UnifiedInputLabelModeStyle.resolveLabelPadding(
        mode: labelMode,
        decorationPadding: d.labelPadding,
        fieldDefaults:
            UnifiedInputThemeScope.themeDataOf(context).fieldDefaults,
      );

  TextStyle _placeholderTextStyle(
    UnifiedInputDecoration d,
    UnifiedInputPalette palette,
  ) {
    return _mergeDigitStyle(
      UnifiedInputThemeResolver.resolvePlaceholderStyle(
        context,
        palette,
        disabled: widget.disabled || widget.isDisabled,
        fieldStyle: _resolvedFieldTextStyle(d),
        placeholderOverride: d.placeholderStyle,
      ),
    );
  }

  Widget _labelBlock(
    UnifiedInputDecoration d,
    UnifiedInputPalette palette,
    String? errorText,
  ) {
    if (d.label == null) return const SizedBox.shrink();
    const mode = UnifiedFieldLabelMode.labelInColumn;
    return Padding(
      padding: _labelPadding(d, mode),
      child: IgnorePointer(
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(d.label!, style: _labelStyle(d, palette, mode)),
                  if (d.requiredField)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6, right: 4),
                      child: UnifiedInputThemeResolver.requiredIcon(
                        context,
                        palette,
                        fallbackColor: palette.labelColor,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              errorText ?? '',
              style: TextStyle(
                color: d.validationColor ?? palette.validationColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _labelRowCompact(UnifiedInputDecoration d, UnifiedInputPalette palette) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            d.label!,
            style: _labelStyle(d, palette, UnifiedFieldLabelMode.labelInRow),
            textAlign: TextAlign.center,
          ),
        ),
        if (d.requiredField)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: UnifiedInputThemeResolver.requiredIcon(context, palette),
          ),
      ],
    );
  }

  Widget _phoneRowContent(
    UnifiedInputDecoration d,
    UnifiedInputPalette palette,
    UnifiedInputPhoneStyle ps,
  ) {
    final useDialHighlight = _unifiedEntryMode &&
        _dialCodeInvalid &&
        _invalidDisplay(ps) == UnifiedInvalidDialCodeDisplay.highlightText;

    final fieldStyle = useDialHighlight
        ? _fieldTextStyle(d, palette, ps, dialCode: true)
        : _fieldTextStyle(d, palette, ps);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_unifiedEntryMode || _splitDialLabelMode) _flagPrefix(ps),
        if (_splitDialLabelMode) _dialCodeLabel(d, palette, ps),
        Expanded(
          child: CupertinoTextField(
            controller: _fc.nationalController,
            focusNode: _fc.focusNode,
            autofocus: widget.autofocus,
            enabled: !_blocksEdit,
            keyboardType: TextInputType.phone,
            textInputAction: widget.textInputAction ?? TextInputAction.done,
            textDirection: TextDirection.ltr,
            inputFormatters: _inputFormatters(),
            style: fieldStyle,
            placeholder: _localizedPlaceholder(widget.placeholder ?? d.placeholder),
            placeholderStyle: _placeholderTextStyle(d, palette),
            padding:
                d.contentPadding ?? const EdgeInsets.symmetric(horizontal: 8),
            suffix: _phoneSuffix(d, palette),
            decoration: const BoxDecoration(color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  Widget _phoneEditorBox(
    UnifiedInputDecoration d,
    UnifiedInputPalette palette,
    UnifiedInputPhoneStyle ps,
  ) {
    final h = _fieldHeight(d);
    final bg = d.backgroundColor ?? Colors.black26;
    return Container(
      height: h,
      width: double.infinity,
      color: bg,
      alignment: Alignment.center,
      child: _phoneRowContent(d, palette, ps),
    );
  }

  Widget _buildLabelInColumnLayout(
    UnifiedInputDecoration d,
    UnifiedInputPalette palette,
    UnifiedInputPhoneStyle ps,
    String? error,
  ) {
    final radius = d.borderRadius ?? palette.borderRadius;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _labelBlock(d, palette, error),
        ClipRRect(
          borderRadius: radius,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: _fieldBorder(d, palette, error),
            ),
            child: _phoneEditorBox(d, palette, ps),
          ),
        ),
      ],
    );
  }

  Widget _buildLabelInRowLayout(
    UnifiedInputDecoration d,
    UnifiedInputPalette palette,
    UnifiedInputPhoneStyle ps,
    String? error,
  ) {
    final labelFlex = d.rowLabelRatio.isNotEmpty ? d.rowLabelRatio[0] : 12;
    final bodyFlex = d.rowLabelRatio.length > 1 ? d.rowLabelRatio[1] : 33;
    final h = _fieldHeight(d);
    final radius = d.borderRadius ?? palette.borderRadius;
    final divider = d.borderSide ?? palette.defaultBorderSide;
    final headerBg =
        d.headerBackgroundColor ?? d.backgroundColor ?? palette.headerBackground;
    final bodyBg = d.backgroundColor ?? palette.bodyBackground;

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: _fieldBorder(d, palette, error),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: labelFlex,
              child: Container(
                constraints: BoxConstraints(minHeight: h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: headerBg,
                  border: BorderDirectional(end: divider),
                ),
                child: d.label == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: _labelPadding(
                          d,
                          UnifiedFieldLabelMode.labelInRow,
                        ),
                        child: _labelRowCompact(d, palette),
                      ),
              ),
            ),
            Expanded(
              flex: bodyFlex,
              child: Container(
                constraints: BoxConstraints(minHeight: h),
                color: bodyBg,
                alignment: Alignment.center,
                child: _phoneRowContent(d, palette, ps),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingLabelLayout(
    UnifiedInputDecoration d,
    UnifiedInputPalette palette,
    UnifiedInputPhoneStyle ps,
    String? error,
  ) {
    final h = _fieldHeight(d);
    final radius = d.borderRadius ?? palette.borderRadius;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: d.label,
        hintText: _localizedPlaceholder(d.placeholder),
        hintStyle: _placeholderTextStyle(d, palette),
        filled: true,
        fillColor: d.backgroundColor,
        contentPadding: EdgeInsets.zero,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: d.borderSide ?? BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: d.borderSide ?? BorderSide.none,
        ),
        errorText: error,
      ),
      child: SizedBox(
        width: double.infinity,
        height: h,
        child: _phoneRowContent(d, palette, ps),
      ),
    );
  }

  UnifiedInputDecoration _resolvedDecoration(
    BuildContext context,
    UnifiedInputDecoration d,
  ) {
    final mode = resolveUnifiedFieldLabelMode(
      mode: widget.labelMode ?? d.labelMode,
      labelInRow: d.labelInRow,
      themeMode: UnifiedInputThemeResolver.fieldLabelMode(context),
    );
    final useRow = mode == UnifiedFieldLabelMode.labelInRow;
    return UnifiedInputDecoration(
      label: widget.label ?? d.label,
      placeholder: widget.placeholder ?? d.placeholder,
      labelStyle: d.labelStyle,
      fieldStyle: d.fieldStyle,
      backgroundColor: d.backgroundColor,
      headerBackgroundColor: d.headerBackgroundColor,
      borderRadius: d.borderRadius,
      borderSide: d.borderSide,
      height: widget.height ?? d.height,
      rowLabelRatio: d.rowLabelRatio,
      labelInRow: useRow,
      labelMode: mode,
      requiredField: widget.isRequired || d.requiredField,
      showError: d.showError,
      validationColor: d.validationColor,
      validationIcon: d.validationIcon,
      prefix: d.prefix,
      prefixIcon: d.prefixIcon,
      suffixIcon: d.suffixIcon,
      contentPadding: d.contentPadding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chrome = resolveUnifiedFieldDecorationContext(
      context,
      decoration: widget.decoration,
      decorationSet: widget.decorationSet,
      brightness: widget.brightness,
    );
    final palette = widget.brightness != null
        ? UnifiedInputThemeResolver.paletteFor(widget.brightness!)
        : UnifiedInputThemeResolver.resolvePalette(context);
    final ps = _phoneStyle(palette);

    final dialError = _dialCodeErrorMessage(ps);
    final error = _fc.errorText ?? dialError;
    final inactive = widget.disabled || widget.isDisabled;
    final hasError = error != null && error.isNotEmpty;

    var paletteDec = chrome.resolved;
    if (chrome.activeSet != null) {
      paletteDec = chrome.composedSet.resolve(
        context,
        state: resolveUnifiedInputFieldVisualState(
          disabled: inactive,
          locked: widget.locked,
          loading: false,
          hasError: hasError,
          showValid: false,
          readOnly: widget.readOnly && !inactive && !widget.locked,
          focused:
              _fc.focusNode.hasFocus && !inactive && !widget.locked,
        ),
        brightness: widget.brightness,
        fieldDecoration: widget.decoration,
      );
    }
    final d = _resolvedDecoration(context, paletteDec);
    final mode = d.labelMode ?? UnifiedFieldLabelMode.floatingLabel;

    final Widget field = switch (mode) {
      UnifiedFieldLabelMode.labelInRow => _buildLabelInRowLayout(
          d,
          palette,
          ps,
          error,
        ),
      UnifiedFieldLabelMode.labelInColumn => _buildLabelInColumnLayout(
          d,
          palette,
          ps,
          error,
        ),
      UnifiedFieldLabelMode.floatingLabel => _buildFloatingLabelLayout(
          d,
          palette,
          ps,
          error,
        ),
    };

    if (widget.width == null) return field;
    return SizedBox(width: widget.width, child: field);
  }
}
