import 'package:flutter/material.dart';

import '../unified_colors.dart';
import 'unified_field_label_mode.dart';
import 'unified_input_decoration.dart';
import 'unified_input_theme.dart';

/// Shared chrome: optional label (column or row), bordered body, optional inline validation panel.
///
/// Use when the inner control is not [UnifiedBaseTextField] but should match its visual language.
class UnifiedFieldShell extends StatelessWidget {
  /// Creates a field shell.
  const UnifiedFieldShell({
    super.key,
    required this.decoration,
    required this.body,
    this.errorText,
    this.minBodyHeight,
  });

  /// Resolved decoration controlling label, palette, border, padding, etc.
  final UnifiedInputDecoration decoration;

  /// Inner content widget rendered inside the bordered body.
  final Widget body;

  /// Non-null non-empty shows validation strip when [decoration.showError] is true.
  final String? errorText;

  /// Defaults to [decoration.height] when set.
  final double? minBodyHeight;

  @override
  Widget build(BuildContext context) {
    final dec = decoration;
    final showStrip = dec.showError && (errorText?.isNotEmpty ?? false);
    final validationColor = dec.validationColor ?? Colors.red;
    final radius = dec.borderRadius ?? BorderRadius.zero;
    final border = dec.borderSide ?? BorderSide.none;
    final bg = dec.backgroundColor ?? Colors.black26;
    final h = minBodyHeight ?? dec.height ?? 56;

    final inner = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SizedBox(
            height: h,
            width: double.infinity,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: body,
            ),
          ),
        ),
        if (showStrip)
          Expanded(
            child: Container(
              height: (dec.labelMode ??
                          resolveUnifiedFieldLabelMode(
                            labelInRow: dec.labelInRow,
                          )) ==
                      UnifiedFieldLabelMode.labelInRow
                  ? h
                  : (h - 12).clamp(40, h),
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: validationColor),
                color: validationColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  if (dec.validationIcon != null)
                    Icon(dec.validationIcon!, color: validationColor, size: 20),
                  Expanded(
                    child: Text(
                      errorText ?? '',
                      style: TextStyle(
                        color: validationColor,
                        fontSize: 9,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    final boxed = Container(
      constraints: BoxConstraints(minHeight: h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: (dec.labelMode ??
                    resolveUnifiedFieldLabelMode(labelInRow: dec.labelInRow)) ==
                UnifiedFieldLabelMode.labelInRow
            ? BorderRadiusDirectional.horizontal(
                end: Radius.circular(radius.bottomRight.x),
              )
            : radius,
        border: Border.fromBorderSide(border),
      ),
      alignment: Alignment.center,
      child: inner,
    );

    if (dec.label == null) {
      return boxed;
    }

    final labelMode = dec.labelMode ??
        resolveUnifiedFieldLabelMode(labelInRow: dec.labelInRow);

    if (labelMode == UnifiedFieldLabelMode.labelInColumn ||
        labelMode == UnifiedFieldLabelMode.floatingLabel) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabelRow(decoration: dec),
          boxed,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: dec.rowLabelRatio[0],
          child: SizedBox(
            height: h,
            child: Align(
              alignment: Alignment.center,
              child: _LabelRow(decoration: dec),
            ),
          ),
        ),
        Expanded(flex: dec.rowLabelRatio[1], child: boxed),
      ],
    );
  }
}

/// @deprecated Renamed to [UnifiedFieldShell].
@Deprecated('Use UnifiedFieldShell')
typedef AppUnifiedFieldShell = UnifiedFieldShell;

class _LabelRow extends StatelessWidget {
  const _LabelRow({required this.decoration});

  final UnifiedInputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    final dec = decoration;
    if (dec.label == null) return const SizedBox.shrink();

    final labelMode = dec.labelMode ??
        resolveUnifiedFieldLabelMode(labelInRow: dec.labelInRow);
    final fieldDefaults =
        UnifiedInputThemeScope.themeDataOf(context).fieldDefaults;
    final pad = UnifiedInputLabelModeStyle.resolveLabelPadding(
      mode: labelMode,
      decorationPadding: dec.labelPadding,
      fieldDefaults: fieldDefaults,
    );
    final labelStyle =
        UnifiedInputLabelModeStyle.resolveLabelStyle(
          mode: labelMode,
          decorationStyle: dec.labelStyle,
          fieldDefaults: fieldDefaults,
        ) ??
        dec.labelStyle ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: UnifiedColors.textColorDark,
        );

    return Padding(
      padding: pad,
      child: IgnorePointer(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dec.label!,
              style: labelStyle,
            ),
            if (dec.requiredField)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Icon(
                  Icons.star_rate_rounded,
                  color: Colors.red,
                  size: 8,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
