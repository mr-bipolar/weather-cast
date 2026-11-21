import 'package:flutter/material.dart';
import 'package:weather/shared/extensions/colors_extension.dart';
import 'package:weather/view/widgets/metric_tile.dart';

class MetricGrid extends StatelessWidget {
  final String? pressure;
  final String? humidity;
  final String? visibility;
  final String? visibilityUnit;
  final String? wind;
  final String? windDirection;
  const new({
    super.key,
    required this.pressure,
    required this.humidity,
    required this.visibility,
    this.visibilityUnit,
    required this.wind,
    this.windDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        // Smoked glass
        color: Colors.black.fade(0.32),
        borderRadius: .circular(20),
        border: .all(color: Colors.white.fade(0.14)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'PRESSURE',
                  value: pressure ?? 'N/A',
                  unit: 'hPa',
                ),
              ),
              const _TileDivider(),
              Expanded(
                child: MetricTile(
                  label: 'HUMIDITY',
                  value: humidity ?? 'N/A',
                  unit: '%',
                ),
              ),
            ],
          ),
          Padding(
            padding: const .symmetric(vertical: 10),
            child: Divider(height: 1, color: Colors.white.fade(0.14)),
          ),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'VISIBILITY',
                  value: visibility ?? 'N/A',
                  unit: visibilityUnit,
                ),
              ),
              const _TileDivider(),
              Expanded(
                child: MetricTile(
                  label: 'WIND',
                  value: wind ?? 'N/A',
                  unit: 'm/s',
                  direction: windDirection,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      margin: const .symmetric(horizontal: 10),
      color: Colors.white.fade(0.14),
    );
  }
}
