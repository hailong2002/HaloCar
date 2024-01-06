import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:halo_app/providers/user_data.dart';
import 'package:halo_app/services/database_service.dart';

class PayData with ChangeNotifier {
  String payId = '';
  String uid = '';
  String service = '';
  double amount = 0;
  DateTime date = DateTime.now();
  String tripId = '';

  Future<void> getPay(String uid) async{
    QuerySnapshot snapshot = await DatabaseService().getPaymentOfUser(uid);
    if(snapshot.docs.isNotEmpty){
      payId = snapshot.docs[0].get('pid');
      uid = uid;
      service = snapshot.docs[0].get('service');
      amount = snapshot.docs[0].get('amount').toDouble();
      date = snapshot.docs[0].get('date').toDate();
      tripId = snapshot.docs[0].get('tripId');
      notifyListeners();
    }

  }

  Future<void> getPayInfo(String pid) async{

    QuerySnapshot snapshot = await DatabaseService().getPayInfo(pid);
    if(snapshot.docs.isNotEmpty) {
      service = snapshot.docs[0].get('service');
      amount = snapshot.docs[0].get('amount').toDouble();
      date = snapshot.docs[0].get('date').toDate();
      tripId = snapshot.docs[0].get('tripId');
      notifyListeners();
    }
      // payId = snapshot.docs[0].get('pid') ?? '';

  }

  Future getTripId(String pid) async{

  }



}