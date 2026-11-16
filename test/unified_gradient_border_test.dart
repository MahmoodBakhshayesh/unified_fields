import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/src/fields/unified_gradient_border.dart';
import 'package:unified_fields/src/fields/unified_input_decoration.dart';
import 'package:unified_fields/src/fields/unified_input_field_defaults.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  const stroke = BorderSide(color: Color(0xFF112233), width: 1);
  const gradient = LinearGradient(
    colors: [Color(0xFFF93F9F), Color(0xFF8723FD)],
  );

  group('borderGradient is additive', () {
    test('decoration defaults leave borderGradient null', () {
      const d = UnifiedInputDecoration();
      expect(d.borderGradient, isNull);
      expect(d.borderSide, isNull);
    });

    test('field defaults leave borderGradient null', () {
      const defaults = UnifiedInputFieldDefaults();
      expect(defaults.borderGradient, isNull);
      expect(defaults.toDecoration().borderGradient, isNull);
    });

    test('merge keeps null gradient when overlay omits it', () {
      const base = UnifiedInputDecoration(borderSide: stroke);
      const overlay = UnifiedInputDecoration(height: 48);
      final merged = base.merge(overlay);
      expect(merged.borderGradient, isNull);
      expect(merged.borderSide, stroke);
      expect(merged.height, 48);
    });

    test('merge preserves existing gradient when overlay omits it', () {
      const base = UnifiedInputDecoration(borderGradient: gradient);
      const overlay = UnifiedInputDecoration(borderSide: stroke);
      final merged = base.merge(overlay);
      expect(merged.borderGradient, gradient);
      expect(merged.borderSide, stroke);
    });
  });

  group('UnifiedFieldBorderBox solid path', () {
    testWidgets('null gradient uses BoxDecoration border (no gradient wrapper)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: UnifiedFieldBorderBox(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: stroke,
                height: 48,
                child: SizedBox(width: 120),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(UnifiedGradientBorder), findsNothing);
      final box = tester.widget<Container>(find.byType(Container).first);
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.gradient, isNull);
      expect(tester.getSize(find.byType(Container).first).height, 48);
    });

    testWidgets('fixed height does not overflow with solid border',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: UnifiedFieldBorderBox(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: stroke,
                height: 48,
                clipInner: true,
                child: ColoredBox(color: Color(0xFF00FF00)),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(UnifiedGradientBorder), findsNothing);
    });
  });

  group('UnifiedFieldBorderBox gradient path', () {
    testWidgets('opt-in gradient paints UnifiedGradientBorder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: UnifiedFieldBorderBox(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: stroke,
                borderGradient: gradient,
                height: 48,
                child: SizedBox.expand(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(UnifiedGradientBorder), findsOneWidget);
      expect(tester.getSize(find.byType(UnifiedGradientBorder)).height, 48);
      expect(tester.takeException(), isNull);
    });

    testWidgets('translucent fill does not use gradient as background',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: Color(0xFF000000),
            body: Center(
              child: UnifiedGradientBorder(
                gradient: gradient,
                borderRadius: BorderRadius.all(Radius.circular(8)),
                width: 2,
                backgroundColor: Color(0x66050517),
                child: SizedBox(width: 120, height: 48),
              ),
            ),
          ),
        ),
      );

      // Stroke-only: inner DecoratedBox holds the translucent fill; no
      // BoxDecoration.gradient on the fill layer.
      final decorated = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      for (final box in decorated) {
        final decoration = box.decoration;
        if (decoration is BoxDecoration) {
          expect(decoration.gradient, isNull);
        }
      }
      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('forceSolid ignores gradient (error chrome)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: UnifiedFieldBorderBox(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFFFF0000), width: 1),
                borderGradient: gradient,
                forceSolid: true,
                height: 48,
                child: SizedBox.expand(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(UnifiedGradientBorder), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('fields without borderGradient keep solid chrome', () {
    testWidgets('UnifiedTextField with only borderSide has no gradient',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnifiedInputThemeScope(
              data: const UnifiedInputThemeData(),
              child: UnifiedTextField(
                label: 'Name',
                decoration: const UnifiedInputDecoration(
                  borderSide: stroke,
                  height: 48,
                  labelMode: UnifiedFieldLabelMode.labelInColumn,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(UnifiedGradientBorder), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
