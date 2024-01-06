import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:halo_app/providers/user_data.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:halo_app/shared/constants.dart';
import 'package:halo_app/shared/widget.dart';
import 'package:provider/provider.dart';

import '../../providers/helperData.dart';
import 'detailTripCustomer.dart';

class ListTrip extends StatefulWidget {
  const ListTrip({Key? key}) : super(key: key);
  @override
  State<ListTrip> createState() => _ListTripState();
}

class _ListTripState extends State<ListTrip> {
  DatabaseService databaseService = DatabaseService();
  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  @override
  void initState(){
    super.initState();
    getDistance();
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  bool _searchBarOpen = false;
  void _toggleSearchBar(){
    setState(() {
      _searchBarOpen = !_searchBarOpen;
      searchText = '';
    });
  }

  String searchText= '';
  double price = 0;
  String distance = '';
  void getDistance() async{
    try{
      String distance = await databaseService.getDistance(user!.uid);
      double distanceParse = double.parse(distance);
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
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: _searchBarOpen ? DismissKeyboard(
          child: TextFormField(
            style: const TextStyle(fontSize: 20, color: Colors.white,fontWeight: FontWeight.bold),
            autofocus: true,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Where you want to go ?',
              hintStyle: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.8),fontWeight: FontWeight.bold),
              border: InputBorder.none,
            ),
            onChanged: (val){
              setState(() {
                searchText = val;
              });
            },
          ),
        ) :
        const Text('Car schedule', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_searchBarOpen ? Icons.close : Icons.search, size: 30,),
            onPressed: _toggleSearchBar,
          ),
        ],
      ),
      body:
      Container(
        height: 706,
        color: Colors.cyan.withOpacity(0.5),
        child: StreamBuilder(
          stream: databaseService.tripCollection.snapshots(),
          builder: (context, snapshot){
            if(!snapshot.hasData){
              return const SizedBox();
            }else{
              List<DocumentSnapshot> documents = snapshot.data!.docs;
              List<DocumentSnapshot> filteredDocuments = [];
              if (searchText.isNotEmpty) {
                String search = searchText.toLowerCase().replaceAll(' ', '');
                for (DocumentSnapshot doc in documents) {
                  String name = doc['end'].toString().toLowerCase().replaceAll(' ', '');
                  if (name.contains(search)) {
                    filteredDocuments.add(doc);
                  }
                }
              }else{
                filteredDocuments = documents;
              }
              return documents.isEmpty ? const Center(child: Text("No result", style: TextStyle(color: Colors.teal, fontSize: 18),)):
                  ListView.builder(
                      itemCount: searchText.isEmpty ? documents.length : filteredDocuments.length,
                      itemBuilder: (context, index){
                        DocumentSnapshot doc = searchText.isEmpty ? documents[index] : filteredDocuments[index];
                        DateTime date = doc['date'].toDate();
                        return  _isLoading ? const Center(child:  CircularProgressIndicator(color: Colors.white,)) :
                         FutureBuilder(
                            future: Future.wait(
                             [
                               databaseService.getCarInfoByCarId(doc['carId']),
                               // databaseService.getAverage(doc['driverId']),
                               databaseService.userCollection.where('uid', isEqualTo: doc['driverId']).get()
                             ]
                            ),
                            builder: (context, snapshot){
                              if(snapshot.hasError){
                                return Text('Error: ${snapshot.error}');
                              }
                              else if (!snapshot.hasData) {
                                return const Text('');
                              }else{
                                DocumentSnapshot doc1 = snapshot.data![0];
                                QuerySnapshot querySnapshot = snapshot.data![1];
                                DocumentSnapshot doc2 = querySnapshot.docs[0];
                                double r = doc2['totalRating'].toDouble();

                                return
                                  date.isBefore(DateTime.now()) ? const SizedBox() :
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                    child:InkWell(
                                      onTap: (){
                                        nextScreen(context, DetailTripOfCustomer(tripId: doc['tripId']));
                                      },
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
                                                          doc['slot'] == doc1['seat'] ? const Text('Out of seats', style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)):
                                                          Icon(Icons.airline_seat_recline_normal_sharp,  color: Colors.amber[700]),
                                                          doc['slot'] == doc1['seat'] ? const Text('') :
                                                          Text('${doc['slot']}/${doc1['seat']}',  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                                                          // Text('Cancel', style: TextStyle(color: Colors.redAccent))
                                                        ],
                                                      ),
                                                      const Divider(color: Colors.cyan, thickness: 0.8),
                                                      RichText(
                                                        text: TextSpan(
                                                            text: ' License plates:',
                                                            style:  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                                            children: [
                                                              TextSpan(text: ' ${doc1['licensePlate']} ',
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
                                                          const SizedBox(width: 25),
                                                          Text("Average: ${doc2['totalRating']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                          const Icon(Icons.star, color: Colors.yellow)
                                                        ],
                                                      ),
                                                      const Divider(color: Colors.cyan, thickness: 0.8),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.drive_eta_rounded, color: Colors.blueAccent,),
                                                          const SizedBox(width: 10),
                                                          SizedBox(
                                                            width: 120,
                                                            child: Text('${doc['start'].split(',')[0]}',
                                                                overflow: TextOverflow.ellipsis,
                                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                          ),
                                                          const Icon(Icons.location_pin, color: Colors.redAccent),
                                                          const SizedBox(width: 10),
                                                          SizedBox(
                                                            width: 120,
                                                            child: Text('${doc['end'].split(',')[0]}',
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
                                            userData.trips.contains(doc['tripId']) ?
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8, left: 8),
                                              child:Container(
                                                  width:320 ,
                                                  height: 140,
                                                  color: Colors.white.withOpacity(0.4),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: const [
                                                        Text('You booked this trip ',
                                                          style: TextStyle(color: Colors.cyan, fontSize: 25, fontFamily: 'Roboto', fontWeight: FontWeight.w900),
                                                        ),
                                                        Icon(Icons.task_alt, size: 30, color: Colors.cyan,)
                                                      ],
                                                    ),
                                                  )
                                              ),
                                            ): const SizedBox(),
                                            doc['slot'] == doc1['seat'] ?
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8, left: 8),
                                              child:  Container(
                                                  width:360 ,
                                                  height: 140,
                                                  color: Colors.white.withOpacity(0.4),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: const [
                                                        Text('Out of seat ',
                                                          style: TextStyle(color: Colors.redAccent, fontSize: 25, fontFamily: 'Roboto', fontWeight: FontWeight.w900),
                                                        ),
                                                        Icon(Icons.group_off, size: 30, color: Colors.redAccent,)
                                                      ],
                                                    ),
                                                  )
                                              ),
                                            ): const SizedBox(),
                                            userData.canceledTrip.contains(doc['tripId']) ?  Padding(
                                              padding: const EdgeInsets.only(top: 8, left: 8),
                                              child:  Container(
                                                  width:360 ,
                                                  height: 140,
                                                  color: Colors.white.withOpacity(0.4),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: const [
                                                        Text('You canceled this trip',
                                                          style: TextStyle(color: Colors.redAccent, fontSize: 25, fontFamily: 'Roboto', fontWeight: FontWeight.w900),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                              ),
                                            ) : const SizedBox(),

                                          ]
                                      ),
                                    ),


                                  );
                              }
                            });


                              }


                  );
            }
          }

        )

      ),

    );
  }
}
