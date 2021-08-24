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

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import './viewport.dart';

class HSScrollable extends StatefulWidget {
  const HSScrollable({
    Key? key,
    this.axisDirection = AxisDirection.down,
    this.scrollBehavior,
    this.physics,
    this.controller,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : super(key: key);

  final AxisDirection axisDirection;

  final ScrollBehavior? scrollBehavior;

  final ScrollPhysics? physics;

  final ScrollController? controller;

  final DragStartBehavior dragStartBehavior;

  @override
  State<StatefulWidget> createState() => HSScrollableState();
}

// TODO: use our own ScrollContext
class HSScrollableState extends State<HSScrollable> implements ScrollContext {
  final GlobalKey _ignorePointerKey = GlobalKey();

  bool _shouldIgnorePointer = false;

  late Map<Type, GestureRecognizerFactory> gestureRecognizers;

  late ScrollBehavior _configuration;
  ScrollPhysics? _physics;

  ScrollPosition? _position;
  ScrollPosition get position => _position!;

  ScrollController? _fallbackController;
  ScrollController get controller => widget.controller ?? _fallbackController!;

  @override
  void initState() {
    if (widget.controller == null) {
      _fallbackController = ScrollController();
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setPosition();
    setGestures();
    super.didChangeDependencies();
  }

  void setPosition() {
    _configuration = widget.scrollBehavior ?? ScrollConfiguration.of(context);
    _physics = _configuration.getScrollPhysics(context);
    if (widget.physics != null) {
      _physics = widget.physics!.applyTo(_physics);
    } else if (widget.scrollBehavior != null) {
      _physics =
          widget.scrollBehavior!.getScrollPhysics(context).applyTo(_physics);
    }
    final oldPosition = _position;
    if (oldPosition != null) {
      controller.detach(oldPosition);
      scheduleMicrotask(oldPosition.dispose);
    }

    // TODO: change this type
    _position = controller.createScrollPosition(_physics!, this, oldPosition);
    assert(_position != null);
    controller.attach(position);
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
            ..onCancel = _handleDragCancel
            ..minFlingDistance = _physics?.minFlingDistance
            ..minFlingDistance = _physics?.minFlingVelocity
            ..maxFlingVelocity = _physics?.maxFlingVelocity
            ..velocityTrackerBuilder =
                _configuration.velocityTrackerBuilder(context)
            ..dragStartBehavior = widget.dragStartBehavior;
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

  bool _shouldUpdatePosition(HSScrollable oldWidget) {
    var newPhysics =
        widget.physics ?? widget.scrollBehavior?.getScrollPhysics(context);
    var oldPhysics = oldWidget.physics ??
        oldWidget.scrollBehavior?.getScrollPhysics(context);
    do {
      if (newPhysics?.runtimeType != oldPhysics?.runtimeType) {
        return true;
      }
      newPhysics = newPhysics?.parent;
      oldPhysics = oldPhysics?.parent;
    } while (newPhysics != null || oldPhysics != null);

    return widget.controller?.runtimeType != oldWidget.controller!.runtimeType;
  }

  @override
  void didUpdateWidget(covariant HSScrollable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        assert(_fallbackController != null);
        assert(widget.controller != null);
        _fallbackController!.detach(position);
        _fallbackController!.dispose();
        _fallbackController == null;
      } else {
        oldWidget.controller?.detach(position);
        if (widget.controller == null) {
          _fallbackController = ScrollController();
        }
      }

      controller.attach(position);
    }

    if (_shouldUpdatePosition(oldWidget)) {
      setPosition();
    }
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.detach(position);
    } else {
      _fallbackController?.detach(position);
      _fallbackController?.dispose();
    }

    position.dispose();
    super.dispose();
  }

  @override
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

  @override
  AxisDirection get axisDirection => widget.axisDirection;

  @override
  // TODO: implement notificationContext
  BuildContext? get notificationContext => throw UnimplementedError();

  @override
  void saveOffset(double offset) {
    // TODO: implement saveOffset
  }

  @override
  void setCanDrag(bool value) {
    // TODO: implement setCanDrag
  }

  @override
  void setSemanticsActions(Set<SemanticsAction> actions) {
    // TODO: implement setSemanticsActions
  }

  @override
  // TODO: implement storageContext
  BuildContext get storageContext => throw UnimplementedError();

  @override
  // TODO: implement vsync
  TickerProvider get vsync => throw UnimplementedError();
}
