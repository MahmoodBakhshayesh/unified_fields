import 'dart:async';

import 'scroll_offset_listener.dart';

/// Default [ScrollOffsetListener] that broadcasts scroll offset deltas.
class ScrollOffsetNotifier implements ScrollOffsetListener {
  /// Whether programmatic scrolls are included in [changes].
  final bool recordProgrammaticScrolls;

  /// Creates a notifier; [recordProgrammaticScrolls] defaults to `true`.
  ScrollOffsetNotifier({this.recordProgrammaticScrolls = true});

  final _streamController = StreamController<double>();

  @override
  Stream<double> get changes => _streamController.stream;

  /// Underlying stream controller for internal scroll reporting.
  StreamController get changeController => _streamController;

  /// Closes [changeController]; call when the listener is no longer needed.
  void dispose() {
    _streamController.close();
  }
}
