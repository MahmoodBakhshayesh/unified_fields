import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../unified_date_picker_types.dart';
import '../unified_fields_typography.dart';
import 'unified_field_label_mode.dart';
import 'unified_gradient_border.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';
import 'unified_input_palette.dart';
import 'unified_input_theme.dart';

/// Lean Cupertino-styled field: label (column or row), editable area, optional inline error.
///
/// Owns an internal [TextEditingController] only when [controller] is omitted.
/// Replaces legacy [AppTextFormField] for unified inputs — no numeric sheet / riverpod here.
///
/// **Form-like behavior without [FormField]** (optional):
/// - [errorText]: parent-driven message (API / cross-field); non-empty wins over [validator].
/// - [autovalidateMode]: when to run [validator] (`null` = [AutovalidateMode.always], same as before).
/// - [onSaved]: invoked from [UnifiedBaseTextFieldState.save] (e.g. submit flow).
/// - [UnifiedBaseTextFieldState.validate] / [UnifiedBaseTextFieldState.save] via
///   `GlobalKey<UnifiedBaseTextFieldState>`.
class UnifiedBaseTextField extends StatefulWidget {
  /// Creates the base text field used by every unified input widget.
  const UnifiedBaseTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.label,
    this.placeholder,
    this.labelStyle,
    this.labelPadding,
    this.style,
    this.placeholderStyle,
    this.backgroundColor,
    this.headerBackgroundColor,
    this.borderRadius,
    this.borderSide,
    this.borderGradient,
    this.height,
    this.padding,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.readOnly = false,
    this.disabled = false,
    this.isDisabled = false,
    this.locked = false,
    this.loading = false,
    this.interactionBlocked = false,

    /// When [locked] becomes true, reset text to [initialValue] / empty.
    this.resetTextWhenLocked,
    this.autofocus = false,
    this.selectTextOnFocus,
    this.isPassword = false,
    this.showPasswordToggle = true,
    this.showClearButton,
    this.requiredField = false,
    this.labelInRow,
    this.labelMode,
    this.rowLabelRatio,
    this.errorText,
    this.autovalidateMode,
    this.validator,
    this.onSaved,
    this.showError,
    this.validationColor,
    this.validationIcon,
    this.prefix,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmit,
    this.mustResolveTextDirectionByInput,
    this.decorationSet,
    this.brightness,
    this.digitCalendarKind,
  });

  /// External [TextEditingController]; if null one is created internally.
  final TextEditingController? controller;

  /// External focus node; if null one is created internally.
  final FocusNode? focusNode;

  /// Initial text when [controller] is null.
  final String? initialValue;

  /// Label rendered above (or beside) the editing area.
  final String? label;

  /// Placeholder / hint text shown when empty.
  final String? placeholder;

  /// Override for the label text style.
  final TextStyle? labelStyle;

  /// Override for label padding (interpretation depends on [labelMode]).
  final EdgeInsetsGeometry? labelPadding;

  /// Override for the editing text style.
  final TextStyle? style;

  /// Override for placeholder / hint text (`null` → theme / [UnifiedInputDecoration]).
  final TextStyle? placeholderStyle;

  /// Background color of the editing area (`null` → theme / palette).
  final Color? backgroundColor;

  /// Background of the left label area when [labelInRow] is true.
  final Color? headerBackgroundColor;

  /// Border radius of the field box (`null` → theme / palette).
  final BorderRadius? borderRadius;

  /// Border side of the field box (`null` → theme / palette).
  final BorderSide? borderSide;

  /// Optional gradient stroke (see [UnifiedInputDecoration.borderGradient]).
  final Gradient? borderGradient;

  /// Minimum height of the inner row.
  final double? height;

  /// Inner content padding.
  final EdgeInsetsGeometry? padding;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Keyboard action button.
  final TextInputAction? textInputAction;

  /// Capitalization rule applied to typed text.
  final TextCapitalization textCapitalization;

  /// Horizontal alignment of typed text.
  final TextAlign textAlign;

  /// Custom input formatters applied to user keystrokes.
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum visible lines.
  final int? maxLines;

  /// Minimum visible lines.
  final int? minLines;

  /// Maximum allowed characters.
  final int? maxLength;

  /// When true, the inner field rejects edits.
  final bool readOnly;

  /// When true, the field is non-editable and visually muted.
  final bool disabled;

  /// When true, greys out the label and shows a forbid icon in the suffix.
  /// Unlike [locked], which uses a lock icon. Either state blocks editing.
  final bool isDisabled;

  /// When true, paints the field in "locked" style with a lock suffix icon.
  final bool locked;

  /// When true, shows a small loading spinner in the suffix (instead of
  /// [suffixIcon]) and blocks focus/edits without muted disabled chrome.
  final bool loading;

  /// When true, blocks focus and direct edits without changing colors or
  /// suffix state icons. Use for pick-only fields (date, async picker) where
  /// a parent [GestureDetector] opens the sheet.
  final bool interactionBlocked;

  /// Whether to reset to [initialValue] when [locked] becomes true (`null` → theme).
  final bool? resetTextWhenLocked;

  /// Whether the inner field should request focus on first build.
  final bool autofocus;

  /// When true, focusing a non-empty editable field selects all text so typing
  /// replaces the current value (`null` → [UnifiedInputFieldDefaults] / theme).
  final bool? selectTextOnFocus;

  /// Render entered text as obscured and add a visibility toggle.
  final bool isPassword;

  /// With [isPassword], whether to add the show / hide visibility toggle
  /// (default true). When false a custom suffix icon is shown instead, if any.
  final bool showPasswordToggle;

  /// Show an "x" suffix to clear the field when it has content (`null` → theme).
  final bool? showClearButton;

  /// Render the required marker next to [label].
  final bool requiredField;

  /// Render the label in the same row as the editing area (`null` → theme / [labelMode]).
  final bool? labelInRow;

  /// Label placement; when null, [labelInRow] maps to [UnifiedFieldLabelMode.labelInRow],
  /// otherwise defaults to [UnifiedFieldLabelMode.floatingLabel].
  final UnifiedFieldLabelMode? labelMode;

  /// Flex ratio between the label cell and the body cell when [labelInRow] is true.
  final List<int>? rowLabelRatio;

  /// Imperative / server-side error; non-empty trim wins over [validator] for display.
  final String? errorText;

  /// When [validator] runs for UI feedback. `null` means [AutovalidateMode.always].
  final AutovalidateMode? autovalidateMode;

  /// Synchronous validator returning the error message, or null when valid.
  final String? Function(String value)? validator;

  /// Called from [UnifiedBaseTextFieldState.save].
  final ValueChanged<String>? onSaved;

  /// Whether to render the inline error strip below the field when present (`null` → theme).
  final bool? showError;

  /// Color used for error chrome (border, label).
  final Color? validationColor;

  /// Optional icon shown in the inline error strip.
  final IconData? validationIcon;

  /// Leading widget shown before the field content.
  final Widget? prefix;

  /// Leading icon shown before the field content.
  final Widget? prefixIcon;

  /// Trailing widget shown after the field content.
  final Widget? suffixIcon;

  /// Called on every keystroke.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits via the keyboard action button.
  final ValueChanged<String>? onSubmit;

  /// If true, the text direction is inferred from the typed content (`null` → theme).
  final bool? mustResolveTextDirectionByInput;

  /// Per-state decorations (focus, error, valid, locked, disabled, …). Merged with [brightness] palette defaults.
  final UnifiedInputDecorationSet? decorationSet;

  /// Brightness used when resolving [decorationSet] (and when [decorationSet] is null, ignored).
  final UnifiedInputBrightness? brightness;

  /// Calendar kind for Persian digit / [UnifiedInputFieldDefaults.textStylePersian] selection.
  final UnifiedFieldsCalendarKind? digitCalendarKind;

  @override
  State<UnifiedBaseTextField> createState() => UnifiedBaseTextFieldState();
}

