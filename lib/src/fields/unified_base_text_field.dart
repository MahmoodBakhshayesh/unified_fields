import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';

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

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;

  final String? label;
  final String? placeholder;
  final TextStyle? labelStyle;
  final TextStyle? style;

  final Color backgroundColor;
  final Color? headerBackgroundColor;
  final BorderRadius borderRadius;
  final BorderSide? borderSide;
  final double? height;
  final EdgeInsetsGeometry? padding;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;

  final bool readOnly;
  final bool disabled;
  final bool locked;
  final bool resetTextWhenLocked;
  final bool autofocus;
  final bool isPassword;
  final bool showClearButton;

  final bool requiredField;
  final bool labelInRow;
  final List<int> rowLabelRatio;

  /// Imperative / server-side error; non-empty trim wins over [validator] for display.
  final String? errorText;

  /// When [validator] runs for UI feedback. `null` means [AutovalidateMode.always].
  final AutovalidateMode? autovalidateMode;

  final String? Function(String value)? validator;
  final ValueChanged<String>? onSaved;
  final bool showError;
  final Color? validationColor;
  final IconData? validationIcon;

  final Widget? prefix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmit;

  final bool mustResolveTextDirectionByInput;

  @override
  State<UnifiedBaseTextField> createState() => UnifiedBaseTextFieldState();
}

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

  Widget _labelBlock(String? errorText) {
    if (widget.label == null) return const SizedBox.shrink();
    final defaultLabelStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textColorDark);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 8),
      child: IgnorePointer(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: Row(children: [
              Text(widget.label!, style: widget.labelStyle ?? defaultLabelStyle),
              if (widget.requiredField)
                const Padding(
                  padding: EdgeInsets.only(bottom: 6,right: 4),
                  child: Icon(Icons.star_rate_rounded, color: AppColors.textColorDark, size: 8),
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

    if (widget.locked && hasText) {
      widgets.add(
        ExcludeFocus(
          child: IconButton(
            style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            onPressed: null,
            icon: Icon(Icons.lock, size: 18, color: AppColors.textColorDark.withValues(alpha: 0.7)),
          ),
        ),
      );
    } else {
      if (widget.isPassword) {
        widgets.add(
          ExcludeFocus(
            child: IconButton(
              style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              onPressed: widget.disabled ? null : _toggleObscure,
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, size: 18, color: AppColors.textColorDark.withValues(alpha: 0.7)),
              tooltip: _obscure ? 'Show password' : 'Hide password',
            ),
          ),
        );
      } else if (widget.suffixIcon != null) {
        widgets.add(widget.suffixIcon!);
      }

      if (widget.showClearButton && hasText && !widget.locked) {
        widgets.insert(
          0,
          ExcludeFocus(
            child: IconButton(
              style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              onPressed: widget.disabled ? null : () => _ctrl.clear(),
              icon: Icon(Icons.clear, size: 18, color: AppColors.textColor.withValues(alpha: 0.7)),
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
      enabled: !widget.disabled && !widget.locked,
      readOnly: widget.readOnly || widget.locked,
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
      style: widget.style ?? TextStyle(color: AppColors.textColorDark),
      placeholder: widget.placeholder,
      placeholderStyle: TextStyle(color: AppColors.hintColor),
      prefix: widget.prefixIcon ?? widget.prefix,
      suffix: _buildSuffixRow(hasText),
      onSubmitted: widget.onSubmit,
      decoration: widget.labelInRow
          ? BoxDecoration(
              color: widget.backgroundColor,
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
    final defaultLabelStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textColorDark);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(widget.label!, style: widget.labelStyle ?? defaultLabelStyle, textAlign: TextAlign.center)),
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
                        color: widget.headerBackgroundColor ?? widget.backgroundColor,
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
                          color: widget.backgroundColor,
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
                      color: widget.backgroundColor,
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
