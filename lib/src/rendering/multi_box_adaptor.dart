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

import 'package:flutter/rendering.dart';

abstract class HSRenderBoxChildManager {
  void createChild(int index, {required RenderBox? after});

  void removeChild(RenderBox child);

  double estimateMaxScrollOffset({
    int? firstIndex,
    int? lastIndex,
    double? leadingScrollOffset,
    double? trailingScrollOffset,
  });

  int get childCount;

  void didAdoptChild(RenderBox child);

  void setDidUnderflow(bool value);

  void didStartLayout() {}

  void didFinishLayout() {}

  bool debugAssetChildListLocked() => true;
}

class HSRenderMultiBoxAdaptorParentData extends ParentData
    with ContainerParentDataMixin<RenderBox> {
  int? index;

  double? layoutOffset;
}

abstract class HSRenderMultiBoxAdaptor extends RenderBox {
  HSRenderMultiBoxAdaptor({
    required this.childManager,
  });

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! HSRenderMultiBoxAdaptorParentData) {
      child.parentData = HSRenderMultiBoxAdaptorParentData();
    }
  }

  final HSRenderBoxChildManager childManager;
}