/// State for [UnifiedBaseTextField] with imperative [validate] / [resetValidation] / [save] hooks.
class UnifiedBaseTextFieldState extends State<UnifiedBaseTextField> {
  late TextEditingController _ctrl;
  bool _ownsController = false;
  bool _obscure = false;
  FocusNode? _internalFocusNode;
  bool _ownsFocusNode = false;

  final ValueNotifier<int> _tick = ValueNotifier(0);
  bool _userInteracted = false;
  bool _validationRequested = false;
  bool _focusListenerAttached = false;
  bool _hovered = false;

  FocusNode get _effectiveFocusNode {
    if (widget.focusNode != null) return widget.focusNode!;
    _internalFocusNode ??= FocusNode();
    _ownsFocusNode = true;
    return _internalFocusNode!;
  }

  AutovalidateMode _effectiveAutovalidateMode(BuildContext context) =>
      UnifiedInputThemeResolver.fieldAutovalidateMode(
        context,
        field: widget.autovalidateMode,
      );

  /// Whether [validator] may contribute to the displayed error (not [errorText]).
  bool _shouldApplyValidator(BuildContext context) {
    final m = _effectiveAutovalidateMode(context);
    if (m == AutovalidateMode.always) return true;
    if (m == AutovalidateMode.disabled) return _validationRequested;
    return _userInteracted || _validationRequested;
  }

  String? _resolvedError(BuildContext context) {
    final ext = widget.errorText?.trim();
    if (ext != null && ext.isNotEmpty) return ext;
    if (!_shouldApplyValidator(context)) return null;
    final v = widget.validator?.call(_ctrl.text);
    if (v != null && v.trim().isNotEmpty) return v;
    return null;
  }

  /// Whether the field currently has no resolved error.
  bool isValid(BuildContext context) => _resolvedError(context) == null;

  /// Runs [validator] visibility rules and rebuilds. Returns whether the field is valid.
  bool validate() {
    setState(() => _validationRequested = true);
    return isValid(context);
  }

  /// Clears the “submit / validate” gate so [AutovalidateMode.disabled] hides validator errors again.
  void resetValidation() {
    setState(() {
      _validationRequested = false;
      _userInteracted = false;
    });
  }

