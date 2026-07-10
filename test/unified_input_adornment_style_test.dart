import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  group('UnifiedInputAdornmentStyle', () {
    testWidgets('global adornment colors tint prefix and suffix icons',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnifiedInputThemeScope(
            data: UnifiedInputThemeData(
              adornmentStyle: const UnifiedInputAdornmentStyle(
                prefixIconColor: Color(0xFF111111),
                suffixIconColor: Color(0xFF222222),
                suffixPadding: EdgeInsets.all(12),
              ),
            ),
            child: const Scaffold(
              body: UnifiedTextField(
                label: 'Qty',
                decoration: UnifiedInputDecoration(
                  prefixIcon: Icon(Icons.tag),
                  suffixIcon: Icon(Icons.info_outline),
                ),
              ),
            ),
          ),
        ),
      );

      final icons = tester.widgetList<Icon>(find.byType(Icon));
      expect(
        icons.any((icon) => icon.color == const Color(0xFF111111)),
        isTrue,
      );
      expect(
        icons.any(
          (icon) =>
              icon.color?.withValues(alpha: 1.0) ==
                  const Color(0xFF222222).withValues(alpha: 1.0) ||
              icon.color == const Color(0xFF222222).withValues(alpha: 0.7),
        ),
        isTrue,
      );
    });

    testWidgets('per-field decoration overrides global adornment colors',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnifiedInputThemeScope(
            data: const UnifiedInputThemeData(
              adornmentStyle: UnifiedInputAdornmentStyle(
                suffixIconColor: Color(0xFF222222),
              ),
            ),
            child: const Scaffold(
              body: UnifiedTextField(
                label: 'One',
                decoration: UnifiedInputDecoration(
                  suffixIcon: Icon(Icons.star),
                  suffixIconColor: Color(0xFFABCDEF),
                ),
              ),
            ),
          ),
        ),
      );

      final star = tester.widget<Icon>(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.star,
        ),
      );
      expect(star.color, const Color(0xFFABCDEF));
    });

    testWidgets('number field step buttons use global step button style',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnifiedInputThemeScope(
            data: UnifiedInputThemeData(
              numericStepButtonStyle: const UnifiedNumericStepButtonStyle(
                iconColor: Color(0xFF00AA00),
                iconSize: 26,
                buttonWidth: 48,
              ),
            ),
            child: const Scaffold(
              body: UnifiedNumberField(label: 'Count'),
            ),
          ),
        ),
      );

      final icons = tester.widgetList<Icon>(find.byType(Icon));
      expect(
        icons.any(
          (icon) =>
              icon.color == const Color(0xFF00AA00) &&
              icon.size == 26,
        ),
        isTrue,
      );

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBoxes.any((box) => box.width == 48), isTrue);
    });

    testWidgets('number field trailing adornment order can place suffix first',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: UnifiedNumberField(
                label: 'Weight',
                trailingAdornmentOrder:
                    UnifiedNumericTrailingAdornmentOrder.adornmentsThenSteps,
                decoration: const UnifiedInputDecoration(
                  suffixIcon: Text('kg'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('kg'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });
  });
}
