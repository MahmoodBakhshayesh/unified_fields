import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

/// Global rects of every semantics node that has a tap action.
List<(Rect, SemanticsData)> _tapNodes(WidgetTester tester) {
  final out = <(Rect, SemanticsData)>[];
  final view = tester.view;
  void walk(SemanticsNode n, Matrix4 t) {
    final m = t.clone();
    if (n.transform != null) m.multiply(n.transform!);
    final d = n.getSemanticsData();
    if (d.hasAction(SemanticsAction.tap)) {
      out.add((MatrixUtils.transformRect(m, n.rect), d));
    }
    n.visitChildren((c) {
      walk(c, m);
      return true;
    });
  }

  final root = tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!;
  walk(root, Matrix4.diagonal3Values(1 / view.devicePixelRatio, 1 / view.devicePixelRatio, 1));
  return out;
}

Rect _nodeRect(WidgetTester tester, String tooltip) =>
    _tapNodes(tester).firstWhere((e) => e.$2.tooltip == tooltip).$1;

const _border = BorderSide(color: Color(0xFF888888), width: 1.5);

UnifiedInputThemeData _theme({
  UnifiedPickerSurfaceStyle? surface,
  UnifiedInputAdornmentStyle? adornment,
  UnifiedFieldLabelMode mode = UnifiedFieldLabelMode.labelInColumn,
}) =>
    UnifiedInputThemeData(
      // Like the DCS app: 44 px touch fields, end-only suffix padding, 32 px slots.
      fieldDefaults: UnifiedInputFieldDefaults(
        labelMode: mode,
        height: 44,
        borderSide: _border,
        suffixPadding: const EdgeInsetsDirectional.only(end: 8),
        suffixWidth: 32,
        suffixHeight: 32,
      ),
      adornmentStyle: adornment,
      pickerSurfaceStyle: surface,
    );

final _key = GlobalKey();

Future<void> _pump(WidgetTester tester, UnifiedInputThemeData data, {Widget? field}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => UnifiedInputThemeScope(data: data, child: child!),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              KeyedSubtree(
                key: _key,
                child: field ??
                    UnifiedTextField(
                      label: 'Password',
                      isPassword: true,
                      showClearButton: true,
                      controller: TextEditingController(text: 'secret'),
                    ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('default (pointer): adornments keep the 32 px slot', () {
    testWidgets('password toggle and clear are 32 px wide, no wider', (tester) async {
      final h = tester.ensureSemantics();
      await _pump(tester, _theme());
      final eye = _nodeRect(tester, 'Show password');
      final clear = _nodeRect(tester, 'Delete');
      expect(eye.width, 32);
      expect(eye.height, lessThanOrEqualTo(32));
      expect(clear.width, 32);
      expect(find.byType(UnifiedAdornmentTapTarget), findsNWidgets(2));
      // No touch floor → the tap target is a pass-through (slot == chip).
      for (final e in find.byType(UnifiedAdornmentTapTarget).evaluate()) {
        expect(tester.getSize(find.byWidget(e.widget)), const Size(32, 32));
      }
      h.dispose();
    });
  });

  group('touch: adornments are >= 44 x 44', () {
    for (final (name, data) in [
      ('picker touch preset', _theme(surface: UnifiedPickerSurfaceStyle.touch)),
      ('adornmentStyle.minTapTarget', _theme(adornment: const UnifiedInputAdornmentStyle(minTapTarget: 44))),
    ]) {
      testWidgets('$name: semantics rects, no overlap, field height unchanged', (tester) async {
        final h = tester.ensureSemantics();
        await _pump(tester, _theme());
        final pointerHeight = tester.getSize(find.byKey(_key)).height;

        await _pump(tester, data);
        expect(tester.getSize(find.byKey(_key)).height, pointerHeight);
        final eye = _nodeRect(tester, 'Show password');
        final clear = _nodeRect(tester, 'Delete');
        for (final r in [eye, clear]) {
          expect(r.width, greaterThanOrEqualTo(44));
          expect(r.height, greaterThanOrEqualTo(44));
        }
        expect(eye.overlaps(clear), isFalse);
        // Chips stay 32 px.
        for (final b in tester.widgetList<IconButton>(find.byType(IconButton))) {
          expect(tester.getSize(find.byWidget(b)), const Size(32, 32));
        }
        h.dispose();
      });
    }

    testWidgets('tap in the slot outside the chip toggles the password', (tester) async {
      await _pump(tester, _theme(surface: UnifiedPickerSurfaceStyle.touch));
      final chip = tester.getRect(find.widgetWithIcon(IconButton, Icons.visibility));
      final slot = tester.getRect(
        find.ancestor(of: find.widgetWithIcon(IconButton, Icons.visibility), matching: find.byType(UnifiedAdornmentTapTarget)),
      );
      expect(slot.height, greaterThanOrEqualTo(44));
      // 2 px below the top of the slot: above the 32 px chip.
      final p = Offset(chip.center.dx, slot.top + 2);
      expect(chip.contains(p), isFalse);
      await tester.tapAt(p);
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('semantics tap toggles the password', (tester) async {
      final h = tester.ensureSemantics();
      await _pump(tester, _theme(surface: UnifiedPickerSurfaceStyle.touch));
      final node = tester.getSemantics(find.ancestor(
        of: find.widgetWithIcon(IconButton, Icons.visibility),
        matching: find.byType(UnifiedAdornmentTapTarget),
      ));
      tester.binding.renderViews.first.owner!.semanticsOwner!.performAction(node.id, SemanticsAction.tap);
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      h.dispose();
    });

    testWidgets('minTapTarget: 0 turns the floor off under the touch preset', (tester) async {
      final h = tester.ensureSemantics();
      await _pump(
        tester,
        _theme(
          surface: UnifiedPickerSurfaceStyle.touch,
          adornment: const UnifiedInputAdornmentStyle(minTapTarget: 0),
        ),
      );
      expect(_nodeRect(tester, 'Show password').width, 32);
      h.dispose();
    });

    for (final mode in [UnifiedFieldLabelMode.labelInRow, UnifiedFieldLabelMode.floatingLabel]) {
      testWidgets('$mode: >= 44 and same field height', (tester) async {
        final h = tester.ensureSemantics();
        await _pump(tester, _theme(mode: mode));
        final pointerHeight = tester.getSize(find.byKey(_key)).height;
        await _pump(tester, _theme(mode: mode, surface: UnifiedPickerSurfaceStyle.touch));
        expect(tester.getSize(find.byKey(_key)).height, pointerHeight);
        final eye = _nodeRect(tester, 'Show password');
        expect(eye.width, greaterThanOrEqualTo(44));
        expect(eye.height, greaterThanOrEqualTo(44));
        h.dispose();
      });
    }

    testWidgets('phone country picker and numeric steps are >= 44', (tester) async {
      final h = tester.ensureSemantics();
      final data = _theme(surface: UnifiedPickerSurfaceStyle.touch);
      for (final field in <Widget>[const UnifiedPhoneField(label: 'Phone'), const UnifiedNumberField(label: 'Num')]) {
        await _pump(tester, _theme(), field: field);
        final pointerHeight = tester.getSize(find.byKey(_key)).height;
        await _pump(tester, data, field: field);
        expect(tester.getSize(find.byKey(_key)).height, pointerHeight);
        final targets = _tapNodes(tester).where((e) => e.$2.flagsCollection.isButton).toList();
        expect(targets, isNotEmpty);
        for (final (r, _) in targets) {
          expect(r.width, greaterThanOrEqualTo(44));
          expect(r.height, greaterThanOrEqualTo(44));
        }
      }
      h.dispose();
    });
  });
}
