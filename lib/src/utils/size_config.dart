import 'package:flutter/material.dart';

class SizeConfig {
  late MediaQueryData _mediaQueryData;
  late double screenWidth;
  late double screenHeight;
  late double defaultSize;
  late double padding;
  late Orientation orientation;
  static const mediumScreenSize = 900;
  static const smallScreenSize = 600;
  static const minimumScreenSize = 400;
  static const leftBarWidth = 200.0;
  static const leftToggleBar = 250.0;
  static const leftBarAdminWidth = 250.0;
  static const navbarHeight = 68.0;
  static const rightPaneWidth = 260.0;
  SizeConfig(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    padding = _mediaQueryData.padding.bottom + _mediaQueryData.padding.top;
  }

// Get the proportionate height as per screen size
  double getProportionateScreenHeight(double inputHeight) {
    // 812 is the layout height that designer use
    return (inputHeight / 812.0) * screenHeight;
  }

  // Get the proportionate height as per screen size
  double getProportionateScreenWidth(double inputWidth) {
    // 375 is the layout width that designer use
    return (inputWidth / 375.0) * screenWidth;
  }
}
