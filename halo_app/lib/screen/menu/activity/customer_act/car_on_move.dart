import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:halo_app/providers/car_data.dart';
import 'package:halo_app/providers/user_data.dart';
import 'package:halo_app/screen/home/detail_trip.dart';
import 'package:halo_app/screen/map/routing.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:halo_app/shared/widget.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../providers/trip_data.dart';

class CarOnMove extends StatefulWidget {
  const CarOnMove({Key? key, required this.tripId, required this.driverId}) : super(key: key);
  final String tripId;
  final String driverId;
  @override
  State<CarOnMove> createState() => _CarOnMoveState();
}

class _CarOnMoveState extends State<CarOnMove> {
  User? user= FirebaseAuth.instance.currentUser;
  LatLng position = LatLng(0, 0);
  LatLng destination = LatLng(0, 0);
  LatLng driverPosition = LatLng(0, 0);
  DatabaseService databaseService = DatabaseService();
  void getUserData() async{
   QuerySnapshot snapshot = await databaseService.gettingUserData(user!.uid);
    setState(() {
      double p1 = snapshot.docs[0].get('position').latitude;
      double p2 = snapshot.docs[0].get('position').longitude;
      double d1 = snapshot.docs[0].get('destination').latitude;
      double d2 = snapshot.docs[0].get('destination').longitude;
      position = LatLng(p1, p2);
      destination = LatLng(d1, d2);
    });
  }

  void getDriverPosition() async{
    QuerySnapshot snapshot = await databaseService.gettingUserData(widget.driverId);
    setState(() {
      double p1 = snapshot.docs[0].get('position').latitude;
      double p2 = snapshot.docs[0].get('position').longitude;
      driverPosition = LatLng(p1, p2);
    });
  }

  @override
  void initState(){
    super.initState();
    getUserData();
    getDriverPosition();
  }

  @override
  Widget build(BuildContext context) {
    TripData tripData = Provider.of<TripData>(context);
    tripData.getDetailTrip(widget.tripId);
    CarData carData = Provider.of<CarData>(context);
    carData.getCarInfo(tripData.driverId);

    return Scaffold(
      appBar:  AppBar(
          backgroundColor: Colors.cyan,
          title:Row(
            children: const [
              Text('Car on move', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 40),
            onPressed: (){
              Navigator.pop(context);
            },
          )
      ),
      body: DefaultTextStyle(
        style: const TextStyle(fontFamily: 'Roboto', color: Colors.black),
        child: Container(
          padding: const EdgeInsets.all(5),
              child: DetailedTrip(tripId: tripData.tripId)
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          nextScreen(context, MapRouting(customerPosition: position, destination: destination, driverPosition: driverPosition));
          // showToast('$position, $destination, $driverPosition', Colors.black);
        },
        child: const Icon(Icons.map_outlined),
      ),
    );
  }
}
