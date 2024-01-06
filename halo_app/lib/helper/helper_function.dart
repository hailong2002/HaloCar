import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction{
  // keys
  static String userLoggedInKey = 'LOOGEDINKEY';
  static String userPhoneNumberKey = 'PHONENUMBERKEY';
  static String userEmailKey = 'EMAILKEY';


  // Saving the data to Share preferences
  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setBool(userLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserPhoneNumberSP(String phoneNumber) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(userPhoneNumberKey, phoneNumber);
  }

  static Future<bool> saveUserEmailSP(String email) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(userEmailKey, email);
  }

  // Getting the data from Share preferences
  static Future<bool?> getUserLoggedInStatus() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(userLoggedInKey);
  }

  static Future<String?> getUserPhoneNumberSP() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userPhoneNumberKey);
  }





}