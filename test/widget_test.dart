import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather/model/weather_model.dart';
import 'package:weather/view/widgets/forecast_rail.dart';

void main() {
  testWidgets('Forecast rail handles an empty forecast', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ForecastRail(items: <ForecastItem>[], timezone: null)),
    );

    expect(tester.takeException(), isNull);
  });
}
