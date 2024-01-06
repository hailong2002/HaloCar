import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:halo_app/helper/helper_function.dart';
import 'package:halo_app/providers/helperData.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:halo_app/shared/constants.dart';
import 'package:halo_app/shared/widget.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';


import 'main_state.dart';

class SetLocation extends StatefulWidget {
  const SetLocation({Key? key, required this.isSetLocation, required this.position}) : super(key: key);
  final bool isSetLocation;
  final String position;
  @override
  State<SetLocation> createState() => _SetLocationState();
}

class _SetLocationState extends State<SetLocation> {

  final MainStateController controller = MainStateController();
  final textController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  DatabaseService databaseService = DatabaseService();
  LatLng _currentPosition = LatLng(0,0);
  String currentPosition = '';
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  _getCurrentLocation() async {
    if(widget.position.isEmpty){
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        currentPosition = await DataHelper.getAddressFromLatLng(_currentPosition);
      } catch (e) {
        print(e);
      }
    }else{
      setState(() {
        currentPosition = widget.position;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.cyan,
      appBar: AppBar(
        title: Text(widget.isSetLocation ? 'Set your position' : 'Set destination', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
        backgroundColor: Colors.cyan,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            FocusScope.of(context).unfocus();
          },
          icon: const Icon(Icons.chevron_left, size: 30),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: DismissKeyboard(
                                child: TextFormField(
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.search,
                                  decoration:  homeTextDecoration.copyWith(
                                    hintText: widget.isSetLocation ? currentPosition : 'Where to go?',
                                    prefixIcon: widget.isSetLocation ? const Icon(Icons.location_on, color: Colors.red) :
                                    const Icon(Icons.search, color: Colors.black),
                                    suffixIcon: IconButton(
                                        onPressed: (){
                                          setState(() {
                                            controller.listSource = RxList<SearchInfo>();
                                            FocusScope.of(context).unfocus();
                                            textController.clear();
                                          });
                                        },
                                        icon: const Icon(Icons.clear)
                                    )

                                  ),
                                  controller: textController,
                                  onChanged: (text) async {
                                    controller.isLoading = true;
                                    var data = await addressSuggestion(text);
                                    setState(() {
                                        if (data.isNotEmpty) {
                                          controller.listSource = data;
                                        }
                                        controller.isLoading = false;
                                    });
                                  },
                                ),
                  ),
            ),
            controller.isLoading ? const CircularProgressIndicator(color: Colors.white) :
             Container(
               height: 500,
                  child: controller.listSource.isEmpty ? Container() :
                  Container(
                    color: Colors.white,
                    child: ListView.builder(
                        itemCount: controller.listSource.length,
                        itemBuilder: (context, index){
                          final item = controller.listSource[index];
                          return ListTile(
                            onTap: (){
                              if(widget.isSetLocation){
                                // showToast('Set position: ${item.point!.latitude} ${item.point!.longitude}',Colors.blueAccent);
                                showToast('Set position successful', Colors.cyan);
                                databaseService.updatePosition(LatLng(item.point!.latitude, item.point!.longitude), user!.uid, true);
                                setState(() {
                                  textController.text = item.address.toString();
                                  controller.listSource = [];
                                });
                              }else{
                                // showToast('Set destination: ${item.point!.latitude} ${item.point!.longitude}',Colors.blueAccent);
                                showToast('Set destination successful', Colors.cyan);
                                databaseService.updatePosition(LatLng(item.point!.latitude, item.point!.longitude), user!.uid, false);
                                setState(() {
                                  textController.text = item.address.toString();
                                  controller.listSource = [];

                                });
                              }
                            },
                            title: Text(item.address.toString(), style: const TextStyle(fontWeight: FontWeight.bold)) ,
                          );
                        }),
                  )
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async{
          var geoPoint = await showSimplePickerLocation(context: context,
            isDismissible: true,
            title: 'Pick address',
            textConfirmPicker: 'Pick',
            initCurrentUserPosition: false,
            initPosition: GeoPoint(latitude:  21.0285, longitude: 105.8542),
            initZoom: 12
          );
          if(geoPoint != null){
            showToast('Click to ${geoPoint.toString()}', Colors.white);
            String address = await DataHelper.getAddressFromLatLng(LatLng(geoPoint.latitude, geoPoint.longitude));
            setState(() {
              currentPosition = address;
            });
            if(widget.isSetLocation){
              // showToast('Set position: ${geoPoint.toString()}',Colors.blueAccent);
              databaseService.updatePosition(LatLng(geoPoint.latitude, geoPoint.longitude), user!.uid, true);
            }else{
              // showToast('Set destination: ${geoPoint.toString()}',Colors.blueAccent);
              databaseService.updatePosition(LatLng(geoPoint.latitude, geoPoint.longitude), user!.uid, false);
            }
          }
        },
        child: const Icon(Icons.pin_drop, color: Colors.cyan),
      ),
    );

  }
}
