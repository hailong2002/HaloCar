import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key, required this.isSignedIn}) : super(key: key);
  final bool isSignedIn;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.cyan
        ),
        // color: Colors.tealAccent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${isSignedIn}'),
               Image.asset('assets/images/logo.png', color: Colors.white, width: 100),
               const Text('Halo Car', style: TextStyle(fontFamily: 'Outfit', fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold))
            ],
          ),
      ),
    );
  }
}
