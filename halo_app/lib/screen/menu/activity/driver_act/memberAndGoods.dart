import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:halo_app/services/database_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../providers/helperData.dart';
import '../../../../providers/trip_data.dart';
import '../../../../shared/widget.dart';
import '../../../map/routing.dart';

class MemberAndGoods extends StatelessWidget {
  const MemberAndGoods({Key? key, required this.tripId}) : super(key: key);
  final String tripId;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:AppBar(
          backgroundColor: Colors.cyan,
          title:const Text('Members and goods of trip', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
              child: TabBarView(
                children: [
                  MemberTrip(tripId: tripId),
                  ListGoodsOfTrip(tripId: tripId)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MemberTrip extends StatefulWidget {
  const MemberTrip({Key? key, required this.tripId}) : super(key: key);
  final String tripId;

  @override
  State<MemberTrip> createState() => _MemberTripState();
}

class _MemberTripState extends State<MemberTrip> {
  DatabaseService databaseService = DatabaseService();
  User? user= FirebaseAuth.instance.currentUser;
  LatLng driverPosition = LatLng(0, 0);

  void getDriverPosition()async{
   QuerySnapshot snapshot = await databaseService.gettingUserData(user!.uid);
   DocumentSnapshot doc = snapshot.docs[0];
    setState(() {
      double p1 = doc.get('position').latitude;
      double p2 = doc.get('position').longitude;
      driverPosition = LatLng(p1, p2);
    });
  }

  @override
  void initState(){
    super.initState();
    getDriverPosition();
  }

  @override
  Widget build(BuildContext context) {
    TripData tripData = Provider.of<TripData>(context);
    tripData.getDetailTrip(widget.tripId);
    return Scaffold(
      body: tripData.members.isEmpty ? const Center(child: Text("There's no one on this trip", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyan))):
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: tripData.members.length,
                  itemBuilder: (BuildContext context, index) {
                    return  FutureBuilder(
                      future: databaseService.gettingUserData(tripData.members[index]),
                      builder: (BuildContext context, snapshot) {
                        if(!snapshot.hasData){
                          return const Text('...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
                        }else{
                          DocumentSnapshot doc = snapshot.data.docs[0];
                          LatLng point1 = LatLng(doc['position'].latitude, doc['position'].longitude);
                          LatLng point2 = LatLng(doc['destination'].latitude, doc['destination'].longitude);
                          return FutureBuilder(
                                future: Future.wait({
                                  DataHelper.getAddressFromGeoPoint(doc['position']),
                                  DataHelper.getAddressFromGeoPoint(doc['destination']),
                                  databaseService.getDistance(doc['uid'])
                                }),
                                builder: (context, snapshot){
                                  if(!snapshot.hasData){
                                  return  const Text('...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white));
                                  }
                                  else{
                                    String position = snapshot.data![0];
                                    String destination = snapshot.data![1];
                                    String distance = snapshot.data![2];
                                    double km = double.parse(distance);
                                    double price = km*0.5;
                                    return Container(
                                      padding: const EdgeInsets.all(5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: Text('${index+1}. ${doc['fullName']}  ${doc['phoneNumber']}',
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                                              ),
                                              ElevatedButton(
                                                  onPressed: (){
                                                    _makePhoneCall('${doc['phoneNumber']}');
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                      padding: EdgeInsets.zero,
                                                      backgroundColor: Colors.greenAccent
                                                  ),
                                                  child:const Icon(Icons.call)
                                              ),
                                              const SizedBox(width: 5),
                                              ElevatedButton(
                                                  onPressed: (){
                                                    nextScreen(context,
                                                        MapRouting(customerPosition: point1, destination: point2, driverPosition: driverPosition));
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                      padding:EdgeInsets.zero,
                                                      backgroundColor: Colors.blueAccent
                                                  ),
                                                  child: const Icon(Icons.map)
                                              ),
                                              const SizedBox(width: 5),
                                              ElevatedButton(
                                                  onPressed: (){
                                                    databaseService.tripFinished(widget.tripId, doc['uid']);
                                                    showToast("The customer has completed trip.", Colors.cyanAccent);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                      padding: EdgeInsets.zero,
                                                      backgroundColor: Colors.cyanAccent
                                                  ),
                                                  child: const Icon(Icons.done)
                                              ),

                                            ],
                                          ),
                                          Text('Position: $position', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey)),
                                          Text('Go: $destination', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey)),
                                          Text('Price: $price usd', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey)),
                                          const Divider(color: Colors.grey, thickness: 0.7)
                                        ],
                                      ),

                                    );
                                   }});

                        }
                      },

                    );
                  },

                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(
      scheme: 'tel',
      path: phoneNumber
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Cannot call: $phoneNumber';
    }
  }


}


class ListGoodsOfTrip extends StatefulWidget {
  const ListGoodsOfTrip({Key? key, required this.tripId}) : super(key: key);
  final String tripId;
  @override
  State<ListGoodsOfTrip> createState() => _ListGoodsOfTripState();
}

class _ListGoodsOfTripState extends State<ListGoodsOfTrip> {

  DatabaseService databaseService = DatabaseService();
  Color color = Colors.black;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: databaseService.goodsCollection.where('tripId', isEqualTo: widget.tripId).where('status', isEqualTo:'Approved').get(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(!snapshot.hasData || snapshot.hasError){
            return const SizedBox();
          }
          else{
            List<DocumentSnapshot> document = snapshot.data.docs;
            return document.isEmpty ? const Center(child: Text("There's no delivery", style: TextStyle(color: Colors.cyan, fontSize: 20, fontWeight: FontWeight.bold))):
              ListView.builder(
                itemCount: document.length,
                itemBuilder: (context, index){
                  DocumentSnapshot doc = document[index];
                  return FutureBuilder(
                    future:  databaseService.getDistance(doc['uid']),
                    builder: (context, snapshot){
                      if(!snapshot.hasData || snapshot.hasError){
                        return const SizedBox();
                      }else{
                        String distance = snapshot.data!;
                        double km = double.parse(distance);
                        double price = km*0.5;
                        return ListTile(
                          title: Text('${index+1}. Receiver: ${doc['phone']}. \nPrice: $price usd',
                              style: TextStyle( fontSize: 18, color: doc['isDelivery'] ?   Colors.green :color )
                          ),
                          subtitle:Text('${doc['description']}',
                              style: TextStyle( fontSize: 18, color:  doc['isDelivery'] ?  Colors.green :color )
                          ),
                          trailing: !doc['isDelivery'] ? const Icon(Icons.paste) : const Icon(Icons.done, color: Colors.green),
                          onTap: (){
                            showDialog(
                                context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    title: const Text('Confirm goods'),
                                    content: const Text('Has the recipient received the goods yet?'),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: (){
                                            setState(() {
                                              color = Colors.red;
                                              databaseService.notDeliveryGoods(doc['gid']);
                                            });
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          child: const Text("No, I can't contact with receiver.")
                                      ),
                                      ElevatedButton(
                                          onPressed: (){
                                            setState(() {
                                              color = Colors.green;
                                              databaseService.deliveryGoods(doc['gid']);
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Yes, successfully delivery.")
                                      )
                                    ],
                                  );
                                }
                            );
                          },
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

