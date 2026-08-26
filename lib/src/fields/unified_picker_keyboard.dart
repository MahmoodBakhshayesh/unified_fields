import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Drops the current focus before a modal sheet / picker opens.
///
/// Never allocate a throwaway node for this (`requestFocus(FocusNode())`): the
/// node is attached to the enclosing scope without an [Element], so its
/// [FocusNode.rect] is unavailable and traversal policies that sort by rect
/// (Tab / arrow keys with [ReadingOrderTraversalPolicy]) assert with
/// "Tried to get the bounds of a focus node that didn't have its context set yet".
void unifiedUnfocusBeforeModal([BuildContext? context]) {
  FocusManager.instance.primaryFocus?.unfocus();
}

bool _hasCommandModifier() {
  final keyboard = HardwareKeyboard.instance;
  return keyboard.isControlPressed ||
      keyboard.isMetaPressed ||
      keyboard.isAltPressed;
}

/// Whether [event] should open the picker of a focused pick-only field.
///
/// Space / Enter key-down without control, meta, or alt held.
bool unifiedIsPickerActivationEvent(KeyEvent event) {
  if (event is! KeyDownEvent) return false;
  if (_hasCommandModifier()) return false;
  final key = event.logicalKey;
  return key == LogicalKeyboardKey.space ||
      key == LogicalKeyboardKey.enter ||
      key == LogicalKeyboardKey.numpadEnter;
}

/// Step direction for [event]: `1` for ArrowUp, `-1` for ArrowDown, else `null`.
///
/// Held arrows repeat. Modified arrows (control / meta / alt) are left to the
/// text-editing shortcuts.
int? unifiedArrowStepDirection(KeyEvent event) {
  if (event is! KeyDownEvent && event is! KeyRepeatEvent) return null;
  if (_hasCommandModifier() || HardwareKeyboard.instance.isShiftPressed) {
    return null;
  }
  if (event.logicalKey == LogicalKeyboardKey.arrowUp) return 1;
  if (event.logicalKey == LogicalKeyboardKey.arrowDown) return -1;
  return null;
}

/// Sequential step matching Tab through picker items: `1` forward, `-1` back.
///
/// Tab, ArrowDown, and ArrowRight move forward. Shift+Tab, ArrowUp, and
/// ArrowLeft move backward. Modified keys are ignored.
int? unifiedPickerTraversalDelta(KeyEvent event) {
  if (event is! KeyDownEvent && event is! KeyRepeatEvent) return null;
  if (_hasCommandModifier()) return null;
  final key = event.logicalKey;
  if (key == LogicalKeyboardKey.tab) {
    return HardwareKeyboard.instance.isShiftPressed ? -1 : 1;
  }
  if (HardwareKeyboard.instance.isShiftPressed) return null;
  if (key == LogicalKeyboardKey.arrowDown ||
      key == LogicalKeyboardKey.arrowRight) {
    return 1;
  }
  if (key == LogicalKeyboardKey.arrowUp ||
      key == LogicalKeyboardKey.arrowLeft) {
    return -1;
  }
  return null;
}

/// Wraps [index] onto `[0, count)`.
int unifiedPickerWrapIndex(int index, int count) {
  if (count <= 0) return 0;
  return (index % count + count) % count;
}

/// Whether a text field currently holds primary focus (Enter should not confirm).
bool unifiedIsTextInputFocused() {
  final ctx = FocusManager.instance.primaryFocus?.context;
  if (ctx == null) return false;
  return ctx.findAncestorStateOfType<EditableTextState>() != null;
}

/// Animates a [FixedExtentScrollController] by [delta] items (ArrowUp = +1).
void unifiedStepFixedExtentWheel(
  FixedExtentScrollController controller, {
  required int delta,
  required int itemCount,
  bool looping = false,
}) {
  if (!controller.hasClients || itemCount <= 0) return;
  final current = controller.selectedItem;
  final next = looping
      ? current + delta
      : (current + delta).clamp(0, itemCount - 1);
  if (next == current) return;
  controller.animateToItem(
    next,
    duration: const Duration(milliseconds: 140),
    curve: Curves.easeOut,
  );
}

/// Opens a pick-only field with Space / Enter while it holds focus.
///
/// The wrapper itself is not a traversal stop, so the inner read-only text
/// field stays the single Tab stop and keeps rendering focused chrome; key
/// events bubble from it up to [onActivate].
class UnifiedPickerKeyboardActivator extends StatelessWidget {
  /// Wraps [child] with Space / Enter activation.
  const UnifiedPickerKeyboardActivator({
    super.key,
    required this.onActivate,
    required this.child,
    this.enabled = true,
  });

  /// Called on Space / Enter (same path as a tap).
  final VoidCallback onActivate;

  /// When false, keys are passed through untouched (locked / disabled fields).
  final bool enabled;

  /// The field to wrap.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (!enabled) return KeyEventResult.ignored;
        if (!unifiedIsPickerActivationEvent(event)) {
          return KeyEventResult.ignored;
        }
        onActivate();
        return KeyEventResult.handled;
      },
      child: child,
    );
  }
}

/// Keeps a focus node (and its listener) for a pick-only field whose node may
/// come from a field controller / binding, and owns a fallback node otherwise.
///
/// [resolve] is safe to call from `build`: it only re-attaches when the node
/// identity changes.
class UnifiedPickerFocusOwner {
  /// Creates an owner that calls [onFocusChanged] whenever focus changes.
  UnifiedPickerFocusOwner(this.onFocusChanged, {this.debugLabel});

