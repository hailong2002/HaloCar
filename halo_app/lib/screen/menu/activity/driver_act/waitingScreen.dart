import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:halo_app/providers/helperData.dart';
import 'package:halo_app/providers/user_data.dart';

import 'package:halo_app/services/database_service.dart';
import 'package:halo_app/shared/widget.dart';
import 'package:provider/provider.dart';

import '../../../../providers/trip_data.dart';
import '../../../../shared/loading.dart';


class WaitingScreen extends StatelessWidget {
  const WaitingScreen({Key? key, required this.tripId}) : super(key: key);
  final String tripId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
          backgroundColor: Colors.cyan,
          title:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:const [
              Text('Waiting list', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              Text('Customers want to join your trip',style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 40),
            onPressed: (){
              Navigator.pop(context);
            },
          )
      ),
      body: DefaultTabController(
        length:  2 ,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.cyan.withOpacity(0.8),
              width: 500,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 10),
                child: ButtonsTabBar(
                  contentPadding: const EdgeInsets.all(5),
                  backgroundColor: Colors.amber[800],
                  unselectedBackgroundColor: Colors.white,
                  unselectedLabelStyle: const TextStyle(color: Colors.cyan, fontSize: 17, fontWeight: FontWeight.bold),
                  labelStyle:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  tabs:const [
                    Tab(
                      icon: Icon(Icons.group),
                      text: "Passenger",
                    ),
                    Tab(
                      icon: Icon(Icons.propane_tank_outlined),
                      text: "Delivery",
                    ),
                  ]
                ),
              ),
            ),

                SizedBox(
                  height: 456,
                  width: 500,
                  child:
                      TabBarView(
                        children: [
                          WaitingListPassenger(tripId: tripId),
                          ListGoodsWaiting(tripId: tripId)

                    ],
                  ),

            ),
          ],
        ),
      ),
    );
  }
}


class WaitingListPassenger extends StatefulWidget {
  const WaitingListPassenger({Key? key, required this.tripId}) : super(key: key);
  final String tripId;

  @override
  State<WaitingListPassenger> createState() => _WaitingListPassengerState();
}

class _WaitingListPassengerState extends State<WaitingListPassenger> {
  DatabaseService databaseService = DatabaseService();
  bool _isLoading = true;
  Color color = Colors.black;

  @override
  void initState(){
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isLoading = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    TripData tripData = Provider.of<TripData>(context);
    tripData.getDetailTrip(widget.tripId);
    return Scaffold(
        backgroundColor: Colors.cyan.withOpacity(0.8),
        body: _isLoading ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 4.0)) :
        Padding(
            padding: const EdgeInsets.all(10.0),
            child: tripData.waiting.isEmpty ? const Center(child: Text("There's no one in waiting list", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white))) :
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 420,
                  child: ListView.builder(
                    itemCount: tripData.waiting.length,
                    itemBuilder: (BuildContext context, index) {
                      return  FutureBuilder(
                        future: databaseService.gettingUserData(tripData.waiting[index]),
                        builder: (BuildContext context, snapshot) {
                          if(!snapshot.hasData){
                            return  const Text('', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white));
                          }
                          else{
                            DocumentSnapshot doc = snapshot.data.docs[0];
                            return FutureBuilder(
                                future: Future.wait({
                                  DataHelper.getAddressFromGeoPoint(doc['position']),
                                  DataHelper.getAddressFromGeoPoint(doc['destination']),
                                  databaseService.getDistance(tripData.waiting[index])
                                }),
                                builder: (context, snapshot){
                                  if(!snapshot.hasData){
                                    return  const Text('', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white));
                                  }
                                  else{
                                    String position = snapshot.data![0];
                                    String destination = snapshot.data![1];
                                    String distance = snapshot.data![2];
                                    double km = double.parse(distance);
                                    double price = km*0.5;
                                    return
                                      Column(
                                              children:[
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 270,
                                                      padding: const EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          color: Colors.white
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                  child: Text('${index+1}. ${doc['fullName']}  ${doc['phoneNumber']}',
                                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))
                                                              ),
                                                            ],
                                                          ),
                                                          Text('Price: ${price.toStringAsFixed(2)} usd', style: const TextStyle(fontSize: 15)),
                                                          Text('Position: $position', style: const TextStyle(fontSize: 15)),
                                                          Text('Go: $destination', style: const TextStyle(fontSize: 15)),
                                                        ],
                                                      ),

                                                    ),
                                                    const SizedBox(width: 15),
                                                    Container(
                                                      height: 97,
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(height: 7),
                                                          SizedBox(
                                                            width: 75,
                                                            height: 40,
                                                            child: ElevatedButton(
                                                                onPressed: (){
                                                                  setState(() {
                                                                    color = Colors.red;
                                                                    databaseService.denyCustomer(doc['uid'], tripData.tripId);
                                                                  });
                                                                  showToast('Deny member', Colors.red);
                                                                },
                                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                                                child: const Icon(Icons.clear, color: Colors.red)
                                                            ),
                                                          ),
                                                          const SizedBox(height: 3),
                                                          SizedBox(
                                                            width: 75,
                                                            height: 40,
                                                            child: ElevatedButton(
                                                                onPressed: (){
                                                                  setState(() {
                                                                    color = Colors.green;
                                                                    databaseService.approveCustomer(doc['uid'], tripData.tripId);
                                                                  });
                                                                  showToast('Approve member', Colors.green);
                                                                },
                                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                                                child: const Icon(Icons.done, color: Colors.blueAccent)
                                                            ),
                                                          ),

                                                        ],
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                                const SizedBox(height: 5),

                                              ]

                                      );


                                  }

                            });

                          }
                        },

                      );
                    },

                  ),
                ),
              ],
            ),
          ),
    );
  }


}

