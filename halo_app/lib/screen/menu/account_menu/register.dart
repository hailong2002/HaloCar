import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:halo_app/shared/constants.dart';
import 'package:halo_app/shared/widget.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_data.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  DatabaseService databaseService = DatabaseService();

  void registerAsDriver(String uid) async{
    await databaseService.RegisterAsDriver(uid);
  }

  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Register as a driver', style:  TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Colors.black)),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 40,color: Colors.black),
            onPressed: (){
              Navigator.pop(context);
            },
          )
      ),
      body: SingleChildScrollView(
        child: DismissKeyboard(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Drive with Halo Car',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.cyan), textAlign: TextAlign.left, ),
                    const Text('Please follow these steps to create an account.\n',
                      style: TextStyle(fontSize: 18, color: Colors.grey),textAlign: TextAlign.justify),
                    const Text('1.Please Enter your information',
                        style: TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: textInputDecoration.copyWith(labelText: 'City/Province'),
                      onChanged: (val){

                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: textInputDecoration.copyWith(hintText: userData.fullName),
                      onChanged: (val){

                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: textInputDecoration.copyWith(labelText: userData.phoneNumber),
                      keyboardType: TextInputType.number,
                      onChanged: (val){
                      },
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.grey, thickness: 0.6),
                    const SizedBox(height: 5),

                    const Text('2.Submit form',
                        style: TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.bold), textAlign: TextAlign.start),
                    Center(
                      child: ElevatedButton(
                          onPressed: () {
                            registerAsDriver(userData.uid);
                            showToast("You're driver now", Colors.cyan);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Constants().mainColor),
                          child: const Text('Register'),
                      ),
                    )
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
