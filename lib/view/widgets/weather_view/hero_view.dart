import 'package:flutter/material.dart';
import 'package:weather/shared/constants/app_strings.dart';
import 'package:weather/shared/extensions/space_extension.dart';
import 'package:weather/theme/color_palette.dart';
import 'package:weather/theme/text_style.dart';

class HeroView extends StatelessWidget {
  final String? temperature;
  final String? conditionDescription;
  final String? weather;
  final String? maxtemp;
  final String? mintemp;
  final String? feelslike;

  const HeroView({
    super.key,
    this.temperature,
    this.conditionDescription,
    this.weather,
    this.maxtemp,
    this.mintemp,
    this.feelslike,
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(68) / 68;
    final height = (76 * scale.clamp(1.0, 2.0)).toDouble();

    final displayCondition = _friendlyCondition(conditionDescription, weather);

    final summary = <String>[
      temperature != null
          ? '$temperature degrees Celsius'
          : AppStrings.tempUnavailable,
      if (displayCondition != null) displayCondition.toLowerCase(),
      if (maxtemp != null) 'high $maxtemp degrees Celsius',
      if (mintemp != null) 'low $mintemp degrees Celsius',
      if (feelslike != null) 'feels like $feelslike degrees Celsius',
    ];

    return Semantics(
      container: true,
      label: summary.join(', '),
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              height: height,
              child: FittedBox(
                fit: .scaleDown,
                child: Text(
                  temperature != null ? '$temperature\u{00B0}C' : 'N/A',
                  style: CustomTextStyle.temperature,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayCondition ?? 'N/A',
              style: CustomTextStyle.condition,
              textAlign: .center,
            ),
            19.h,
            Wrap(
              alignment: .center,
              spacing: 14,
              runSpacing: 4,
              children: [
                _highlight('H', maxtemp),
                _highlight('L', mintemp),
                if (feelslike != null) _highlight('Feels', feelslike),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String? _friendlyCondition(String? description, String? main) {
  final detail = description?.trim() ?? '';

  if (detail.isNotEmpty) {
    return detail[0].toUpperCase() + detail.substring(1);
  }

  final summary = main?.trim() ?? '';

  if (summary.isNotEmpty) return summary.toUpperCase();

  return null;
}

Widget _highlight(String label, String? value) => RichText(
  text: TextSpan(
    children: [
      TextSpan(text: '$label ', style: CustomTextStyle.caption),
      TextSpan(
        text: value != null ? '$value\u{00B0}C' : 'N/A',
        style: CustomTextStyle.highlight.copyWith(
          color: ColorPalette.ink,
          fontWeight: .w600,
        ),
      ),
    ],
  ),
);
