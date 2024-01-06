import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:halo_app/screen/menu/account_menu/register.dart';
import 'package:halo_app/screen/menu/account_menu/terms.dart';
import 'package:halo_app/shared/widget.dart';

import '../../../shared/constants.dart';

class BecomeDriver extends StatefulWidget {
  const BecomeDriver({Key? key}) : super(key: key);

  @override
  State<BecomeDriver> createState() => _BecomeDriverState();
}

class _BecomeDriverState extends State<BecomeDriver> {
  bool _isExpanded = false;
  bool showFloatBtn = false;

  void handleExpand(){
    setState(()=> _isExpanded  = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Become a driver', style:  TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black)),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 40,color: Colors.black),
            onPressed: (){
              Navigator.pop(context);
            },
          )
      ),
        body: NotificationListener<UserScrollNotification>(
          onNotification: (notification){
            if(notification.direction == ScrollDirection.forward)
              if(showFloatBtn) setState(()=> showFloatBtn = false);
            if(notification.direction == ScrollDirection.reverse)
              if(!showFloatBtn) setState(()=> showFloatBtn = true);
            return true;
          },
          child: SingleChildScrollView(
              child: Column(
                children: [
                   Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children:  [
                        const Text('Become a partner of Halo Car',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35)),
                        const Text("Become abc partner to earn income and more. Let's start the journey together.", style: TextStyle(fontSize: 17),),
                        ElevatedButton(
                          onPressed: (){nextScreen(context, const Register());},
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(_isExpanded ? 30 : 60)
                              )
                          ),
                          child:  const Text('Register'),
                        ),
                        // Image.asset('assets/images/becomeDr.jpg'),
                        const MyListTile(
                            title: 'Requirement',
                            content: '-Vietnamese citizens age: Male from 18 to 65 years old, Female from 18 to 60 years old. \n'
                            '-Meet the health condition for driving class B2. \n-Negative for heroin. \n-The vehicle has a shelf life of not more than 11 years.'
                        ),
                        const MyListTile(
                            title: 'Documents to be prepared',
                            content: '-Identity card/passport/ID card (valid within 1 month). \n'
                                '-Driving license of class B2 or higher. \n'
                                '-Criminal record (added within 30 days of registration). \n'
                                '-Appointment letter of criminal record/Postal receipt. \n'
                                '-Health certificate (with heroin test). \n'
                                '-Valid car registration or mortgage receipt. \n'
                                '-Certificate of inspection. \n'
                                '-Contract vehicle badges. \n'
                                '-Reflective stamps. \n'
                        ),
                        const MyListTile(
                            title: 'Next step',
                            content: 'Step 1: Click the . button "Register" \n'
                                     'Step 2: Submit your application online \n'
                                     'Step 3: Complete the online training \n'
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ),
      floatingActionButton: Visibility(
        visible: showFloatBtn,
        child: FloatingActionButton(
          onPressed: () { nextScreen(context, const Register()); },
          backgroundColor: Constants().mainColor,
          child: const Icon(Icons.app_registration, color: Colors.white, ),
        ),
      ),

    );
  }
}
