import 'dart:async';

import 'package:flutter/material.dart';
import 'package:halo_app/helper/helper_function.dart';
import 'package:halo_app/screen/authentication/email_sign_in.dart';
import 'package:halo_app/screen/authentication/otp_screen.dart';
import 'package:halo_app/screen/home.dart';
import 'package:halo_app/screen/menu/account_menu/terms.dart';
import 'package:halo_app/services/auth_service.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:halo_app/shared/widget.dart';
import 'package:halo_app/shared/constants.dart';
import 'package:flutter/gestures.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';


class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String phoneNumber = '';
  String otpPin = '';
  AuthService authService = AuthService();
  bool screenState = true;
  String verificationId = '';
  String countryDial = '+84';
  int remainingTime  = 60;
  Timer? timer;
  bool _visible = false;


  void startCountdown(){
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(remainingTime >0){
        setState(() {
          remainingTime--;
        });
      }else{
        timer.cancel();
        remainingTime = 100;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DismissKeyboard(
        child: SingleChildScrollView(
          child: Form(
            child: Stack(
              children: [
                  Container(
                    height: 640,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomLeft,
                        colors: [Colors.cyan, Colors.white]
                      )
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:const  [
                              Padding(
                                padding: EdgeInsets.only(top: 40, left: 115, bottom: 5),
                                child: Image(image: AssetImage('assets/images/logo.png'),
                                height: 100, color:Colors.white,),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 7.0),
                                child: Text("Halo Car",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 60,
                                        fontFamily: 'Outfit'
                                    )
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(left: 12.0),
                                child: Text("Book a car now with Halo Car !", style: TextStyle(fontSize: 18,  color: Colors.white54, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            Container(
                              width: 340,
                              decoration: const  BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                              ),
                              child: Padding(padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                child: Column(
                                  children: [
                                    // screenState ? stateLogin() : stateOTP(),
                                    stateLogin(),
                                    InkWell(
                                      onTap: (){
                                        setState(() {
                                          _visible = phoneNumber.length < 4 || phoneNumber.contains(RegExp(r'[a-zA-Z]'));
                                        });
                                        if (!_visible) {
                                          print('Valid phone number');
                                          nextScreen(context, OtpVerify(phoneNumber: phoneNumber));
                                        } else {
                                          print('Invalid phone number');
                                        }
                                      },
                                      child: Container(
                                        width: 150,
                                        height: 50,
                                        decoration:BoxDecoration(
                                          borderRadius: BorderRadius.circular(30),
                                          color: Colors.cyan,
                                        ),
                                        child: const Center(
                                          child: Text('Login',
                                              style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold, fontFamily:'Outfit')),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height:10),
                                    Visibility(visible: _visible, child: const Text('Invalid phone number', style: TextStyle(color: Colors.redAccent) )),
                                    const SizedBox(height:10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        children:const[
                                          Expanded(child: Divider(thickness: 0.6, color: Colors.grey)),
                                          Text("  Or log in with  ", style: TextStyle(color: Colors.grey, fontSize: 16,fontWeight: FontWeight.bold)),
                                          Expanded(child: Divider(thickness: 0.6, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height:5),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // InkWell(
                                          //   onTap: (){
                                          //     nextScreen(context, const SignInWithEmail());
                                          //   },
                                          //     child: Container(
                                          //         width: 60,
                                          //         height: 60,
                                          //         decoration: BoxDecoration(
                                          //             borderRadius: BorderRadius.circular(30),
                                          //             color: Colors.white,
                                          //         ),
                                          //         child: Padding(
                                          //           padding: const EdgeInsets.all(10.0),
                                          //           child: Icon(Icons.email),
                                          //         ),
                                          //     ),
                                          // ),
                                          const SizedBox(width:15),
                                          InkWell(
                                            onTap: ()async{
                                              bool isVerified = await authService.signInWithGoogle();
                                              if(isVerified){
                                                HelperFunction.saveUserLoggedInStatus(true);
                                                nextScreen(context, const Home());
                                              }

                                            },
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(30),
                                                boxShadow: [BoxShadow(offset:const Offset(0,1), blurRadius:1, color: Colors.grey.withOpacity(0.3), spreadRadius: 3)],
                                                color: Colors.white,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Image.asset('assets/images/googleButton.png'),
                                              ),
                                            ),
                                          ),
                                        ]
                                    ),
                                    const SizedBox(height:5),

                                  ],
                                ),
                              ),
                            ),

                              ],

                        )
                      ],
                    ),
                  )
                ],

            ),
          ),
        ),
      )
    );
  }

  Widget stateLogin(){
    return Column(
      children: [
        const SizedBox(height: 10),
        RichText(
          text: const TextSpan(
              text:'Login/Register for ',
              style: TextStyle(fontSize: 16, color: Colors.black45),
              children: <TextSpan>[
                TextSpan(text: 'Halo Car', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(text:' account now', style:TextStyle(fontSize: 16, color: Colors.black45))
              ]
            ),
          ) ,
        const SizedBox(height: 10),
        SizedBox(
          height: 60,
          // decoration: shadowBox,
          child: DefaultTextStyle(
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
            child: IntlPhoneField(
              key: formKey,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold,),
              decoration: textInputDecoration.copyWith(
                  labelText: '  Phone Number',
                labelStyle: const TextStyle(fontWeight: FontWeight.bold)
              ),
              onCountryChanged: (country) {
                setState(()=> countryDial = '+${country.dialCode}');
              },
              initialCountryCode: 'VN',
              onChanged: (val) {
                  setState(() => phoneNumber = val.completeNumber);
              },
              autovalidateMode: AutovalidateMode.disabled,
              disableLengthCheck: true,

        ),
          )
          ),
        const SizedBox(height: 5),
        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
              text:"By logging in, you agree to the ",
              style: const TextStyle(fontSize: 15, color: Colors.black45),
              children: <TextSpan>[
                TextSpan(
                    text: "Halo Car's Terms of Service",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[300]),
                    recognizer: TapGestureRecognizer()..onTap = (){
                      nextScreen(context, const Terms() ) ;
                    }
                ),
                const TextSpan(text: ' and ',style: TextStyle(fontSize: 15, color: Colors.black45)),
                TextSpan(
                    text: "Privacy Policy",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Colors.teal[300]),
                    recognizer: TapGestureRecognizer()..onTap = (){
                      nextScreen(context, const Terms() ) ;
                    }
                )
              ]
          ),
        ) ,
        const SizedBox(height: 20),

      ],
    );
  }




}
