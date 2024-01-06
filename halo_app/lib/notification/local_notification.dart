import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'noti.dart';

class LocalNotification extends StatefulWidget {
  const LocalNotification({Key? key}) : super(key: key);

  @override
  State<LocalNotification> createState() => _LocalNotificationState();
}

class _LocalNotificationState extends State<LocalNotification> {

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    Noti.initialize(flutterLocalNotificationsPlugin);
    Future.delayed(const Duration(milliseconds: 3000), () {
      // Noti.showBigTextNotification(
      //     title: 'Good evening',
      //     body: "You're in waiting list. Wait for driver response",
      //     fln: flutterLocalNotificationsPlugin
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: ElevatedButton(
            onPressed: (){
              Noti.showBigTextNotification(
                  title: 'Good evening',
                  body: "You're in waiting list. Wait for driver response",
                  fln: flutterLocalNotificationsPlugin
              );
            },
            child: Text('Push'),
          ),
        ),
      ),
    );
  }
}
