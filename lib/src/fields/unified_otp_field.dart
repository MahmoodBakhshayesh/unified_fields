import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../unified_fields_typography.dart';
import 'unified_gradient_border.dart';
import 'unified_input_theme.dart';

/// One-time-code entry: [length] boxes backed by a single hidden [TextField],
/// so paste, SMS autofill ([AutofillHints.oneTimeCode]), backspace and the
/// platform keyboard behave natively.
///
/// Box chrome uses [UnifiedFieldBorderBox] (solid [borderSide] or gradient
/// [borderGradient]); unset colors and text style fall back to the
/// [UnifiedInputPalette] / theme field style.
class UnifiedOtpField extends StatefulWidget {
  /// Creates an OTP field.
  const UnifiedOtpField({
    super.key,
    this.length = 6,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onCompleted,
    this.autofocus = false,
    this.enabled = true,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.hasError = false,
    this.boxWidth = 56,
    this.boxHeight = 56,
    this.gap = 16,
    this.alignment = MainAxisAlignment.center,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.backgroundColor,
    this.filledBackgroundColor,
    this.borderSide,
    this.borderGradient,
    this.focusedBorderSide,
    this.focusedBorderGradient,
    this.errorBorderSide,
    this.textStyle,
    this.cursorColor,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.textDirection = TextDirection.ltr,
  }) : assert(length > 0);

  /// Number of boxes / characters.
  final int length;

  /// Optional external controller (text is clamped to [length]).
  final TextEditingController? controller;

  /// Optional external focus node.
  final FocusNode? focusNode;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Called once all [length] characters are entered.
  final ValueChanged<String>? onCompleted;

  /// Focus on first build.
  final bool autofocus;

  /// When false, the field ignores input and taps.
  final bool enabled;

  /// Render entered characters as [obscuringCharacter].
  final bool obscureText;

  /// Character shown for each entry when [obscureText] is true.
  final String obscuringCharacter;

  /// Draws every box with [errorBorderSide] (palette validation color by default).
  final bool hasError;

  /// Box width.
  final double boxWidth;

  /// Box height.
  final double boxHeight;

  /// Horizontal gap between boxes.
  final double gap;

  /// Row alignment of the boxes.
  final MainAxisAlignment alignment;

  /// Box corner radius.
  final BorderRadius borderRadius;

  /// Box fill (palette field background by default).
  final Color? backgroundColor;

  /// Fill of boxes that already hold a character (defaults to [backgroundColor]).
  final Color? filledBackgroundColor;

  /// Idle box stroke (also the stroke width for [borderGradient]).
  final BorderSide? borderSide;

  /// Optional gradient stroke for idle boxes.
  final Gradient? borderGradient;

  /// Stroke of the box receiving the next character while focused
  /// (defaults to [borderSide]).
  final BorderSide? focusedBorderSide;

  /// Gradient for the active box while focused. Defaults to [borderGradient],
  /// or to a solid [focusedBorderSide] when only that is set.
  final Gradient? focusedBorderGradient;

  /// Stroke used for every box when [hasError] is true.
  final BorderSide? errorBorderSide;

  /// Character style (theme field style by default).
  final TextStyle? textStyle;

  /// Color of the caret drawn in the active box (text color by default).
  final Color? cursorColor;

  /// Keyboard (numeric by default).
  final TextInputType keyboardType;

  /// Input filters (digits only by default). Persian (۰–۹) and Arabic-Indic
  /// (٠–٩) digits are always converted to ASCII first, so codes reach
  /// [onChanged] / [onCompleted] as `0`–`9`.
  final List<TextInputFormatter>? inputFormatters;

  /// Order of the boxes; codes read left-to-right even in RTL layouts.
  final TextDirection textDirection;

  @override
  State<UnifiedOtpField> createState() => _UnifiedOtpFieldState();
}

