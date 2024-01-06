import 'dart:io';

import 'package:flutter/material.dart';
import 'package:halo_app/services/auth_service.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:halo_app/shared/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_data.dart';
import '../../../shared/widget.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  DatabaseService databaseService = DatabaseService();
  String phoneNumber = '';
  String fullName = '';
  String email = '';
  File? imageFile;
  String? avatarUrl;

  Future uploadImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(()=> imageFile = imageTemp);
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  void handleUpdateDatabase(String uid){
    if(imageFile == null){
      databaseService.updateUserData(uid, phoneNumber, email, fullName, File(''));
    }else{
      databaseService.updateUserData(uid, phoneNumber, email, fullName, imageFile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.cyan,
          title: const  Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white )),
          leading: IconButton(
            onPressed: (){Navigator.pop(context);},
            icon: const Icon(Icons.chevron_left, size: 35, color: Colors.white),
          ),
      ),
      backgroundColor: Colors.cyan,
      body: DismissKeyboard(
        child: SingleChildScrollView(
          child: Container(
            height: 520,
            color: Colors.white.withOpacity(0.3),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white),
                      child: Column(
                        children: <Widget>[
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow:[ BoxShadow(offset:const Offset(0,1), blurRadius:1, color: Colors.grey.withOpacity(0.5), spreadRadius: 4)]
                          ),
                          width: 150,
                          height: 150,
                          child: GestureDetector(
                            onTap: uploadImage,
                              child: ClipOval(
                                child: userData.avatarUrl.isNotEmpty ? Image.network(userData.avatarUrl, width: 150, height: 150) :
                                (imageFile != null ? Image.file(imageFile!) : const Icon(Icons.add_a_photo_outlined, size: 60, color: Colors.white,))
                              )
                          ),
                        ),
                          // const SizedBox(height: 10),
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child:  Column(
                                  children: [
                                    const SizedBox(height: 30),
                                    TextFormField(
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      decoration: textEditDecoration.copyWith(hintText: userData.fullName,
                                          prefixIcon: const Icon(Icons.edit_outlined, color: Colors.cyan)
                                      ),
                                      onChanged: (val){
                                          fullName = val;
                                      },
                                      validator: (val){
                                        if(val!.isEmpty) return 'Invalid name';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      enabled:userData.phoneNumber.isEmpty ? true:  false,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      decoration:textEditDecoration.copyWith(hintText: userData.phoneNumber,
                                      prefixIcon: const Icon(Icons.phone_iphone_rounded, color: Colors.cyan)),
                                      onChanged: (val) {
                                          phoneNumber = val;
                                      },
                                      validator: (val){
                                        return RegExp( r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(val!) ? null : 'Invalid phone number';
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      enabled:userData.email.isEmpty ? true:  false,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      decoration: textEditDecoration.copyWith(
                                        hintText: userData.email,
                                        prefixIcon: const Icon(Icons.email_rounded, color: Colors.cyan)
                                      ),
                                      onChanged: (val)=> email = val,
                                      validator: (val){
                                        return RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                            .hasMatch(val!)
                                            ? null
                                            : "Please enter a valid email";
                                      },
                                    ),

                                    const SizedBox(height: 25),
                                    ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Constants().mainColor,
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(25.0),
                                            ),
                                          ),
                                          onPressed: (){
                                              fullName =  fullName.isEmpty ? userData.fullName : fullName;
                                              phoneNumber =phoneNumber.isEmpty ? userData.phoneNumber : phoneNumber;
                                              email = email.isEmpty? userData.email : email;
                                              handleUpdateDatabase(userData.uid);
                                              showToast('Update successfully', Colors.cyanAccent);
                                            },
                                          child: const Text('Save', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
