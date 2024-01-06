import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import 'package:halo_app/screen/authentication/login.dart';
import 'package:halo_app/screen/menu/account_menu/become_driver.dart';
import 'package:halo_app/screen/menu/account_menu/profile.dart';
import 'package:halo_app/screen/menu/account_menu/terms.dart';
import 'package:halo_app/services/auth_service.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_data.dart';
import '../../../shared/widget.dart';
import 'car_info.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  AuthService authService = AuthService();
  DatabaseService databaseService = DatabaseService();
  String? avatarUrl= '';
  bool isSwitched = false;
  User? user = FirebaseAuth.instance.currentUser;


  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    userData.getUserData();
    return StreamBuilder(
        stream: databaseService.userCollection.where('uid', isEqualTo: user!.uid).snapshots(),
        builder: (context, snapshot){
          if (!snapshot.hasData) {
            return Text('');
          } else {
            DocumentSnapshot doc = snapshot.data!.docs[0];
            return Scaffold(
              backgroundColor: Colors.cyan[400],
              body:SingleChildScrollView(
                child: Stack(
                    children: [
                      Image.asset('assets/images/acc.png', fit: BoxFit.fill, height: 213),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                                children:  [
                                  Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Padding(
                                        padding:  const EdgeInsets.only(top: 30.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow:[ BoxShadow(offset:const Offset(0,1), blurRadius:1, color: Colors.grey.withOpacity(0.3), spreadRadius: 8)]
                                          ),
                                          height: 40, width: 40,
                                          child: IconButton(
                                              onPressed: (){ nextScreen(context,  Profile());},
                                              icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 25,)
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(top: 50),
                                        child: Center(
                                          child: Container(
                                            decoration:  BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                boxShadow:[ BoxShadow(offset:const Offset(0,1), blurRadius:1, color: Colors.grey.withOpacity(0.5), spreadRadius: 5)]
                                            ),
                                            child: ClipOval(
                                              child: userData.avatarUrl.isNotEmpty ? Image.network(userData.avatarUrl, width: 100, height: 100,):
                                              const Icon(Icons.account_circle, size: 100, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text((doc['fullName']).isEmpty ? 'Please add your name' : doc['fullName'],
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 27)),
                                  const SizedBox(height: 0),
                                  userData.role == "driver" ? const Text('You are a driver', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 15)) : const Text(''),
                                ]
                            ),
                          ),
                          // const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const  Icon(Icons.phone_iphone_outlined, color: Colors.white),
                                  title:  Text(userData.phoneNumber.isEmpty ? '*Add your phone number':userData.phoneNumber , style: const TextStyle(fontWeight: FontWeight.bold, color:Colors.white, fontSize: 20)),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.mail, color: Colors.white),
                                  title:  Text(userData.email.isEmpty ? '*Add your email':userData.email, style: const TextStyle(fontWeight: FontWeight.bold, color:Colors.white,fontSize: 18)),
                                ),
                                const Divider(color: Colors.white, thickness: 0.8),
                                userData.role == 'driver' ?
                                ListTile(
                                  leading: const Icon(Icons.info_outline, color: Colors.white),
                                  title:   const Text('Car information',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 18)),
                                  onTap: (){
                                    nextScreen(context, const CarInfo());
                                  },
                                ) : const SizedBox(),
                                ListTile(
                                  leading:  const Icon(Icons.paste, color: Colors.white),
                                  title:   const Text('Terms and Privacy Policy',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 18)),
                                  onTap: (){
                                    nextScreen(context, const Terms());
                                  },
                                ),
                                ListTile(
                                  leading:  const Icon(Icons.drive_eta_outlined, color: Colors.white),
                                  title:    Text(userData.role != 'driver' ? 'Become a driver' : "You're now driver",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 18)),
                                  // trailing:   userData.role == 'driver' ? Switch(
                                  //   hoverColor: Colors.amber,
                                  //     value: isSwitched,
                                  //     onChanged: (val){
                                  //       setState(()=> isSwitched = val);
                                  //       if(isSwitched){
                                  //         // ShowSnackBar(context, Colors.white, 'Driver mode on');
                                  //         showToast('Driver mode on', Colors.cyan);
                                  //       }else{
                                  //         // ShowSnackBar(context, Colors.white, 'Driver mode off');
                                  //         showToast('Driver mode off',Colors.cyan);
                                  //       }
                                  //     },
                                  //   activeColor: Colors.yellow,
                                  //   activeTrackColor: Colors.teal,
                                  // ) : null,
                                  onTap: (){userData.role != 'driver' ?
                                  nextScreen(context, const BecomeDriver()) : null;
                                  },
                                ),


                                const Divider(color: Colors.white, thickness: 0.8),
                                ListTile(
                                  leading: const Icon(Icons.logout, color: Colors.white),
                                  title:   const Text('Log out',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 18)),
                                  onTap: (){
                                    showDialog(
                                        context: context,
                                        builder: (context){
                                          return AlertDialog(
                                            title: const Text('Log out', style: TextStyle(fontWeight: FontWeight.bold),),
                                            content: const Text('Are you sure want to log out ?', style: TextStyle(fontWeight: FontWeight.bold)),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: (){Navigator.pop(context);},
                                                child: const Text('Cancel', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async{
                                                  await authService.logOut();
                                                  Navigator.of(context).pushAndRemoveUntil(
                                                      MaterialPageRoute(builder: (context)=>const LogIn()),
                                                          (route) => false);
                                                },
                                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent)) ,
                                                child:  const Text('Logout', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                                              )
                                            ],
                                          );
                                        }
                                    );
                                  },
                                ),

                              ],
                            ),
                          ),


                        ],
                      ),
                    ]
                ),
              ),


            );
          }


        });



      }


  }