  /// Calls [UnifiedBaseTextField.onSaved] with the current text (same idea as [FormField.save]).
  void save() => widget.onSaved?.call(_ctrl.text);

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
    if (widget.controller != null) {
      _ctrl = widget.controller!;
    } else {
      _ctrl = TextEditingController(text: widget.initialValue ?? '');
      _ownsController = true;
    }
    _ctrl.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFocusListener();
  }

  bool _shouldListenToFocus(BuildContext context) =>
      (widget.decorationSet?.isConfigured ?? false) ||
      UnifiedInputThemeResolver.fieldSelectTextOnFocus(
        context,
        field: widget.selectTextOnFocus,
      );

  void _syncFocusListener() {
    final needed = _shouldListenToFocus(context);
    if (needed && !_focusListenerAttached) {
      _effectiveFocusNode.addListener(_onFocusChanged);
      _focusListenerAttached = true;
    } else if (!needed && _focusListenerAttached) {
      _detachFocusListener(widget.focusNode);
      _focusListenerAttached = false;
    }
  }

  void _onFocusChanged() {
    if (!mounted) return;

    if (UnifiedInputThemeResolver.fieldSelectTextOnFocus(
          context,
          field: widget.selectTextOnFocus,
        ) &&
        _effectiveFocusNode.hasFocus &&
        !_visuallyDisabled &&
        !widget.readOnly &&
        !widget.locked &&
        !widget.interactionBlocked) {
      final text = _ctrl.text;
      if (text.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_effectiveFocusNode.hasFocus) return;
          final current = _ctrl.text;
          if (current.isEmpty) return;
          _ctrl.selection = TextSelection(
            baseOffset: 0,
            extentOffset: current.length,
          );
        });
      }
    }

    if ((widget.decorationSet?.isConfigured ?? false)) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant UnifiedBaseTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _ctrl.removeListener(_onTextChanged);
      if (_ownsController) _ctrl.dispose();
      if (widget.controller != null) {
        _ctrl = widget.controller!;
        _ownsController = false;
      } else {
        _ctrl = TextEditingController(text: widget.initialValue ?? '');
        _ownsController = true;
      }
      _ctrl.addListener(_onTextChanged);
    }

    if (oldWidget.locked != widget.locked &&
        widget.locked &&
        UnifiedInputThemeResolver.fieldResetTextWhenLocked(
          context,
          field: widget.resetTextWhenLocked,
        )) {
      _ctrl.removeListener(_onTextChanged);
      _ctrl.text = widget.initialValue ?? '';
      _ctrl.addListener(_onTextChanged);
      _tick.value++;
    }

    if (oldWidget.isPassword != widget.isPassword) {
      _obscure = widget.isPassword;
    }

    if (oldWidget.decorationSet != widget.decorationSet ||
        oldWidget.selectTextOnFocus != widget.selectTextOnFocus) {
      _syncFocusListener();
    } else if (oldWidget.focusNode != widget.focusNode) {
      if (_focusListenerAttached) {
        _detachFocusListener(oldWidget.focusNode);
        _effectiveFocusNode.addListener(_onFocusChanged);
      }
    }

    if (oldWidget.errorText != widget.errorText) {
      _tick.value++;
    }
  }

  void _detachFocusListener(FocusNode? previousExternal) {
    final node =
        previousExternal ?? (_ownsFocusNode ? _internalFocusNode : null);
    node?.removeListener(_onFocusChanged);
    _focusListenerAttached = false;
  }

  void _onTextChanged() {
    widget.onChanged?.call(_ctrl.text);
    _tick.value++;
  }

  void _markUserInteracted() {
    if (_userInteracted) return;
    _userInteracted = true;
    final m = _effectiveAutovalidateMode(context);
    if (m != AutovalidateMode.always && m != AutovalidateMode.disabled) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (_focusListenerAttached) {
      _detachFocusListener(widget.focusNode);
    }
    if (_ownsFocusNode) {
      _internalFocusNode?.dispose();
    }
    _ctrl.removeListener(_onTextChanged);
    if (_ownsController) _ctrl.dispose();
    _tick.dispose();
    super.dispose();
  }

  UnifiedInputFieldVisualState _visualState(
    BuildContext context,
    bool hasError,
  ) {
    final set = widget.decorationSet;
    final showValid =
        hasError == false &&
        set?.valid != null &&
        isValid(context) &&
        (_validationRequested ||
            _effectiveAutovalidateMode(context) == AutovalidateMode.always);
    return resolveUnifiedInputFieldVisualState(
      disabled: _visuallyDisabled,
      locked: widget.locked && !_visuallyDisabled,
      loading: widget.loading && !_visuallyDisabled,
      hasError: hasError,
      showValid: showValid,
      readOnly:
          widget.readOnly &&
          !_visuallyDisabled &&
          !widget.locked &&
          !widget.loading,
      focused:
          _effectiveFocusNode.hasFocus &&
          !_visuallyDisabled &&
          !widget.locked &&
          !widget.loading &&
          !hasError,
      hovered:
          _hovered &&
          !_effectiveFocusNode.hasFocus &&
          !_visuallyDisabled &&
          !widget.locked &&
          !widget.loading &&
          !hasError,
    );
  }

  UnifiedInputDecoration _widgetDecorationOverrides() {
    var d = const UnifiedInputDecoration();
    if (widget.labelStyle != null) {
      d = d.merge(UnifiedInputDecoration(labelStyle: widget.labelStyle));
    }
    if (widget.labelPadding != null) {
      d = d.merge(UnifiedInputDecoration(labelPadding: widget.labelPadding));
    }
    if (widget.style != null) {
      d = d.merge(UnifiedInputDecoration(fieldStyle: widget.style));
    }
    if (widget.placeholderStyle != null) {
      d = d.merge(
        UnifiedInputDecoration(placeholderStyle: widget.placeholderStyle),
      );
    }
    if (widget.backgroundColor != null) {
      d = d.merge(
        UnifiedInputDecoration(backgroundColor: widget.backgroundColor),
      );
    }
    if (widget.headerBackgroundColor != null) {
      d = d.merge(
        UnifiedInputDecoration(
          headerBackgroundColor: widget.headerBackgroundColor,
        ),
      );
    }
    if (widget.borderRadius != null) {
      d = d.merge(UnifiedInputDecoration(borderRadius: widget.borderRadius));
    }
    if (widget.borderSide != null) {
      d = d.merge(UnifiedInputDecoration(borderSide: widget.borderSide));
    }
    if (widget.borderGradient != null) {
      d = d.merge(
        UnifiedInputDecoration(borderGradient: widget.borderGradient),
      );
    }
    if (widget.height != null) {
      d = d.merge(UnifiedInputDecoration(height: widget.height));
    }
    if (widget.rowLabelRatio != null) {
      d = d.merge(UnifiedInputDecoration(rowLabelRatio: widget.rowLabelRatio!));
    }
    if (widget.labelInRow != null) {
      d = d.merge(UnifiedInputDecoration(labelInRow: widget.labelInRow!));
    }
    if (widget.labelMode != null) {
      d = d.merge(UnifiedInputDecoration(labelMode: widget.labelMode));
    }
    d = d.merge(
      UnifiedInputDecoration(
        requiredField: widget.requiredField,
        validationColor: widget.validationColor,
        validationIcon: widget.validationIcon,
        prefix: widget.prefix,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        contentPadding: widget.padding,
      ),
    );
    if (widget.showError != null) {
      d = d.merge(UnifiedInputDecoration(showError: widget.showError!));
    }
    return d;
  }

  UnifiedInputDecoration _resolveDecoration(
    BuildContext context,
    UnifiedInputPalette palette,
    bool hasError,
  ) {
    final overrides = _widgetDecorationOverrides();
    if (widget.decorationSet?.isConfigured ?? false) {
      return widget.decorationSet!.resolve(
        context,
        state: _visualState(context, hasError),
        brightness: widget.brightness,
        fieldDecoration: overrides,
      );
    }
    return resolveUnifiedDecoration(
      context,
      overrides: overrides,
      brightness: widget.brightness,
    );
  }

  bool _useLegacyDisabledChrome() =>
      !(widget.decorationSet?.isConfigured ?? false) ||
      !widget.decorationSet!.hasLayerFor(UnifiedInputFieldVisualState.disabled);

  bool _useLegacyLockedChrome() =>
      !(widget.decorationSet?.isConfigured ?? false) ||
      !widget.decorationSet!.hasLayerFor(UnifiedInputFieldVisualState.locked);

  void _toggleObscure() {
    if (!widget.isPassword || widget.disabled) return;
    setState(() => _obscure = !_obscure);
  }

  TextDirection? _resolveTextDirection(BuildContext context) {
    if (!UnifiedInputThemeResolver.fieldMustResolveTextDirectionByInput(
      context,
      field: widget.mustResolveTextDirectionByInput,
    )) {
      return null;
    }
    final t = _ctrl.text.trimLeft();
    if (t.isEmpty) return null;
    final first = t[0];
    final rtl = RegExp(
      r'[\u0600-\u06FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    ).hasMatch(first);
    return rtl ? TextDirection.rtl : TextDirection.ltr;
  }

  bool get _visuallyDisabled => widget.isDisabled || widget.disabled;

  bool get _blocksInteraction =>
      _visuallyDisabled ||
      widget.locked ||
      widget.loading ||
      widget.interactionBlocked;

  bool get _absorbInnerPointers =>
      widget.interactionBlocked ||
      widget.loading ||
      _visuallyDisabled ||
      widget.locked;

  Color _labelColor(
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
    UnifiedFieldLabelMode labelMode,
  ) {
    final fieldDefaults = UnifiedInputThemeScope.themeDataOf(
      context,
    ).fieldDefaults;
    final modeStyle = UnifiedInputLabelModeStyle.forMode(
      fieldDefaults,
      labelMode,
    );
    final base =
        dec.labelStyle?.color ??
        widget.labelStyle?.color ??
        modeStyle?.labelStyle?.color ??
        palette.labelColor;
    if (widget.decorationSet?.isConfigured ?? false) {
      if ((_visuallyDisabled && !_useLegacyDisabledChrome()) ||
          (widget.locked && !_useLegacyLockedChrome())) {
        return base;
      }
    }
    if (_visuallyDisabled && _useLegacyDisabledChrome()) {
      return UnifiedInputThemeResolver.disabledLabelColor(
        context,
        palette,
        base: base,
      );
    }
    if (widget.locked && _useLegacyLockedChrome()) {
      return UnifiedInputThemeResolver.lockedLabelColor(
        context,
        palette,
        base: base,
      );
    }
    return base;
  }

  TextStyle _resolveLabelStyle(
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
    UnifiedFieldLabelMode labelMode,
  ) {
    final fieldDefaults = UnifiedInputThemeScope.themeDataOf(
      context,
    ).fieldDefaults;
    final base =
        UnifiedInputLabelModeStyle.resolveLabelStyle(
          mode: labelMode,
          decorationStyle: dec.labelStyle,
          widgetStyle: widget.labelStyle,
          fieldDefaults: fieldDefaults,
        ) ??
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: palette.labelColor,
        );
    return base.copyWith(color: _labelColor(palette, dec, labelMode));
  }

  EdgeInsetsGeometry _resolveLabelPadding(
    UnifiedInputDecoration dec,
    UnifiedFieldLabelMode labelMode,
  ) {
    return UnifiedInputLabelModeStyle.resolveLabelPadding(
      mode: labelMode,
      decorationPadding: dec.labelPadding,
      widgetPadding: widget.labelPadding,
      fieldDefaults: UnifiedInputThemeScope.themeDataOf(context).fieldDefaults,
    );
  }

  TextStyle _resolveFieldStyle(
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
  ) {
    final base =
        _resolvedFieldTextStyle(dec) ??
        TextStyle(color: palette.fieldTextColor);
    final textBase = base.color ?? palette.fieldTextColor;
    TextStyle resolved;
    if (_visuallyDisabled && _useLegacyDisabledChrome()) {
      resolved = base.copyWith(
        color: UnifiedInputThemeResolver.disabledFieldColor(
          context,
          palette,
          base: textBase,
        ),
      );
    } else if (widget.locked && _useLegacyLockedChrome()) {
      resolved = base.copyWith(
        color: UnifiedInputThemeResolver.lockedFieldColor(
          context,
          palette,
          base: textBase,
        ),
      );
    } else {
      resolved = base;
    }
    return UnifiedFieldsTypography.instance.mergeDigitStyle(
      resolved,
      calendarKind: widget.digitCalendarKind,
    );
  }

  Color _effectiveBackgroundColor(
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
  ) {
    final bg =
        dec.backgroundColor ?? widget.backgroundColor ?? palette.bodyBackground;
    if (_visuallyDisabled && _useLegacyDisabledChrome()) {
      return bg.withValues(
        alpha: UnifiedInputThemeResolver.disabledFieldBackgroundOpacity(
          context,
        ),
      );
    }
    if (widget.locked && _useLegacyLockedChrome()) {
      return bg.withValues(
        alpha: UnifiedInputThemeResolver.lockedFieldBackgroundOpacity(context),
      );
    }
    return bg;
  }

  Color _effectiveHeaderBackgroundColor(
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
  ) {
    return dec.headerBackgroundColor ??
        dec.backgroundColor ??
        widget.headerBackgroundColor ??
        widget.backgroundColor ??
        palette.bodyBackground;
  }

  Widget _normalizeLeadingAdornment(
    Widget adornment,
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
  ) {
    if (adornment is Row) return adornment;
    final style = UnifiedInputThemeResolver.resolveAdornmentStyle(
      context,
      decoration: dec,
    );
    return UnifiedSuffixIconChrome.normalize(
      adornment,
      width: dec.prefixWidth ?? style.prefixWidth,
      height: dec.prefixHeight ?? style.prefixHeight,
      iconColor: UnifiedInputThemeResolver.prefixIconColor(
        context,
        palette,
        decoration: dec,
      ),
      iconSize: UnifiedInputThemeResolver.adornmentIconSize(
        context,
        decoration: dec,
      ),
    );
  }

  Widget _normalizeTrailingAdornment(
    Widget adornment,
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
  ) {
    if (adornment is Row) return adornment;
    final style = UnifiedInputThemeResolver.resolveAdornmentStyle(
      context,
      decoration: dec,
    );
    return UnifiedSuffixIconChrome.normalize(
      adornment,
      width: dec.suffixWidth ?? style.suffixWidth,
      height: dec.suffixHeight ?? style.suffixHeight,
      iconColor: UnifiedInputThemeResolver.resolvedSuffixIconColor(
        context,
        palette,
        decoration: dec,
      ),
      iconSize: UnifiedInputThemeResolver.adornmentIconSize(
        context,
        decoration: dec,
      ),
    );
  }

  Widget? _joinAdornments(List<Widget> widgets, UnifiedInputDecoration dec) {
    if (widgets.isEmpty) return null;
    final gap = UnifiedInputThemeResolver.adornmentGap(
      context,
      decoration: dec,
    );
    if (widgets.length == 1 || gap <= 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widgets,
      );
    }
    final children = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      if (i > 0) children.add(SizedBox(width: gap));
      children.add(widgets[i]);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  Widget? _buildPrefixRow(
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
  ) {
    final widgets = <Widget>[];
    final prefixIcon = dec.prefixIcon ?? widget.prefixIcon;
    final prefix = dec.prefix ?? widget.prefix;
    if (prefixIcon != null) {
      widgets.add(_normalizeLeadingAdornment(prefixIcon, palette, dec));
    }
    if (prefix != null) {
      widgets.add(_normalizeLeadingAdornment(prefix, palette, dec));
    }
    final row = _joinAdornments(widgets, dec);
    if (row == null) return null;
    return Padding(
      padding: _adornmentPadding(
        UnifiedInputThemeResolver.prefixAdornmentPadding(
          context,
          decoration: dec,
        ),
        dec,
      ),
      child: row,
    );
  }

  Widget _stateSuffixIcon(
    IconData icon,
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
  ) {
    return UnifiedSuffixIconChrome.build(
      icon: icon,
      color: UnifiedInputThemeResolver.resolvedSuffixIconColor(
        context,
        palette,
        decoration: dec,
      ),
      glyphSize: UnifiedInputThemeResolver.adornmentIconSize(
        context,
        decoration: dec,
      ),
    );
  }

  Widget _loadingSuffix() {
    final color = UnifiedInputThemeResolver.loadingIndicatorColor(context);
    return ExcludeFocus(
      child: SizedBox(
        width: UnifiedSuffixIconChrome.slotSize,
        height: UnifiedSuffixIconChrome.slotSize,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
        ),
      ),
    );
  }

  Widget _labelBlock(
    String? errorText,
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
  ) {
    if (!unifiedFieldHasVisibleLabel(widget.label))
      return const SizedBox.shrink();
    const mode = UnifiedFieldLabelMode.labelInColumn;
    final defaultLabelStyle = _resolveLabelStyle(palette, dec, mode);
    return Padding(
      padding: _resolveLabelPadding(dec, mode),
      child: _labelTapToFocus(
        IgnorePointer(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(widget.label!, style: defaultLabelStyle),
                    if (widget.requiredField)
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
                  color: _validationColor(palette, dec),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  /// Tapping the label above the box focuses an editable field (pointer and
  /// touch). The label is a convenience duplicate of the box, so its gesture
  /// is excluded from semantics: assistive technologies see one text field,
  /// not an extra ~18 px tap target. Read-only / blocked fields keep the
  /// label pass-through, so a picker's own tap handler still opens it.
  Widget _labelTapToFocus(Widget label) {
    if (widget.readOnly || _blocksInteraction) return label;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: () => _effectiveFocusNode.requestFocus(),
      child: label,
    );
  }

  Widget? _buildSuffixRow(
    BuildContext context,
    bool hasText,
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
  ) {
    final widgets = <Widget>[];
    final customSuffix = widget.suffixIcon ?? dec.suffixIcon;

    if (_visuallyDisabled) {
      widgets.add(
        _stateSuffixIcon(Icons.not_interested_outlined, palette, dec),
      );
    } else if (widget.locked) {
      widgets.add(_stateSuffixIcon(Icons.lock_outline, palette, dec));
    } else if (widget.loading) {
      widgets.add(_loadingSuffix());
    } else {
      if (widget.isPassword && widget.showPasswordToggle) {
        widgets.add(
          UnifiedSuffixIconChrome.build(
            icon: _obscure ? Icons.visibility : Icons.visibility_off,
            color: UnifiedInputThemeResolver.resolvedSuffixIconColor(
              context,
              palette,
              decoration: dec,
            ),
            glyphSize: UnifiedInputThemeResolver.adornmentIconSize(
              context,
              decoration: dec,
            ),
            onPressed: _blocksInteraction ? null : _toggleObscure,
            tooltip: _obscure ? 'Show password' : 'Hide password',
          ),
        );
      } else if (customSuffix != null) {
        widgets.add(_normalizeTrailingAdornment(customSuffix, palette, dec));
      }

      if (UnifiedInputThemeResolver.fieldShowClearButton(
            context,
            field: widget.showClearButton,
          ) &&
          hasText &&
          !widget.locked &&
          !_visuallyDisabled &&
          !widget.loading &&
          !widget.interactionBlocked) {
        widgets.insert(
          0,
          UnifiedSuffixIconChrome.build(
            icon: Icons.clear,
            color: UnifiedInputThemeResolver.clearButtonColor(context, palette)
                .withValues(
                  alpha:
                      UnifiedInputThemeScope.themeDataOf(
                        context,
                      ).suffixIconOpacity ??
                      0.7,
                ),
            glyphSize: UnifiedInputThemeResolver.adornmentIconSize(
              context,
              decoration: dec,
            ),
            onPressed: _blocksInteraction ? null : () => _ctrl.clear(),
            tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
          ),
        );
      }
    }

    if (widgets.isEmpty) return null;
    final row = _joinAdornments(widgets, dec);
    return Padding(
      padding: _adornmentPadding(
        UnifiedInputThemeResolver.suffixAdornmentPadding(
          context,
          decoration: dec,
        ),
        dec,
      ),
      child: row,
    );
  }

  TextStyle? _resolvedFieldTextStyle(UnifiedInputDecoration dec) =>
      UnifiedInputThemeResolver.fieldTextStyle(
        context,
        calendarKind: widget.digitCalendarKind,
        decorationStyle: dec.fieldStyle,
        widgetStyle: widget.style,
      );

  TextStyle _placeholderStyle(
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
  ) {
    return UnifiedInputThemeResolver.resolvePlaceholderStyle(
      context,
      palette,
      disabled: _visuallyDisabled,
      fieldStyle: _resolvedFieldTextStyle(dec),
      placeholderOverride: dec.placeholderStyle ?? widget.placeholderStyle,
    );
  }

  Color _validationColor(
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
  ) =>
      dec.validationColor ??
      widget.validationColor ??
      UnifiedInputThemeResolver.validationColor(context, palette);

  /// When [isDisabled] / [disabled], [CupertinoTextField] with `enabled: false` hides
  /// placeholder or value. Render both hint and text explicitly instead.
  Widget _disabledFieldContent(
    BuildContext context,
    UnifiedInputPalette palette,
    bool hasText,
    UnifiedInputDecoration dec, {
    required bool labelInRow,
  }) {
    final padding =
        dec.contentPadding ??
        widget.padding ??
        const EdgeInsets.symmetric(horizontal: 12);
    final placeholderStyle = _placeholderStyle(palette, dec);
    final valueStyle = _resolveFieldStyle(palette, dec);
    final hint = widget.placeholder?.trim();
    final showHintAndValue = hasText && hint != null && hint.isNotEmpty;
    final valueText = hasText
        ? (widget.isPassword && _obscure ? '•' * _ctrl.text.length : _ctrl.text)
        : '';

    Widget textPart;
    if (showHintAndValue) {
      textPart = Row(
        children: [
          Flexible(
            child: Text(
              hint,
              style: placeholderStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: _resolveTextDirection(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              valueText,
              style: valueStyle,
              maxLines: widget.maxLines == 0 ? null : widget.maxLines,
              overflow: TextOverflow.ellipsis,
              textAlign: widget.textAlign,
              textDirection: _resolveTextDirection(context),
            ),
          ),
        ],
      );
    } else {
      textPart = Text(
        hasText ? valueText : (hint ?? ''),
        style: hasText ? valueStyle : placeholderStyle,
        maxLines: widget.maxLines == 0 ? null : widget.maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: widget.textAlign,
        textDirection: _resolveTextDirection(context),
      );
    }

    final suffix = _buildSuffixRow(context, hasText, palette, dec);
    final prefix = _buildPrefixRow(palette, dec);
    return Container(
      alignment: Alignment.centerLeft,
      padding: padding,
      decoration: labelInRow
          ? BoxDecoration(color: _effectiveBackgroundColor(palette, dec))
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (prefix != null) prefix,
          Expanded(child: textPart),
          if (suffix != null) suffix,
        ],
      ),
    );
  }

  Widget _cupertinoField(
    BuildContext context,
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec, {
    required bool labelInRow,
  }) {
    final hasText = _ctrl.text.isNotEmpty;
    if (_visuallyDisabled) {
      return AbsorbPointer(
        child: _disabledFieldContent(
          context,
          palette,
          hasText,
          dec,
          labelInRow: labelInRow,
        ),
      );
    }
    final obscureOneLine = widget.isPassword && _obscure;
    final effectiveMaxLines = obscureOneLine
        ? 1
        : (widget.maxLines == 0 ? null : widget.maxLines);
    final field = CupertinoTextField(
      controller: _ctrl,
      focusNode: _effectiveFocusNode,
      autofocus: widget.autofocus,
      enabled: !widget.locked,
      readOnly: widget.readOnly || _blocksInteraction,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      textAlignVertical: TextAlignVertical.center,
      padding:
          dec.contentPadding ??
          widget.padding ??
          const EdgeInsets.symmetric(horizontal: 12),
      keyboardType: widget.keyboardType,
      textAlign: widget.textAlign,
      textDirection: _resolveTextDirection(context),
      textCapitalization: widget.textCapitalization,
      obscureText: _obscure && widget.isPassword,
      maxLines: effectiveMaxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters ?? const [],
      style: _resolveFieldStyle(palette, dec),
      placeholder: widget.placeholder,
      placeholderStyle: _placeholderStyle(palette, dec),
      prefix: _buildPrefixRow(palette, dec),
      suffix: _buildSuffixRow(context, hasText, palette, dec),
      onSubmitted: widget.onSubmit,
      decoration: const BoxDecoration(color: Colors.transparent),
    );
    if (_absorbInnerPointers) {
      return AbsorbPointer(child: field);
    }
    return field;
  }

  Widget _bodyRow(
    BuildContext context,
    String? errorText,
    bool hasError,
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec, {
    required bool labelInRow,
  }) {
    final h = dec.height ?? widget.height ?? 56;
    final field = _cupertinoField(
      context,
      palette,
      dec,
      labelInRow: labelInRow,
    );
    // Stretch the editable area to the decorated height so [height] is visible
    // on both text and picker (read-only) fields. Parent label-in-row layout
    // already supplies a tight height via [SizedBox]; label-in-column uses minHeight.
    return Container(
      constraints: labelInRow ? null : BoxConstraints(minHeight: h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Expanded(child: field)],
      ),
    );
  }

  InputBorder _materialOutlineBorder(
    UnifiedInputPalette palette,
    bool hasError,
    UnifiedInputDecoration dec, {
    bool focused = false,
  }) {
    final radius =
        dec.borderRadius ?? widget.borderRadius ?? palette.borderRadius;
    // Gradient strokes are painted by [UnifiedGradientBorder]; hide Material stroke.
    final useGradient =
        !hasError && (dec.borderGradient ?? widget.borderGradient) != null;
    if (useGradient) {
      return OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      );
    }
    final resolved =
        dec.borderSide ?? widget.borderSide ?? palette.defaultBorderSide;
    final side = hasError
        ? BorderSide(
            color: _validationColor(palette, dec),
            width: resolved.width,
          )
        : resolved;
    return OutlineInputBorder(borderRadius: radius, borderSide: side);
  }

  Widget? _floatingLabelWidget(
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
  ) {
    if (!unifiedFieldHasVisibleLabel(widget.label)) return null;
    const mode = UnifiedFieldLabelMode.floatingLabel;
    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label!, style: _resolveLabelStyle(palette, dec, mode)),
        if (widget.requiredField)
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: UnifiedInputThemeResolver.requiredIcon(
              context,
              palette,
              fallbackColor: palette.labelColor,
            ),
          ),
      ],
    );
    return Padding(padding: _resolveLabelPadding(dec, mode), child: label);
  }

  Widget _materialFloatingField(
    BuildContext context,
    String? errorText,
    bool hasError,
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec, {
    double? fixedHeight,
  }) {
    final hasText = _ctrl.text.isNotEmpty;
    final showErrorOnField =
        hasError &&
        UnifiedInputThemeResolver.fieldShowError(
          context,
          field: widget.showError,
        ) &&
        dec.showError;
    final fieldStyle = _resolveFieldStyle(palette, dec);
    final basePadding =
        dec.contentPadding ??
        widget.padding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    final singleLine = widget.isPassword || widget.maxLines == 1;
    // A dense decorator never grows its fill past one text line, so center the
    // line in [fixedHeight] with vertical padding (Figma auto-layout style).
    final contentPadding = fixedHeight != null && singleLine
        ? _centeredPadding(
            basePadding,
            fixedHeight,
            fieldStyle,
            _placeholderStyle(palette, dec),
          )
        : basePadding;
    final hint = _layerOpacityHint(_placeholderStyle(palette, dec));
    final field = TextField(
      controller: _ctrl,
      focusNode: _effectiveFocusNode,
      autofocus: widget.autofocus,
      enabled: !_visuallyDisabled,
      readOnly: widget.readOnly || _blocksInteraction,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      keyboardType: widget.keyboardType,
      textAlign: widget.textAlign,
      textDirection: _resolveTextDirection(context),
      textCapitalization: widget.textCapitalization,
      obscureText: _obscure && widget.isPassword,
      maxLines: widget.isPassword && _obscure
          ? 1
          : (widget.maxLines == 0 ? null : widget.maxLines),
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      style: fieldStyle,
      onSubmitted: widget.onSubmit,
      textAlignVertical: fixedHeight == null ? null : TextAlignVertical.center,
      decoration: InputDecoration(
        isDense: true,
        label: _floatingLabelWidget(palette, dec),
        hintText: hint == null ? widget.placeholder : null,
        hint: hint,
        hintStyle: _placeholderStyle(palette, dec),
        filled: true,
        fillColor: _effectiveBackgroundColor(palette, dec),
        contentPadding: contentPadding,
        border: _materialOutlineBorder(palette, hasError, dec),
        enabledBorder: _materialOutlineBorder(palette, hasError, dec),
        focusedBorder: _materialOutlineBorder(
          palette,
          hasError,
          dec,
          focused: true,
        ),
        disabledBorder: _materialOutlineBorder(palette, hasError, dec),
        errorBorder: _materialOutlineBorder(palette, true, dec),
        focusedErrorBorder: _materialOutlineBorder(
          palette,
          true,
          dec,
          focused: true,
        ),
        errorText: showErrorOnField ? errorText : null,
        errorStyle: TextStyle(
          color: _validationColor(palette, dec),
          fontSize: 12,
        ),
        // [InputDecoration.prefix] hides until focus / text; leading adornments
        // must stay visible on an empty field (and size to their own row).
        prefixIcon: _materialPrefixIcon(palette, dec, contentPadding),
        prefixIconConstraints: const BoxConstraints(),
        suffixIcon: _buildSuffixRow(context, hasText, palette, dec),
      ),
    );
    if (_absorbInnerPointers) {
      return AbsorbPointer(child: field);
    }
    return field;
  }

  /// Placeholder drawn opaque inside an [Opacity] layer when its color is
  /// translucent, so overlapping glyphs (joined Persian / Arabic letters) are
  /// composited once — the way Figma and CSS apply layer opacity. Null when
  /// the plain [InputDecoration.hintText] renders identically.
  Widget? _layerOpacityHint(TextStyle style) {
    final text = widget.placeholder;
    final color = style.color;
    if (text == null ||
        text.isEmpty ||
        color == null ||
        color.a >= 1 ||
        style.foreground != null) {
      return null;
    }
    return Opacity(
      opacity: color.a,
      child: Text(
        text,
        style: style.copyWith(color: color.withValues(alpha: 1)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: widget.textAlign,
        textDirection: _resolveTextDirection(context),
      ),
    );
  }

  /// Leading adornments for the Material path. Material places
  /// [InputDecoration.prefixIcon] a fixed gap (4 px in M3) before the text and
  /// skips `contentPadding.start`; pad the row so the gap equals
  /// `contentPadding.start`, like the Cupertino path.
  Widget? _materialPrefixIcon(
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
    EdgeInsetsGeometry contentPadding,
  ) {
    final row = _buildPrefixRow(palette, dec);
    if (row == null) return null;
    final dir = Directionality.of(context);
    final resolved = contentPadding.resolve(dir);
    final start = dir == TextDirection.rtl ? resolved.right : resolved.left;
    final builtInGap = Theme.of(context).useMaterial3 ? 4.0 : 0.0;
    final extra = math.max(0.0, start - builtInGap);
    if (extra == 0) return row;
    return Padding(
      padding: EdgeInsetsDirectional.only(end: extra),
      child: row,
    );
  }

  /// [padding] with top / bottom set so one line of [style] (or the taller
  /// [hintStyle]) is centered in [height]. Horizontal insets are kept.
  EdgeInsetsGeometry _centeredPadding(
    EdgeInsetsGeometry padding,
    double height,
    TextStyle style,
    TextStyle hintStyle,
  ) {
    final scaler = MediaQuery.textScalerOf(context);
    double lineHeight(TextStyle s) {
      final painter = TextPainter(
        text: TextSpan(text: ' ', style: s),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final h = painter.height;
      painter.dispose();
      return h;
    }

    final line = math.max(lineHeight(style), lineHeight(hintStyle));
    final vertical = math.max(0.0, (height - line) / 2);
    final resolved = padding.resolve(Directionality.of(context));
    return EdgeInsetsDirectional.fromSTEB(
      Directionality.of(context) == TextDirection.rtl
          ? resolved.right
          : resolved.left,
      vertical,
      Directionality.of(context) == TextDirection.rtl
          ? resolved.left
          : resolved.right,
      vertical,
    );
  }

  Widget _buildLabelInRowLayout(
    BuildContext context,
    String? errorText,
    bool hasError,
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
    Widget Function(Widget child) wrapInteraction,
  ) {
    final ratio = dec.effectiveRowLabelRatio;
    final labelFlex = ratio[0];
    final bodyFlex = ratio[1];
    final h = dec.height ?? widget.height ?? 56;
    final radius =
        dec.borderRadius ?? widget.borderRadius ?? palette.borderRadius;
    final divider =
        dec.borderSide ??
        widget.borderSide ??
        const BorderSide(color: Color(0xff58514C), width: 0.5);
    final headerBg = _effectiveHeaderBackgroundColor(palette, dec);
    final showErrorMessage =
        hasError &&
        errorText != null &&
        UnifiedInputThemeResolver.fieldShowError(
          context,
          field: widget.showError,
        ) &&
        dec.showError;

    return wrapInteraction(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Do not set clipBehavior on the bordered container — it clips the stroke.
          // Height lives on the inner SizedBox (pre-1.3.0 contract) so solid
          // borders keep the same outer size; gradient pads outside that box.
          UnifiedFieldBorderBox(
            borderRadius: radius,
            borderSide: hasError
                ? BorderSide(
                    color: _validationColor(palette, dec),
                    width: (dec.borderSide ?? widget.borderSide)?.width ?? 1,
                  )
                : (dec.borderSide ??
                      widget.borderSide ??
                      palette.defaultBorderSide),
            borderGradient: hasError
                ? null
                : (dec.borderGradient ?? widget.borderGradient),
            forceSolid: hasError,
            clipInner: true,
            child: SizedBox(
              height: h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: labelFlex,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: headerBg,
                        border: BorderDirectional(end: divider),
                      ),
                      child: !unifiedFieldHasVisibleLabel(widget.label)
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: _resolveLabelPadding(
                                dec,
                                UnifiedFieldLabelMode.labelInRow,
                              ),
                              child: _labelRowCompact(palette, dec),
                            ),
                    ),
                  ),
                  Expanded(
                    flex: bodyFlex,
                    child: ColoredBox(
                      color: _effectiveBackgroundColor(palette, dec),
                      child: _bodyRow(
                        context,
                        errorText,
                        hasError,
                        palette,
                        dec,
                        labelInRow: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showErrorMessage)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                errorText,
                style: TextStyle(
                  color: _validationColor(palette, dec),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// With adornment tap targets on, only the horizontal part of the
  /// adornment padding applies: vertical padding would cap the slot below
  /// the field height. The row is centred, so the chips do not move.
  EdgeInsetsGeometry _adornmentPadding(
    EdgeInsetsGeometry padding,
    UnifiedInputDecoration dec,
  ) {
    if (!_adornmentTapTargetsOn(dec)) return padding;
    final r = padding.resolve(Directionality.of(context));
    return EdgeInsets.only(left: r.left, right: r.right);
  }

  /// Touch adornment targets on: the box lets them reach the outer edge
  /// (label-in-column; label-in-row already gives the body the full height).
  bool _adornmentTapTargetsOn(UnifiedInputDecoration dec) =>
      UnifiedInputThemeResolver.adornmentMinTapTarget(
        context,
        decoration: dec,
      ) >
      0;

  Widget _buildLabelInColumnLayout(
    BuildContext context,
    String? errorText,
    bool hasError,
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
    Widget Function(Widget child) wrapInteraction,
  ) {
    final radius =
        dec.borderRadius ?? widget.borderRadius ?? palette.borderRadius;
    // Do not ClipRRect the bordered container — that clips the border stroke.
    // Do not ClipRRect the label — high borderRadius clips glyph tops.
    return wrapInteraction(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _labelBlock(errorText, palette, dec),
          UnifiedFieldBorderBox(
            height: dec.height ?? widget.height ?? 56,
            borderRadius: radius,
            backgroundColor: _effectiveBackgroundColor(palette, dec),
            borderSide: hasError
                ? BorderSide(
                    color: _validationColor(palette, dec),
                    width: (dec.borderSide ?? widget.borderSide)?.width ?? 1,
                  )
                : (dec.borderSide ??
                      widget.borderSide ??
                      palette.defaultBorderSide),
            borderGradient: hasError
                ? null
                : (dec.borderGradient ?? widget.borderGradient),
            forceSolid: hasError,
            clipInner: true,
            strokeOverChild: _adornmentTapTargetsOn(dec),
            child: _bodyRow(
              context,
              errorText,
              hasError,
              palette,
              dec,
              labelInRow: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingLabelLayout(
    BuildContext context,
    String? errorText,
    bool hasError,
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
    Widget Function(Widget child) wrapInteraction,
  ) {
    final h = dec.height ?? widget.height;
    final configuredGradient = dec.borderGradient ?? widget.borderGradient;
    final gradient = hasError ? null : configuredGradient;
    final field = _materialFloatingField(
      context,
      errorText,
      hasError,
      palette,
      dec,
      fixedHeight: configuredGradient == null ? null : h,
    );
    if (configuredGradient == null) {
      // Unchanged pre-1.3.0 floating layout when gradient is unset.
      return wrapInteraction(
        h == null ? field : SizedBox(height: h, child: field),
      );
    }
    if (gradient == null) {
      // Error on a gradient field: same box height (padding centers the text),
      // solid Material error outline, message below the box.
      return wrapInteraction(field);
    }
    final radius =
        dec.borderRadius ?? widget.borderRadius ?? palette.borderRadius;
    final stroke =
        dec.borderSide ?? widget.borderSide ?? palette.defaultBorderSide;
    final strokeW = stroke.width <= 0 ? 1.0 : stroke.width;
    // Stroke is painted inside bounds (same outer size as Material outline).
    final inner = h == null ? field : SizedBox(height: h, child: field);
    return wrapInteraction(
      UnifiedGradientBorder(
        gradient: gradient,
        borderRadius: radius,
        width: strokeW,
        child: inner,
      ),
    );
  }

  Widget _labelRowCompact(
    UnifiedInputPalette palette,
    UnifiedInputDecoration dec,
  ) {
    final defaultLabelStyle = _resolveLabelStyle(
      palette,
      dec,
      UnifiedFieldLabelMode.labelInRow,
    ).copyWith(height: 1.0);
    final label = Text(
      widget.label!,
      style: defaultLabelStyle,
      textAlign: TextAlign.center,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
    );
    if (!widget.requiredField) {
      return Center(child: label);
    }
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: label),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 2),
            child: UnifiedInputThemeResolver.requiredIcon(context, palette),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _tick,
      builder: (context, _, _) {
        final palette = UnifiedInputThemeResolver.resolvePalette(context);
        final errorText = _resolvedError(context);
        final hasError = errorText != null && errorText.isNotEmpty;
        final dec = _resolveDecoration(context, palette, hasError);

        Widget wrapInteraction(Widget child) {
          Widget result = MouseRegion(
            onEnter: (_) {
              if (_visuallyDisabled || widget.locked || widget.loading) return;
              if (!_hovered) {
                _hovered = true;
                _tick.value++;
              }
            },
            onExit: (_) {
              if (!_hovered) return;
              _hovered = false;
              _tick.value++;
            },
            child: child,
          );
          final m = _effectiveAutovalidateMode(context);
          if (m == AutovalidateMode.always || m == AutovalidateMode.disabled) {
            return result;
          }
          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _markUserInteracted(),
            child: result,
          );
        }

        final effectiveLabelMode = resolveUnifiedFieldLabelMode(
          mode: dec.labelMode ?? widget.labelMode,
          labelInRow: dec.labelInRow || (widget.labelInRow ?? false),
          themeMode: UnifiedInputThemeResolver.fieldLabelMode(context),
        );

        switch (effectiveLabelMode) {
          case UnifiedFieldLabelMode.labelInRow:
            return _buildLabelInRowLayout(
              context,
              errorText,
              hasError,
              palette,
              dec,
              wrapInteraction,
            );
          case UnifiedFieldLabelMode.labelInColumn:
            return _buildLabelInColumnLayout(
              context,
              errorText,
              hasError,
              palette,
              dec,
              wrapInteraction,
            );
          case UnifiedFieldLabelMode.floatingLabel:
            return _buildFloatingLabelLayout(
              context,
              errorText,
              hasError,
              palette,
              dec,
              wrapInteraction,
            );
        }
      },
    );
  }
}
