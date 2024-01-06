import 'package:flutter/material.dart';
import 'package:halo_app/services/auth_service.dart';
import 'package:halo_app/shared/constants.dart';

import '../../helper/helper_function.dart';
import '../../shared/widget.dart';
import '../home.dart';

class SignInWithEmail extends StatefulWidget {
  const SignInWithEmail({Key? key}) : super(key: key);

  @override
  State<SignInWithEmail> createState() => _SignInWithEmailState();
}

class _SignInWithEmailState extends State<SignInWithEmail> {
  String email = '';
  String password = '';
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: DismissKeyboard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 200),
            child: Column(
              children: [
                TextFormField(
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: textInputDecoration.copyWith(
                      labelText: 'Email',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      prefixIcon: const Icon(Icons.email_outlined)
                  ),
                  onChanged: (val){
                    setState(()=> email = val);
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: textInputDecoration.copyWith(
                      labelText: 'Password',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      prefixIcon: const Icon(Icons.vpn_key_outlined)
                  ),
                  onChanged: (val){
                    setState(()=> password = val);
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: ()async {
                    bool isVerified = await authService.signInWithEmailAndPassword(email, password);
                    if(isVerified){
                        HelperFunction.saveUserLoggedInStatus(true);
                        nextScreen(context, const Home());
                      }
                    },
                    child: const Icon(Icons.login)
                )


              ],
            ),
          ),

        ),
      ),
    );
  }
}
