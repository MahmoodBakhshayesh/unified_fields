import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../unified_colors.dart';

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
    /// When [locked] becomes true, reset text to [initialValue] / empty.
    this.resetTextWhenLocked = true,
    this.autofocus = false,
    this.isPassword = false,
    this.showClearButton = false,
    this.requiredField = false,
    this.labelInRow = false,
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

    if (oldWidget.locked != widget.locked && widget.locked && widget.resetTextWhenLocked) {
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
    final rtl = RegExp(r'[\u0600-\u06FF\uFB50-\uFDFF\uFE70-\uFEFF]').hasMatch(first);
    return rtl ? TextDirection.rtl : TextDirection.ltr;
  }

  Border? _borderFromSide(BorderSide? side, [bool? hasError]) {
    if(hasError??false) return Border.all(color: Colors.red,width: 1);
    if (side == null) return null;
    return Border.fromBorderSide(side);
  }

  bool get _nonInteractive => widget.disabled || widget.isDisabled || widget.locked;

  Color get _labelColor {
    if (widget.isDisabled || widget.disabled) {
      return UnifiedColors.textColorDark.withValues(alpha: 0.45);
    }
    if (widget.locked) {
      return UnifiedColors.textColorDark.withValues(alpha: 0.55);
    }
    return UnifiedColors.textColorDark;
  }

  TextStyle _resolveLabelStyle() {
    final base = widget.labelStyle ?? TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _labelColor);
    return base.copyWith(color: _labelColor);
  }

  TextStyle _resolveFieldStyle() {
    final base = widget.style ?? TextStyle(color: UnifiedColors.textColorDark);
    if (widget.isDisabled || widget.disabled) {
      return base.copyWith(color: UnifiedColors.textColorDark.withValues(alpha: 0.45));
    }
    if (widget.locked) {
      return base.copyWith(color: UnifiedColors.textColorDark.withValues(alpha: 0.55));
    }
    return base;
  }

  Color get _effectiveBackgroundColor {
    if (widget.isDisabled || widget.disabled) {
      return widget.backgroundColor.withValues(alpha: 0.55);
    }
    if (widget.locked) {
      return widget.backgroundColor.withValues(alpha: 0.65);
    }
    return widget.backgroundColor;
  }

  Widget _stateSuffixIcon(IconData icon) {
    return ExcludeFocus(
      child: IconButton(
        style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        onPressed: null,
        icon: Icon(icon, size: 18, color: UnifiedColors.textColorDark.withValues(alpha: 0.7)),
      ),
    );
  }

  Widget _labelBlock(String? errorText) {
    if (widget.label == null) return const SizedBox.shrink();
    final defaultLabelStyle = _resolveLabelStyle();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 8),
      child: IgnorePointer(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: Row(children: [
              Text(widget.label!, style: defaultLabelStyle),
              if (widget.requiredField)
                const Padding(
                  padding: EdgeInsets.only(bottom: 6,right: 4),
                  child: Icon(Icons.star_rate_rounded, color: UnifiedColors.textColorDark, size: 8),
                ),
            ],)),
            Text(errorText ?? '', style: TextStyle(color: widget.validationColor ?? Colors.red, fontSize: 12)),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget? _buildSuffixRow(bool hasText) {
    final widgets = <Widget>[];

    if (widget.isDisabled || widget.disabled) {
      widgets.add(_stateSuffixIcon(Icons.not_interested_outlined));
    } else if (widget.locked) {
      widgets.add(_stateSuffixIcon(Icons.lock_outline));
    } else {
      if (widget.isPassword) {
        widgets.add(
          ExcludeFocus(
            child: IconButton(
              style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              onPressed: widget.disabled ? null : _toggleObscure,
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, size: 18, color: UnifiedColors.textColorDark.withValues(alpha: 0.7)),
              tooltip: _obscure ? 'Show password' : 'Hide password',
            ),
          ),
        );
      } else if (widget.suffixIcon != null) {
        widgets.add(widget.suffixIcon!);
      }

      if (widget.showClearButton && hasText && !widget.locked && !widget.isDisabled && !widget.disabled) {
        widgets.insert(
          0,
          ExcludeFocus(
            child: IconButton(
              style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              onPressed: widget.disabled ? null : () => _ctrl.clear(),
              icon: Icon(Icons.clear, size: 18, color: UnifiedColors.textColor.withValues(alpha: 0.7)),
            ),
          ),
        );
      }
    }

    if (widgets.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: widgets),
    );
  }

  Widget _cupertinoField() {
    final hasText = _ctrl.text.isNotEmpty;
    final obscureOneLine = widget.isPassword && _obscure;
    final effectiveMaxLines = obscureOneLine ? 1 : (widget.maxLines == 0 ? null : widget.maxLines);
    return CupertinoTextField(
      controller: _ctrl,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: !_nonInteractive,
      readOnly: widget.readOnly || _nonInteractive,
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
      style: _resolveFieldStyle(),
      placeholder: widget.placeholder,
      placeholderStyle: TextStyle(
        color: widget.isDisabled || widget.disabled
            ? UnifiedColors.hintColor.withValues(alpha: 0.45)
            : UnifiedColors.hintColor,
      ),
      prefix: widget.prefixIcon ?? widget.prefix,
      suffix: _buildSuffixRow(hasText),
      onSubmitted: widget.onSubmit,
      decoration: widget.labelInRow
          ? BoxDecoration(
              color: _effectiveBackgroundColor,
              borderRadius: widget.borderRadius,
              border: _borderFromSide(widget.borderSide),
            )
          : const BoxDecoration(color: Colors.transparent),
    );
  }

  Widget _bodyRow(String? errorText, bool hasError) {
    final minH = widget.height ?? 56;
    return Container(
      constraints: BoxConstraints(minHeight: minH),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _cupertinoField()),
          // if (hasError && widget.showError) Expanded(child: _errorStrip(errorText)),
        ],
      ),
    );
  }

  Widget _labelRowCompact() {
    final defaultLabelStyle = _resolveLabelStyle();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(widget.label!, style: defaultLabelStyle, textAlign: TextAlign.center)),
        if (widget.requiredField)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Icon(Icons.star_rate_rounded, color: Colors.red, size: 8),
          ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _tick,
        builder: (context, _, _) {
          final errorText = _resolvedError;
          final hasError = errorText != null && errorText.isNotEmpty;
          final radius = widget.borderRadius;

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

          if (widget.labelInRow) {
            final labelFlex = widget.rowLabelRatio.isNotEmpty ? widget.rowLabelRatio[0] : 12;
            final bodyFlex = widget.rowLabelRatio.length > 1 ? widget.rowLabelRatio[1] : 33;
            final h = widget.height ?? 56;

            return wrapInteraction(
              ClipRRect(
                borderRadius: radius,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: labelFlex,
                      child: Container(
                        height: h,
                        color: widget.headerBackgroundColor ?? _effectiveBackgroundColor,
                        alignment: Alignment.center,
                        child: widget.label == null
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: _labelRowCompact(),
                              ),
                      ),
                    ),
                    Expanded(
                      flex: bodyFlex,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _effectiveBackgroundColor,
                          borderRadius: BorderRadiusDirectional.horizontal(end: Radius.circular(radius.bottomRight.x)),
                        ),
                        height: h,
                        child: _bodyRow(errorText, hasError),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return wrapInteraction(
            ClipRRect(
              borderRadius: radius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _labelBlock(errorText),
                  Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: _effectiveBackgroundColor,
                      borderRadius: radius,
                      border: _borderFromSide(widget.borderSide, hasError),
                    ),
                    child: _bodyRow(errorText, hasError),
                  ),
                ],
              ),
            ),
          );
        },
    );
  }
}
