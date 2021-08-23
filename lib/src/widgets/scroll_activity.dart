// Copyright 2021 gaowanqiu
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'
    hide ScrollActivity, ScrollActivityDelegate;

abstract class HSScrollActivityDelegate {
  AxisDirection get axisDirection;

  double setPixels(double pixels);

  void applyUserOffset(double delta);

  void goIdle();

  void goBallistic(double velocity);
}

abstract class HSScrollActivity {
  HSScrollActivity(this._delegate);

  HSScrollActivityDelegate get delegate => _delegate;
  HSScrollActivityDelegate _delegate;
  set delegate(HSScrollActivityDelegate value) {
    assert(_delegate != value);
    _delegate = value;
  }

  void resetActivity() {}

  // TODO: rename to `onApplyNewDimensions`
  void applyNewDimensions() {}

  bool get shouldIgnorePointer;

  bool get isScrolling;

  double get velocity;

  void dispose() {}

  @override
  String toString() => describeIdentity(this);
}

class HSIdleScrollActivity extends HSScrollActivity {
  HSIdleScrollActivity(HSScrollActivityDelegate delegate) : super(delegate);

  @override
  void applyNewDimensions() {
    delegate.goBallistic(0.0);
  }

  @override
  bool get isScrolling => false;

  @override
  bool get shouldIgnorePointer => false;

  @override
  double get velocity => 0.0;
}

class HSHoldScrollActivity extends HSScrollActivity {
  HSHoldScrollActivity(HSScrollActivityDelegate delegate) : super(delegate);

  @override
  bool get isScrolling => throw UnimplementedError();

  @override
  bool get shouldIgnorePointer => false;

  @override
  double get velocity => 0.0;
}

class HSDragScrollActivity extends HSScrollActivity {
  HSDragScrollActivity(HSScrollActivityDelegate delegate) : super(delegate);

  @override
  bool get isScrolling => true;

  @override
  bool get shouldIgnorePointer => true;

  @override
  double get velocity => 0.0;
}

class HSBallisticScrollActivity extends HSScrollActivity {
  HSBallisticScrollActivity(
    HSScrollActivityDelegate delegate,
    Simulation simulation,
    TickerProvider vsync,
  ) : super(delegate) {
    _controller = AnimationController.unbounded(vsync: vsync)
      ..addListener(_tick)
      ..animateWith(simulation).whenComplete(_end);
  }

  late AnimationController _controller;

  void _tick() {
    if (!applyMoveTo(_controller.value)) {
      delegate.goIdle();
    }
  }

  bool applyMoveTo(double value) {
    return delegate.setPixels(value) == 0.0;
  }

  void _end() {
    delegate.goBallistic(0.0);
  }

  @override
  bool get isScrolling => true;

  @override
  bool get shouldIgnorePointer => true;

  @override
  double get velocity => _controller.velocity;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class HSDrivenScrollActivity extends HSScrollActivity {
  HSDrivenScrollActivity(
    HSScrollActivityDelegate delegate, {
    required double from,
    required double to,
    required Duration duration,
    required Curve curve,
    required TickerProvider vsync,
  }) : super(delegate) {
    _completer = Completer<void>();
    _controller = AnimationController.unbounded(
      value: from,
      vsync: vsync,
      debugLabel: objectRuntimeType(this, 'HSDrivenScrollActivity'),
    )
      ..addListener(_tick)
      ..animateTo(to, duration: duration, curve: curve).whenComplete(_end);
  }

  late final Completer<void> _completer;
  late final AnimationController _controller;

  Future<void> get done => _completer.future;

  void _tick() {
    // TODO: should use tolerance
    if (delegate.setPixels(_controller.value) != 0.0) {
      delegate.goIdle();
    }
  }

  void _end() {
    delegate.goBallistic(velocity);
  }

  @override
  bool get isScrolling => true;

  @override
  bool get shouldIgnorePointer => true;

  @override
  double get velocity => _controller.velocity;

  @override
  void dispose() {
    _completer.complete();
    _controller.dispose();
    super.dispose();
  }
}
