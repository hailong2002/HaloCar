import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:halo_app/screen/home/rateWidget.dart';
import 'package:halo_app/screen/menu/activity/driver_act/waitingScreen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/trip_data.dart';
import '../../providers/user_data.dart';
import '../../services/database_service.dart';
import '../../shared/loading.dart';
import '../../shared/widget.dart';
import '../map/maps.dart';
import '../menu/activity/driver_act/edit_trip.dart';
import '../menu/activity/driver_act/memberAndGoods.dart';

class DetailedTrip extends StatefulWidget {
  const DetailedTrip({Key? key,required this.tripId}) : super(key: key);
  final String tripId;


  @override
  State<DetailedTrip> createState() => _DetailedTripState();
}

class _DetailedTripState extends State<DetailedTrip> {

  bool _isLoading = true;
  User? user = FirebaseAuth.instance.currentUser;
  DatabaseService databaseService = DatabaseService();
  double price = 0;
  String distance = '';
  void getDistance() async{
    try{
    String distance = await databaseService.getDistance(user!.uid);
    double distanceParse = double.parse(distance);
    setState(() {
      price = 0.5*distanceParse;
      this.distance = distance;
    });}
    catch (e){
        return;
    }
  }

  @override
  void initState(){
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isLoading = false;
      });
    });
    getDistance();
  }
  @override
  Widget build(BuildContext context) {
    TripData tripData = Provider.of<TripData>(context);
    tripData.getDetailTrip(widget.tripId);
    UserData userData = Provider.of<UserData>(context);
    userData.getUserData();
    return _isLoading ? const Loading() :  SingleChildScrollView(
        child: FutureBuilder(
          future: Future.wait({
            databaseService.gettingUserData(tripData.driverId),
            databaseService.getCarInfo(tripData.driverId),
          }),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if(!snapshot.hasData){
              return const Text('', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white));
            }
            if(snapshot.connectionState == ConnectionState.active){
              return const CircularProgressIndicator();
            }
            else{
              List<dynamic> results = snapshot.data!;
              DocumentSnapshot doc0 = results[0].docs[0];
              DocumentSnapshot doc1 = results[1].docs[0];
              return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: Colors.red),
                              const SizedBox(width: 5),
                              Flexible(child: Text(userData.position, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                              IconButton(
                                onPressed: (){nextScreen(context, SetLocation(isSetLocation: true, position: userData.position));},
                                icon:const Icon(Icons.edit_outlined, color: Colors.cyan
                                ),
                              )
                            ],
                          ),
                          userData.role == 'driver' ?  const SizedBox() :
                          Row(
                            children: [
                              const Icon(Icons.drive_eta_rounded, color: Colors.blueAccent),
                              const SizedBox(width: 5),
                              Flexible(child: Text(userData.destination, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                              IconButton(
                                onPressed: (){nextScreen(context, SetLocation(isSetLocation: false, position: userData.destination));},
                                icon:const Icon(Icons.edit_outlined, color: Colors.cyan
                                ),
                              )
                            ],
                          ),
                          const Divider(color: Colors.grey, thickness: 0.8),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Driver's name: ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${doc0['fullName']}', style: const TextStyle(fontSize: 18),)
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text("Phone number: ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${doc0['phoneNumber']}', style: const TextStyle(fontSize: 18),)
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text('License plates: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${doc1['licensePlate']}', style: const TextStyle(fontSize: 18),)
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text('Car: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${doc1['brand']} ${doc1['model']}, color: ${doc1['color']}', style: const TextStyle(fontSize: 18),)
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text('Start at: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(tripData.startPoint, style: const TextStyle(fontSize: 18),)
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text('To: ',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(tripData.endPoint, style: const TextStyle(fontSize: 18 ))
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text('Depart at: ',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${DateFormat.EEEE().format(tripData.date)}, ${DateFormat.MMMM().format(tripData.date)} ${tripData.date.day}, ${tripData.date.year}',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text('Rolling time: ',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${tripData.date.hour.toString().padLeft(2, '0')}:${tripData.date.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 18))
                        ],
                      ),
                      const Text('(Time when the driver starts picking up passengers)', style: TextStyle( fontWeight: FontWeight.bold),),
                      Row(
                        children: [
                          const Text('Available seats in the car: ',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${tripData.slot}/${doc1['seat']}', style: const TextStyle(fontSize: 18))
                        ],
                      ),
                      const SizedBox(height: 5),
                      userData.role == 'driver' ? const SizedBox() :
                      Row(
                        children: [
                          const Text('Price (usd): ',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('$price', style: const TextStyle(fontSize: 18))
                        ],
                      ),
                      const SizedBox(height: 5),
                      userData.role == 'driver' ? const SizedBox() :
                      Row(
                        children: [
                          const Text('Distance (km): ',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(distance, style: const TextStyle(fontSize: 18))
                        ],
                      ),
                      const SizedBox(height: 10)
                    ],
                  )

              );
            }
          },
        ),

    );
  }
}
