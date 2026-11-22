import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/env/env.dart';
import 'package:weather/model/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherServices {
  final String _apiKey = Env.weatherKey;
  final String _host = "https://api.openweathermap.org/data/2.5/weather";
  final String _forecastHost =
      "https://api.openweathermap.org/data/2.5/forecast";

  static const Duration _httpTimeout = Duration(seconds: 15);
  static const Duration _locationTimeout = Duration(seconds: 30);

  Future<Position>? _positionFuture;

  Future<Position> _devicePosition() {
    return _positionFuture ??= _fetchDevicePosition();
  }

  Future<Position> _fetchDevicePosition() async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    return Geolocator.getCurrentPosition(locationSettings: locationSettings)
        .timeout(_locationTimeout);
  }

  // api call function
  Future<WeatherData?> getWeather(String cityName) async {
    try {
      final response = await http
          .get(Uri.parse('$_host?q=$cityName&appid=$_apiKey&units=metric'))
          .timeout(_httpTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw Exception('Data not found..! (HTTP ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Log => GetWeather : $e');
    }
    return null;
  }

  // device api call
  Future<WeatherData?> weather() async {
    try {
      final position = await _devicePosition();
      final lat = position.latitude, long = position.longitude;

      final response = await http
          .get(
            Uri.parse('$_host?lat=$lat&lon=$long&appid=$_apiKey&units=metric'),
          )
          .timeout(_httpTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw Exception('Data not found..! (HTTP ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Log => weather : $e');
    }
    return null;
  }

  // forecast by city
  Future<ForecastData?> getForecast(String cityName) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_forecastHost?q=$cityName&appid=$_apiKey&units=metric'),
          )
          .timeout(_httpTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ForecastData.fromJson(data);
      } else {
        throw Exception('Forecast not found..! (HTTP ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Log => GetForecast : $e');
    }
    return null;
  }

  // forecast by device location
  Future<ForecastData?> forecast() async {
    try {
      final position = await _devicePosition();
      final lat = position.latitude, long = position.longitude;

      final response = await http
          .get(
            Uri.parse(
              '$_forecastHost?lat=$lat&lon=$long&appid=$_apiKey&units=metric',
            ),
          )
          .timeout(_httpTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ForecastData.fromJson(data);
      } else {
        throw Exception('Forecast not found..! (HTTP ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Log => forecast : $e');
    }
    return null;
  }
}
