import 'dart:async';

import 'package:flutter/material.dart';

class LifecycleStreamBuilder<T> extends StatefulWidget {
  final Widget Function(Snapshot data) builder;
  final Stream<T> stream;
  const LifecycleStreamBuilder(
      {super.key, required this.builder, required this.stream});
  @override
  State<StatefulWidget> createState() => _LifecycleStreamBuilderState();
}

class Snapshot<T> {
  late T? data;

  Snapshot.empty() {
    data = null;
  }
  Snapshot.success(T newValue) {
    data = newValue;
  }
}

class _LifecycleStreamBuilderState<T> extends State<LifecycleStreamBuilder<T>>
    with WidgetsBindingObserver {
  StreamSubscription<T>? _streamSubscription;
  late Snapshot snapshot;
  @override
  void initState() {
    super.initState();
    snapshot = Snapshot.empty();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _subscribe();
    });
  }

  @override
  void didUpdateWidget(covariant LifecycleStreamBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _streamSubscription = widget.stream.listen((event) {
      setState(() {
        debugPrint('sdsdsdsdsd');
        snapshot = Snapshot.success(event);
      });
    });
  }

  void _unsubscribe() {
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
      _streamSubscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('${snapshot.data}');
    return widget.builder(snapshot);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        _streamSubscription?.pause();
        break;
      case AppLifecycleState.resumed:
        _streamSubscription?.resume();
        break;
      default:
        break;
    }
  }
}
