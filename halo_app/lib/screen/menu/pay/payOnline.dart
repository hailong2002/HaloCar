import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:halo_app/screen/menu/pay/paypalWebview.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:halo_app/shared/widget.dart';
import 'package:webview_flutter/webview_flutter.dart';


class MakePayment extends StatefulWidget {
  const MakePayment({Key? key, required this.tripId, required this.amount, required this.driverId, required this.onPressDone}) : super(key: key);
  final String tripId;
  final double amount;
  final String driverId;
  final Function() onPressDone;
  @override
  State<MakePayment> createState() => _MakePaymentState();
}

class _MakePaymentState extends State<MakePayment> {
  DatabaseService databaseService = DatabaseService();
  User? user = FirebaseAuth.instance.currentUser;

  void payOnlineDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: FutureBuilder(
                      future: databaseService.gettingUserData(widget.driverId),
                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(color: Colors.white);
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                     } else{
                        DocumentSnapshot doc = snapshot.data.docs[0];
                      return Text('Send ${widget.amount} usd to email:\n${doc['paypalEmail']}', style:const TextStyle(fontSize: 14),);
            }}),
          content:  Container(
              width: 450,
              height: 400,
              child:  const WebView(
                initialUrl: 'https://www.sandbox.paypal.com/myaccount/transfer/homepage',
                javascriptMode: JavascriptMode.unrestricted,
              ),
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                  onPressed: (){
                    databaseService.makePayment(user!.uid, widget.amount, widget.tripId, widget.driverId);
                    Navigator.pop(context);
                    widget.onPressDone();
                  },
                  child: Text('Done')
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
              onPressed: (){
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (BuildContext context) => UsePaypal(
                //         sandboxMode: true,
                //         clientId:
                //         "AYFkezo59v6ceYQcHoSaZHcZnuP6eiM7UzC-ySkUoI0NStWHVo6-pt_wM60vTsg10x4bQ5VSXsvZsCXN",
                //         secretKey:
                //         "EC7uj600t_c_51Ah2D0Ko5ANIFnzj1RIaLF9_OCi51LxifCM-kIOBEdzcy6z2Nz41MuBqLNFcVT5_cGU",
                //         returnURL: "https://samplesite.com/return",
                //         cancelURL: "https://samplesite.com/cancel",
                //         transactions: const [
                //           {
                //             "amount": {
                //               "total": '20',
                //               "currency": "USD",
                //               "details": {
                //                 "subtotal": '20',
                //                 "shipping": '0',
                //                 "shipping_discount": 0
                //               }
                //             },
                //             "description": "The payment transaction description.",
                //             "payment_options": {
                //               "allowed_payment_method":
                //                   "INSTANT_FUNDING_SOURCE"
                //             },
                //             "item_list": {
                //               "items": [
                //                 {
                //                   "name": "A demo product",
                //                   "quantity": 1,
                //                   "price": '20',
                //                   "currency": "USD"
                //                 }
                //               ],
                //
                //               // shipping address is not required though
                //               "shipping_address": {
                //                 "recipient_name": "Jane Foster",
                //                 "line1": "Travis County",
                //                 "line2": "",
                //                 "city": "Austin",
                //                 "country_code": "US",
                //                 "postal_code": "73301",
                //                 "phone": "+00000000",
                //                 "state": "Texas"
                //               },
                //             }
                //           }
                //
                //
                //
                //         ],
                //         note: "Contact us for any questions on your order.",
                //
                //         onSuccess: (Map params) async {
                //           print("onSuccess: $params");
                //         },
                //         onError: (error) {
                //           print("onError: $error");
                //         },
                //         onCancel: (params) {
                //           print('cancelled: $params');
                //         }),
                //   ),
                // );
                payOnlineDialog();
                // nextScreen(context,PayPalLoginScreen(tripId: widget.tripId, amount: widget.amount, driverId: widget.driverId));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white ,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side:const BorderSide(color: Colors.blue, width: 3)),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15)
              ),
              child: const Text('Pay now!\nOnline payment',
                style: TextStyle(color: Colors.blue, fontSize: 17, fontFamily: 'Outfit', fontWeight: FontWeight.w900))
        );
  }
}

