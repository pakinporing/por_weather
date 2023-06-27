class WeatherDay {
  final int dt;
  final String main;
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int seaLevel;
  final int grndLevel;
  final int humidity;

  WeatherDay({
    required this.dt,
    required this.main,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.seaLevel,
    required this.grndLevel,
    required this.humidity,
  });

  factory WeatherDay.fromJson(Map<String, dynamic> json) {
    return WeatherDay(
      dt: json['dt'],
      main: json['weather'][0]['main'],
      temp: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      tempMin: json['main']['temp_min'].toDouble(),
      tempMax: json['main']['temp_max'].toDouble(),
      pressure: json['main']['pressure'],
      seaLevel: json['main']['sea_level'],
      grndLevel: json['main']['grnd_level'],
      humidity: json['main']['humidity'],
    );
  }
}

class WeatherData {
  final String cod;
  final int message;
  final int cnt;
  final List<WeatherDay> days;
  final String cityName;

  WeatherData({
    required this.cod,
    required this.message,
    required this.cnt,
    required this.days,
    required this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    var list = json['list'] as List;
    List<WeatherDay> weatherDays =
        list.map((i) => WeatherDay.fromJson(i)).toList();

    return WeatherData(
      cod: json['cod'],
      message: json['message'],
      cnt: json['cnt'],
      days: weatherDays,
      cityName: json['city']['name'],
    );
  }
}
