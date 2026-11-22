import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather/view/widgets/metric_grid.dart';

void main() {
  testWidgets('Metric grid renders its labels and values', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MetricGrid(
          humidity: '55',
          pressure: '1013',
          wind: '3.2',
          windDirection: 'NW',
          visibility: '10.0',
          visibilityUnit: 'km',
        ),
      ),
    );

    expect(find.text("PRESSURE"), findsOneWidget);
    expect(find.text('1013'), findsOneWidget);

    expect(find.text("WIND"), findsOneWidget);
    expect(find.text("3.2"), findsOneWidget);

    expect(find.text("VISIBILITY"), findsOneWidget);
    expect(find.text("10.0"), findsOneWidget);

    expect(find.text("HUMIDITY"), findsOneWidget);
    expect(find.text("55"), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
