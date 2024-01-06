import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:halo_app/helper/helper_function.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:email_otp/email_otp.dart';
import 'package:halo_app/shared/widget.dart';
import 'package:pinput/pinput.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //Sign in with google
  Future<bool> signInWithGoogle() async{
    try {
      // Begin interactive sign in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // Obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      // Create a new credential for user
      final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User user = userCredential.user!;
      final userExist = await DatabaseService().isUserExist(user.uid);
      if(!userExist){
        DatabaseService(uid: user.uid).savingUserData(phone, gUser.email);
      }
      // await _auth.signInWithCredential(credential);
      return true;
    }catch (e){
      print('Error: $e');
      return false;
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password)async{
      try{
        User user = (await _auth.signInWithEmailAndPassword(email: email, password: password)).user!;
        return true;
      }on FirebaseAuthException catch(e){
        print(e.message);
        return false;
      }
  }

  //Logout
  Future logOut() async{
    try{
      await HelperFunction.saveUserLoggedInStatus(false);
      await HelperFunction.saveUserPhoneNumberSP('');
      await _auth.signOut();
    }catch (e){
      return null;
    }
  }

  String verId = '';
  String phone = '';
  String email = '';
  String verificationId = '';
  String sms = '';

  //Send OTP
  Future<void> sendOTP(String phoneNumber) async{
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential){},
      verificationFailed: (FirebaseAuthException e) {
        print('Verification Failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('Code Auto Retrieval Timeout: $verificationId');
        this.verificationId = verificationId;
      },
      timeout: const Duration(seconds: 120),
  );
    phone = phoneNumber;
}

  Future<bool> verifyOTP(String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    try {
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User user = userCredential.user!;
      print('Verification Successful: ${user.uid} $verificationId');
      final userExist = await DatabaseService().isUserExist(user.uid);
      if(!userExist){
        DatabaseService(uid: user.uid).savingUserData(phone, email);
      }
      return true;

    } catch (e) {
      print('Verification Failed: $e');
      return false;
    }
  }




}
