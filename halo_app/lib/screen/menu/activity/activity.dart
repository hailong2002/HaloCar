import 'dart:convert';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:halo_app/providers/user_data.dart';
import 'package:halo_app/screen/menu/activity/driver_act/driver_schedule.dart';
import 'package:halo_app/screen/menu/activity/driver_act/createTrip.dart';
import 'package:halo_app/screen/menu/activity/tableCalender.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/constants.dart';
import '../../../shared/loading.dart';
import '../../../shared/widget.dart';
import '../../home.dart';
import '../account_menu/account.dart';
import 'customer_act/customer_delivery.dart';
import 'customer_act/customer_trip.dart';
class Activity extends StatefulWidget {
  const Activity({Key? key}) : super(key: key);

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {

  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: Constants().mainColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 30),
              height: 800,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text('Activities', style: TextStyle(color: Colors.white, fontSize: 30, fontFamily: 'Outfit', fontWeight: FontWeight.bold),),
                  ),
                  const SizedBox(height: 10),
                  DefaultTabController(
                    length: userData.role != 'driver' ? 2 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          color: Colors.white.withOpacity(0.3),
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
                              tabs: userData.role != 'driver'? const [
                                Tab(
                                  icon: Icon(Icons.directions_car),
                                  text: "Booking car",
                                ),
                                Tab(
                                  icon: Icon(Icons.propane_tank_outlined),
                                  text: "Delivery",
                                ),

                              ] :
                              const [
                                Tab(
                                  icon: Icon(Icons.calendar_month),
                                  text: "Schedule",
                                ),
                              ],

                            ),
                          ),
                        ),
                        userData.role != 'driver' ?
                        const SizedBox(
                          height: 620,
                          width: 500,
                          child: TabBarView(
                              children: [
                                CustomerTrip(),
                                CustomerDelivery(),
                              ],
                            ),
                        ) :const SizedBox(
                          height: 600,
                          width: 500,
                          child: TabBarView(
                            children: [
                              DriverSchedule(),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class Delivery extends StatefulWidget {
  const Delivery({Key? key}) : super(key: key);

  @override
  State<Delivery> createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.3),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)
          ),
          child: InkWell(
            onTap: (){nextScreen(context, const Home());},
            child: SizedBox(
              height: 130,
              child: ListView(
                padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('01/08/2023 | 15:00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Over', style: TextStyle(color: Colors.cyan))
                    ],
                  ),
                  const Divider(color: Colors.cyan, thickness: 0.5),
                  Row(
                    children: [
                      Icon(Icons.luggage, color: Colors.blueAccent,),
                      Container(
                        width: 250,
                        child: Text('  256 Le Thanh Nghi, Hai Ba Trung, Hanoi',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 18,)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.location_pin, color: Colors.redAccent,),
                      Container(
                        width: 250,
                        child: Text('  Dai Cuong, Kim Bang, Ha Nam',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 18,)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}







