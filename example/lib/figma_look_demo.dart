import 'package:flutter/material.dart';
import 'package:unified_fields/unified_fields.dart';

/// Recreates the SareNakh Figma fields (sign-in / sign-up / search / OTP) with
/// theme-level setup only — fields just pass content.
///
/// Values come straight from Figma Dev Mode / Plugin API:
/// * stroke style "Linear Stroke pink + violet" (copied with its transform),
/// * 16 px radius, 16 px start inset, 24 px icon, 10 px gap, 57 px height,
/// * placeholder IRANYekanXFaNum Light 14 / 24, white @ 60 %.
///
/// For pixel parity use the design's SVG icons and font in your app; this
/// example falls back to Material icons and the platform font.
class FigmaLookDemoPage extends StatelessWidget {
  const FigmaLookDemoPage({super.key});

  static const violet = Color(0xFF8B5CF6);
  static const ink = Color(0xFF050517);

  /// Figma stroke style, transform included (renders the same at any size).
  static const stroke = UnifiedFigmaLinearGradient(
    figmaTransform: [
      [0.9476081728935242, 0.052391864359378815, 0],
      [-0.9476081728935242, 0.9476081728935242, 0.5],
    ],
    colors: [violet, ink, Color(0xFFFF5CA8)],
    stops: [0, 0.5925726890563965, 1],
  );

  static const placeholderStyle = TextStyle(
    fontFamily: 'IRANYekan',
    fontWeight: FontWeight.w300,
    fontSize: 14,
    height: 24 / 14,
    // Figma splits line-height leading evenly (Flutter default: proportional).
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0x99FFFFFF),
  );

  /// Field chrome for a screen. Auth screens: 40 % fill + 0.5 px stroke;
  /// in-app screens: opaque fill + 1 px stroke.
  static UnifiedInputThemeData theme({bool auth = false}) => UnifiedInputThemeData(
        validationColor: const Color(0xFF95021D),
        fieldDefaults: UnifiedInputFieldDefaults(
          labelMode: UnifiedFieldLabelMode.floatingLabel,
          height: 57,
          backgroundColor: auth ? ink.withValues(alpha: 0.4) : ink,
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: violet, width: auth ? 0.5 : 1),
          borderGradient: stroke,
          placeholderStyle: placeholderStyle,
          textStyle: placeholderStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w400),
          prefixIconColor: violet,
          adornmentIconSize: 24,
          prefixPadding: const EdgeInsetsDirectional.only(start: 16),
          contentPadding: const EdgeInsetsDirectional.only(start: 10, end: 16),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(useMaterial3: true),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text('Figma look (SareNakh)')),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _Caption('Sign-up (auth chrome)'),
              UnifiedInputThemeScope(
                data: theme(auth: true),
                child: const Column(
                  children: [
                    UnifiedTextField(placeholder: 'شماره همراه یا کد ملی', prefixIcon: Icon(Icons.fingerprint)),
                    SizedBox(height: 17),
                    UnifiedTextField(
                      placeholder: 'رمز عبور',
                      isPassword: true,
                      showPasswordToggle: false,
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    SizedBox(height: 17),
                    UnifiedTextField(
                      placeholder: 'تکرار رمز عبور',
                      isPassword: true,
                      showPasswordToggle: false,
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _Caption('Search (in-app chrome)'),
              UnifiedInputThemeScope(
                data: theme(),
                child: const UnifiedTextField(
                  placeholder: 'شماره همراه شخص مورد نظر',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.fingerprint),
                ),
              ),
              const SizedBox(height: 24),
              const _Caption('One-time code'),
              UnifiedOtpField(
                length: 5,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                backgroundColor: const Color(0x1A23282E),
                borderSide: const BorderSide(color: violet, width: 1),
                borderGradient: stroke,
                focusedBorderSide: const BorderSide(color: Color(0xFFFF5CA8), width: 1.5),
                textStyle: const TextStyle(fontFamily: 'IRANYekan', fontSize: 20, color: Colors.white),
                onCompleted: (code) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(code))),
              ),
              const SizedBox(height: 24),
              const _Caption('Error banner (any box can use the Figma stroke)'),
              const UnifiedGradientBorder(
                gradient: UnifiedFigmaLinearGradient(
                  figmaTransform: [
                    [0.9476081728935242, 0.052391864359378815, 0],
                    [-0.9476081728935242, 0.9476081728935242, 0.5],
                  ],
                  colors: [Color(0xFF95021D), ink, Color(0xFF95021D)],
                  stops: [0, 0.5925726890563965, 1],
                ),
                width: 0.5,
                borderRadius: BorderRadius.all(Radius.circular(16)),
                backgroundColor: Color(0x1A95021D),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('اوپس! شماره همراه صحیح نیست', style: TextStyle(fontFamily: 'IRANYekan', fontWeight: FontWeight.w300, fontSize: 14, height: 24 / 14, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, textDirection: TextDirection.ltr, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      );
}
