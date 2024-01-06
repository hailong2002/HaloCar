import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import 'helperData.dart';

class UserData with ChangeNotifier{
  String uid = '';
  String phoneNumber = '';
  String email = '';
  String avatarUrl = '';
  String role = '';
  String fullName = '';
  List trips =[];
  String position = '';
  String destination = '';
  String carId ='';
  List pay = [];
  List canceledTrip = [];
  List finishedTrip = [];
  double totalRating = 0;
  String paypalEmail = '';

  Future<void> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    uid = user!.uid ?? '';
    QuerySnapshot userData = await DatabaseService().userCollection.where('uid', isEqualTo: user.uid).get();
    if(userData.docs.isNotEmpty){
      phoneNumber = userData.docs[0].get('phoneNumber');
      email = userData.docs[0].get('email');
      fullName = userData.docs[0].get('fullName');
      role = userData.docs[0].get('role');
      avatarUrl = userData.docs[0].get('avatar');
      carId = userData.docs[0].get('carId');
      pay = userData.docs[0].get('pay');
      canceledTrip = userData.docs[0].get('cancel');
      finishedTrip = userData.docs[0].get('finishedTrip');
      totalRating = userData.docs[0].get('totalRating').toDouble();
      if(role != 'driver'){
        trips = userData.docs[0].get('trips') ?? '';
      }
      position = await DataHelper.getAddressFromGeoPoint(userData.docs[0].get('position'));
      destination = await DataHelper.getAddressFromGeoPoint(userData.docs[0].get('destination'));
      paypalEmail = userData.docs[0].get('paypalEmail');
      notifyListeners();
    }

  }

  Future<void> getUserDataWithUid(String uid) async {
    QuerySnapshot userData = await DatabaseService().gettingUserData(uid);
    if(userData.docs.isNotEmpty){
      this.uid = uid;
      phoneNumber = userData.docs[0].get('phoneNumber');
      email = userData.docs[0].get('email');
      fullName = userData.docs[0].get('fullName');
      role = userData.docs[0].get('role');
      avatarUrl = userData.docs[0].get('avatar');
      carId = userData.docs[0].get('carId');
      if(role != 'driver'){
        trips = userData.docs[0].get('trips') ?? '';
      }
      position = await DataHelper.getAddressFromGeoPoint(userData.docs[0].get('position'));
      destination = await DataHelper.getAddressFromGeoPoint(userData.docs[0].get('destination'));
      paypalEmail = userData.docs[0].get('paypalEmail');
      notifyListeners();
    }

  }


}
