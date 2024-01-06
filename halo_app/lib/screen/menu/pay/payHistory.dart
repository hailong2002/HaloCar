import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:halo_app/providers/user_data.dart';
import 'package:halo_app/screen/menu/pay/payDetail.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:halo_app/shared/widget.dart';
import 'package:provider/provider.dart';

import '../../../shared/constants.dart';
import '../../../shared/loading.dart';
class PayHistory extends StatefulWidget {
  const PayHistory({Key? key}) : super(key: key);

  @override
  State<PayHistory> createState() => _PayHistoryState();
}

class _PayHistoryState extends State<PayHistory> {
  User? user = FirebaseAuth.instance.currentUser;
  DatabaseService databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  void updatePaypal() async{
    String paypalEmail = '';
    showDialog(
        context: context,
        builder: (BuildContext context){
          return Form(
            key: _formKey,
            child: AlertDialog(
              title: const Text('Email of Paypal account '),
              content: TextFormField(
                decoration: textInputDecoration.copyWith(
                  prefixIcon: const Icon(Icons.paypal)
                ),
                onChanged: (val){
                  setState(() {
                    paypalEmail = val;
                  });
                },
                validator: (val){
                  return RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(val!)
                      ? null
                      : "Please enter a valid email";
                },
              ),
              actions: [
                ElevatedButton(onPressed: (){
                  if(_formKey.currentState!.validate()){
                    databaseService.updatePaypalEmail(paypalEmail, user!.uid);
                    showToast('Save PayPal email successfully', Colors.cyan);
                  }
                }, child: const Text('Save'))
              ],
            ),
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    userData.getUserData();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan,
          automaticallyImplyLeading: false,
          title: const  Text('Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white )),
          actions: [
            IconButton(
                onPressed: updatePaypal,
                icon: const Icon(Icons.paypal)
            )
          ],
        ),
      body: SizedBox(
        height: 500,
        child: userData.pay.isEmpty ? const Center(child: Text("You don't have any transcriptions.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.cyan))):
        FutureBuilder<QuerySnapshot>(
                  future: databaseService.getPaymentOfUser(user!.uid),
                  builder: (context, snapshot){
                      if(!snapshot.hasData){
                        return const SizedBox();
                      } else{
                        List<DocumentSnapshot> documents = snapshot.data!.docs;
                        documents.sort((a, b) {
                          DateTime dateA = a['date'].toDate();
                          DateTime dateB = b['date'].toDate();
                          return dateB.compareTo(dateA);
                        });
                        return SizedBox(
                          height: 500,
                          child: ListView.builder(
                            itemCount: documents.length,
                            itemBuilder: (BuildContext context, int index) {
                              DocumentSnapshot doc = documents[index];
                              DateTime date = doc['date'].toDate();
                              return  ListTile(
                                trailing:const Icon(Icons.chevron_right),
                                title: Text('Amount: ${doc['amount']} usd',style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                subtitle: Text('${date.day}/${date.month}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                onTap: (){
                                  nextScreen(context, PayDetail(pid: doc['pid']));
                                },
                              );
                            },

                          ),
                        );

                      }
              })

      ),
    );
  }
}
