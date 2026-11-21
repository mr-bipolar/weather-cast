class WeatherData {
  final List<Weather> _weather;
  final Main _main;
  final int _visibility;
  final Wind _wind;
  final Sys _sys;
  final String _name;
  final int? _timezone;

  // Main constructor
  WeatherData({
    required this._weather,
    required this._main,
    required this._visibility,
    required this._wind,
    required this._sys,
    required this._name,
    this._timezone,
  });

  //=========== Data from api
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final rawWeather = json['weather'];
    final weatherList = rawWeather is List ? rawWeather : const <dynamic>[];
    final rawMain = json['main'];
    final main = rawMain is Map
        ? rawMain.cast<String, dynamic>()
        : const <String, dynamic>{};
    final rawWind = json['wind'];
    final wind = rawWind is Map
        ? rawWind.cast<String, dynamic>()
        : const <String, dynamic>{};
    final rawSys = json['sys'];
    final sys = rawSys is Map
        ? rawSys.cast<String, dynamic>()
        : const <String, dynamic>{};
    final rawVisibility = json['visibility'];
    final rawName = json['name'];
    final rawTimezone = json['timezone'];

    return WeatherData(
      weather: weatherList
          .whereType<Map<String, dynamic>>()
          .map((item) => Weather.fromJson(item))
          .toList(),
      main: Main.fromJson(main),
      visibility: rawVisibility is int ? rawVisibility : 0,
      wind: Wind.fromJson(wind),
      sys: Sys.fromJson(sys),
      name: rawName is String ? rawName : '',
      timezone: rawTimezone is int ? rawTimezone : null,
    );
  }

  // Get value
  List<Weather> get weather => _weather;
  Main get main => _main;
  int get visibility => _visibility;
  Wind get wind => _wind;
  Sys get sys => _sys;
  String get name => _name;
  int? get timezone => _timezone;
}

//========== inner class Weather

class Weather {
  final String _main;
  final String _description;
  final int? _id;

  Weather({required this._main, required this._description, this._id});

  factory Weather.fromJson(Map<String, dynamic> json) {
    final rawMain = json['main'];
    final rawDescription = json['description'];
    final rawId = json['id'];
    return Weather(
      main: rawMain is String ? rawMain : '',
      description: rawDescription is String ? rawDescription : '',
      id: rawId is int ? rawId : null,
    );
  }

  String get main => _main;
  String get description => _description;
  int? get id => _id;
}

//========= inner class Main
class Main {
  final double _temp;
  final double _tempMin;
  final double _tempMax;
  final int _pressure;
  final int _humidity;
  final double? _feelsLike;

  Main({
    required this._temp,
    required this._tempMin,
    required this._tempMax,
    required this._pressure,
    required this._humidity,
    this._feelsLike,
  });

  factory Main.fromJson(Map<String, dynamic> json) {
    final rawTemp = json['temp'];
    final rawTempMin = json['temp_min'];
    final rawTempMax = json['temp_max'];
    final rawPressure = json['pressure'];
    final rawHumidity = json['humidity'];
    final rawFeels = json['feels_like'];
    return Main(
      temp: rawTemp is num ? rawTemp.toDouble() : 0.0,
      tempMin: rawTempMin is num ? rawTempMin.toDouble() : 0.0,
      tempMax: rawTempMax is num ? rawTempMax.toDouble() : 0.0,
      pressure: rawPressure is int ? rawPressure : 0,
      humidity: rawHumidity is int ? rawHumidity : 0,
      feelsLike: rawFeels is num ? rawFeels.toDouble() : null,
    );
  }

  double get temp => _temp;
  double get tempMin => _tempMin;
  double get tempMax => _tempMax;
  int get pressure => _pressure;
  int get humidity => _humidity;
  double? get feelsLike => _feelsLike;
}

//=========== inner class wind
class Wind {
  final double? _speed;
  final int? _deg;

  Wind({this._speed, this._deg});

