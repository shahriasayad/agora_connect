import 'dart:math';

import 'package:flutter/material.dart';

class AppScreenUtil {
  static double screenWidth = 0;
  static double screenHeight = 0;
  static Orientation orientation = Orientation.portrait;
  static bool _isInitialized = false;

  /// Maximum logical width before we stop scaling up to prevent tablet distortion.
  static const double _maxScalingConstraint = 600.0;

  /// Base generic mobile width for scaling calculations.
  static const double _mobileBaseline = 390.0;
  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Prevent initializing with 0.0 dimensions during early app startup / builder phase
    if (size.width == 0 || size.height == 0) return;

    final currentOrientation = MediaQuery.of(context).orientation;
    if (_isInitialized &&
        screenWidth == size.width &&
        screenHeight == size.height &&
        orientation == currentOrientation) {
      return;
    }

    screenWidth = size.width;
    screenHeight = size.height;
    orientation = currentOrientation;
    _isInitialized = true;
  }

  /// Device-adaptive scale factor using the shortest side.
  /// Prevents giant, distorted scaling on tablets by clamping the maximum size.
  static double get scaleFactor {
    if (!_isInitialized) return 1.0;

    double shortestSide = min(screenWidth, screenHeight);

    // Clamp the shortest side to prevent excessive scaling on iPads/desktops
    double clampedSide = min(shortestSide, _maxScalingConstraint);

    return clampedSide / _mobileBaseline;
  }

  /// Text scale factor that is slightly tighter to maintain readability
  /// without becoming comically large on big screens.
  static double get textScaleFactor {
    if (!_isInitialized) return 1.0;

    double shortestSide = min(screenWidth, screenHeight);

    // Clamp text scaling even sooner (e.g., max 500 logical pixels)
    double clampedSide = min(shortestSide, 500.0);
    return clampedSide / _mobileBaseline;
  }
}

extension ResponsiveExtension on num {
  /// Responsive width: scales adaptively based on shortest side, safely clamped for tablets.
  double get w => this * AppScreenUtil.scaleFactor;

  /// Responsive height: uses the same balanced scale factor to maintain aspect ratios.
  double get h => this * AppScreenUtil.scaleFactor;

  /// Responsive text size: scales gracefully and caps earlier for readability.
  double get sp => this * AppScreenUtil.textScaleFactor;

  /// Responsive radius
  double get r => this * AppScreenUtil.scaleFactor;
  Widget get vSpace => SizedBox(height: h);
  Widget get hSpace => SizedBox(width: w);
}
