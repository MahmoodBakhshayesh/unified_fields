import 'package:material_ui/material_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

final _data = UnifiedInputThemeData(
  pickerPresentation: UnifiedPickerPresentation.bottomSheet,
  fieldDefaults: const UnifiedInputFieldDefaults(
    labelMode: UnifiedFieldLabelMode.labelInColumn,
    height: 44,
  ),
);

Future<void> _pump(WidgetTester tester, Widget field) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => UnifiedInputThemeScope(data: _data, child: child!),
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [field])),
      ),
    ),
  );
}

List<SemanticsData> _tapNodes(WidgetTester tester) {
  final out = <SemanticsData>[];
  void walk(SemanticsNode n) {
    final d = n.getSemanticsData();
    if (d.hasAction(SemanticsAction.tap)) out.add(d);
    n.visitChildren((c) {
      walk(c);
      return true;
    });
  }

  walk(tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!);
  return out;
}

void main() {
  testWidgets('tapping the label above the box focuses the field', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await _pump(tester, UnifiedTextField(label: 'Name', focusNode: focus));
    expect(focus.hasFocus, isFalse);
    await tester.tap(find.text('Name'));
    await tester.pump();
    expect(focus.hasFocus, isTrue);
  });

  testWidgets('a touch tap on the label focuses the field', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await _pump(tester, UnifiedTextField(label: 'Name', focusNode: focus));
    await tester.tap(find.text('Name'), kind: PointerDeviceKind.touch);
    await tester.pump();
    expect(focus.hasFocus, isTrue);
  });

  testWidgets('the label is not its own semantics tap target', (tester) async {
    final h = tester.ensureSemantics();
    await _pump(tester, const UnifiedTextField(label: 'Name'));
    final taps = _tapNodes(tester);
    // Only the text field itself is tappable.
    expect(taps, hasLength(1));
    expect(taps.single.flagsCollection.isTextField, isTrue);
    // The label text is still announced.
    expect(find.bySemanticsLabel('Name'), findsOneWidget);
    h.dispose();
  });

  testWidgets('disabled / locked fields: label tap does not focus', (tester) async {
    for (final field in [
      (FocusNode f) => UnifiedTextField(label: 'Name', focusNode: f, disabled: true),
      (FocusNode f) => UnifiedTextField(label: 'Name', focusNode: f, locked: true),
    ]) {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await _pump(tester, field(focus));
      await tester.tap(find.text('Name'), warnIfMissed: false);
      await tester.pump();
      expect(focus.hasFocus, isFalse);
    }
  });

  testWidgets('picker field: tapping the label still opens the picker', (tester) async {
    await _pump(
      tester,
      UnifiedSinglePickerField<String>(label: 'Fruit', items: const ['Apple', 'Pear'], hasSearch: false),
    );
    expect(find.text('Pear'), findsNothing);
    await tester.tap(find.text('Fruit').first);
    await tester.pumpAndSettle();
    expect(find.text('Pear'), findsOneWidget);
  });
}
