import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalLoginScreen extends StatefulWidget {
  const PayPalLoginScreen({Key? key, required this.tripId, required this.amount, required this.driverId}) : super(key: key);
  final String tripId;
  final double amount;
  final String driverId;
  @override
  State<PayPalLoginScreen> createState() => _PayPalLoginScreenState();
}

class _PayPalLoginScreenState extends State<PayPalLoginScreen> {
  DatabaseService databaseService = DatabaseService();
  User? user = FirebaseAuth.instance.currentUser;
  String driverEmail = '';
  // void getDriverEmailPaypal() async{
  //   DocumentSnapshot snapshot = await databaseService.gettingUserData(widget.driverId);
  //   driverEmail =  snapshot.get('paypalEmail').toString();
  // }
  //
  // @override
  // void initState(){
  //   super.initState();
  //   getDriverEmailPaypal();
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseService.gettingUserData(widget.driverId),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Colors.white);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          driverEmail = snapshot.data.docs[0].get('paypalEmail')?.toString() ?? 'No email';
          return  Scaffold(
           appBar: AppBar(
            title: const Text('Send money via  email below', style: TextStyle(fontFamily: 'Roboto', fontSize: 15)),
            bottom: PreferredSize(
                preferredSize: Size.zero,
                child: Text(driverEmail, style: const TextStyle(fontSize: 12, color: Colors.white))
            ),
            leading: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  databaseService.makePayment(user!.uid, widget.amount, widget.tripId, widget.driverId);
                  Navigator.pop(context);
                }
            ),
          ),

          body: const WebView(
            initialUrl: 'https://www.sandbox.paypal.com/myaccount/transfer/homepage',
            javascriptMode: JavascriptMode.unrestricted,
          ),
        );
    }
      },

    );

  }

}

