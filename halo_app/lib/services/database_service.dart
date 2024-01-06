import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class DatabaseService{
  final String? uid;
  final String? carId;
  DatabaseService({this.uid, this.carId});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection("user");
  final CollectionReference tripCollection = FirebaseFirestore.instance.collection("trip");
  final CollectionReference carCollection = FirebaseFirestore.instance.collection("car");
  final CollectionReference payCollection = FirebaseFirestore.instance.collection("pay");
  final CollectionReference goodsCollection = FirebaseFirestore.instance.collection("goods");
  FirebaseStorage  firebaseStorage = FirebaseStorage.instance;
  LatLng position = LatLng(0,0);
  _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      this.position = LatLng(position.latitude, position.longitude);
    } catch (e) {
      print(e);
    }
  }
  //user
  Future savingUserData(String phoneNumber, String email) async{
    await _getCurrentLocation();
    return await userCollection.doc(uid).set({
      "uid": uid,
      "email": email,
      "phoneNumber": phoneNumber,
      "fullName": "",
      "avatar" : "",
      "role": "customer",
      "carId":"",
      "cancel": [],
      "pay": [],
      "trips": [],
      "position": GeoPoint(position.latitude, position.longitude),
      "destination": GeoPoint(position.latitude, position.longitude),
      "finishedTrip": [],
      "totalRating": 0,
      "paypalEmail": ''
    });
  }

  Future updatePaypalEmail(String paypalEmail, String uid) async{
    DocumentReference documentReference = userCollection.doc(uid);
    await documentReference.update({
      'paypalEmail': paypalEmail
    });
  }

  Future<bool> isUserExist(String uid) async{
    try{
      final snapshot = await userCollection.where('uid', isEqualTo: uid).get();
      return snapshot.docs.isNotEmpty;
    }catch(e){
      print('Error: $e');
      return false;
    }
  }

  Future gettingUserData(String uid) async{
    QuerySnapshot snapshot = await userCollection.where("uid", isEqualTo: uid).get();
    return snapshot;
  }


  Future<void> updateUserData(String userId, String phoneNumber, String email, String fullName, File avatar) async{
    try{
     final storageRef = firebaseStorage.ref().child('avatars')
          .child('avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');
      if(avatar != File('') && avatar.existsSync()){
        final uploadTask = storageRef.putFile(avatar);
        final snapshot = await Future.wait([uploadTask]);
        final imageUrl = await snapshot[0].ref.getDownloadURL();
        await userCollection.doc(userId).update({
          "phoneNumber" : phoneNumber,
          "email": email,
          "fullName": fullName,
          "avatar": imageUrl,
        });
      }else{
        await userCollection.doc(userId).update({
          "phoneNumber" : phoneNumber,
          "email": email,
          "fullName": fullName,
          // "avatar": '',
        });
      }
    }catch(e){
      print('Error: $e');
    }
  }

  Future<void> RegisterAsDriver(String uid) async{
    try{
      await userCollection.doc(uid).update({
        "role" : "driver"
      });
    }catch (e){
      print('Error: $e');
    }
  }

  Future<void> updatePosition(LatLng position, String uid, bool isSetPosition) async{
    DocumentReference  documentReference = userCollection.doc(uid);
    if(isSetPosition){
      await documentReference.update({
        'position': GeoPoint(position.latitude, position.longitude)
      });
    }else{
      await documentReference.update({
        'destination': GeoPoint(position.latitude, position.longitude)
      });
    }

  }

  //Trip
  Future CreateTrip(String uid, DateTime date, String start, String end, String carId) async{
      try{
        DocumentReference scheduleDocumentReference = await tripCollection.add({
          'tripId': "",
          'driverId': uid,
          'carId': carId,
          'date': Timestamp.fromDate(date),
          'start': start,
          'end':  end,
          'isStarted': false,
          'isFinished': false,
          'rating': [],
          'slot': 1,
          'waiting': [],
          'member': [],
          'averageRating': 0,
        });
        await scheduleDocumentReference.update({
          // 'member': FieldValue.arrayUnion([uid]),
          'tripId': scheduleDocumentReference.id
        });
      }catch(e){
        print('Error: $e');
      }
  }

  Future<QuerySnapshot> getTrip() async{
    QuerySnapshot snapshot = await tripCollection.get();
    return snapshot;
  }


  Future getAverage(String uid) async{
    QuerySnapshot snapshot = await userCollection.where('uid', isEqualTo: uid).get();
    // String totalRating = snapshot.docs[0].get('totalRating').toString();
    DocumentSnapshot documentSnapshot = snapshot.docs[0];
    return documentSnapshot;
  }

  Future cancelTrip(String uid, String tripId) async{
    DocumentReference tripDocumentReference = tripCollection.doc(tripId);
    DocumentReference userDocumentReference = userCollection.doc(uid);
    QuerySnapshot snapshot = await tripCollection.where('tripId', isEqualTo: tripId).get();
    List<String> members = List<String>.from(snapshot.docs[0].get('member')) ;
    if(members.contains(uid)){
      await tripDocumentReference.update({
        'member' : FieldValue.arrayRemove([uid]),
        'slot': FieldValue.increment(-1)
      });
    }else{
      await tripDocumentReference.update({
        'waiting': FieldValue.arrayRemove([uid]),
      });

    }
    await userDocumentReference.update({
      'cancel': FieldValue.arrayUnion([tripId])
    });
    // await userDocumentReference.update({
    //   'trips': FieldValue.arrayRemove([tripId])
    // });
  }

  Future isBookTrip(String uid) async{
    QuerySnapshot snapshot = await userCollection.where('uid', isEqualTo: uid).get();
    List<String> trips = List<String>.from(snapshot.docs[0].get('trips')) ;
    return trips;
  }


  Future addCustomerToWaiting(String uid, String tripId) async{
    DocumentReference documentReference = tripCollection.doc(tripId);
    QuerySnapshot snapshot = await userCollection.where('uid', isEqualTo: uid).get();
    List<String> canceledTrip = snapshot.docs[0].get('cancel').cast<String>();
    DocumentReference userReference = userCollection.doc(uid);

    await documentReference.update({
      'waiting':FieldValue.arrayUnion([uid])
    });
    await userReference.update({
      'trips': FieldValue.arrayUnion([tripId])
    });
    if(canceledTrip.contains(tripId)){
      await userReference.update({
        'cancel': FieldValue.arrayRemove([tripId])
      });
    }

  }

  Future denyCustomer(String uid,String tripId) async{
    DocumentReference documentReference = tripCollection.doc(tripId);
    DocumentReference userReference = userCollection.doc(uid);
    await documentReference.update({
      'waiting':FieldValue.arrayRemove([uid])
    });
    
    await userReference.update({
      'trips': FieldValue.arrayRemove([tripId])
    });
  }

  Future approveCustomer(String uid,String tripId) async{
    DocumentReference documentReference = tripCollection.doc(tripId);
    await documentReference.update({
      'member':FieldValue.arrayUnion([uid]),
      'waiting':FieldValue.arrayRemove([uid]),
      'slot': FieldValue.increment(1)
    });
    DocumentReference userDocumentReference = userCollection.doc(uid);
    await userDocumentReference.update({
      'trips': FieldValue.arrayUnion([tripId])
    });
  }

  Future deleteTrip(String tripId) async{
    DocumentReference documentReference = tripCollection.doc(tripId);
    try{
      documentReference.delete();
      print('Successfully deleted');
    }catch (e){
      print('Error: $e');
    }
  }

  Future editTripInfo(String tripId, DateTime date) async{
    DocumentReference documentReference = tripCollection.doc(tripId);
    await documentReference.update({
      'date': date,
    });
  }

  Future tripStart(String tripId) async{
    DocumentReference documentReference = tripCollection.doc(tripId);
    await documentReference.update({
      'isStarted': true
    });
  }

  Future tripFinished(String tripId, String uid) async{
    DocumentReference documentReference = tripCollection.doc(tripId);
    DocumentSnapshot snapshot = await tripCollection.doc(tripId).get();
    List<String> members = snapshot.get('member').cast<String>();
    await documentReference.update({
      'member': FieldValue.arrayRemove([uid])
    });
    members.remove(uid);
    if(members.isEmpty){
      await documentReference.update({
        'isFinished': true
      });
    }

  }

  Future rateTrip(String tripId, double rate, String uid, String driverId) async {
    try {
      DocumentReference documentReference = tripCollection.doc(tripId);
      DocumentReference userReference = userCollection.doc(driverId);

      DocumentSnapshot snapshot = await documentReference.get();
      List<String> rates = snapshot.get('rating').cast<String>();

      List<String> updatedRates = List<String>.from(rates);

      for (var r in rates) {
        List<String> rateParts = r.split(' ');
        String userRate = rateParts[1];
        if (userRate == uid) {
          updatedRates.remove(r);
          updatedRates.add('$rate $uid');
        }else{
          updatedRates.add('$rate $uid');
        }
      }

      await documentReference.update({
        'rating': updatedRates,
      });

      double totalRating = 0.0;

      for (var r in updatedRates) {
        List<String> rateParts = r.split(' ');
        double userRate = double.parse(rateParts[0]);
        totalRating += userRate;
      }

      double averageRating = updatedRates.isEmpty
          ? rate
          : totalRating / updatedRates.length;

      await documentReference.update({
        'averageRating': averageRating,
      });

      QuerySnapshot tripOfDriver =
      await tripCollection.where('driverId', isEqualTo: driverId).get();

      int ratedTrip = 0;
      double totalRate = 0;

      for (QueryDocumentSnapshot doc in tripOfDriver.docs) {
        double rating = doc['averageRating'].toDouble();
        if (rating != 0) {
          totalRate += rating;
          ratedTrip++;
        }
      }

      double driverRating = ratedTrip == 0 ? 0 : totalRate / ratedTrip;
      driverRating = double.parse(driverRating.toStringAsFixed(1));

      await userReference.update({
        'totalRating': driverRating,
      });
    } catch (e) {
      print('Error in rateTrip: $e');
    }
  }


  //car
  Future updateOrCreateCar(String uid, String brand, String model, String color, int seat, String licensePlate) async {
      QuerySnapshot snapshot = await userCollection.where('uid', isEqualTo: uid).get();
      DocumentReference userReference =  userCollection.doc(uid);
      String id = snapshot.docs[0].get('carId');
      if(id.isEmpty){
        DocumentReference documentReference = await carCollection.add({
          'brand': brand,
          'model': model,
          'color': color,
          'seat': seat,
          'carId': '',
          'licensePlate': licensePlate,
          'uid': uid
        });
        String carId = documentReference.id;
        await carCollection.doc(carId).update({
          'carId': carId,
        });
        await userReference.update({
          'carId': carId
        });
      }else{
        await carCollection.doc(id).update({
          'brand': brand,
          'model': model,
          'color': color,
          'seat': seat,
          'licensePlate': licensePlate,
        });
      }
    }

  Future<QuerySnapshot> getCarInfo(String uid) async{
    QuerySnapshot snapshot = await carCollection.where('uid', isEqualTo: uid).get();
    return snapshot;
  }

  Future getCarInfoByCarId(String carId) async{
    QuerySnapshot snapshot = await carCollection.where('carId', isEqualTo: carId).get();
    DocumentSnapshot documentSnapshot = snapshot.docs[0];
    return documentSnapshot;
  }

    //Payment
    Future makePayment(String uid, double amount, String tripId, String driverId) async{
      DocumentReference userReference = userCollection.doc(uid);
      DocumentReference driverReference = userCollection.doc(driverId);

      DocumentReference payReference = await payCollection.add({
        'pid': '',
        'date': DateTime.now(),
        'amount':amount,
        'uid': uid,
        'tripId':tripId,
        'service': 'Paypal'
      });

      DocumentReference pReference = await payCollection.add({
        'pid': '',
        'date': DateTime.now(),
        'amount':amount,
        'uid': driverId,
        'tripId':tripId,
        'service': 'Paypal'
      });

      await payReference.update({
        'pid': payReference.id
      });

      await pReference.update({
        'pid': pReference.id
      });

      await userReference.update({
        'pay': FieldValue.arrayUnion([payReference.id])
      });

      await driverReference.update({
        'pay': FieldValue.arrayUnion([pReference.id])
      });

    }

    Future<QuerySnapshot> getPaymentOfUser(String uid) async{
      QuerySnapshot snapshot = await payCollection.where('uid', isEqualTo: uid).get();
      return snapshot;
    }

  Future<QuerySnapshot> getPayInfo(String pid) async{
    QuerySnapshot snapshot = await payCollection.where('pid', isEqualTo: pid).get();
    return snapshot;
  }

  Future getTripIdOfPayment(String pid) async{
    QuerySnapshot snapshot = await payCollection.where('pid', isEqualTo: pid).get();
    String tripId = snapshot.docs[0].get('tripId').toString();
    return tripId;
  }


  Future<String> getDistance(String uid ) async {
    QuerySnapshot snapshot = await userCollection.where('uid', isEqualTo: uid).get();
    if (snapshot.docs.isNotEmpty) {
      GeoPoint geoPoint1 = snapshot.docs[0].get('position');
      GeoPoint geoPoint2 = snapshot.docs[0].get('destination');
      LatLng p1 = LatLng(geoPoint1.latitude, geoPoint1.longitude);
      LatLng p2 = LatLng(geoPoint2.latitude, geoPoint2.longitude);
      var distance = const Distance();
      int decimalPlaces = 1;
      final km = distance.as(LengthUnit.Kilometer, p1, p2);
      String result = km.toStringAsFixed(decimalPlaces);
      return result;
    }else{
      return "Not found user";
    }
  }

  Future<double> getPrice(String distance) async{
    try{
      double distanceParse = double.parse(distance);
      double price = 0.5*distanceParse;
      return price;
    }
    catch (e){
      return 0;
    }
  }

  //goods
  Future createGoods(String uid, String phone, String description, String tripId, String payMethod, String position, String destination) async{
    DocumentReference documentReference = await goodsCollection.add({
      'gid': '',
      'uid': uid,
      'phone': phone,
      'description': description,
      'tripId': tripId,
      'status': 'Wait',
      'isDelivery': false,
      'payMethod': payMethod,
      'position': position,
      'destination': destination
    });
    await documentReference.update({
      'gid': documentReference.id
    });

  }


  Future getGoodsDelivery(String uid) async{
    QuerySnapshot snapshot = await goodsCollection.where('uid', isEqualTo: uid).get();
    return snapshot;
  }

  Future deliveryGoods(String gid) async{
    DocumentReference documentReference = goodsCollection.doc(gid);
    await documentReference.update({
      'isDelivery': true
    });
  }

  Future notDeliveryGoods(String gid) async{
    DocumentReference documentReference = goodsCollection.doc(gid);
    await documentReference.update({
      'isDelivery': false
    });
  }

  Future approveDelivery(String gid) async{
    DocumentReference documentReference = goodsCollection.doc(gid);
    await documentReference.update({
      'status': 'Approved'
    });
  }

  Future rejectDelivery(String gid) async{
    DocumentReference documentReference = goodsCollection.doc(gid);
    await documentReference.update({
      'status': 'Reject'
    });
  }











  }