  factory Wind.fromJson(Map<String, dynamic> json) {
    final rawSpeed = json['speed'];
    final rawDeg = json['deg'];
    return Wind(
      speed: rawSpeed is num ? rawSpeed.toDouble() : null,
      deg: rawDeg is int ? rawDeg : null,
    );
  }

  double? get speed => _speed;
  int? get deg => _deg;
}

//=========== inner class Sys
class Sys {
  final int _sunrise;
  final int _sunset;

  Sys({required this._sunrise, required this._sunset});

  factory Sys.fromJson(Map<String, dynamic> json) {
    final rawSunrise = json['sunrise'];
    final rawSunset = json['sunset'];
    return Sys(
      sunrise: rawSunrise is int ? rawSunrise : 0,
      sunset: rawSunset is int ? rawSunset : 0,
    );
  }

  int get sunrise => _sunrise;
  int get sunset => _sunset;
}

//========= Forecast data  (free 5-day / 3-hour endpoint)
class ForecastData {
  final List<ForecastItem> _items;

  /// City UTC offset in seconds.
  final int? _timezone;

  ForecastData({required this._items, this._timezone});

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    final rawList = json['list'];
    final list = rawList is List ? rawList : const <dynamic>[];
    final rawCity = json['city'];
    final city = rawCity is Map
        ? rawCity.cast<String, dynamic>()
        : const <String, dynamic>{};
    final rawOffset = city['timezone'];
    return ForecastData(
      items: list
          .whereType<Map<String, dynamic>>()
          .where((item) => item['dt'] is int)
          .map((item) => ForecastItem.fromJson(item))
          .toList(),
      timezone: rawOffset is int ? rawOffset : null,
    );
  }

  List<ForecastItem> get items => _items;
  int? get timezone => _timezone;
}

class ForecastItem {
  final DateTime _time;

  final double? _temp;
  final double? _feelsLike;
  final String _condition;
  final String? _description;
  final int? _conditionId;

  /// sun or moon glyph.
  final bool? _isNight;

  ForecastItem({
    required this._time,
    this._temp,
    this._feelsLike,
    required this._condition,
    this._description,
    this._conditionId,
    this._isNight,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    final rawMain = json['main'];
    final main = rawMain is Map
        ? rawMain.cast<String, dynamic>()
        : const <String, dynamic>{};
    final rawWeather = json['weather'];
    final weatherList = rawWeather is List ? rawWeather : const <dynamic>[];
    final firstWeather = weatherList.isNotEmpty && weatherList.first is Map
        ? (weatherList.first as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final rawSys = json['sys'];
    final sys = rawSys is Map
        ? rawSys.cast<String, dynamic>()
        : const <String, dynamic>{};
    final pod = sys['pod'] is String ? sys['pod'] as String : null;
    final icon = firstWeather['icon'] is String
        ? firstWeather['icon'] as String
        : null;
    bool? isNight;
    if (pod == 'n') {
      isNight = true;
    } else if (pod == 'd') {
      isNight = false;
    } else if (icon != null) {
      if (icon.endsWith('n')) {
        isNight = true;
      } else if (icon.endsWith('d')) {
        isNight = false;
      }
    }

    final rawTemp = main['temp'];
    final rawFeels = main['feels_like'];
    final rawCondition = firstWeather['main'];
    final rawDescription = firstWeather['description'];
    final rawId = firstWeather['id'];

    return ForecastItem(
      time: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
        isUtc: true,
      ),
      temp: rawTemp is num ? rawTemp.toDouble() : null,
      feelsLike: rawFeels is num ? rawFeels.toDouble() : null,
      condition: rawCondition is String ? rawCondition : '',
      description: rawDescription is String ? rawDescription : null,
      conditionId: rawId is int ? rawId : null,
      isNight: isNight,
    );
  }

  DateTime get time => _time;
  double? get temp => _temp;
  double? get feelsLike => _feelsLike;
  String get condition => _condition;
  String? get description => _description;
  int? get conditionId => _conditionId;
  bool? get isNight => _isNight;
}
