import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:halo_app/providers/pay_data.dart';
import 'package:halo_app/providers/trip_data.dart';
import 'package:halo_app/providers/user_data.dart';
import 'package:halo_app/screen/home/detail_trip.dart';
import 'package:halo_app/screen/home/rateWidget.dart';
import 'package:halo_app/screen/menu/account_menu/profile.dart';

import 'package:halo_app/screen/menu/pay/payOnline.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../notification/noti.dart';
import '../../shared/loading.dart';
import '../../shared/widget.dart';
import '../menu/activity/customer_act/delivery_form.dart';



class DetailTripOfCustomer extends StatefulWidget {
  DetailTripOfCustomer({Key? key, required this.tripId}) : super(key: key);
  String tripId = '';
  @override
  State<DetailTripOfCustomer> createState() => _DetailTripOfCustomerState();
}

class _DetailTripOfCustomerState extends State<DetailTripOfCustomer> {
  bool _isLoading = true;
  bool _isConfirm = false;
  bool _isOnlinePay = false;

  DateTime bookTime = DateTime.now();
  User? user = FirebaseAuth.instance.currentUser;
  DatabaseService databaseService = DatabaseService();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState(){
    super.initState();
    Noti.initialize(flutterLocalNotificationsPlugin);
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        _isLoading = false;
      });
    });
    _isBookTrip();
    getDistance();
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
      });}
    catch (e){
      return;
    }
  }

  void _isBookTrip() async{
    List<String> trips = await databaseService.isBookTrip(user!.uid);
    List<String> tripIdOfPayment = [];
    QuerySnapshot snapshot = await databaseService.getPaymentOfUser(user!.uid);
    for(QueryDocumentSnapshot doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String id = data['tripId'] as String;
      tripIdOfPayment.add(id);
    }
    for(String tripId in trips){
      if(widget.tripId == tripId){
        if(tripIdOfPayment.contains(widget.tripId)){
          setState(() {
            _isOnlinePay = true;
          });
        }
      }
    }
  }

  void onPressDone(){
    setState(() {
      _isOnlinePay = true;
    });
  }


  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    TripData tripData = Provider.of<TripData>(context);
    tripData.getDetailTrip(widget.tripId);
    UserData userData = Provider.of<UserData>(context);
    userData.getUserData();
    PayData payData = Provider.of<PayData>(context);
    payData.getPay(user!.uid);
    return  Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.cyan,
            title:Row(
              children: [
                 const Text('Trip details', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                 const SizedBox(width: 10),
                _isConfirm &&  !userData.canceledTrip.contains(widget.tripId)? const Icon(Icons.task_alt, size: 35,) : const SizedBox()
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, size: 40),
              onPressed: (){
                Navigator.pop(context);
              },
            ),

        ),
        body: _isLoading ? const Loading():
        SingleChildScrollView(
          child: Column(
            children: [
              DetailedTrip(tripId: tripData.tripId),
              tripData.isFinished ? Rating(tripId: tripData.tripId, uid: user!.uid, driverId: tripData.driverId) :
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            tripData.waiting.contains(user!.uid) || tripData.members.contains(user!.uid) ? const SizedBox() :
                            Row(
                              children: [
                                ElevatedButton(
                                    onPressed: (){
                                      if(userData.phoneNumber.isEmpty){
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context){
                                              return AlertDialog(
                                                title: Text('Warning'),
                                                content: Text("You've not add your phone number yet.\nAdd phone number to use our service."),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: (){
                                                        nextScreen(context,  Profile());
                                                      },
                                                      child: Text('Add now')
                                                  )
                                                ],
                                              );
                                            }
                                        );
                                      }
                                      setState(() {
                                        Noti.showBigTextNotification(title: 'Book successfully', body: "You're in waiting list. Wait for driver response!", fln: flutterLocalNotificationsPlugin);
                                        databaseService.addCustomerToWaiting(user!.uid, widget.tripId);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        backgroundColor: Colors.cyan,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                                    ),
                                    child: const Text('Book',style: TextStyle( fontWeight: FontWeight.bold, fontSize: 25))
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        nextScreen(context, DeliveryForm(tripId: tripData.tripId, price: price, driverId:tripData.driverId, uid:userData.uid));
                                        // showShippingForm(context, userData.uid, tripData.tripId, price, tripData.driverId);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        backgroundColor: Colors.orange,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                                    ),
                                    child: const Text('Delivery',style: TextStyle( fontWeight: FontWeight.bold, fontSize: 25))
                                )
                              ],
                            ),
                            tripData.waiting.contains(userData.uid) ?
                            Row(
                              children: [
                                const SizedBox(width: 5),
                                const Icon(Icons.hourglass_bottom, color: Colors.cyan),
                                const Text("Waiting for driver's response.", style:  TextStyle(color: Colors.cyan, fontSize: 16, fontFamily: 'Roboto')),
                                TextButton(
                                    onPressed: (){
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context){
                                            return AlertDialog(
                                              title: const Text('Cancel booking', style: TextStyle(fontWeight: FontWeight.bold)),
                                              content:const Text('Are you sure want to cancel ?', style: TextStyle(fontWeight: FontWeight.bold)),
                                              actions: [
                                                ElevatedButton(onPressed: (){Navigator.pop(context);},
                                                    child: const Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
                                                ElevatedButton(
                                                    onPressed: (){
                                                      Noti.showBigTextNotification(title: 'Cancel successfully', body: "You've canceled this trip.", fln: flutterLocalNotificationsPlugin);
                                                      Navigator.pop(context);
                                                      databaseService.cancelTrip(user!.uid, widget.tripId);
                                                    },
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                                    child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.bold)))
                                              ],
                                            );
                                          }
                                      );
                                    },
                                    child: const Text('Cancel',style:  TextStyle(color: Colors.red, fontSize: 18, fontFamily: 'Roboto'))
                                )
                              ],
                            ) : const SizedBox(),
                            tripData.members.contains(userData.uid) ?
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                      boxShadow: const [
                                        BoxShadow(
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                            offset: Offset(1, 6),
                                            color: Colors.grey
                                        )
                                      ]),
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text('Payment', style: TextStyle(fontSize: 35, color: Colors.blue, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                                          const SizedBox(width: 10),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap:(){
                                                  setState(() {
                                                    _isOnlinePay = true;
                                                  });
                                                },
                                                child: Visibility(
                                                  visible: !_isOnlinePay,
                                                  child:  MakePayment(tripId: tripData.tripId, amount: price, driverId: tripData.driverId, onPressDone: onPressDone),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      tripData.members.contains(user!.uid) && !_isOnlinePay ?
                                      Text("You've booked this trip at ${bookTime.hour.toString().padLeft(2, '0')}:${bookTime.minute.toString().padLeft(2, '0')},"
                                          " ${DateFormat.EEEE().format(bookTime)}, ${DateFormat.MMMM().format(bookTime)} ${bookTime.day}, ${bookTime.year} and selected pay later. Your fee is $price usd.",
                                        style: const TextStyle(fontSize: 17 , fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                                      )
                                          : const SizedBox(),
                                      _isOnlinePay ?
                                      Text("You've booked this trip at ${bookTime.hour.toString().padLeft(2, '0')}:${bookTime.minute.toString().padLeft(2, '0')},"
                                          " ${DateFormat.EEEE().format(bookTime)}, ${DateFormat.MMMM().format(bookTime)} ${bookTime.day}, ${bookTime.year}. You have paid for this move via paypal.",
                                        style: const TextStyle(fontSize: 17 , fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                                      )
                                          : const SizedBox(),

                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                tripData.members.contains(userData.uid) ? Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: (){
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context){
                                              return AlertDialog(
                                                title: const Text('Cancel booking', style: TextStyle(fontWeight: FontWeight.bold)),
                                                content:const Text('Are you sure want to cancel ?', style: TextStyle(fontWeight: FontWeight.bold)),
                                                actions: [
                                                  ElevatedButton(onPressed: (){Navigator.pop(context);},
                                                      child: const Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
                                                  ElevatedButton(
                                                      onPressed: (){
                                                        databaseService.cancelTrip(user!.uid, tripData.tripId);
                                                        setState(() {
                                                          _isConfirm = false;
                                                        });
                                                        Noti.showBigTextNotification(title: 'Cancel successfully', body: "You've canceled this trip.", fln: flutterLocalNotificationsPlugin);
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                                      child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.bold)))
                                                ],
                                              );
                                            }
                                        );

                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15)
                                      ),
                                      child:const Text('Cancel',
                                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                    const Text(' You can cancel trip every time.', style: TextStyle(fontSize: 15 , fontWeight: FontWeight.bold))
                                  ],
                                ) : const SizedBox(),
                              ],
                            ) : const SizedBox()
                          ],
                        ),
              ),

            ],
          ),
        ),
    );

  }
}

