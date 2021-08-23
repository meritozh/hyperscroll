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

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import './viewport.dart';

class HSScrollable extends StatefulWidget {
  const HSScrollable({
    Key? key,
    this.axis = Axis.vertical,
  }) : super(key: key);

  final Axis axis;

  @override
  State<StatefulWidget> createState() => HSScrollableState();
}

class HSScrollableState extends State<HSScrollable> {
  final GlobalKey _ignorePointerKey = GlobalKey();

  bool _shouldIgnorePointer = false;

  late Map<Type, GestureRecognizerFactory> gestureRecognizers;

  @override
  void initState() {
    super.initState();
    setGestures();
  }

  void setGestures() {
    gestureRecognizers = <Type, GestureRecognizerFactory>{
      HorizontalDragGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
        () => HorizontalDragGestureRecognizer(),
        (HorizontalDragGestureRecognizer instance) {
          instance
            ..onDown = _handleDragDown
            ..onStart = _handleDragStart
            ..onUpdate = _handleDragUpdate
            ..onEnd = _handleDragEnd
            ..onCancel = _handleDragCancel;
        },
      ),
      VerticalDragGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
        () => VerticalDragGestureRecognizer(),
        (VerticalDragGestureRecognizer instance) {
          instance
            ..onDown = _handleDragDown
            ..onStart = _handleDragStart
            ..onUpdate = _handleDragUpdate
            ..onEnd = _handleDragEnd
            ..onCancel = _handleDragCancel;
        },
      ),
    };
  }

  void setIgnorePointer(bool value) {
    if (_shouldIgnorePointer == value) {
      return;
    }
    _shouldIgnorePointer = value;
    if (_ignorePointerKey.currentContext != null) {
      final renderBox = _ignorePointerKey.currentContext!.findRenderObject()!
          as RenderIgnorePointer;
      renderBox.ignoring = _shouldIgnorePointer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: gestureRecognizers,
      behavior: HitTestBehavior.opaque,
      child: IgnorePointer(
        key: _ignorePointerKey,
        ignoring: _shouldIgnorePointer,
        ignoringSemantics: false,
        child: HSViewport(
          // TODO: replace with builder
          child: Container(),
        ),
      ),
    );
  }

  void _handleDragDown(DragDownDetails details) {}
  void _handleDragStart(DragStartDetails details) {}
  void _handleDragUpdate(DragUpdateDetails details) {}
  void _handleDragEnd(DragEndDetails details) {}
  void _handleDragCancel() {}
}
