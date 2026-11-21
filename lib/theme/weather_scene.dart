import 'package:flutter/material.dart';
import 'package:weather/core/enums/weather_scene_types.dart';
import 'package:weather/theme/color_palette.dart';

@immutable
class WeatherScene {
  final WeatherSceneTypes kind;
  final bool isNight;

  const new({required this.kind, required this.isNight});

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

  /// Warm key light used by the sun/moon glow and character highlights.
  Color get glowColor {
    if (isNight) return ColorPalette.moon;
    switch (kind) {
      case WeatherSceneTypes.clear:
        return ColorPalette.sunGold;
      case WeatherSceneTypes.clouds:
        return const Color(0xFFF3E6D2);
      case WeatherSceneTypes.rain:
        return const Color(0xFFBFD8E6);
      case WeatherSceneTypes.thunderstorm:
        return const Color(0xFFD9CFFF);
      case WeatherSceneTypes.snow:
        return const Color(0xFFF2FAFF);
      case WeatherSceneTypes.fog:
        return const Color(0xFFE4EBE9);
      case WeatherSceneTypes.haze:
        return const Color(0xFFF2C98F);
      case WeatherSceneTypes.storm:
        return const Color(0xFFC9B8F0);
    }
  }

  /// Deep brush-shadow tone used for the lower half of each scene.
  Color get shadowColor {
    if (isNight) return const Color(0xFF05060A);
    switch (kind) {
      case WeatherSceneTypes.clear:
        return ColorPalette.deepTeal;
      case WeatherSceneTypes.clouds:
        return const Color(0xFF3F4C5C);
      case WeatherSceneTypes.rain:
        return ColorPalette.rainSlate;
      case WeatherSceneTypes.thunderstorm:
        return ColorPalette.stormNight;
      case WeatherSceneTypes.snow:
        return ColorPalette.iceDeep;
      case WeatherSceneTypes.fog:
        return const Color(0xFF5C6C67);
      case WeatherSceneTypes.haze:
        return const Color(0xFF8A6350);
      case WeatherSceneTypes.storm:
        return const Color(0xFF120D22);
    }
  }

  String get semanticLabel {
    switch (kind) {
      case WeatherSceneTypes.clear:
        return isNight ? 'Clear night scene' : 'Clear sky scene';
      case WeatherSceneTypes.clouds:
        return 'Cloudy sky scene';
      case WeatherSceneTypes.rain:
        return 'Rainy scene';
      case WeatherSceneTypes.thunderstorm:
        return 'Thunderstorm scene';
      case WeatherSceneTypes.snow:
        return 'Snowy scene';
      case WeatherSceneTypes.fog:
        return 'Foggy scene';
      case WeatherSceneTypes.haze:
        return 'Hazy scene';
      case WeatherSceneTypes.storm:
        return 'Stormy scene';
    }
  }

  static WeatherScene resolve({
    String? condition,
    int? conditionId,
    bool isNight = false,
  }) {
    final main = (condition ?? '').toLowerCase().trim();

    switch (main) {
      case 'clear':
        return WeatherScene(kind: WeatherSceneTypes.clear, isNight: isNight);
      case 'clouds':
        return WeatherScene(kind: WeatherSceneTypes.clouds, isNight: isNight);
      case 'rain':
      case 'drizzle':
        return WeatherScene(kind: WeatherSceneTypes.rain, isNight: isNight);
      case 'thunderstorm':
        return WeatherScene(
          kind: WeatherSceneTypes.thunderstorm,
          isNight: isNight,
        );
      case 'snow':
        return WeatherScene(kind: WeatherSceneTypes.snow, isNight: isNight);
      case 'mist':
      case 'fog':
        return WeatherScene(kind: WeatherSceneTypes.fog, isNight: isNight);
      case 'haze':
      case 'smoke':
      case 'dust':
      case 'sand':
      case 'ash':
        return WeatherScene(kind: WeatherSceneTypes.haze, isNight: isNight);
      case 'squall':
      case 'tornado':
        return WeatherScene(kind: WeatherSceneTypes.storm, isNight: isNight);
    }

    return WeatherScene(kind: _kindFromId(conditionId), isNight: isNight);
  }

  static WeatherSceneTypes _kindFromId(int? id) {
    if (id == null) return WeatherSceneTypes.clouds;
    if (id >= 200 && id < 300) return WeatherSceneTypes.thunderstorm;
    if (id >= 300 && id < 400) return WeatherSceneTypes.rain;
    if (id >= 500 && id < 600) return WeatherSceneTypes.rain;
    if (id >= 600 && id < 700) return WeatherSceneTypes.snow;
    if (id >= 700 && id < 800) return WeatherSceneTypes.fog;
    if (id == 800) return WeatherSceneTypes.clear;
    if (id > 800 && id < 900) return WeatherSceneTypes.clouds;
    return WeatherSceneTypes.clouds;
  }

  static bool nightAt({
    required int sunrise,
    required int sunset,
    DateTime? now,
  }) {
    final current = (now ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
    return current < sunrise || current >= sunset;
  }
}
