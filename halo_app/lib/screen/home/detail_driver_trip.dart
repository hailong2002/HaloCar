import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:halo_app/screen/home/rateWidget.dart';
import 'package:halo_app/screen/menu/activity/driver_act/waitingScreen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../notification/noti.dart';
import '../../providers/trip_data.dart';
import '../../providers/user_data.dart';
import '../../services/database_service.dart';
import '../../shared/loading.dart';
import '../../shared/widget.dart';
import '../menu/activity/driver_act/edit_trip.dart';
import 'detail_trip.dart';
import '../menu/activity/driver_act/memberAndGoods.dart';

class DetailTripOfDriver extends StatefulWidget {
  const DetailTripOfDriver({Key? key,required this.tripId}) : super(key: key);
  final String tripId;

  @override
  State<DetailTripOfDriver> createState() => _DetailTripOfDriverState();
}

class _DetailTripOfDriverState extends State<DetailTripOfDriver> {
  bool _isLoading = true;

  DateTime bookTime = DateTime.now();
  User? user = FirebaseAuth.instance.currentUser;

  DatabaseService databaseService = DatabaseService();
  @override
  void initState(){
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
    });
    Noti.initialize(flutterLocalNotificationsPlugin);
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();


  @override
  Widget build(BuildContext context) {
    TripData tripData = Provider.of<TripData>(context);
    tripData.getDetailTrip(widget.tripId);
    UserData userData = Provider.of<UserData>(context);
    userData.getUserData();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title:Row(
          children: const [
            Text('Trip details', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
            SizedBox(width: 10),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        actions: [
          userData.uid == tripData.driverId && !tripData.isStarted ?
          Row(
            children: [
              IconButton(
                  onPressed: (){
                    nextScreen(context, EditTrip(start: tripData.startPoint, end: tripData.endPoint, tripId: tripData.tripId, amount_customer: tripData.members.length));
                  },
                  icon: const Icon(Icons.edit)
              ),
              IconButton(
                  onPressed: (){
                    showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            title: const Text('Delete trip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.cyan, fontFamily: 'Roboto')),
                            content:const Text('Are you sure want to delete this trip?', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
                            actions: [
                              ElevatedButton(onPressed: (){Navigator.pop(context);},
                                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
                              ElevatedButton(
                                  onPressed: (){
                                    if(tripData.members.isNotEmpty){
                                      Navigator.of(context).pop();
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context){
                                            return const AlertDialog(
                                              title: Text("Cannot delete trip", style: TextStyle(color: Colors.red)),
                                              content: Text("This trip has customers, so you can delete it"),
                                            );
                                          }
                                      );
                                    }else{
                                      Navigator.of(context).pop();
                                      databaseService.deleteTrip(widget.tripId);
                                      Navigator.pop(context);
                                    }

                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                  child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)))
                            ],
                          );
                        }
                    );
                  },
                  icon:const Icon(Icons.delete)
              )
            ],
          ): const SizedBox(),
        ],
      ),
      body:  _isLoading ? const Loading() :
      SingleChildScrollView(
          child: Column(
            children: [
              DetailedTrip(tripId: tripData.tripId),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                                onPressed: (){
                                  nextScreen(context, WaitingScreen(tripId: tripData.tripId));
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                child: const Text('List waiting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)
                            ),
                            const SizedBox(width: 25),
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                                onPressed: (){
                                  nextScreen(context, MemberAndGoods(tripId: tripData.tripId));
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                                child: Row(
                                  children: const [
                                    Text('Member & Good ',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                    // Icon(Icons.groups, size: 25,)
                                  ],
                                )
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                                onPressed: (){
                                  if(tripData.date.day == DateTime.now().day){
                                    databaseService.tripStart(tripData.tripId);
                                    Noti.showBigTextNotification(
                                        title: "Trip's started",
                                        body: "You've started your trip from ${tripData.startPoint.split(',')[0]} to ${tripData.endPoint.split(',')[0]}",
                                        fln: flutterLocalNotificationsPlugin
                                    );
                                  } else{
                                    showToast('Not yet', Colors.red);
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                child:const Text('Start',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                            )
                          ],
                        )
                      ],
                    ),
              )
            ],
          ),

      ),
    );
  }
}