class _UnifiedOtpFieldState extends State<UnifiedOtpField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  String _lastCompleted = '';

  TextEditingController get _ctrl => widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void dispose() {
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    widget.onChanged?.call(value);
    if (value.length == widget.length && value != _lastCompleted) {
      _lastCompleted = value;
      widget.onCompleted?.call(value);
    } else if (value.length < widget.length) {
      _lastCompleted = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = UnifiedInputThemeResolver.resolvePalette(context);
    final style = (UnifiedInputThemeResolver.fieldTextStyle(context) ??
            TextStyle(fontSize: 20, color: palette.fieldTextColor))
        .merge(widget.textStyle);
    final textColor = style.color ?? palette.fieldTextColor;
    final idleSide = widget.borderSide ?? palette.defaultBorderSide;
    final errorSide = widget.errorBorderSide ?? BorderSide(color: palette.validationColor, width: idleSide.width);
    final fill = widget.backgroundColor ?? palette.bodyBackground;

    final hidden = TextField(
      controller: _ctrl,
      focusNode: _focus,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      inputFormatters: [
        // Persian / Arabic-Indic keypads: ۱۲۳ → 123 before any filter runs.
        const _AsciiDigitsFormatter(),
        ...(widget.inputFormatters ?? [FilteringTextInputFormatter.digitsOnly]),
        LengthLimitingTextInputFormatter(widget.length),
      ],
      autofillHints: const [AutofillHints.oneTimeCode],
      showCursor: false,
      enableInteractiveSelection: false,
      style: const TextStyle(color: Colors.transparent, fontSize: 1),
      decoration: const InputDecoration.collapsed(hintText: null),
      onChanged: _onChanged,
    );

    return ListenableBuilder(
      listenable: Listenable.merge([_ctrl, _focus]),
      builder: (context, _) {
        final text = _ctrl.text;
        final focused = _focus.hasFocus;
        final active = text.length.clamp(0, widget.length - 1);
        final boxes = <Widget>[];
        for (var i = 0; i < widget.length; i++) {
          if (i > 0) boxes.add(SizedBox(width: widget.gap));
          final isActive = focused && i == active && text.length < widget.length;
          final char = i < text.length ? (widget.obscureText ? widget.obscuringCharacter : text[i]) : null;
          boxes.add(
            SizedBox(
              width: widget.boxWidth,
              height: widget.boxHeight,
              child: UnifiedFieldBorderBox(
                borderRadius: widget.borderRadius,
                borderSide: widget.hasError ? errorSide : (isActive ? widget.focusedBorderSide ?? idleSide : idleSide),
                borderGradient: widget.hasError
                    ? null
                    : isActive
                        // A focused side without a focused gradient means a solid focus ring.
                        ? widget.focusedBorderGradient ?? (widget.focusedBorderSide != null ? null : widget.borderGradient)
                        : widget.borderGradient,
                forceSolid: widget.hasError,
                backgroundColor: char != null ? widget.filledBackgroundColor ?? fill : fill,
                height: widget.boxHeight,
                alignment: Alignment.center,
                child: Center(
                  child: char != null
                      ? Text(char, style: style, textAlign: TextAlign.center)
                      : isActive
                          ? Container(width: 1.5, height: (style.fontSize ?? 20) * 1.2, color: widget.cursorColor ?? textColor)
                          : const SizedBox.shrink(),
                ),
              ),
            ),
          );
        }
        return Semantics(
          textField: true,
          label: 'One-time code',
          value: text,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? () => _focus.requestFocus() : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Keeps the IME connection; visually transparent and untouchable.
                Positioned.fill(child: IgnorePointer(child: Opacity(opacity: 0, child: hidden))),
                LayoutBuilder(
                  builder: (context, constraints) => Directionality(
                    textDirection: widget.textDirection,
                    child: Row(
                      mainAxisSize: constraints.hasBoundedWidth ? MainAxisSize.max : MainAxisSize.min,
                      mainAxisAlignment: widget.alignment,
                      children: boxes,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AsciiDigitsFormatter extends TextInputFormatter {
  const _AsciiDigitsFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = UnifiedFieldsTypography.fromPersianDigits(newValue.text);
    // One UTF-16 unit per digit either way, so the selection stays valid.
    return text == newValue.text ? newValue : newValue.copyWith(text: text);
  }
}
