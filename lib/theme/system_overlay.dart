import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather/theme/weather_scene.dart';

class SystemOverlay {
  SystemOverlay._();

  static double _contrastWith(Color first, Color second) {
    final bocf = first.computeLuminance(); // brightness of color first (bocf)
    final bocs = second.computeLuminance(); // brightness of color second (bocs)
    final hb = bocf > bocs ? bocf : bocs; // higher brightness (hb)
    final lb = bocf < bocs ? bocf : bocs; // lower  brightness (lb)
    return (hb + 0.05) / (lb + 0.05);
  }

  static SystemUiOverlayStyle statusBarStyle(WeatherScene scene) {
    final top = scene.gradient.first;
    final lightContrast = _contrastWith(top, Colors.white);
    final darkContrast = _contrastWith(top, Colors.black);
    final lightIcons = lightContrast >= darkContrast;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: lightIcons ? Brightness.light : Brightness.dark,
      statusBarBrightness: lightIcons ? Brightness.dark : Brightness.light,
    );
  }
}
