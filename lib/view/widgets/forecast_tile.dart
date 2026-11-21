import 'package:flutter/material.dart';
import 'package:weather/core/enums/weather_scene_types.dart';
import 'package:weather/model/weather_model.dart';
import 'package:weather/theme/text_style.dart';
import 'package:weather/theme/weather_scene.dart';
import 'package:weather/view/widgets/custom_painters/glyph_painter.dart';

class ForecastTile extends StatelessWidget {
  const new({super.key, required this.item, required this.label});

  final ForecastItem item;
  final String label;

  @override
  Widget build(BuildContext context) {
    final condition = item.condition.trim();
    final hasCondition = condition.isNotEmpty;
    final entryIsNight = item.isNight;
    final scene = hasCondition
        ? WeatherScene.resolve(
            condition: condition,
            conditionId: item.conditionId,
            isNight: entryIsNight ?? false,
          )
        : null;
    final clearWithoutFlag =
        scene?.kind == WeatherSceneTypes.clear && entryIsNight == null;
    final showGlyph = scene != null && !clearWithoutFlag;

    final temp = item.temp;
    final degrees = temp != null ? '${temp.round()}\u{00B0}C' : 'N/A';

    final description = item.description?.trim() ?? '';
    final friendly = description.isNotEmpty
        ? description.toLowerCase()
        : (hasCondition ? condition.toLowerCase() : null);
    final semanticLabel = <String>[
      label != 'N/A' ? label : 'time unavailable',
      temp != null
          ? '${temp.round()} degrees Celsius'
          : 'temperature unavailable',
      friendly ?? 'condition unavailable',
    ].join(', ');

    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: CustomTextStyle.railTime,
              maxLines: 1,
              overflow: .ellipsis,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 22,
              height: 22,
              child: showGlyph
                  ? CustomPaint(painter: GlyphPainter(scene))
                  : const Center(
                      child: Text('–', style: CustomTextStyle.metricLabel),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              degrees,
              style: CustomTextStyle.railTemp,
              maxLines: 1,
              overflow: .ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
