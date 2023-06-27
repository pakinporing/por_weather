import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:por_weather/model/WeatherData.dart'; // Assume that WeatherDay and WeatherData are in models.dart

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final myController = TextEditingController();
  bool isLoading = true;
  WeatherData? weatherData;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void updateWeatherData(String resBody) {
    Map<String, dynamic> data = jsonDecode(resBody);

    // We directly create our WeatherData from the JSON
    setState(() {
      weatherData = WeatherData.fromJson(data);
      isLoading = false;
    });

    // Let's print first day's data for testing
    if (weatherData != null && weatherData!.days.isNotEmpty) {
      WeatherDay firstDay = weatherData!.days.first;
      print('Temperature: ${firstDay.temp}');
      print('Main: ${firstDay.main}');
      print('Humidity: ${firstDay.humidity}');
      // Add more print statements for other data you need
    }
  }

  Future<void> fetchData() async {
    // LocationPermission permission;

    // // Check if GPS is enabled
    // bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!isLocationServiceEnabled) {
    //   // GPS not enabled, show a toast message
    //   Fluttertoast.showToast(
    //       msg: "GPS ไม่ได้ถูกเปิดใช้งาน, กรุณาเปิด GPS",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       timeInSecForIosWeb: 2,
    //       backgroundColor: Colors.red,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    //   return;
    // }

    // // Check location permissions
    // permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    //   if (permission == LocationPermission.denied) {
    //     // Permissions are denied, show a toast message
    //     Fluttertoast.showToast(
    //         msg:
    //             "การเข้าถึงตำแหน่งถูกปฏิเสธ, กรุณาอนุญาตให้เราเข้าถึงตำแหน่งของคุณ",
    //         toastLength: Toast.LENGTH_SHORT,
    //         gravity: ToastGravity.BOTTOM,
    //         timeInSecForIosWeb: 2,
    //         backgroundColor: Colors.red,
    //         textColor: Colors.white,
    //         fontSize: 16.0);
    //     return;
    //   }
    // }

    // if (permission == LocationPermission.deniedForever) {
    //   // Permissions are denied forever, show a toast message
    //   Fluttertoast.showToast(
    //       msg:
    //           "การเข้าถึงตำแหน่งถูกปฏิเสธอย่างถาวร, เราไม่สามารถร้องขอการอนุญาตได้",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.CENTER,
    //       timeInSecForIosWeb: 2,
    //       backgroundColor: Colors.red,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    //   return;
    // }

    // If GPS is enabled and permissions are granted, get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double latitude = position.latitude;
    double longitude = position.longitude;

    var url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?cnt=5&lat=$latitude&lon=$longitude&appid=8e7cb329abf8bf036cc6f7858110175e&units=metric');
    var res = await http.get(url);
    if (res.statusCode == 200) {
      updateWeatherData(res.body);
    }
  }

  Future<void> fetchDataByCityName(String cityName) async {
    // ...
    var url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?cnt=5&q=$cityName&appid=8e7cb329abf8bf036cc6f7858110175e&units=metric');
    var res = await http.get(url);
    if (res.statusCode == 200) {
      updateWeatherData(res.body);
    } else {
      print('66666  ไม่มีสถานที่ 666');
      Fluttertoast.showToast(
          msg: "ไม่มี $cityName อยู่ในฐานข้อมูลโว้ยยย",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    // ...
  }

  // @override
  // Widget build(BuildContext context) {
  //   if (isLoading) {
  //     return Scaffold(
  //       backgroundColor: Color.fromARGB(255, 111, 190, 255),
  //       body: Center(child: CircularProgressIndicator()),
  //     );
  //   } else {
  //     return Scaffold(
  //         backgroundColor: Color.fromARGB(255, 111, 190, 255),
  //         appBar: AppBar(
  //           title: TextField(
  //             controller: myController,
  //             onSubmitted: (value) {
  //               fetchDataByCityName(value);
  //               myController.clear();
  //             },
  //             style: TextStyle(color: Colors.white),
  //             decoration: InputDecoration(
  //               hintText: "Search",
  //               hintStyle: TextStyle(color: Colors.white),
  //               prefixIcon: Icon(Icons.search, color: Colors.white),
  //             ),
  //           ),
  //           backgroundColor: Color.fromARGB(255, 111, 190, 255),
  //         ),
  //         body: RefreshIndicator(
  //           onRefresh: fetchData,
  //           child: SingleChildScrollView(
  //             physics: const AlwaysScrollableScrollPhysics(),
  //             child: Center(
  //               child: Padding(
  //                 padding: const EdgeInsets.only(top: 70),
  //                 child: Column(
  //                   children: [
  //                     SizedBox(
  //                       width: 240,
  //                       height: 240,
  //                       child: Image.asset(
  //                         (iconStautus == '01d' || iconStautus == '01n')
  //                             ? 'assets/iconsstatus/sunny.png'
  //                             : (iconStautus == '02d' || iconStautus == '02n')
  //                                 ? 'assets/iconsstatus/clear-sky.png'
  //                                 : (iconStautus == '03d' ||
  //                                         iconStautus == '03n')
  //                                     ? 'assets/iconsstatus/cloud.png'
  //                                     : (iconStautus == '04d' ||
  //                                             iconStautus == '04n')
  //                                         ? 'assets/iconsstatus/cloudy-day.png'
  //                                         : (iconStautus == '09d' ||
  //                                                 iconStautus == '09n')
  //                                             ? 'assets/iconsstatus/rainy-day.png'
  //                                             : (iconStautus == '10d' ||
  //                                                     iconStautus == '10n')
  //                                                 ? 'assets/iconsstatus/downpour.png'
  //                                                 : (iconStautus == '11d' ||
  //                                                         iconStautus == '11n')
  //                                                     ? 'assets/iconsstatus/dark-and-stormy.png'
  //                                                     : (iconStautus == '13d' ||
  //                                                             iconStautus ==
  //                                                                 '13n')
  //                                                         ? 'assets/iconsstatus/snowflake.png'
  //                                                         : (iconStautus ==
  //                                                                     '50d' ||
  //                                                                 iconStautus ==
  //                                                                     '50n')
  //                                                             ? 'assets/iconsstatus/fog.png'
  //                                                             : 'assets/cloud_sun.png',
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       height: 15,
  //                     ),
  //                     Text(
  //                       '$myLocation',
  //                       style: TextStyle(
  //                           fontSize: 36,
  //                           fontWeight: FontWeight.w400,
  //                           color: Color.fromARGB(255, 255, 255, 255)),
  //                     ),
  //                     SizedBox(
  //                       height: 15,
  //                     ),
  //                     Text(
  //                       '$day',
  //                       style: TextStyle(
  //                           fontSize: 18,
  //                           fontWeight: FontWeight.w400,
  //                           color: Color.fromARGB(255, 255, 255, 255)),
  //                     ),
  //                     SizedBox(
  //                       height: 15,
  //                     ),
  //                     Text(
  //                       '$temp°',
  //                       style: TextStyle(
  //                           fontSize: 72,
  //                           fontWeight: FontWeight.w700,
  //                           color: Color.fromARGB(255, 255, 255, 255)),
  //                     ),
  //                     SizedBox(
  //                       height: 15,
  //                     ),
  //                     Text(
  //                       '$climateDescription',
  //                       style: TextStyle(
  //                           fontSize: 18,
  //                           fontWeight: FontWeight.w400,
  //                           color: Color.fromARGB(255, 255, 255, 255)),
  //                     ),
  //                     SizedBox(
  //                       height: 15,
  //                     ),
  //                     Container(
  //                       width:
  //                           350, // ตั้งค่าความกว้างที่คุณต้องการให้ Divider มี
  //                       child: Divider(
  //                         color: Colors.white,
  //                         thickness: 2,
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       height: 30,
  //                     ),
  //                     Padding(
  //                       padding: const EdgeInsets.only(left: 30),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         children: [
  //                           Transform.rotate(
  //                             angle: deg * math.pi / 180,
  //                             child: Icon(
  //                               Icons.navigation,
  //                               color: Colors.white,
  //                               size: 40,
  //                             ),
  //                           ),
  //                           SizedBox(width: 10),
  //                           Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 '$speed km/h',
  //                                 style: TextStyle(
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.w400,
  //                                   color: Colors.white,
  //                                 ),
  //                               ),
  //                               Text(
  //                                 'Wind',
  //                                 style: TextStyle(
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.w400,
  //                                   color: Colors.white,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                           SizedBox(width: 50),
  //                           Icon(
  //                             Icons.water_drop_outlined,
  //                             color: Colors.white,
  //                             size: 40,
  //                           ),
  //                           SizedBox(width: 10),
  //                           Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 '$humidity %',
  //                                 style: TextStyle(
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.w400,
  //                                   color: Colors.white,
  //                                 ),
  //                               ),
  //                               Text(
  //                                 'Humidity',
  //                                 style: TextStyle(
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.w400,
  //                                   color: Colors.white,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(height: 20),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Icon(
  //                           Icons.thermostat,
  //                           color: Colors.white,
  //                           size: 40,
  //                         ),
  //                         SizedBox(width: 10),
  //                         Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text(
  //                               '$pressure mbar',
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.w400,
  //                                 color: Colors.white,
  //                               ),
  //                             ),
  //                             Text(
  //                               'Pressure',
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.w400,
  //                                 color: Colors.white,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         SizedBox(width: 50),
  //                         Icon(
  //                           Icons.swap_vert,
  //                           color: Colors.white,
  //                           size: 40,
  //                         ),
  //                         SizedBox(width: 10),
  //                         Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text(
  //                               '$sunrise sunrise',
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.w400,
  //                                 color: Colors.white,
  //                               ),
  //                             ),
  //                             Text(
  //                               '$sunset sunset',
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.w400,
  //                                 color: Colors.white,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Color.fromARGB(255, 111, 190, 255),
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (weatherData != null && weatherData!.days.isNotEmpty) {
      return Scaffold(
        backgroundColor: Color.fromARGB(255, 111, 190, 255),
        appBar: AppBar(
          title: TextField(
            controller: myController,
            onSubmitted: (value) {
              fetchDataByCityName(value);
              myController.clear();
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
          child: ListView.builder(
            itemCount: weatherData!.days.length,
            itemBuilder: (context, index) {
              WeatherDay dayData = weatherData!.days[index];
              return ListTile(
                title: Text(
                    '${DateFormat('EEEE').format(DateTime.fromMillisecondsSinceEpoch(dayData.dt * 1000))}'),
                subtitle: Text('${dayData.main}'),
                leading: CircleAvatar(
                  // The condition of the image should be replaced with a real condition
                  backgroundImage: AssetImage(dayData.main.contains("Cloud")
                      ? 'assets/iconsstatus/cloud.png'
                      : 'assets/iconsstatus/sunny.png'),
                ),
                trailing: Text('${dayData.temp.toInt()}°'),
              );
            },
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Color.fromARGB(255, 111, 190, 255),
        body: Center(child: Text("No weather data available")),
      );
    }
  }
}
