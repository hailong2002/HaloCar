import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:halo_app/screen/menu/account_menu/account.dart';
import 'package:halo_app/screen/menu/activity/activity.dart';
import 'package:halo_app/screen/home.dart';
import 'package:halo_app/screen/menu/pay/payOnline.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'constants.dart';


const textInputDecoration = InputDecoration(
  labelStyle: TextStyle( fontSize: 18, color: Colors.grey),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide:  BorderSide(color: Colors.blueAccent, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Colors.grey, width: 3),
    ),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
);

final textEditDecoration = InputDecoration(
  // labelStyle: TextStyle( fontSize: 18, color: Constants().mainColor),
  hintStyle: const TextStyle(fontSize: 20, color: Colors.grey),
  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
  focusedBorder: OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(20)),
    borderSide:  BorderSide(color: Constants().mainColor, width: 2),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius:const BorderRadius.all(Radius.circular(20)),
    borderSide: BorderSide(color: Constants().mainColor, width: 2),
  ),
  border: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
    // icon: const CircleAvatar(backgroundColor: Colors.cyan, child: Icon(Icons.edit, color: Colors.white)),
);

final homeTextDecoration =  InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 10,),
  prefixIcon: const Icon(Icons.search_rounded, color: Colors.black,),
  hintText: 'Where to go ?',
  hintStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  filled: true,
  fillColor: Colors.white,
  focusedBorder: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30)),
    borderSide:  BorderSide(color: Colors.white, width: 2),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(30)),
    borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 2),
  ),
  border: OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(30)),
    borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
  ),
);

const shadowBox = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(15)),
  boxShadow: [
    BoxShadow(
      blurRadius: 10,
      spreadRadius: 1,
      offset: Offset(0, 6),
      color: Colors.grey
      // color: Color(0xFF26C6DA)
    )
  ]
);

void nextScreen(context, page){
  Navigator.push(context, MaterialPageRoute(builder: (context)=>page));
}

void ShowSnackBar(context, color, message){
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.cyan,
          content: Text(message, style: const TextStyle(fontSize: 17)),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(label:'Ok', onPressed: (){}, textColor: Colors.white),
      )
  );
}

void showToast(String msg, Color color) {
  Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.CENTER,
      fontSize: 16.0,
      backgroundColor: Colors.white,
      textColor: color,
  );
}



class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.cyan,
        title:Row(
          children:  [
            Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 40),
          onPressed: (){
            Navigator.pop(context);
          },
        )
    );
  }
}











