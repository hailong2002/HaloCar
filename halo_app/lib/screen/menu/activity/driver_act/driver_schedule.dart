import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:halo_app/providers/trip_data.dart';
import 'package:halo_app/providers/user_data.dart';
import 'package:halo_app/screen/home/detailTripCustomer.dart';
import 'package:halo_app/screen/menu/activity/driver_act/createTrip.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:provider/provider.dart';

import '../../../../notification/noti.dart';
import '../../../../shared/loading.dart';
import '../../../../shared/widget.dart';
import '../../../home/detail_driver_trip.dart';

class DriverSchedule extends StatefulWidget {
  const DriverSchedule({Key? key}) : super(key: key);

  @override
  State<DriverSchedule> createState() => _DriverScheduleState();
}

class _DriverScheduleState extends State<DriverSchedule> {

  User? user = FirebaseAuth.instance.currentUser;
  DatabaseService databaseService = DatabaseService();

  List<String> driverTrips = [];
  int result = 0;
  int initNum = 0;
  Future getDriverTrips(String driverId) async{
    QuerySnapshot snapshot = await databaseService.tripCollection.where('driverId', isEqualTo: driverId).get();
    for(var doc in snapshot.docs){
      String id = doc.get('tripId');
      driverTrips.add(id);
      for(var id in driverTrips){
        QuerySnapshot snapshot = await databaseService.tripCollection.where('tripId', isEqualTo: id).get();
        int num = snapshot.docs[0].get('waiting').length;
        if(initNum != num){
          Noti.initialize(flutterLocalNotificationsPlugin);
          Noti.showBigTextNotification(
              title: initNum < num ? 'Customer book your trip' : 'Customer cancel your trip',
              body: "Check your waiting list.",
              fln: flutterLocalNotificationsPlugin
          );
          setState(() {
            initNum = num;
          });

        }
      }
    }

  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _isLoading = true;
  @override
  void initState(){
    super.initState();
    getDriverTrips(user!.uid);
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _isLoading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white.withOpacity(0.3),
      body:  Column(
          children: [
            const Divider(color: Colors.white, thickness: 1),
            Row(
              children: [
                const Text(' Create new trip:', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: IconButton(
                      onPressed: ()async{
                        nextScreen(context, const CreateTrip());
                      },
                      icon: const Icon(Icons.add_circle, size: 30, color: Colors.white),
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              child: _isLoading ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 10,)): SizedBox(
                height: 330,
                child: StreamBuilder(
                  stream: databaseService.tripCollection.where('driverId', isEqualTo: user!.uid).snapshots(),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData ) {
                      return const SizedBox();
                    }else{
                      List<DocumentSnapshot> documents = snapshot.data!.docs;
                      return documents.isEmpty ? const Center(child: Text("You do not have any trips.\n          Let's create one", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))) :
                      ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: documents.length ,
                          itemBuilder: (context, index){
                            DocumentSnapshot doc0 = documents[index];
                            DateTime date = doc0['date'].toDate();
                            return FutureBuilder(
                                future: databaseService.getCarInfo(user!.uid),
                                builder: (context, snapshot){
                                  if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (!snapshot.hasData ) {
                                      return const SizedBox();
                                    }else{
                                      DocumentSnapshot doc1 = snapshot.data!.docs[0];
                                      return  InkWell(
                                          onTap: (){
                                            nextScreen(context, DetailTripOfDriver(tripId: doc0['tripId']));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Stack(
                                                children:[ Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(15)
                                                  ),
                                                  child: SizedBox(
                                                    height: 140,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Icon(Icons.date_range_sharp, color: Colors.amber[700]),
                                                              Text(' ${date.day}/${date.month}/${date.year} ',
                                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                              const SizedBox(width: 10),
                                                              Icon(Icons.timer_outlined, color: Colors.amber[700]),
                                                              Text(' ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                              const SizedBox(width: 15),
                                                              Icon(Icons.airline_seat_recline_normal_sharp,  color: Colors.amber[700]),
                                                              Text('${doc0['slot']}/${doc1['seat']}',  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                                                            ],
                                                          ),
                                                          const Divider(color: Colors.cyan, thickness: 0.8),
                                                          RichText(
                                                            text: TextSpan(
                                                                text: ' License plates:',
                                                                style:  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                                                children: [
                                                                  TextSpan(text: ' ${doc1['licensePlate']}',
                                                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyan)
                                                                  )
                                                                ]
                                                            ),
                                                          ),
                                                          const SizedBox(height: 6),
                                                          const Divider(color: Colors.cyan, thickness: 0.8),
                                                          Row(
                                                            children: [
                                                              const Icon(Icons.drive_eta_rounded, color: Colors.blueAccent,),
                                                              const SizedBox(width: 10),
                                                              SizedBox(
                                                                width: 120,
                                                                child: Text('${doc0['start'].split(',')[0]}',
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                              ),
                                                              const Icon(Icons.location_pin, color: Colors.redAccent),
                                                              const SizedBox(width: 10),
                                                              SizedBox(
                                                                width: 120,
                                                                child: Text('${doc0['end'].split(',')[0]}',
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 5),

                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                  doc0['isFinished'] ?
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Container(
                                                      color: Colors.white.withOpacity(0.9),
                                                      width:360 ,
                                                      height: 120,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          const Text('Finished,',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.cyan
                                                            ),
                                                          ),
                                                          Text(doc0['averageRating'] != 0 ? 'your rate: ${doc0['averageRating']}':"there's no review yet.",style: const TextStyle(
                                                              fontWeight: FontWeight.bold, fontSize: 20,color: Colors.cyan
                                                          ),
                                                          ),
                                                          doc0['averageRating'] != 0 ? const Icon(Icons.star, color: Colors.yellow, size: 22 ) :
                                                          const SizedBox(),

                                                        ],

                                                      ),
                                                    ),
                                                  )
                                                      : const SizedBox()

                                                ]
                                            ),
                                          ),
                                        );
                                  }
                                }
                            );
                          }
                      );
                    }
                  },
                )

              ),
            ),
          ],
        ),
    );
  }
}
