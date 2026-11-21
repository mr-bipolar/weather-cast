import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather/theme/weather_scene.dart';

class SystemOverlay {
  SystemOverlay._();

  static bool _shouldUseLightIcons(Color background) {
    final luminance = background.computeLuminance();

    final whiteContrast = 1.05 / (luminance + 0.05);
    final blackContrast = (luminance + 0.05) / 0.05;

    return whiteContrast > blackContrast;
  }

  static SystemUiOverlayStyle style(WeatherScene scene) {
    final top = scene.gradient.first;
    final bottom = scene.gradient.last;

    final lightStatusIcons = _shouldUseLightIcons(top);
    final lightNavigationIcons = _shouldUseLightIcons(bottom);

    return SystemUiOverlayStyle(
      // Top status bar
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: lightStatusIcons
          ? Brightness.light
          : Brightness.dark,
      statusBarBrightness: lightStatusIcons
          ? Brightness.dark
          : Brightness.light,

      // Bottom navigation bar
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: lightNavigationIcons
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );
  }
}
