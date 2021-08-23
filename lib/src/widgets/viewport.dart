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

import 'package:flutter/widgets.dart';

import '../rendering/viewport.dart';

class HSViewportElement extends RenderObjectElement {
  HSViewportElement(RenderObjectWidget widget) : super(widget);

  @override
  HSRenderViewport get renderObject => super.renderObject as HSRenderViewport;

  @override
  HSViewport get widget => super.widget as HSViewport;
}

class HSViewport extends RenderObjectWidget {
  const HSViewport({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  RenderObjectElement createElement() => HSViewportElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) => HSRenderViewport();

  @override
  void updateRenderObject(
      BuildContext context, HSRenderViewport renderObject) {}

  // TODO(gaowanqiu): do we need `didUnmountRenderObject`?
}
