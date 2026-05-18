import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../unified_fields_typography.dart';
import 'unified_field_label_mode.dart';
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
    this.style,
    this.backgroundColor = Colors.black26,
    this.headerBackgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.borderSide = const BorderSide(color: Color(0xff58514C), width: 0.5),
    this.height = 56,
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
    this.resetTextWhenLocked = true,
    this.autofocus = false,
    this.isPassword = false,
    this.showClearButton = false,
    this.requiredField = false,
    this.labelInRow = false,
    this.labelMode,
    this.rowLabelRatio = const [12, 33],
    this.errorText,
    this.autovalidateMode,
    this.validator,
    this.onSaved,
    this.showError = true,
    this.validationColor,
    this.validationIcon,
    this.prefix,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmit,
    this.mustResolveTextDirectionByInput = false,
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

  /// Override for the editing text style.
  final TextStyle? style;

  /// Background color of the editing area.
  final Color backgroundColor;

  /// Background of the left label area when [labelInRow] is true.
  final Color? headerBackgroundColor;

  /// Border radius of the field box.
  final BorderRadius borderRadius;

  /// Border side of the field box.
  final BorderSide? borderSide;

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

  /// Whether to reset to [initialValue] when [locked] becomes true.
  final bool resetTextWhenLocked;

  /// Whether the inner field should request focus on first build.
  final bool autofocus;

  /// Render entered text as obscured and add a visibility toggle.
  final bool isPassword;

  /// Show an "x" suffix to clear the field when it has content.
  final bool showClearButton;

  /// Render the required marker next to [label].
  final bool requiredField;

  /// Render the label in the same row as the editing area.
  final bool labelInRow;

  /// Label placement; when null, [labelInRow] maps to [UnifiedFieldLabelMode.labelInRow],
  /// otherwise defaults to [UnifiedFieldLabelMode.floatingLabel].
  final UnifiedFieldLabelMode? labelMode;

  /// Flex ratio between the label cell and the body cell when [labelInRow] is true.
  final List<int> rowLabelRatio;

  /// Imperative / server-side error; non-empty trim wins over [validator] for display.
  final String? errorText;

  /// When [validator] runs for UI feedback. `null` means [AutovalidateMode.always].
  final AutovalidateMode? autovalidateMode;

  /// Synchronous validator returning the error message, or null when valid.
  final String? Function(String value)? validator;

  /// Called from [UnifiedBaseTextFieldState.save].
  final ValueChanged<String>? onSaved;

  /// Whether to render the inline error strip below the field when present.
  final bool showError;

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

  /// If true, the text direction is inferred from the typed content.
  final bool mustResolveTextDirectionByInput;

  @override
  State<UnifiedBaseTextField> createState() => UnifiedBaseTextFieldState();
}

/// State for [UnifiedBaseTextField] with imperative [validate] / [resetValidation] / [save] hooks.
class UnifiedBaseTextFieldState extends State<UnifiedBaseTextField> {
  late TextEditingController _ctrl;
  bool _ownsController = false;
  bool _obscure = false;

  final ValueNotifier<int> _tick = ValueNotifier(0);
  bool _userInteracted = false;
  bool _validationRequested = false;

  AutovalidateMode get _effectiveAutovalidateMode =>
      widget.autovalidateMode ?? AutovalidateMode.always;

  /// Whether [validator] may contribute to the displayed error (not [errorText]).
  bool get _shouldApplyValidator {
    final m = _effectiveAutovalidateMode;
    if (m == AutovalidateMode.always) return true;
    if (m == AutovalidateMode.disabled) return _validationRequested;
    return _userInteracted || _validationRequested;
  }

  String? get _resolvedError {
    final ext = widget.errorText?.trim();
    if (ext != null && ext.isNotEmpty) return ext;
    if (!_shouldApplyValidator) return null;
    final v = widget.validator?.call(_ctrl.text);
    if (v != null && v.trim().isNotEmpty) return v;
    return null;
  }

  /// Whether the field currently has no resolved error.
  bool get isValid => _resolvedError == null;

  /// Runs [validator] visibility rules and rebuilds. Returns whether the field is valid.
  bool validate() {
    setState(() => _validationRequested = true);
    return isValid;
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
        widget.resetTextWhenLocked) {
      _ctrl.removeListener(_onTextChanged);
      _ctrl.text = widget.initialValue ?? '';
      _ctrl.addListener(_onTextChanged);
      _tick.value++;
    }

