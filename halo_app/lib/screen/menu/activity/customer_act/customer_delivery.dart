import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:halo_app/screen/map/routing.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../providers/user_data.dart';
import '../../../../services/database_service.dart';
import '../../../../shared/widget.dart';
import '../../../home/detailTripCustomer.dart';
import 'car_on_move.dart';

class CustomerDelivery extends StatefulWidget {
  const CustomerDelivery({Key? key}) : super(key: key);

  @override
  State<CustomerDelivery> createState() => _CustomerDeliveryState();
}

class _CustomerDeliveryState extends State<CustomerDelivery> {
  DatabaseService databaseService = DatabaseService();
  bool _isLoading = true;

  @override
  void initState(){
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isLoading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    userData.getUserData();
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.3),
      body: _isLoading ?  const Center(child:  CircularProgressIndicator(color: Colors.white, strokeWidth: 10)):
      FutureBuilder(
            future: databaseService.goodsCollection.where('uid', isEqualTo: userData.uid).get(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if(!snapshot.hasData || snapshot.hasError){
                return const SizedBox();
              }else{
                List<DocumentSnapshot> documents = snapshot.data.docs;
                return documents.isEmpty ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 160),
                  child:  Text("You don't have any deliveries", style: TextStyle(fontSize: 20, color: Colors.white)),
                ):
                  SingleChildScrollView(
                    child: Container(
                      height: 400,
                      child: Padding(
                      padding: const EdgeInsets.all(10.0),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount:  documents.length,
                          itemBuilder: (context, index){
                            DocumentSnapshot doc = documents[index];
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: FutureBuilder(
                                  future: databaseService.tripCollection.where('tripId', isEqualTo: doc['tripId']).get(),
                                  builder: (BuildContext context, snapshot){
                                    if(!snapshot.hasData || snapshot.hasError){
                                      return const SizedBox();
                                    }else{
                                        DocumentSnapshot trip;
                                        // snapshot.data!.docs.length == 1 ?  trip = snapshot.data!.docs[0] :
                                        // trip = snapshot.data!.docs[index];
                                        trip = snapshot.data!.docs[0];
                                        DateTime date = trip['date'].toDate();
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(color: Colors.white),
                                            color: Colors.white
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('${date.day}/${date.month}/${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(color: Colors.cyan, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                                                ),
                                                trip['isStarted'] && !trip['isFinished'] ? const Text('Delivering',style:TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange)) :
                                                Text('${doc['status']}',
                                                    style:TextStyle(fontSize: 15, fontWeight: FontWeight.bold,fontFamily: 'Outfit', color: doc['status'] != 'Approved' ? Colors.red : Colors.green)),
                                                trip['isStarted'] && trip['isFinished'] ? Text(doc['isDelivery'] ? 'Shipped' : 'Not delivery',
                                                    style:TextStyle(fontSize: 15, fontWeight: FontWeight.bold,fontFamily: 'Outfit', color: doc['isDelivery'] ? Colors.green : Colors.red)) : const SizedBox(),
                                              ],
                                            ),
                                            Text('${doc['description']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                            Text('From ${trip['start'].split(',')[0]} to ${trip['end'].split(',')[0]}',style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                            Text('Receiver: ${doc['phone']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      );

                                    }
                                  }),
                            );
                          }
                      ),
                ),
                    ),
                  );

              }

            },


        ),


    );
  }
}
