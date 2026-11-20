import 'package:flutter/material.dart';
import 'package:weather/core/enums/weather_scene_types.dart';
import 'package:weather/theme/color_palette.dart';

class WeatherScene {
  final WeatherSceneTypes kind;
  final bool isNight;

  const WeatherScene({required this.kind, required this.isNight});

  /// Backdrop gradient, top to bottom.
  List<Color> get gradient {
    if (isNight) {
      switch (kind) {
        case WeatherSceneTypes.clear:
          return const [
            Color(0xFF2A3560),
            Color(0xFF141A33),
            ColorPalette.nightBottom,
          ];
        case WeatherSceneTypes.clouds:
          return const [
            Color(0xFF2C3252),
            Color(0xFF191D30),
            Color(0xFF0A0C14),
          ];
        case WeatherSceneTypes.rain:
          return const [
            Color(0xFF2B3A4C),
            Color(0xFF17222E),
            Color(0xFF080D13),
          ];
        case WeatherSceneTypes.thunderstorm:
          return const [
            Color(0xFF2E2547),
            Color(0xFF1C1533),
            Color(0xFF0A0714),
          ];
        case WeatherSceneTypes.snow:
          return const [
            Color(0xFF3A4A63),
            Color(0xFF243146),
            Color(0xFF101823),
          ];
        case WeatherSceneTypes.fog:
          return const [
            Color(0xFF333D3D),
            Color(0xFF1F2727),
            Color(0xFF0C1111),
          ];
        case WeatherSceneTypes.haze:
          return const [
            Color(0xFF4A3B39),
            Color(0xFF2A2322),
            Color(0xFF110E0E),
          ];
        case WeatherSceneTypes.storm:
          return const [
            Color(0xFF2D2142),
            Color(0xFF1A1230),
            Color(0xFF08050F),
          ];
      }
    }

    switch (kind) {
      case WeatherSceneTypes.clear:
        return const [
          Color(0xFFF8C56B),
          ColorPalette.peach,
          ColorPalette.turquoise,
          ColorPalette.deepTeal,
        ];
      case WeatherSceneTypes.clouds:
        return const [Color(0xFFB7B4D4), Color(0xFF8996A8), Color(0xFF5B6B7E)];
      case WeatherSceneTypes.rain:
        return const [Color(0xFF7C97AE), Color(0xFF4F6D85), Color(0xFF2E4254)];
      case WeatherSceneTypes.thunderstorm:
        return const [
          ColorPalette.stormIndigo,
          Color(0xFF33284D),
          ColorPalette.stormNight,
        ];
      case WeatherSceneTypes.snow:
        return const [
          ColorPalette.ice,
          Color(0xFFB9D2E0),
          ColorPalette.iceDeep,
        ];
      case WeatherSceneTypes.fog:
        return const [Color(0xFFCFD6D6), Color(0xFFAEBDB8), Color(0xFF84968F)];
      case WeatherSceneTypes.haze:
        return const [
          Color(0xFFE7C08A),
          ColorPalette.hazeAmber,
          ColorPalette.dustyRose,
        ];
      case WeatherSceneTypes.storm:
        return const [
          ColorPalette.stormViolet,
          Color(0xFF3B2C57),
          Color(0xFF1B1430),
        ];
    }
  }
}
