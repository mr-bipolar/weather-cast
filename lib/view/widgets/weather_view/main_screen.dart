import 'package:flutter/material.dart';
import 'package:weather/model/weather_model.dart';
import 'package:weather/shared/extensions/space_extension.dart';
import 'package:weather/theme/weather_scene.dart';
import 'package:weather/view/widgets/forecast_rail.dart';
import 'package:weather/view/widgets/metric_grid.dart';
import 'package:weather/view/widgets/weather_characters/weather_character.dart';
import 'package:weather/view/widgets/weather_view/footer.dart';
import 'package:weather/view/widgets/weather_view/header.dart';
import 'package:weather/view/widgets/weather_view/hero_view.dart';
import 'package:weather/view/widgets/weather_view/search_view.dart';
import 'package:weather/view/widgets/weather_view/status_strip.dart';

// Import your existing Header, SearchView, StatusStrip,
// HeroView and Footer widget files here.

class MainScreenView extends StatelessWidget {
  final TextEditingController textEditingController;
  final WeatherScene scene;

  // Connection and loading state
  final bool isConnected;
  final bool isLoading;
  final String? loadError;

  // Weather information
  final String? temperature;
  final String? conditionDescription;
  final String? weather;
  final String? maxtemp;
  final String? mintemp;
  final String? feelslike;

  // Location and sun information
  final String? cityname;
  final String? sunrise;
  final String? sunset;
  final DateTime? lastUpdated;

  // Weather metrics
  final String? pressure;
  final String? humidity;
  final String? visibility;
  final String? visibilityUnit;
  final String? windspeed;
  final String? windDirection;

  // Forecast
  final List<ForecastItem> forecastItems;
  final int? forecastTimezone;

  const new({
    super.key,
    required this.textEditingController,
    required this.scene,
    required this.isConnected,
    required this.isLoading,
    required this.cityname,
    required this.forecastItems,
    required this.forecastTimezone,
    this.loadError,
    this.temperature,
    this.conditionDescription,
    this.weather,
    this.maxtemp,
    this.mintemp,
    this.feelslike,
    this.sunrise,
    this.sunset,
    this.lastUpdated,
    this.pressure,
    this.humidity,
    this.visibility,
    this.visibilityUnit,
    this.windspeed,
    this.windDirection,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 400;

          final pad = compact ? 16.0 : 20.0;
          final searchGap = compact ? 14.0 : 18.0;
          final heroGap = compact ? 18.0 : 22.0;

          final breather = ((constraints.maxHeight - 700) * 0.35).clamp(
            0.0,
            80.0,
          );

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(pad, 10, pad, 18),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 28,
                  maxWidth: 560,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Header(isConnected: isConnected, cityname: "Kollam"),
                    16.h,
                    SearchView(textEditingController: textEditingController),
                    StatusStrip(isLoading: isLoading),
                    SizedBox(height: searchGap + breather),
                    Center(
                      child: ExcludeSemantics(
                        child: WeatherCharacter(scene: scene, size: 168),
                      ),
                    ),
                    12.h,
                    HeroView(),
                    SizedBox(height: heroGap),
                    ForecastRail(
                      items: forecastItems,
                      timezone: forecastTimezone,
                    ),
                    14.h,
                    MetricGrid(
                      pressure: pressure,
                      humidity: humidity,
                      visibility: visibility,
                      visibilityUnit: visibilityUnit,
                      wind: windspeed,
                      windDirection: windDirection,
                    ),
                    14.h,
                    Footer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
