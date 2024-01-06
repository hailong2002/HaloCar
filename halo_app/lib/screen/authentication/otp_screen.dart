import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:halo_app/helper/helper_function.dart';
import 'package:halo_app/screen/home.dart';
import 'package:halo_app/screen/menu/account_menu/terms.dart';
import 'package:halo_app/services/auth_service.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:halo_app/shared/widget.dart';
import 'package:halo_app/shared/constants.dart';
import 'package:flutter/gestures.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:halo_app/screen/authentication/login.dart';

import '../home.dart';

class OtpVerify extends StatefulWidget {
  OtpVerify({Key? key, required this.phoneNumber}) : super(key: key);
  String? phoneNumber;
  @override
  State<OtpVerify> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  AuthService authService = AuthService();
  String otpPin = '';
  String verificationId = 'it is empty bro';
  int remainingTime  = 100;
  Timer? timer;
  bool _visible = false;
  bool isVerified = true;


  void startCountdown(){
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(remainingTime >0){
        setState(() {
          remainingTime--;
        });
      }else{
        timer.cancel();
      }
    });
  }

  @override
  void initState(){
    super.initState();
    startCountdown();
    authService.sendOTP(widget.phoneNumber!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: DismissKeyboard(
            child: Container(
              height: 600,
                decoration:  BoxDecoration(
                  color: Colors.cyan[300]
                ),
                child: Stack(
                  children: [
                     Padding(
                       padding: const EdgeInsets.only(top: 20),
                       child: ElevatedButton(
                          onPressed: (){Navigator.pop(context);},
                          style: ElevatedButton.styleFrom(shape: const CircleBorder(), backgroundColor: Colors.white),
                          child: const Icon(Icons.chevron_left, color: Colors.black,),
                        ),
                     ),
                    
                    Padding(
                      padding: const EdgeInsets.only(top:50, left: 20),
                      child:  Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children:[
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.3)
                                )),
                               Image.asset('assets/images/otp.png', width: 80, height: 100, color: Colors.white)
                          ]),
                          const SizedBox(height: 15),
                          const Text('Verify OTP', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'Roboto')),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const Text('Please enter the code we just send to ',
                                    style: TextStyle(color: Colors.white, fontSize: 17,fontWeight: FontWeight.bold)),
                                Text('${widget.phoneNumber}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize:17,
                                        fontWeight: FontWeight.bold
                                    ))
                              ],
                            )
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 300),
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(65)),
                          color: Colors.white
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
                        child: Column(
                            children: [
                                  PinCodeTextField(
                                    keyboardType: TextInputType.number,
                                    appContext: context,
                                    length: 6,
                                    textStyle: const TextStyle(fontSize: 30),
                                    pinTheme: PinTheme(
                                      shape: PinCodeFieldShape.box,
                                      borderRadius: BorderRadius.circular(25),
                                      fieldHeight: 60,
                                      fieldWidth: 50,
                                      inactiveColor: Colors.grey,
                                      activeColor: Colors.cyanAccent,
                                      selectedColor: Colors.cyanAccent,
                                    ),
                                    onChanged: (val){
                                      setState(()=> otpPin = val);
                                    },
                                  ),
                                  remainingTime > 0 ?
                                   Text('$remainingTime', style: const TextStyle(fontSize: 22, color: Colors.cyan)):
                                   Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children:const [
                                          Icon(Icons.warning_amber, color: Colors.redAccent,),
                                          Text(' OTP is incorrect or expired', style: TextStyle(color: Colors.redAccent, fontSize: 20,fontWeight: FontWeight.bold),)
                                        ],
                                      ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text("Don't receive the code?", style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),
                                        TextButton(
                                            onPressed: (){
                                              authService.sendOTP(widget.phoneNumber!);
                                              remainingTime = 100;
                                              startCountdown();
                                              },
                                            child:  Text('Resend',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.cyan[400],
                                                  fontWeight: FontWeight.bold,
                                                  decoration: TextDecoration.underline,
                                              )
                                            )
                                          )
                                        ],
                                  ),
                              const SizedBox(height: 20),
                              InkWell(
                                child: Container(
                                  width: 180,
                                  height: 60,
                                  decoration:BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: remainingTime > 0 ? Colors.cyan : Colors.cyan.withOpacity(0.2),
                                  ),
                                  child: const Center(
                                    child: Text('Login',
                                        style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                onTap: () async {
                                  if (remainingTime > 0) {
                                    bool _isVerified = await authService.verifyOTP(otpPin);
                                    if (_isVerified == true) {
                                      HelperFunction.saveUserPhoneNumberSP(widget.phoneNumber!);
                                      HelperFunction.saveUserLoggedInStatus(true);
                                      nextScreen(context, Home());
                                    }
                                    else {
                                      showToast('Incorrect OTP, please re-enter', Colors.red);
                                    }
                                  } else {
                                      null;
                                  }
                                }),
                              const SizedBox(height: 20),
                            ]),
                      ),
                    ),
                  ),
                ])
            ),
          ),
        )
    );
  }
}
