import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:por_weather/view/error/ErrorPage.dart';

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

  // void checkGPS() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //   setState(() {
  //     isLoading = true;
  //   });
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // GPS is off, show alert
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('GPS is off'),
  //           // content: Text('Please turn on GPS to use this application.'),
  //           content: Text('เปิด GPS สิไอฟาย'),
  //           actions: [
  //             TextButton(
  //               child: Text('OK'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();

  //                 // setState(() {
  //                 //   isLoading = false;
  //                 // });
  //                 // fetchData();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //     return;
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //       'Location permissions are permantly denied, we cannot request permissions.',
  //     );
  //   }

  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission != LocationPermission.whileInUse &&
  //         permission != LocationPermission.always) {
  //       return Future.error(
  //         'Location permissions are denied (actual value: $permission).',
  //       );
  //     }
  //   }
  // }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      LocationPermission permission;
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.',
        );
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return Future.error(
            'Location permissions are denied (actual value: $permission).',
          );
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('11111');
      print(position);
      print('222222222');
      double latitude = position.latitude;
      double longitude = position.longitude;

      double testLat = 55;
      double testLong = 41;

      var url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=8e7cb329abf8bf036cc6f7858110175e&units=metric');
      // 'https://api.openweathermap.org/data/2.5/weather?lat=$testLat&lon=$testLong&appid=8e7cb329abf8bf036cc6f7858110175e&units=metric');

      var res = await http.get(url);

      if (res.statusCode == 200) {
        // ถ้าเซิร์ฟเวอร์ส่งคืนคำตอบ 200 OK, จากนั้นแยก JSON.
        Map<String, dynamic> data = jsonDecode(res.body);

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

          // print(
          //     '------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!---------------------------------');
          // print('Climate Description: $climateDescription');
          // print('Climate: $climate');
          // print('iconStautus: $iconStautus');
          // print('myLocation: $myLocation');
          // print('formattedDate: $formattedDate');
          // print('deg: $deg');
          // print('speed: $speed');
          // print('pressure: $pressure');
          // print(
          //     '------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!---------------------------------');
        });
      }
      if (res.statusCode == 400 || res.statusCode == 401) {
        print('Error: 400 Jaa!!!!!!!!!!!!!');
      }
    } catch (error) {
      print('Error: $error');
      if (error.toString() ==
              "The location service on the device is disabled." ||
          error.toString() ==
              "User denied permissions to access the device's location.") {
        print('GPS is not enabled');

        // Display a dialog or Snackbar asking the user to enable GPS
        // Or direct the user to their device's location settings

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('GPS is off'),
              content: Text('Please turn on GPS to use this application.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      isLoading = false;
                    });
                    // fetchData();
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => ErrorPage()),
                    // );
                  },
                ),
              ],
            );
          },
        );
      }
    }
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
          // appBar: AppBar(
          //   title: Text('สวัสดี, Flutter!'),
          // ),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
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
                            SizedBox(width: 45),
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
                        ),
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
