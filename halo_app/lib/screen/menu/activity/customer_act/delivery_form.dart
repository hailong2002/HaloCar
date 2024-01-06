import 'package:flutter/material.dart';
import 'package:halo_app/providers/user_data.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:halo_app/shared/constants.dart';
import 'package:halo_app/shared/widget.dart';
import 'package:provider/provider.dart';

import '../../pay/payOnline.dart';

class DeliveryForm extends StatefulWidget {
  const DeliveryForm({Key? key, required this.tripId, required this.price, required this.driverId, required this.uid}) : super(key: key);
  final String tripId;
  final double price;
  final String driverId;
  final String uid;
  @override
  State<DeliveryForm> createState() => _DeliveryFormState();
}

class _DeliveryFormState extends State<DeliveryForm> {
  String phone = '';
  String description ='';
  bool isOnlinePay = false;
  String option1 = 'Pay when the driver arrives to pick up the goods.';
  String option2 = 'The consignee will pay';
  String option3 = 'I will pay online';
  String selectedOption = '';
  final key1 = GlobalKey<FormState>();
  final key2 = GlobalKey<FormState>();
  DatabaseService databaseService = DatabaseService();

  void onPressDone(){
    setState(() {
      isOnlinePay = true;
    });
  }
  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    return Scaffold(
      appBar: const MyAppBar(title: 'Delivery form'),
      body:   Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            child:  SingleChildScrollView(
              child: DismissKeyboard(
                child: Column(
                    children: [
                      const Text('*The delivery price is the same as the passenger transport price',
                          style: TextStyle(color: Colors.cyan, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                      const SizedBox(height: 5),
                      Form(
                        key: key1,
                        child: TextFormField(
                          style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                          decoration: textInputDecoration.copyWith(
                              hintText: 'Receiver phone number',
                              hintStyle:  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
                          ),
                          onChanged: (val){
                            phone = val;
                          },
                          validator: (val){
                            if(val!.length != 10){
                              return 'Invalid phone number, must be 10 characters!';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Form(
                        key: key2,
                        child: TextFormField(
                          maxLines: 3,
                          style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                          decoration: textInputDecoration.copyWith(
                              hintText: 'Name and description of goods',
                              hintStyle:  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
                          ),
                          onChanged: (val){
                            description = val;
                          },
                          validator: (val){
                            if(val!.length < 5 || val.length > 100){
                              return 'Description must be in range 5-100 characters!';
                            }
                            return null;
                          },
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title:  Text(option1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                        leading: Radio<String>(
                          value: option1,
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value!;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(option2, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                        leading: Radio<String>(
                          value: option2,
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value!;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(option3, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                        leading: Radio<String>(
                          value: option3,
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value!;
                            });
                          },
                        ),
                      ),
                      selectedOption == option3 ?
                      MakePayment(tripId: widget.tripId, amount: widget.price, driverId: widget.driverId, onPressDone: onPressDone)
                          : const SizedBox(),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: (){
                            if(key1.currentState!.validate() && key2.currentState!.validate()){
                              databaseService.createGoods(widget.uid, phone, description, widget.tripId, selectedOption, userData.position, userData.destination);
                              showToast('Successfully', Colors.cyanAccent);
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                          child:const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                      )
                    ],
                  ),
              ),
            ),
            ),


      ),
    );
  }
}