    if (oldWidget.isPassword != widget.isPassword) {
      _obscure = widget.isPassword;
    }
  }

  void _onTextChanged() {
    widget.onChanged?.call(_ctrl.text);
    _tick.value++;
  }

  void _markUserInteracted() {
    if (_userInteracted) return;
    _userInteracted = true;
    final m = _effectiveAutovalidateMode;
    if (m != AutovalidateMode.always && m != AutovalidateMode.disabled) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTextChanged);
    if (_ownsController) _ctrl.dispose();
    _tick.dispose();
    super.dispose();
  }

  void _toggleObscure() {
    if (!widget.isPassword || widget.disabled) return;
    setState(() => _obscure = !_obscure);
  }

  TextDirection? _resolveTextDirection() {
    if (!widget.mustResolveTextDirectionByInput) return null;
    final t = _ctrl.text.trimLeft();
    if (t.isEmpty) return null;
    final first = t[0];
    final rtl = RegExp(
      r'[\u0600-\u06FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    ).hasMatch(first);
    return rtl ? TextDirection.rtl : TextDirection.ltr;
  }

  Border? _borderFromSide(BorderSide? side, [bool? hasError]) {
    if (hasError ?? false) {
      return Border.all(
        color: _validationColor(UnifiedInputThemeResolver.resolvePalette(context)),
        width: 1,
      );
    }
    if (side == null) return null;
    return Border.fromBorderSide(side);
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

  Color _labelColor(UnifiedInputPalette palette) {
    final base = widget.labelStyle?.color ?? palette.labelColor;
    if (_visuallyDisabled) {
      return UnifiedInputThemeResolver.disabledLabelColor(
        context,
        palette,
        base: base,
      );
    }
    if (widget.locked) {
      return UnifiedInputThemeResolver.lockedLabelColor(
        context,
        palette,
        base: base,
      );
    }
    return base;
  }

  TextStyle _resolveLabelStyle(UnifiedInputPalette palette) {
    final base =
        widget.labelStyle ??
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: palette.labelColor,
        );
    return base.copyWith(color: _labelColor(palette));
  }

  TextStyle _resolveFieldStyle(UnifiedInputPalette palette) {
    final base = widget.style ?? TextStyle(color: palette.fieldTextColor);
    final textBase = base.color ?? palette.fieldTextColor;
    TextStyle resolved;
    if (_visuallyDisabled) {
      resolved = base.copyWith(
        color: UnifiedInputThemeResolver.disabledFieldColor(
          context,
          palette,
          base: textBase,
        ),
      );
    } else if (widget.locked) {
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
    return UnifiedFieldsTypography.instance.mergeDigitStyle(resolved);
  }

  Color get _effectiveBackgroundColor {
    if (_visuallyDisabled) {
      return widget.backgroundColor.withValues(
        alpha: UnifiedInputThemeResolver.disabledFieldBackgroundOpacity(context),
      );
    }
    if (widget.locked) {
      return widget.backgroundColor.withValues(
        alpha: UnifiedInputThemeResolver.lockedFieldBackgroundOpacity(context),
      );
    }
    return widget.backgroundColor;
  }

  Widget _stateSuffixIcon(IconData icon, UnifiedInputPalette palette) {
    return UnifiedSuffixIconChrome.build(
      icon: icon,
      color: UnifiedInputThemeResolver.suffixIconColor(context, palette),
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

  Widget _labelBlock(String? errorText, UnifiedInputPalette palette) {
    if (widget.label == null) return const SizedBox.shrink();
    final defaultLabelStyle = _resolveLabelStyle(palette);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 8),
      child: IgnorePointer(
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
                color: _validationColor(palette),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget? _buildSuffixRow(bool hasText, UnifiedInputPalette palette) {
    final widgets = <Widget>[];

    if (_visuallyDisabled) {
      widgets.add(_stateSuffixIcon(Icons.not_interested_outlined, palette));
    } else if (widget.locked) {
      widgets.add(_stateSuffixIcon(Icons.lock_outline, palette));
    } else if (widget.loading) {
      widgets.add(_loadingSuffix());
    } else {
      if (widget.isPassword) {
        widgets.add(
          UnifiedSuffixIconChrome.build(
            icon: _obscure ? Icons.visibility : Icons.visibility_off,
            color: UnifiedInputThemeResolver.suffixIconColor(context, palette),
            onPressed: _blocksInteraction ? null : _toggleObscure,
            tooltip: _obscure ? 'Show password' : 'Hide password',
          ),
        );
      } else if (widget.suffixIcon != null) {
        widgets.add(UnifiedSuffixIconChrome.normalize(widget.suffixIcon!));
      }

      if (widget.showClearButton &&
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
                  alpha: UnifiedInputThemeScope.themeDataOf(context).suffixIconOpacity ?? 0.7,
                ),
            onPressed: _blocksInteraction ? null : () => _ctrl.clear(),
            tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
          ),
        );
      }
    }

    if (widgets.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widgets,
      ),
    );
  }

  TextStyle _placeholderStyle(UnifiedInputPalette palette) {
    return UnifiedInputThemeResolver.placeholderStyle(
      context,
      palette,
      disabled: _visuallyDisabled,
      fontSize: widget.style?.fontSize,
    );
  }

  Color _validationColor(UnifiedInputPalette palette) =>
      widget.validationColor ??
      UnifiedInputThemeResolver.validationColor(context, palette);

  /// When [isDisabled] / [disabled], [CupertinoTextField] with `enabled: false` hides
  /// placeholder or value. Render both hint and text explicitly instead.
  Widget _disabledFieldContent(UnifiedInputPalette palette, bool hasText) {
    final padding =
        widget.padding ?? const EdgeInsets.symmetric(horizontal: 12);
    final placeholderStyle = _placeholderStyle(palette);
    final valueStyle = _resolveFieldStyle(palette);
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
              textDirection: _resolveTextDirection(),
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
              textDirection: _resolveTextDirection(),
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
        textDirection: _resolveTextDirection(),
      );
    }

    final suffix = _buildSuffixRow(hasText, palette);
    return Container(
      alignment: Alignment.centerLeft,
      padding: padding,
      decoration: widget.labelInRow
          ? BoxDecoration(color: _effectiveBackgroundColor)
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ?widget.prefixIcon,
          ?widget.prefix,
          Expanded(child: textPart),
          ?suffix,
        ],
      ),
    );
  }

  Widget _cupertinoField(UnifiedInputPalette palette) {
    final hasText = _ctrl.text.isNotEmpty;
    if (_visuallyDisabled) {
      return AbsorbPointer(child: _disabledFieldContent(palette, hasText));
    }
    final obscureOneLine = widget.isPassword && _obscure;
    final effectiveMaxLines = obscureOneLine
        ? 1
        : (widget.maxLines == 0 ? null : widget.maxLines);
    final field = CupertinoTextField(
      controller: _ctrl,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: !widget.locked,
      readOnly: widget.readOnly || _blocksInteraction,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      textAlignVertical: TextAlignVertical.center,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12),
      keyboardType: widget.keyboardType,
      textAlign: widget.textAlign,
      textDirection: _resolveTextDirection(),
      textCapitalization: widget.textCapitalization,
      obscureText: _obscure && widget.isPassword,
      maxLines: effectiveMaxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters ?? const [],
      style: _resolveFieldStyle(palette),
      placeholder: widget.placeholder,
      placeholderStyle: _placeholderStyle(palette),
      prefix: widget.prefixIcon ?? widget.prefix,
      suffix: _buildSuffixRow(hasText, palette),
      onSubmitted: widget.onSubmit,
      decoration: const BoxDecoration(color: Colors.transparent),
    );
    if (_absorbInnerPointers) {
      return AbsorbPointer(child: field);
    }
    return field;
  }

  Widget _bodyRow(
    String? errorText,
    bool hasError,
    UnifiedInputPalette palette,
  ) {
    final minH = widget.height ?? 56;
    return Container(
      constraints: BoxConstraints(minHeight: minH),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _cupertinoField(palette)),
          // if (hasError && widget.showError) Expanded(child: _errorStrip(errorText)),
        ],
      ),
    );
  }

  InputBorder _materialOutlineBorder(
    UnifiedInputPalette palette,
    bool hasError, {
    bool focused = false,
  }) {
    final side = hasError
        ? BorderSide(color: _validationColor(palette), width: 1)
        : (widget.borderSide ?? palette.defaultBorderSide);
    return OutlineInputBorder(
      borderRadius: widget.borderRadius,
      borderSide: focused && !hasError
          ? side.copyWith(width: (side.width + 0.5).clamp(0.5, 2.0))
          : side,
    );
  }

  Widget? _floatingLabelWidget(UnifiedInputPalette palette) {
    if (widget.label == null) return null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label!, style: _resolveLabelStyle(palette)),
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
  }

  Widget _materialFloatingField(
    String? errorText,
    bool hasError,
    UnifiedInputPalette palette,
  ) {
    final hasText = _ctrl.text.isNotEmpty;
    final showErrorOnField = hasError && widget.showError;
    final field = TextField(
      controller: _ctrl,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: !_visuallyDisabled,
      readOnly: widget.readOnly || _blocksInteraction,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      keyboardType: widget.keyboardType,
      textAlign: widget.textAlign,
      textDirection: _resolveTextDirection(),
      textCapitalization: widget.textCapitalization,
      obscureText: _obscure && widget.isPassword,
      maxLines: widget.isPassword && _obscure
          ? 1
          : (widget.maxLines == 0 ? null : widget.maxLines),
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      style: _resolveFieldStyle(palette),
      onSubmitted: widget.onSubmit,
      decoration: InputDecoration(
        isDense: true,
        label: _floatingLabelWidget(palette),
        hintText: widget.placeholder,
        hintStyle: _placeholderStyle(palette),
        filled: true,
        fillColor: _effectiveBackgroundColor,
        contentPadding:
            widget.padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _materialOutlineBorder(palette, hasError),
        enabledBorder: _materialOutlineBorder(palette, hasError),
        focusedBorder: _materialOutlineBorder(palette, hasError, focused: true),
        disabledBorder: _materialOutlineBorder(palette, hasError),
        errorBorder: _materialOutlineBorder(palette, true),
        focusedErrorBorder: _materialOutlineBorder(palette, true, focused: true),
        errorText: showErrorOnField ? errorText : null,
        errorStyle: TextStyle(
          color: _validationColor(palette),
          fontSize: 12,
        ),
        prefixIcon: widget.prefixIcon,
        prefix: widget.prefix,
        suffixIcon: _buildSuffixRow(hasText, palette),
      ),
    );
    if (_absorbInnerPointers) {
      return AbsorbPointer(child: field);
    }
    return field;
  }

  Widget _buildLabelInRowLayout(
    String? errorText,
    bool hasError,
    UnifiedInputPalette palette,
    Widget Function(Widget child) wrapInteraction,
  ) {
    final labelFlex = widget.rowLabelRatio.isNotEmpty
        ? widget.rowLabelRatio[0]
        : 12;
    final bodyFlex = widget.rowLabelRatio.length > 1
        ? widget.rowLabelRatio[1]
        : 33;
    final h = widget.height ?? 56;
    final radius = widget.borderRadius;
    final divider =
        widget.borderSide ??
        const BorderSide(color: Color(0xff58514C), width: 0.5);
    final headerBg =
        widget.headerBackgroundColor ?? _effectiveBackgroundColor;

    return wrapInteraction(
      Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: _borderFromSide(widget.borderSide, hasError),
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
                  child: widget.label == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _labelRowCompact(palette),
                        ),
                ),
              ),
              Expanded(
                flex: bodyFlex,
                child: Container(
                  constraints: BoxConstraints(minHeight: h),
                  color: _effectiveBackgroundColor,
                  child: _bodyRow(errorText, hasError, palette),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelInColumnLayout(
    String? errorText,
    bool hasError,
    UnifiedInputPalette palette,
    Widget Function(Widget child) wrapInteraction,
  ) {
    final radius = widget.borderRadius;
    return wrapInteraction(
      ClipRRect(
        borderRadius: radius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _labelBlock(errorText, palette),
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: _effectiveBackgroundColor,
                borderRadius: radius,
                border: _borderFromSide(widget.borderSide, hasError),
              ),
              child: _bodyRow(errorText, hasError, palette),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingLabelLayout(
    String? errorText,
    bool hasError,
    UnifiedInputPalette palette,
    Widget Function(Widget child) wrapInteraction,
  ) {
    return wrapInteraction(
      _materialFloatingField(errorText, hasError, palette),
    );
  }

  Widget _labelRowCompact(UnifiedInputPalette palette) {
    final defaultLabelStyle = _resolveLabelStyle(palette);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            widget.label!,
            style: defaultLabelStyle,
            textAlign: TextAlign.center,
          ),
        ),
        if (widget.requiredField)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: UnifiedInputThemeResolver.requiredIcon(context, palette),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _tick,
      builder: (context, _, _) {
        final palette = UnifiedInputThemeResolver.resolvePalette(context);
        final errorText = _resolvedError;
        final hasError = errorText != null && errorText.isNotEmpty;

        Widget wrapInteraction(Widget child) {
          final m = _effectiveAutovalidateMode;
          if (m == AutovalidateMode.always || m == AutovalidateMode.disabled) {
            return child;
          }
          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _markUserInteracted(),
            child: child,
          );
        }

        final effectiveLabelMode = resolveUnifiedFieldLabelMode(
          mode: widget.labelMode,
          labelInRow: widget.labelInRow,
        );

        switch (effectiveLabelMode) {
          case UnifiedFieldLabelMode.labelInRow:
            return _buildLabelInRowLayout(
              errorText,
              hasError,
              palette,
              wrapInteraction,
            );
          case UnifiedFieldLabelMode.labelInColumn:
            return _buildLabelInColumnLayout(
              errorText,
              hasError,
              palette,
              wrapInteraction,
            );
          case UnifiedFieldLabelMode.floatingLabel:
            return _buildFloatingLabelLayout(
              errorText,
              hasError,
              palette,
              wrapInteraction,
            );
        }
      },
    );
  }
}
