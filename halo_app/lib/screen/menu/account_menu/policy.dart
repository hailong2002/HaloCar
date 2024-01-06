import 'package:flutter/material.dart';

import '../../../shared/constants.dart';

class Policy extends StatefulWidget {
  const Policy({Key? key}) : super(key: key);

  @override
  State<Policy> createState() => _PolicyState();
}

class _PolicyState extends State<Policy> {

  final ScrollController scrollController = ScrollController();
  bool showScrollButton = false;

  @override
  void initState(){
    super.initState();
    scrollController.addListener(scrollListener);
  }

  void scrollListener(){
    if(scrollController.offset >= 200){
      setState(() => showScrollButton = true);
    }else{
      setState(() => showScrollButton = false);
    }
  }

  void scrollOnTop(){
    scrollController.animateTo(0, duration: const Duration(microseconds: 500), curve: Curves.easeInOut);
  }

  @override
  void dispose(){
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: ListTile(
                leading:const Icon(Icons.chevron_left, size: 35, color: Colors.black,),
                title: const  Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25 )),
                onTap: (){Navigator.pop(context);},
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: const [
                    SizedBox(height: 20),
                    Text('SECURITY NOTICE - Effective October 1, 2023\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17), textAlign: TextAlign.start),
                    Text(textAlign: TextAlign.justify , 'The Privacy Notice below describes how we, Halo Car, collect, store, use, process, save, transfer, disclose and protect your Personal Information. This Privacy Notice applies to all Users of our mobile Applications (including User Applications, Merchant Applications and driver partner Applications), websites, services and products (collectively, the “Apps”), unless they are subject to a separate privacy notice.'),
                    Text(textAlign: TextAlign.justify, 'This Privacy Notice is provided in a layered format for you to navigate through the specific areas outlined below. Please read this Privacy Notice carefully to ensure that you understand our data protection methods. We wanted to make this Notice easier to understand, so we wrote a summary that highlights all the important points. Unless otherwise defined, all capitalized terms used in this Privacy Notice shall have the same meanings as them in the applicable Terms of Use between you and Halo Car.'),
                    Text(textAlign: TextAlign.justify, 'Confirmation and Acceptance\nBy accepting this Privacy Notice, you acknowledge that you have read and understood this Privacy Notice and that you accept all of these terms. In particular, you consent and consent to us collecting, using, disclosing, storing, transferring or otherwise processing your Personal Information in accordance with this Privacy Notice.'),
                    Text(textAlign: TextAlign.justify, "In the event that you provide us with Personal Information relating to other individuals (for example, Personal Information relating to your spouse, family member or friend), you represent and warrant that you have obtained that individual's consent for, and on behalf of that individual, consent to, our collection, use, disclosure and processing of such individual's Personal Information."),
                    Text(textAlign: TextAlign.justify, "You may withdraw your consent to any or all collection, use or disclosure of your Personal Information at any time by giving us reasonable written notice at the contact information set forth below. You can also revoke your consent for us to send you certain notifications and information through the ""opt out" "or ""unsubscribe" "feature set in the messages we send you. Depending on the circumstances and the nature of the consent you revoke, you understand and agree that upon revoking such consent, you may no longer be able to use the Application or certain services. Your withdrawal of consent may result in the termination of your account or your contractual relationship with us, with all arising rights and obligations still fully reserved. Upon receiving notice that you revoke your consent for the collection, use or disclosure of your Personal Information, we will notify you of the possible consequences of revoking that consent so that you can decide if you really want to revoke consent."),
                    Text(textAlign: TextAlign.justify, 'What information do we collect about you?\nWe collect Personal Information when you use our Application. We also collect device and technical information from you and any other information you may submit while using our Application. If you choose not to provide such information, we will not be able to provide the Application to you normally.'),
                    Text(textAlign: TextAlign.justify, 'How will we use information about you?\nHow we use your information depends on whether you are a User or a Service Provider. If you are a User, we use your information to administer and manage your Account with us, communicate with you and provide you with various services and functions available in our Application. If you are a Service Provider, we use your information to verify that you can provide services, enable you to provide services to Users, administer and manage your account with us, communicate with you and provide you with various services and functionalities available in our Application. We also use your information to maintain our Applications and tailor our products and services to your preferences. In addition, we use your information to market our products and services to you and to our Group companies, partners and agents (with your consent if required by Applicable Law).'),
                    Text(textAlign: TextAlign.justify, 'Who do we share your information with?\nWe share your data with Users and Service Providers (if applicable) to facilitate the performance of services for or by you, with our partners and third party providers, to the extent necessary for them to provide our services, such as payment processing, insurance claims and verification. We only use the services of these third parties to process or store your information for the purposes described in this Privacy Notice. We also share your information with our Affiliates for the purposes described in this Privacy Notice and with government and regulatory agencies as required by Applicable Law.'),
                    Text(textAlign: TextAlign.justify, 'Where do we process your information?\nOur servers may be located outside the Territory. We may also transfer your information to our Affiliates and third party vendors and partners outside of the Territory for the purposes outlined in this Privacy Notice.'),
                    Text(textAlign: TextAlign.justify, 'How long do we process your information?\nWe will process your information for the maximum period necessary to fulfill the purpose for which it was collected or as required by Applicable Law.')
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: showScrollButton ?
      FloatingActionButton(onPressed: scrollOnTop, backgroundColor: Constants().mainColor, child: const Icon(Icons.arrow_upward, size: 30,)) : null,
    );
  }
}

