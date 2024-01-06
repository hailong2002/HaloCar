import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:halo_app/providers/user_data.dart';
import 'package:halo_app/services/database_service.dart';

class CarData with ChangeNotifier {
  String carId = '';
  String brand = '';
  String model = '';
  String color = '';
  int seat = 0;
  String licensePlate = '';

  Future<bool> getCarInfo(String uid) async{
    QuerySnapshot snapshot = await DatabaseService().getCarInfo(uid);
    if(snapshot.docs.isNotEmpty){
      carId = snapshot.docs[0].get('carId');
      brand = snapshot.docs[0].get('brand');
      model = snapshot.docs[0].get('model');
      seat = snapshot.docs[0].get('seat');
      color = snapshot.docs[0].get('color');
      licensePlate = snapshot.docs[0].get('licensePlate');
      notifyListeners();
      return true;
    }
    return false;

  }




}