class ListGoodsWaiting extends StatefulWidget {
  const ListGoodsWaiting({Key? key, required this.tripId}) : super(key: key);
  final String tripId;
  @override
  State<ListGoodsWaiting> createState() => _ListGoodsWaitingState();
}

class _ListGoodsWaitingState extends State<ListGoodsWaiting> {

  DatabaseService databaseService = DatabaseService();
  Color color = Colors.black;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan.withOpacity(0.8),
      body: FutureBuilder(
        future: databaseService.goodsCollection.where('tripId', isEqualTo: widget.tripId)
          .where('status', isEqualTo: 'Wait').get(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(!snapshot.hasData || snapshot.hasError){
            return const SizedBox();
          }
          else{
            List<DocumentSnapshot> document = snapshot.data.docs;
            return  document.isEmpty ?
            const Center(child: Text("There's no delivery", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))):
            ListView.builder(
                itemCount: document.length,
                itemBuilder: (context, index){
                  DocumentSnapshot doc = document[index];
                  return FutureBuilder(
                    future: databaseService.getDistance(doc['uid']),
                    builder: (context, snapshot){
                      if(!snapshot.hasData){
                        return const SizedBox();
                      }else{
                        String distance = snapshot.data!;
                        double km = double.parse(distance);
                        double price = km*0.5;
                        return  Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: (){
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context){
                                          return  AlertDialog(
                                            title: const Text('Details', style: TextStyle(color: Colors.cyan, fontSize: 25)),
                                            content: SizedBox(
                                              height: 220,
                                              child: DefaultTextStyle(
                                                style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.black, fontSize: 17),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('From ${doc['position'].split(',')[0]} to ${doc['destination'].split(',')[0]}.',
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', fontSize: 18),
                                                    ),
                                                    Text("Receiver's phone number: ${doc['phone']}."),
                                                    Text('${doc['payMethod']}.'),
                                                    Text('$km km.'),
                                                    Text('Price: ${price.toStringAsFixed(2)} usd'),
                                                    Text('Goods: ${doc['description']}.'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    width:220,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: Colors.white),
                                        color: Colors.white
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${index+1}. Receiver: ${doc['phone']}',
                                            style: TextStyle( fontSize: 16, color: color)
                                        ),
                                        Text('Goods: ${doc['description']}',
                                          style: TextStyle( fontSize: 17, color: color, overflow: TextOverflow.ellipsis), maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 55,
                                  child: ElevatedButton(
                                      onPressed: (){
                                        setState(() {
                                          color = Colors.red;
                                          databaseService.rejectDelivery(doc['gid']);
                                        });
                                        showToast('Reject goods', Colors.red);
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                      child: const Icon(Icons.clear, color: Colors.red)
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: 55,
                                  child: ElevatedButton(
                                      onPressed: (){
                                        setState(() {
                                          color = Colors.green;
                                          databaseService.approveDelivery(doc['gid']);
                                        });
                                        showToast('Approve goods', Colors.green);
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                      child: const Icon(Icons.done, color: Colors.blueAccent)
                                  ),
                                )
                              ],
                            )

                        );
                      }

                    },

                  );
                }

            );
          }
        },
      ),
    );
  }
}
