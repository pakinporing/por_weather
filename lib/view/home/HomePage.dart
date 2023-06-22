import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;

  String climateDescription = '';
  String climate = '';
  String myLocation = '';
  String iconStautus = '';
  String day = '';
  String sunrise = '';
  String sunset = '';
  int deg = 0;
  double temp = 0;
  int humidity = 0;
  double speed = 0;
  int pressure = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void updateWeatherData(String resBody) {
    Map<String, dynamic> data = jsonDecode(resBody);

    // แปลง timestamp เป็นวันที่และเวลา
    int timestamp = data['dt'];
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    String formattedDate = DateFormat('EEEE').format(date); // ชื่อวัน

    int sunriseTimestamp = data['sys']['sunrise'];
    DateTime sunriseDate =
        DateTime.fromMillisecondsSinceEpoch(sunriseTimestamp * 1000);
    String formattedSunrise = DateFormat('HH:mm').format(sunriseDate);

    int sunsetTimestamp = data['sys']['sunset'];
    DateTime sunsetDate =
        DateTime.fromMillisecondsSinceEpoch(sunsetTimestamp * 1000);
    String formattedSunset = DateFormat('HH:mm').format(sunsetDate);

    // กำหนดค่าใหม่โดยใช้ข้อมูลจาก API
    setState(() {
      climateDescription = data['weather'][0]['description'];
      climate = data['weather'][0]['main'];
      iconStautus = data['weather'][0]['icon'];
      temp = data['main']['temp'];
      pressure = data['main']['pressure'];
      myLocation = data['name'];
      day = formattedDate;
      deg = data['wind']['deg'];
      speed = data['wind']['speed'];
      humidity = data['main']['humidity'];
      sunset = formattedSunset;
      sunrise = formattedSunrise;
      isLoading = false;
    });

    print(
        '---------------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!---------------------------------');
    print('Climate Description: $climateDescription');
    print('Climate: $climate');
    print('iconStautus: $iconStautus');
    print('myLocation: $myLocation');
    print('formattedDate: $formattedDate');
    print('deg: $deg');
    print('speed: $speed');
    print('pressure: $pressure');
    print(
        '---------------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!---------------------------------');
  }

  Future<void> fetchData() async {
    // ...

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double latitude = position.latitude;
    double longitude = position.longitude;

    // double testLat = 55;
    // double testLong = 41;

    var url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=8e7cb329abf8bf036cc6f7858110175e&units=metric');
    // 'https://api.openweathermap.org/data/2.5/weather?lat=$testLat&lon=$testLong&appid=8e7cb329abf8bf036cc6f7858110175e&units=metric');
    var res = await http.get(url);
    if (res.statusCode == 200) {
      updateWeatherData(res.body);
    }
    // ...
  }

  Future<void> fetchDataByCityName(String cityName) async {
    // ...
    var url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=8e7cb329abf8bf036cc6f7858110175e&units=metric');
    var res = await http.get(url);
    if (res.statusCode == 200) {
      updateWeatherData(res.body);
    }
    // ...
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Color.fromARGB(255, 111, 190, 255),
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
          backgroundColor: Color.fromARGB(255, 111, 190, 255),
          appBar: AppBar(
            title: TextField(
              onSubmitted: (value) {
                fetchDataByCityName(value);
              },
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
            ),
            backgroundColor: Color.fromARGB(255, 111, 190, 255),
          ),
          body: RefreshIndicator(
            onRefresh: fetchData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: Image.asset(
                          (iconStautus == '01d' || iconStautus == '01n')
                              ? 'assets/iconsstatus/sunny.png'
                              : (iconStautus == '02d' || iconStautus == '02n')
                                  ? 'assets/iconsstatus/clear-sky.png'
                                  : (iconStautus == '03d' ||
                                          iconStautus == '03n')
                                      ? 'assets/iconsstatus/cloud.png'
                                      : (iconStautus == '04d' ||
                                              iconStautus == '04n')
                                          ? 'assets/iconsstatus/cloudy-day.png'
                                          : (iconStautus == '09d' ||
                                                  iconStautus == '09n')
                                              ? 'assets/iconsstatus/rainy-day.png'
                                              : (iconStautus == '10d' ||
                                                      iconStautus == '10n')
                                                  ? 'assets/iconsstatus/downpour.png'
                                                  : (iconStautus == '11d' ||
                                                          iconStautus == '11n')
                                                      ? 'assets/iconsstatus/dark-and-stormy.png'
                                                      : (iconStautus == '13d' ||
                                                              iconStautus ==
                                                                  '13n')
                                                          ? 'assets/iconsstatus/snowflake.png'
                                                          : (iconStautus ==
                                                                      '50d' ||
                                                                  iconStautus ==
                                                                      '50n')
                                                              ? 'assets/iconsstatus/fog.png'
                                                              : 'assets/cloud_sun.png',
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        '$myLocation',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        '$day',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        '$temp°',
                        style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        '$climateDescription',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        width:
                            350, // ตั้งค่าความกว้างที่คุณต้องการให้ Divider มี
                        child: Divider(
                          color: Colors.white,
                          thickness: 2,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Transform.rotate(
                              angle: deg * math.pi / 180,
                              child: Icon(
                                Icons.navigation,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$speed km/h',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Wind',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 50),
                            Icon(
                              Icons.water_drop_outlined,
                              color: Colors.white,
                              size: 40,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$humidity %',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Humidity',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.thermostat,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$pressure mbar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Pressure',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 50),
                          Icon(
                            Icons.swap_vert,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$sunrise sunrise',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '$sunset sunset',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ));
    }
  }
}
