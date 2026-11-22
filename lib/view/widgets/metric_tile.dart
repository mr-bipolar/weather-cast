import 'package:flutter/material.dart';
import 'package:weather/shared/extensions/space_extension.dart';
import 'package:weather/theme/text_style.dart';

class MetricTile extends StatelessWidget {
  const new({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.direction,
  });

  final String label;
  final String value;
  final String? unit;
  final String? direction;

  @override
  Widget build(BuildContext context) {
    final reading = unit == null ? value : '$value $unit';
    var textStyle = CustomTextStyle.caption.copyWith(fontSize: 9.5);
    return Semantics(
      label: direction == null
          ? '$label $reading'
          : '$label, direction $direction, $reading',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(label, style: CustomTextStyle.metricLabel),
            4.h,
            Row(
              crossAxisAlignment: .baseline,
              textBaseline: .alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: CustomTextStyle.metricValue,
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                ),
                if (unit != null) ...[
                  3.w,
                  Flexible(
                    child: Text(
                      unit!,
                      style: textStyle,
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                  ),
                ],
                if (direction != null) ...[
                  3.w,
                  Flexible(
                    child: Text(
                      direction!,
                      style: textStyle,
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
