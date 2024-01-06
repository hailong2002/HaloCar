import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:halo_app/providers/helperData.dart';
import 'package:halo_app/providers/user_data.dart';
import 'package:halo_app/screen/home/list_trip.dart';
import 'package:halo_app/screen/map/maps.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../notification/noti.dart';
import '../shared/constants.dart';
import '../shared/widget.dart';
import 'home/dashboard.dart';
import 'menu/account_menu/account.dart';
import 'menu/activity/activity.dart';
import 'menu/pay/payHistory.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  DatabaseService databaseService = DatabaseService();
  User? user = FirebaseAuth.instance.currentUser;

  final items = <Widget>[
    const Icon(Icons.home_filled, size: 30),
    const Icon(Icons.paste, size: 30),
    const Icon(Icons.wallet, size: 30),
    const Icon(Icons.account_circle, size: 30)
  ];

  final List<Widget> _widgetOptions  = const [
    Home(),
    Activity(),
    PayHistory(),
    Account()
  ];

  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    Noti.initialize(flutterLocalNotificationsPlugin);
    getTrip();
  }
  void getTrip() async{
    try{
      QuerySnapshot snapshot = await databaseService.userCollection.where('uid', isEqualTo: user!.uid).get();
      List<dynamic> trips = snapshot.docs[0].get('trips');
      for(var tripId in trips){
        QuerySnapshot snapshot = await databaseService.tripCollection.where('tripId', isEqualTo: tripId).get();
        DocumentSnapshot documentSnapshot = snapshot.docs[0];
        if( documentSnapshot['isStarted'] && !documentSnapshot['isFinished']){
          Noti.showBigTextNotification(
              title: "Trip started",
              body: "You have 1 trip will start today.",
              fln: flutterLocalNotificationsPlugin
          );
        }
      }
    }catch(e){
      print(e);
    }

  }


  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    userData.getUserData();
    return Scaffold(
        body: userData.role != 'driver' ? DismissKeyboard(
              child:  _selectedIndex == 0 ?  Container(
                color: Constants().mainColor,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: 560,
                      child: Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  style: const TextStyle(fontSize: 20),
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.search,
                                  decoration:  homeTextDecoration.copyWith(
                                      hintText: userData.position,
                                      prefixIcon:  const Icon(Icons.location_on, color: Colors.red)
                                  ),
                                  onTap: (){
                                    nextScreen(context, SetLocation(isSetLocation: true, position: userData.position,));
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  style: const TextStyle(fontSize: 20),
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.search,
                                  decoration:  homeTextDecoration.copyWith(
                                      hintText: userData.destination.isEmpty ? 'Where to go?' : userData.destination,
                                      prefixIcon:  const Icon(Icons.search, color: Colors.black)
                                  ),
                                  onTap: (){
                                    nextScreen(context, SetLocation(isSetLocation: false,position: userData.position));
                                  },
                                ),
                                const SizedBox(height: 20),
                                const Text('Our services',
                                style: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 35),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Divider(color: Colors.white, thickness: 0.9),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: (){nextScreen(context, const ListTrip());},
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Container(
                                        width: 160,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                color: Colors.white.withOpacity(0.2),
                                                offset: const Offset(1, 1),
                                                spreadRadius: 4,
                                                blurRadius: 2
                                            )]
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(20),
                                                  child: Image.asset('assets/images/bc.png', fit: BoxFit.fill, width: 200),
                                                ),
                                              ),
                                              const Text('Booking car',
                                                style: TextStyle(fontSize: 20, color: Colors.cyan, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  InkWell(
                                    onTap: (){
                                      nextScreen(context, const ListTrip());
                                    },
                                    child: Container(
                                        width: 160,
                                        height: 149,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.white.withOpacity(0.2),
                                                  offset: const Offset(1, 1),
                                                  spreadRadius: 4,
                                                  blurRadius: 2
                                              )
                                            ]
                                        ),
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                                  child: Image.asset('assets/images/deli.jpg', fit: BoxFit.fill, width: 120),
                                                ),
                                            // const SizedBox(height: 5),
                                            const Text('Delivery',
                                              style: TextStyle(fontSize: 20, color: Colors.cyan, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )
                                    ),
                                  ),
                                ],
                              )
                            ],
                        ),
                          ),
                    ),
                  ),
                ),
              ) : _widgetOptions.elementAt(_selectedIndex)
        ) : _selectedIndex == 0 ? const DriverDashboard():_widgetOptions.elementAt(_selectedIndex) ,
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            userData.role != 'driver' ?
            SalomonBottomBarItem(
                icon: const Icon(Icons.home_outlined, size: 25),
                title: const Text('Home', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
                selectedColor: Constants().mainColor,
                unselectedColor: Colors.grey
            ):
            SalomonBottomBarItem(
                icon: const Icon(Icons.dashboard, size: 25),
                title: const Text('Dashboard', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
                selectedColor: Constants().mainColor,
                unselectedColor: Colors.grey
            ),
            SalomonBottomBarItem(
                icon: const Icon(Icons.paste,size: 25),
                title: const Text('Activity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                selectedColor: Constants().mainColor,
                unselectedColor: Colors.grey
            ),
            SalomonBottomBarItem(
                // icon: const Badge(
                //     label:  Text('', style: TextStyle(fontWeight: FontWeight.bold)),
                //     isLabelVisible: true,
                //     padding:  EdgeInsets.symmetric(horizontal: 5),
                //     alignment: AlignmentDirectional(19, -1),
                //     largeSize: 10,
                //     backgroundColor: Colors.redAccent,
                //     child:  Icon(Icons.account_balance_wallet_outlined,size: 26)
                //
                // ),
                icon: const Icon(Icons.account_balance_wallet_outlined,size: 26),
                title: const Text('Pay',style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                selectedColor: Constants().mainColor,
                unselectedColor: Colors.grey
            ),
            SalomonBottomBarItem(
                icon: const Icon(Icons.perm_identity_outlined, size: 26),
                title: const Text('Account',style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                selectedColor: Constants().mainColor,
                unselectedColor: Colors.grey
            )
          ],
        ),



        );
  }
}
