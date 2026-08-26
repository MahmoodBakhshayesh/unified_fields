import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

class _PushSpy extends NavigatorObserver {
  _PushSpy(this.pushes);

  final List<Route<dynamic>> pushes;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes.add(route);
  }
}

void main() {
  Future<void> pumpFields(
    WidgetTester tester, {
    ValueChanged<String?>? onChanged,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: Column(
                children: [
                  UnifiedSinglePickerField<String>(
                    label: 'Country',
                    items: const ['Iran', 'Germany', 'Japan'],
                    hasSearch: false,
                    onChanged: onChanged,
                  ),
                  const UnifiedTextField(label: 'Name'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('closing a picker sheet leaves no context-less focus node', (
    tester,
  ) async {
    await pumpFields(tester);

    await tester.tap(find.byType(UnifiedSinglePickerField<String>));
    await tester.pumpAndSettle();
    expect(find.text('Germany'), findsOneWidget);

    Navigator.of(tester.element(find.text('Germany'))).pop();
    await tester.pumpAndSettle();

    // A throwaway `FocusNode()` handed to `requestFocus` stays attached to the
    // scope without an element, so it holds primary focus with a null context:
    // traversal that sorts by `FocusNode.rect` asserts on it and every shortcut
    // (Tab included) is dropped until something else is clicked.
    final nodes = <FocusNode>[];
    void collect(FocusNode node) {
      nodes.add(node);
      node.children.forEach(collect);
    }

    collect(FocusManager.instance.rootScope);
    final detached = nodes
        .where(
          (node) =>
              node.context == null && node != FocusManager.instance.rootScope,
        )
        .toList();
    expect(detached, isEmpty);
    expect(FocusManager.instance.primaryFocus?.context, isNotNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Space opens the picker of the focused field', (tester) async {
    await pumpFields(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    expect(find.text('Germany'), findsOneWidget);
  });

  testWidgets('Escape closes the picker sheet', (tester) async {
    await pumpFields(tester);

    await tester.tap(find.byType(UnifiedSinglePickerField<String>));
    await tester.pumpAndSettle();
    expect(find.text('Germany'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Germany'), findsNothing);
  });

  testWidgets('Space opens the date picker of the focused field', (
    tester,
  ) async {
    final pushes = <Route<dynamic>>[];
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [_PushSpy(pushes)],
        home: const Scaffold(
          body: Center(
            child: SizedBox(width: 400, child: UnifiedDateField(label: 'Born')),
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    pushes.clear();

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    expect(pushes, isNotEmpty);
  });

  testWidgets('arrow keys highlight rows and Enter selects', (tester) async {
    String? picked;
    await pumpFields(tester, onChanged: (v) => picked = v);

    await tester.tap(find.byType(UnifiedSinglePickerField<String>));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(picked, 'Germany');
  });

  testWidgets('arrow right highlights rows like Tab', (tester) async {
    String? picked;
    await pumpFields(tester, onChanged: (v) => picked = v);

    await tester.tap(find.byType(UnifiedSinglePickerField<String>));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(picked, 'Germany');
  });

  testWidgets('Tab highlights rows and Enter selects', (tester) async {
    String? picked;
    await pumpFields(tester, onChanged: (v) => picked = v);

    await tester.tap(find.byType(UnifiedSinglePickerField<String>));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(picked, 'Germany');
  });

  testWidgets('Escape closes the date picker without applying', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 400, child: UnifiedDateField(label: 'Born')),
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    expect(find.text('Confirm'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Confirm'), findsNothing);
  });

  testWidgets('Enter confirms the time wheel picker', (tester) async {
    TimeOfDay? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: UnifiedTimeOfDayField(
                label: 'Alarm',
                pickerStyle: UnifiedFieldsTimePickerStyle.wheels,
                onChanged: (v) => picked = v,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    expect(find.text('Confirm'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('Confirm'), findsNothing);
    expect(picked, isNotNull);
  });

  testWidgets('arrow up / down step a numeric field', (tester) async {
    final values = <num>[];
    final controller = TextEditingController(text: '2');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: UnifiedNumberField(
                label: 'Bags',
                controller: controller,
                step: 2,
                min: 0,
                max: 6,
                onChanged: (v) => values.add(v),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(UnifiedNumberField));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(values.last, 4);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(values.last, 2);
  });
}
