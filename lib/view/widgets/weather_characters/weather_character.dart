import 'package:flutter/material.dart';
import 'package:weather/core/animations/ambient_motion.dart';
import 'package:weather/theme/weather_scene.dart';
import 'package:weather/view/widgets/custom_painters/character_painter.dart';

class WeatherCharacter extends StatelessWidget {
  final WeatherScene scene;
  final double size;
  const new({super.key, required this.scene, this.size = 172});

  @override
  Widget build(BuildContext context) {
    final motion = AmbientMotion.maybeOf(context);
    return Semantics(
      label: '${scene.semanticLabel} character',
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: RepaintBoundary(
            child: CustomPaint(painter: CharacterPainter(scene, motion)),
          ),
        ),
      ),
    );
  }
}
