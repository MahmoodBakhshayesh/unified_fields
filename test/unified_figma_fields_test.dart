import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

const _stroke = UnifiedFigmaLinearGradient(
  figmaTransform: [
    [0.9476081728935242, 0.052391864359378815, 0],
    [-0.9476081728935242, 0.9476081728935242, 0.5],
  ],
  colors: [Color(0xFF8B5CF6), Color(0xFF050517), Color(0xFFFF5CA8)],
  stops: [0, 0.5925726890563965, 1],
);

Widget _app(Widget child) => MaterialApp(
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(child: SizedBox(width: 370, child: child)),
        ),
      ),
    );

const _figmaDecoration = UnifiedInputDecoration(
  height: 57,
  backgroundColor: Color(0xFF050517),
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(color: Color(0xFF8B5CF6), width: 1),
  borderGradient: _stroke,
  placeholderStyle: TextStyle(fontSize: 14, height: 24 / 14, color: Color(0x99FFFFFF)),
  prefixPadding: EdgeInsetsDirectional.only(start: 16),
  contentPadding: EdgeInsetsDirectional.only(start: 10, end: 16),
);

void main() {
  group('UnifiedFigmaLinearGradient', () {
    // Position along the gradient of [p] for begin/end alignments in [rect].
    double tAt(Rect rect, (Alignment, Alignment) a, Offset p) {
      final b = a.$1.withinRect(rect);
      final e = a.$2.withinRect(rect);
      final d = e - b;
      final v = p - b;
      return (v.dx * d.dx + v.dy * d.dy) / (d.dx * d.dx + d.dy * d.dy);
    }

    test('matches Figma t = a·u + b·v + c at any box size', () {
      const g = UnifiedFigmaLinearGradient(
        figmaTransform: [
          [0.9, 0.2, 0.05],
          [0, 1, 0],
        ],
        colors: [Colors.red, Colors.blue],
      );
      for (final rect in const [Rect.fromLTWH(0, 0, 370, 57), Rect.fromLTWH(10, 20, 56, 56)]) {
        final a = g.alignmentsFor(rect);
        for (final uv in const [Offset(0, 0), Offset(1, 0), Offset(0, 1), Offset(0.3, 0.7), Offset(1, 1)]) {
          final p = rect.topLeft + Offset(uv.dx * rect.width, uv.dy * rect.height);
          expect(tAt(rect, a, p), closeTo(0.9 * uv.dx + 0.2 * uv.dy + 0.05, 1e-9));
        }
      }
    });

    test('equality includes the transform', () {
      expect(_stroke, const UnifiedFigmaLinearGradient(
        figmaTransform: [
          [0.9476081728935242, 0.052391864359378815, 0],
          [-0.9476081728935242, 0.9476081728935242, 0.5],
        ],
        colors: [Color(0xFF8B5CF6), Color(0xFF050517), Color(0xFFFF5CA8)],
        stops: [0, 0.5925726890563965, 1],
      ));
      expect(
        _stroke == const UnifiedFigmaLinearGradient(figmaTransform: [[1, 0, 0], [0, 1, 0]], colors: [Color(0xFF8B5CF6), Color(0xFF050517), Color(0xFFFF5CA8)], stops: [0, 0.5925726890563965, 1]),
        isFalse,
      );
    });
  });

  testWidgets('gradient stroke paints above the fill', (tester) async {
    await tester.pumpWidget(_app(const UnifiedGradientBorder(
      gradient: _stroke,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      backgroundColor: Color(0xFF050517),
      child: SizedBox(height: 57),
    )));
    final paint = tester.widget<CustomPaint>(
      find.descendant(of: find.byType(UnifiedGradientBorder), matching: find.byType(CustomPaint)).first,
    );
    expect(paint.painter, isNull);
    expect(paint.foregroundPainter, isNotNull);
    final box = tester.widget<DecoratedBox>(
      find.descendant(of: find.byType(UnifiedGradientBorder), matching: find.byType(DecoratedBox)).first,
    );
    expect((box.decoration as BoxDecoration).borderRadius, const BorderRadius.all(Radius.circular(16)));
  });

  group('gradient text field (Figma-style box)', () {
    testWidgets('fills the fixed height and shows the leading icon when empty', (tester) async {
      await tester.pumpWidget(_app(const UnifiedTextField(
        placeholder: 'Phone',
        prefixIcon: SizedBox(key: ValueKey('icon'), width: 24, height: 24),
        decoration: _figmaDecoration,
      )));
      expect(tester.getSize(find.byType(InputDecorator)).height, closeTo(57, 0.01));
      expect(find.byKey(const ValueKey('icon')), findsOneWidget);
      expect(tester.getSize(find.byKey(const ValueKey('icon'))).width, greaterThan(0));
      // Icon 16 px from the start (right in RTL), text 10 px after it.
      final field = tester.getRect(find.byType(InputDecorator));
      final icon = tester.getRect(find.byKey(const ValueKey('icon')));
      expect(field.right - icon.right, closeTo(16, 0.01));
    });

    testWidgets('keeps the box height on validation errors', (tester) async {
      await tester.pumpWidget(_app(Form(
        autovalidateMode: AutovalidateMode.always,
        child: UnifiedTextField(
          placeholder: 'Phone',
          validator: (_) => 'Required',
          decoration: _figmaDecoration,
        ),
      )));
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
      final decorator = tester.renderObject<RenderBox>(find.byType(InputDecorator));
      // Box (57) + message below.
      expect(decorator.size.height, greaterThan(57));
      final message = tester.getRect(find.text('Required'));
      expect(message.top, greaterThanOrEqualTo(tester.getTopLeft(find.byType(InputDecorator)).dy + 57));
    });

    testWidgets('translucent placeholder is composited as one layer', (tester) async {
      await tester.pumpWidget(_app(const UnifiedTextField(placeholder: 'Phone', decoration: _figmaDecoration)));
      final opacity = tester.widget<Opacity>(find.ancestor(of: find.text('Phone'), matching: find.byType(Opacity)).first);
      expect(opacity.opacity, closeTo(0.6, 0.001));
      final text = tester.widget<Text>(find.text('Phone'));
      expect(text.style!.color!.a, 1);
    });

    testWidgets('showPasswordToggle: false hides the visibility toggle', (tester) async {
      await tester.pumpWidget(_app(const Column(children: [
        UnifiedTextField(placeholder: 'a', isPassword: true),
        UnifiedTextField(placeholder: 'b', isPassword: true, showPasswordToggle: false),
      ])));
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });

  group('UnifiedOtpField', () {
    testWidgets('fills boxes, filters input and reports completion once', (tester) async {
      final completed = <String>[];
      final ctrl = TextEditingController();
      await tester.pumpWidget(_app(UnifiedOtpField(length: 5, controller: ctrl, onCompleted: completed.add, borderGradient: _stroke)));
      expect(find.byType(UnifiedFieldBorderBox), findsNWidgets(5));

      await tester.enterText(find.byType(TextField), '12a3');
      await tester.pump();
      expect(ctrl.text, '123');
      expect(find.text('1'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(completed, isEmpty);

      await tester.enterText(find.byType(TextField), '1234567');
      await tester.pump();
      expect(ctrl.text, '12345');
      expect(completed, ['12345']);
    });

    testWidgets('boxes keep Figma size and gap, digits read left to right in RTL', (tester) async {
      final ctrl = TextEditingController(text: '12');
      await tester.pumpWidget(_app(UnifiedOtpField(length: 5, controller: ctrl, boxWidth: 56, boxHeight: 56, gap: 16)));
      final boxes = tester.widgetList(find.byType(UnifiedFieldBorderBox)).toList();
      final first = tester.getRect(find.byWidget(boxes[0]));
      final second = tester.getRect(find.byWidget(boxes[1]));
      expect(first.size, const Size(56, 56));
      expect(second.left - first.right, 16);
      expect(tester.getCenter(find.text('1')).dx, lessThan(tester.getCenter(find.text('2')).dx));
    });

    testWidgets('accepts Persian and Arabic-Indic keypad digits', (tester) async {
      final completed = <String>[];
      final ctrl = TextEditingController();
      await tester.pumpWidget(_app(UnifiedOtpField(length: 5, controller: ctrl, onCompleted: completed.add)));
      await tester.enterText(find.byType(TextField), '۱۲۳٤٥');
      await tester.pump();
      expect(ctrl.text, '12345');
      expect(completed, ['12345']);
    });

    testWidgets('obscures characters', (tester) async {
      await tester.pumpWidget(_app(UnifiedOtpField(length: 4, controller: TextEditingController(text: '42'), obscureText: true)));
      expect(find.text('•'), findsNWidgets(2));
      expect(find.text('4'), findsNothing);
    });
  });
}
