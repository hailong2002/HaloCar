import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';
import 'package:halo_app/screen/menu/account_menu/car_info.dart';
import 'package:halo_app/screen/menu/activity/tableCalender.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../providers/car_data.dart';
import '../../../../providers/trip_data.dart';
import '../../../../providers/user_data.dart';
import '../../../../services/database_service.dart';
import 'package:http/http.dart' as http;

import '../../../../shared/constants.dart';
import '../../../../shared/widget.dart';
import '../../../map/main_state.dart';
class EditTrip extends StatefulWidget {
  const EditTrip({Key? key, required this.start, required this.end, required this.tripId, required this.amount_customer}) : super(key: key);
  final String start;
  final String end;
  final String tripId;
  final int amount_customer;
  @override
  State<EditTrip> createState() => _EditTripState();
}

class _EditTripState extends State<EditTrip> {

  String licensePlate = '';
  String start = '';
  String end = '';
  DatabaseService databaseService = DatabaseService();
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController textChooseStarting = TextEditingController();
  TextEditingController textChooseDestination = TextEditingController();
  bool isChosen = false;
  bool isShow = false;
  final MainStateController controller = MainStateController();
  final textController = TextEditingController();



  //Date & time
  DateTime selectedDay = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  double selectedPrice = 0;
  void _showTableCalendar(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return Dialog(
            child: SizedBox(
              child: TableCalender(
                onDaySelected: (newDay) {
                  setState(() {
                    selectedDay = newDay;
                  });
                },
                initialSelectedDate: selectedDay,
              ),
            ),
          );
        }
    );
  }



  @override
  Widget build(BuildContext context) {
    CarData carData = Provider.of<CarData>(context);
    carData.getCarInfo(user!.uid);
    UserData userData = Provider.of<UserData>(context);
    userData.getUserData();

    return  Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.cyan,
          title:Row(
            children: const [
              Text('Edit trip', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 40),
            onPressed: (){
              Navigator.pop(context);
            },
          )
      ),
      body: SingleChildScrollView(
        child: DismissKeyboard(
          child: Container(
            height: 800,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    enabled: false,
                    controller: textChooseStarting,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    decoration: textEditDecoration.copyWith(
                        prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                        hintText: widget.start,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        hintStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                        suffixIcon: textChooseStarting.text.isNotEmpty ?
                        IconButton(onPressed: (){
                          textChooseStarting.text = '';
                          setState(() {
                            controller.listSource = [];
                            isShow = false;
                          });
                          }, icon: const Icon(Icons.clear)) : null
                    ),
                    onChanged: (val) async{
                      controller.isLoading = true;
                      var data = await addressSuggestion(val);
                      setState(() {
                        if (data.isNotEmpty) {
                          isShow = true;
                          isChosen = true;
                          controller.listSource = data;
                        }
                        controller.isLoading = false;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    enabled: false,
                    controller: textChooseDestination,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    decoration: textEditDecoration.copyWith(
                        prefixIcon: const Icon(Icons.drive_eta_rounded, color: Colors.cyan),
                        hintText: widget.end,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        hintStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                        suffixIcon: textChooseDestination.text.isNotEmpty ?
                        IconButton(onPressed: (){
                          setState(() {
                            textChooseDestination.text = '';
                            controller.listSource = [];
                            isShow = false;
                          });
                        }, icon: const Icon(Icons.clear)) : null
                    ),
                    onChanged: (val) async{
                      controller.isLoading = true;
                      var data = await addressSuggestion(val);
                      setState(() {
                        if (data.isNotEmpty) {
                          isShow = true;
                          controller.listSource = data;
                        }
                        controller.isLoading = false;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  isShow ?
                  SizedBox(
                    height: 300,
                    child:   controller.listSource.isEmpty ? Container() :
                    Container(
                      color: Colors.white,
                      child: ListView.builder(
                          itemCount: controller.listSource.length,
                          itemBuilder: (context, index){
                            final item = controller.listSource[index];
                            return ListTile(
                              onTap: (){
                                if(isChosen){
                                  textChooseStarting.text = item.address.toString();
                                  start = item.address.toString();
                                  isChosen = false;
                                }else{
                                  textChooseDestination.text  = item.address.toString();
                                  end = item.address.toString();
                                }
                                setState(() {
                                  controller.listSource =  [];
                                  isShow = false;
                                });
                              },
                              title: Text(item.address.toString(), style: const TextStyle(fontWeight: FontWeight.bold)) ,
                            );
                          }),
                    ),
                  ) : const SizedBox(),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _showTableCalendar,
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.all(5)
                        ),
                        child: Row(
                          children: const [
                            Text('Date ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Icon(Icons.date_range, size: 20),
                          ],
                        ),
                      ),
                      Text(' ${DateFormat.EEEE().format(selectedDay)}, ${DateFormat.MMMM().format(selectedDay)} ${selectedDay.day}, ${selectedDay.year}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: ()async{
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                              initialEntryMode: TimePickerEntryMode.input,
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    primaryColor: Colors.blue, // Màu chủ đạo cho picker
                                    textTheme: const TextTheme(
                                      displayLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      titleMedium: TextStyle(fontSize: 16),
                                      labelLarge: TextStyle(fontSize: 18, color: Colors.blue),
                                      bodySmall:  TextStyle(fontSize: 14, color: Colors.black54),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if(timeOfDay != null){
                              setState(() {
                                selectedTime = timeOfDay;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.all(5)
                          ),
                          child: Row(
                            children:const [
                              Text('Time ',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Icon(Icons.timer_sharp, size: 20),
                            ],
                          )
                      ),
                      Text(' ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.cyan,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('You car information    ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
                            IconButton(onPressed: (){nextScreen(context, const CarInfo());}, icon: const Icon(Icons.edit_outlined, color: Colors.white))
                          ],
                        ),
                        Row(
                          children: [
                            Text('Brand: ${carData.brand}',style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17,color: Colors.white)),
                            const SizedBox(width: 50),
                            Text('Model: ${carData.model}',style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17,color: Colors.white)),
                          ],
                        ),

                        Text('Color: ${carData.color}',style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17,color: Colors.white)),

                        Text('Seat: ${carData.seat}',style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17,color: Colors.white)),

                        Text('License Plate: ${carData.licensePlate}',style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17,color: Colors.white)),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ElevatedButton(
                        onPressed: (){
                          if(widget.amount_customer != 0) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context){
                                  return const AlertDialog(
                                    title: Text("Cannot edit trip"),
                                    content: Text("This trip has customers, so you can edit it"),
                                  );
                                }
                            );
                          }else{
                            databaseService.editTripInfo(
                              widget.tripId,
                              DateTime(selectedDay.year, selectedDay.month, selectedDay.day, selectedTime.hour, selectedTime.minute),
                            );
                            showToast('Successfully edit', Colors.cyan);
                          }

                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25), backgroundColor: Colors.cyan),
                        child: const Text('Save', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                    ),
                  )  ,
                ],
              ),

            ),

          ),
        ),

      ),
    );
  }
}