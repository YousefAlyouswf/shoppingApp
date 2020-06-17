import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/enums/screenDevice.dart';

class SizingInfo {
  final Orientation orientation;
  final DeviceScreen deviceScreen;
  final Size screenSize;
  final Size localWidgetSize;

  SizingInfo(
      {this.orientation,
      this.deviceScreen,
      this.screenSize,
      this.localWidgetSize});

  String toString() {
    return "orientation: $orientation, deviceScreen: $deviceScreen, screenSize: $screenSize, localWidgetSize: $localWidgetSize";
  }
}
