import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/theme/text_style.dart';

class Footer extends StatelessWidget {
  final String? sunrise;
  final String? sunset;
  final DateTime? lastUpdated;
  final String? loadError;

  const Footer({
    super.key,
    this.sunrise,
    this.sunset,
    this.lastUpdated,
    this.loadError,
  });

  @override
  Widget build(BuildContext context) {
    final stale = loadError != null && lastUpdated != null;

    final updated = lastUpdated != null
        ? '${stale ? 'last updated' : 'updated'} '
              '${DateFormat('h:mm a').format(lastUpdated!)}'
        : null;

    final summary = <String>[
      sunrise != null ? 'Sunrise $sunrise' : 'Sunrise unavailable',
      sunset != null ? 'Sunset $sunset' : 'Sunset unavailable',
      ?updated,
    ];

    return Semantics(
      container: true,
      label: summary.join(', '),
      child: ExcludeSemantics(
        child: Wrap(
          alignment: .center,
          crossAxisAlignment: .center,
          spacing: 10,
          runSpacing: 4,
          children: [
            _smallStat('Sunrise', sunrise),
            _afterDot(_smallStat('Sunset', sunset)),
            if (lastUpdated != null)
              Text(
                '${stale ? 'Last updated' : 'Updated'} '
                '${DateFormat('h:mm a').format(lastUpdated!)}',
                style: CustomTextStyle.caption,
              ),
          ],
        ),
      ),
    );
  }
}

Widget _smallStat(String label, String? value) => RichText(
  text: TextSpan(
    children: [
      TextSpan(text: '$label ', style: CustomTextStyle.caption),
      TextSpan(
        text: value ?? 'N/A',
        style: CustomTextStyle.railTemp.copyWith(fontSize: 11.5),
      ),
    ],
  ),
);

Widget _afterDot(Widget child) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Text('·', style: CustomTextStyle.caption),
    const SizedBox(width: 10),
    child,
  ],
);