  /// Invoked on every focus change of the resolved node.
  final VoidCallback onFocusChanged;

  /// Debug label for the fallback node.
  final String? debugLabel;

  FocusNode? _owned;
  FocusNode? _attached;

  /// The node to hand to the inner field: [external] when provided, otherwise a
  /// lazily created node owned by this instance.
  FocusNode resolve(FocusNode? external) {
    final node = external ?? (_owned ??= FocusNode(debugLabel: debugLabel));
    if (!identical(_attached, node)) {
      _attached?.removeListener(onFocusChanged);
      node.addListener(onFocusChanged);
      _attached = node;
    }
    return node;
  }

  /// Whether the resolved node currently holds focus.
  bool get hasFocus => _attached?.hasFocus ?? false;

  /// Focuses the resolved node (no-op before the first [resolve]).
  void requestFocus() => _attached?.requestFocus();

  /// Detaches the listener and disposes the fallback node. Call from `dispose`.
  void dispose() {
    _attached?.removeListener(onFocusChanged);
    _attached = null;
    _owned?.dispose();
    _owned = null;
  }
}

/// Keyboard chrome for picker dialogs and sheets.
///
/// * Escape dismisses the route (cancel).
/// * Tab / Shift+Tab and arrow keys stay inside the picker and move focus
///   (or the list highlight) through items.
/// * Enter / numpad Enter call [onConfirm] when set and the user is not typing
///   in a text field.
///
/// Nested scopes collapse: an inner [UnifiedPickerModalScope] registers its
/// [onConfirm] on the outer one instead of stacking another [FocusScope].
class UnifiedPickerModalScope extends StatefulWidget {
  /// Wraps picker content with Escape / Tab / optional Enter handling.
  const UnifiedPickerModalScope({
    super.key,
    required this.child,
    this.onConfirm,
    this.onCancel,
  });

  /// Picker body.
  final Widget child;

  /// Confirm action (date / time / duration / multi-select). Null for
  /// single-select lists that pick on Enter themselves.
  final VoidCallback? onConfirm;

  /// Cancel action; defaults to [Navigator.maybePop].
  final VoidCallback? onCancel;

  @override
  State<UnifiedPickerModalScope> createState() =>
      _UnifiedPickerModalScopeState();
}

class _UnifiedPickerModalScopeState extends State<UnifiedPickerModalScope> {
  VoidCallback? _registeredConfirm;
  _UnifiedPickerModalScopeState? _host;

  void registerConfirm(VoidCallback? confirm) {
    _registeredConfirm = confirm;
  }

  VoidCallback? get _effectiveConfirm => _registeredConfirm ?? widget.onConfirm;

  @override
  void didUpdateWidget(covariant UnifiedPickerModalScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _host?.registerConfirm(widget.onConfirm);
  }

  @override
  void dispose() {
    _host?.registerConfirm(null);
    _host = null;
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (event is KeyDownEvent && key == LogicalKeyboardKey.escape) {
      (widget.onCancel ?? () => Navigator.of(context).maybePop()).call();
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent &&
        (key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter)) {
      if (unifiedIsTextInputFocused()) return KeyEventResult.ignored;
      final confirm = _effectiveConfirm;
      if (confirm == null) return KeyEventResult.ignored;
      confirm();
      return KeyEventResult.handled;
    }
    // Arrow keys traverse focus like Tab. A descendant that handles them
    // (list highlight, wheel column) wins first.
    if (unifiedIsTextInputFocused()) return KeyEventResult.ignored;
    final delta = unifiedPickerTraversalDelta(event);
    if (delta == null || key == LogicalKeyboardKey.tab) {
      return KeyEventResult.ignored;
    }
    if (delta > 0) {
      FocusScope.of(context).nextFocus();
    } else {
      FocusScope.of(context).previousFocus();
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final ancestor = context
        .findAncestorStateOfType<_UnifiedPickerModalScopeState>();
    if (ancestor != null) {
      _host = ancestor;
      ancestor.registerConfirm(widget.onConfirm);
      return widget.child;
    }
    return FocusScope(
      autofocus: true,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: widget.child,
    );
  }
}

/// Makes a wheel column a Tab stop and steps it with ArrowUp / ArrowDown.
class UnifiedPickerWheelKeyboard extends StatelessWidget {
  /// Wraps a [ListWheelScrollView] / [CupertinoPicker] column.
  const UnifiedPickerWheelKeyboard({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.child,
    this.looping = false,
  });

  /// Scroll controller for the column.
  final FixedExtentScrollController controller;

  /// Number of values in the column.
  final int itemCount;

  /// Whether the wheel wraps.
  final bool looping;

  /// The wheel itself.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        final dir = unifiedArrowStepDirection(event);
        if (dir == null) return KeyEventResult.ignored;
        unifiedStepFixedExtentWheel(
          controller,
          delta: dir,
          itemCount: itemCount,
          looping: looping,
        );
        return KeyEventResult.handled;
      },
      child: Builder(
        builder: (context) {
          final focused = Focus.of(context).hasFocus;
          if (!focused) return child;
          return ColoredBox(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08),
            child: child,
          );
        },
      ),
    );
  }
}
