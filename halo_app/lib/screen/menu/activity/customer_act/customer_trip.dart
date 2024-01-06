import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:halo_app/providers/user_data.dart';
import 'package:halo_app/screen/menu/activity/customer_act/car_on_move.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:halo_app/shared/widget.dart';
import 'package:provider/provider.dart';


import '../../../home/detailTripCustomer.dart';

class CustomerTrip extends StatefulWidget {
  const CustomerTrip({Key? key}) : super(key: key);

  @override
  State<CustomerTrip> createState() => _CustomerTripState();
}

class _CustomerTripState extends State<CustomerTrip> {
  DatabaseService databaseService = DatabaseService();
  bool _isLoading = true;
  List<String> waiting = [];
  List<String> canceledTrip = [];
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState(){
    super.initState();
    getDistance();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isLoading = false;
      });
    });

  }

  double price = 0;
  String distance = '';
  void getDistance() async{
    try{
      String distance = await databaseService.getDistance(user!.uid);
      double distanceParse = double.parse(distance) ?? 0;
      setState(() {
        price = 0.5*distanceParse;
        this.distance = distance;
      });
    } catch (e){
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    userData.getUserData();
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.3),
      body: _isLoading ?  const Center(child:  CircularProgressIndicator(color: Colors.white, strokeWidth: 10)):
      SizedBox(
        height: 400,
        child: userData.trips.isEmpty ? const Center(child: Text("You don't have any trips.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20))):
        ListView.builder(
          padding: const EdgeInsets.all(0),
            itemCount: userData.trips.length,
            itemBuilder: (context, index){
              return FutureBuilder<QuerySnapshot>(
                  future: databaseService.tripCollection.where('tripId', isEqualTo:userData.trips[index]).get(),
                  builder: (context, snapshot){
                    if(!snapshot.hasData){
                      return const SizedBox();
                    } else{
                      DocumentSnapshot trip = snapshot.data!.docs[0];
                      DateTime date = trip['date'].toDate();
                      return FutureBuilder(
                          future: databaseService.getCarInfoByCarId(trip['carId']),
                          builder:(context, snapshot){
                            if(!snapshot.hasData){
                              return const SizedBox();
                            }else {
                              DocumentSnapshot doc = snapshot.data!;
                              return  InkWell(
                                onTap: (){
                                  if(trip['isStarted'] && !trip['isFinished']){
                                    nextScreen(context, CarOnMove(tripId: trip['tripId'], driverId: trip['driverId']));
                                  }else{
                                    nextScreen(context, DetailTripOfCustomer(tripId: trip['tripId']));
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                      children:[
                                        Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(15)
                                        ),
                                        child: SizedBox(
                                          height: 160,
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
                                                    Text('${trip['slot']}/${doc['seat']}',  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                    // Text('Cancel', style: TextStyle(color: Colors.redAccent))
                                                  ],
                                                ),
                                                const Divider(color: Colors.cyan, thickness: 0.8),
                                                RichText(
                                                  text: TextSpan(
                                                      text: ' License plates:',
                                                      style:  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                                      children: [
                                                        TextSpan(text: ' ${doc['licensePlate']}',
                                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyan)
                                                        )
                                                      ]
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(Icons.price_change, color: Colors.lightGreen[600]),
                                                    Text(" $price usd",
                                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,)
                                                    ),
                                                    const SizedBox(width: 10),
                                                  ],
                                                ),
                                                const Divider(color: Colors.cyan, thickness: 0.8),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.drive_eta_rounded, color: Colors.blueAccent,),
                                                    const SizedBox(width: 10),
                                                    SizedBox(
                                                      width: 120,
                                                      child: Text('${trip['start'].split(',')[0]}',
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                    ),
                                                    const Icon(Icons.location_pin, color: Colors.redAccent),
                                                    const SizedBox(width: 10),
                                                    SizedBox(
                                                      width: 120,
                                                      child: Text('${trip['end'].split(',')[0]}',
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
                                        trip['isFinished'] ?
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            color: Colors.white.withOpacity(0.8),
                                            width:360 ,
                                            height: 140,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: const[
                                                Text('This trip was finished.',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold, fontSize: 20, color: Colors.cyan
                                                  ),
                                                ),
                                                Text('Please leave a review of the trip',style: TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 20,color: Colors.cyan
                                                ),
                                                ),
                                                Icon(Icons.star, color: Colors.yellow, size: 25 ),

                                              ],

                                            ),
                                          ),
                                        ) : const SizedBox(),
                                        trip['isStarted'] && trip['member'].contains(userData.uid) ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            color: Colors.white.withOpacity(0.9),
                                            width:360 ,
                                            height: 140,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: const[
                                                Text('The driver is on the move',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold, fontSize: 20, color: Colors.orange
                                                  ),
                                                ),
                                                Text('Click to see details',style: TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 20,color: Colors.orange
                                                ),
                                                ),
                                                Icon(Icons.drive_eta_rounded, color: Colors.orange, size: 25 ),

                                              ],

                                            ),
                                          ),
                                        ): const SizedBox(),
                                        trip['waiting'].contains(userData.uid) ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            color: Colors.white.withOpacity(0.8),
                                            width:360 ,
                                            height: 140,
                                            child:const Center(
                                              child:Text("Waiting for driver's response",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 20, color: Colors.cyan
                                                ),
                                              ),
                                            ),
                                          ),
                                        ) : const SizedBox(),
                                        userData.canceledTrip.contains(trip['tripId']) ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            color: Colors.white.withOpacity(0.8),
                                            width:360 ,
                                            height: 140,
                                            child:const Center(
                                              child:Text("You canceled this trip",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red
                                                ),
                                              ),
                                            ),
                                          ),
                                        ) : const SizedBox()
                                      ]
                                  ),
                                ),
                              );
                            }
                          }
                      );

                    }
              });
        }),
      ),

    );
  }
}