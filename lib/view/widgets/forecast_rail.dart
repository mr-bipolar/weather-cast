import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/model/weather_model.dart';
import 'package:weather/shared/extensions/colors_extension.dart';
import 'package:weather/theme/text_style.dart';
import 'package:weather/view/widgets/forecast_tile.dart';

class ForecastRail extends StatelessWidget {
  final List<ForecastItem> items;
  final int maxEntries;

  final int? timezone;
  const new({
    super.key,
    required this.items,
    this.maxEntries = 8,
    this.timezone,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final visible = items.take(maxEntries).toList(growable: false);
    final scaler = MediaQuery.textScalerOf(context).scale(10) / 10;
    final tileWidth = (46.0 * scaler).clamp(46.0, 72.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const .only(left: 4, bottom: 8),
          child: Semantics(
            label: 'Forecast, next ${visible.length} entries, 3-hourly',
            excludeSemantics: true,
            child: Text(
              'NEXT ${visible.length} · 3-HOURLY',
              style: CustomTextStyle.metricLabel,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            // Smoked glass
            color: Colors.black.fade(0.32),
            borderRadius: .circular(20),
            border: .all(color: Colors.white.fade(0.14)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tiles = [
                for (final item in visible)
                  ForecastTile(
                    item: item,
                    label: _cityTimeLabel(item, timezone),
                  ),
              ];

              if (constraints.maxWidth >= visible.length * tileWidth) {
                return Row(
                  children: [for (final tile in tiles) Expanded(child: tile)],
                );
              }

              return SingleChildScrollView(
                scrollDirection: .horizontal,
                padding: const .only(left: 2, right: 8),
                child: Row(
                  children: [
                    for (final tile in tiles)
                      SizedBox(width: tileWidth, child: tile),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

String _cityTimeLabel(ForecastItem item, int? timezone) {
  if (timezone == null) return 'N/A';
  final cityTime = item.time.toUtc().add(Duration(seconds: timezone));
  return DateFormat('h a').format(cityTime);
}
