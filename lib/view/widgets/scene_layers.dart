import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:weather/shared/extensions/colors_extension.dart';
import 'package:weather/theme/color_palette.dart';
import 'package:weather/theme/weather_scene.dart';
import 'package:weather/view/widgets/custom_painters/scene_motion_painter.dart';
import 'package:weather/view/widgets/custom_painters/static_scene_painter.dart';

class SceneLayers extends StatelessWidget {
  const new({super.key, required this.scene, required this.motion});

  final WeatherScene scene;
  final Animation<double> motion;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base sky gradient (static per scene)
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: scene.gradient,
            ),
          ),
        ),
        // Painted still atmosphere: sky light, stars, hills
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: StaticScenePainter(scene: scene),
              isComplex: true,
            ),
          ),
        ),
        // Moving atmosphere: clouds, precipitation, fog, shimmer
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: SceneMotionPainter(scene: scene, motion: motion),
              willChange: true,
            ),
          ),
        ),
        // Legibility scrim (keeps text AA over any scene)
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _scrimColors(scene),
                  stops: const [0.0, 0.28, 0.72, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Helppers
List<Color> _scrimColors(WeatherScene scene) {
  const ink = ColorPalette.ink;
  final top = _scrimAlphaFor(
    scene.gradient.first,
    ink,
    3.0,
  ).clamp(0.16, 0.40).toDouble();
  final midColor = scene.gradient[scene.gradient.length ~/ 2];
  final mid = _scrimAlphaFor(midColor, ink, 3.0).clamp(0.04, 0.34).toDouble();
  final lower = math.max(0.22, mid * 0.9);

  return [
    Colors.black.fade(top),
    Colors.black.fade(mid),
    Colors.black.fade(lower),
    Colors.black.fade(0.46),
  ];
}

double _scrimAlphaFor(Color background, Color text, double target) {
  if (_contrastRatio(background, text) >= target) return 0;
  for (var i = 1; i <= 60; i++) {
    final alpha = i / 100;
    final blended = Color.lerp(background, Colors.black, alpha)!;
    if (_contrastRatio(blended, text) >= target) return alpha;
  }
  return 0.60;
}

double _contrastRatio(Color first, Color second) {
  final lf = first.computeLuminance();
  final ls = second.computeLuminance();
  final hi = math.max(lf, ls);
  final lo = math.min(lf, ls);
  return (hi + 0.05) / (lo + 0.05);
}
