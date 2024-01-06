import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:halo_app/providers/user_data.dart';
import 'package:halo_app/services/database_service.dart';

import 'helperData.dart';

class TripData with ChangeNotifier {
  String tripId = '';
  String driverId = '';
  String startPoint = '';
  String endPoint = '';
  List members = [];
  DateTime date = DateTime.now();
  int slot = 0;
  double price = 0;
  bool isFinished = false;
  bool isStarted = false;
  String carId = '';
  List waiting = [];
  List rating = [];
  double averageRating = 0;

  Future<void> getDetailTrip(String tripId) async {
    QuerySnapshot snapshot = await DatabaseService().tripCollection.where('tripId', isEqualTo: tripId).get();
    if(snapshot.docs.isNotEmpty){
      this.tripId = tripId;
      driverId = snapshot.docs[0].get('driverId');
      startPoint = snapshot.docs[0].get('start').split(',')[0];
      endPoint = snapshot.docs[0].get('end').split(',')[0];
      date = snapshot.docs[0].get('date').toDate();
      slot = snapshot.docs[0].get('slot');
      // price = snapshot.docs[0].get('price').toDouble();
      members = snapshot.docs[0].get('member');
      isFinished = snapshot.docs[0].get('isFinished');
      isStarted  = snapshot.docs[0].get('isStarted');
      carId  = snapshot.docs[0].get('carId');
      waiting = snapshot.docs[0].get('waiting');
      rating = snapshot.docs[0].get('rating');
      averageRating = snapshot.docs[0].get('averageRating').toDouble();
      notifyListeners();
    }

  }







}