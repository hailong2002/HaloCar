
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:halo_app/providers/car_data.dart';
import 'package:halo_app/providers/pay_data.dart';
import 'package:halo_app/providers/trip_data.dart';
import 'package:halo_app/providers/user_data.dart';
import 'package:halo_app/screen/authentication/login.dart';
import 'package:halo_app/screen/home/rateWidget.dart';

import 'package:halo_app/screen/map/maps.dart';
import 'package:halo_app/screen/map/routing.dart';
import 'package:halo_app/screen/map/tracking.dart';
import 'package:halo_app/screen/menu/account_menu/become_driver.dart';
import 'package:halo_app/screen/menu/account_menu/car_info.dart';
import 'package:halo_app/screen/menu/account_menu/register.dart';
import 'package:halo_app/screen/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:halo_app/screen/home.dart';
import 'package:halo_app/screen/menu/activity/activity.dart';

import 'package:halo_app/screen/menu/pay/payOnline.dart';
import 'package:halo_app/screen/menu/pay/paypalWebview.dart';
import 'package:halo_app/shared/loading.dart';
import 'package:halo_app/shared/splash_screen.dart';
import 'package:halo_app/helper/helper_function.dart';
import 'package:halo_app/shared/widget.dart';
import 'package:provider/provider.dart';
import 'package:halo_app/notification/local_notification.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => UserData()),
      ChangeNotifierProvider(create: (context) => TripData()),
      ChangeNotifierProvider(create: (context) => CarData()),
      ChangeNotifierProvider(create: (context) => PayData()),
    ],
        child: const MyApp()
    )
  );

}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;

  @override void initState() {
    super.initState();
    setState(() {
      getUserLoggedInStatus();
    });
  }

  getUserLoggedInStatus() async{
    await HelperFunction.getUserLoggedInStatus().then((value) {
      if (value != null){
        setState(() {
          _isSignedIn = value;
        });
        print(_isSignedIn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home:   _isSignedIn ?  const Home() : const  LogIn()
      // home: Home(),


    );
  }


}










