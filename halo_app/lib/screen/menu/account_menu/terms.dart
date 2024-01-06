import 'package:flutter/material.dart';
import 'package:halo_app/screen/menu/account_menu/policy.dart';
import 'package:halo_app/shared/widget.dart';

class Terms extends StatefulWidget {
  const Terms({Key? key}) : super(key: key);

  @override
  State<Terms> createState() => _TermsState();
}

class _TermsState extends State<Terms> {

  final ScrollController scrollController = ScrollController();
  bool showScrollButton = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
  }

  void scrollListener(){
    if(scrollController.offset >= 300 ){
      setState(()=> showScrollButton = true);
    }else{
      setState(()=> showScrollButton = false);
    }
  }

  void scrollOnTop(){
    scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
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
                title: const  Text('Terms & policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25 )),
                onTap: (){Navigator.pop(context);},
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 10),
                child: Column(
                    children: [
                      const MyListTile(title: 'About these terms of service', content:"Please read these Terms of Use carefully. This is an electronic agreement and by registering or using any part of the System, You acknowledge that You have read, understood, accepted and agreed to these Terms of Use and will be bound by these terms. If You do not agree to be bound by these Terms of Use, You may not access or use any part of the System "),
                      const MyListTile(title: 'About terms of user', content: "Halo Car is a technology services company. Halo Car provides a system that connects Transportation Providers with Users. Halo Car does not provide Transportation Services, nor act as a carrier or transportation service provider, taxi or private vehicle rental operator, nor act as an agent for any of the above entities or entities. All Transportation Services are provided directly to You by a Transportation Provider. Nothing in these Terms of Use constitutes any obligation or liability of Halo Car in connection with the provision of Transportation Services.",),
                      const MyListTile(title: 'Your Responsibilities', content: "Account means the registered account You receive to access the System as a User;Affiliate means, in relation to a party, any entity that controls, is controlled by, or is under common control with, that party, where control means direct or indirect ownership of more than 50 percent of the voting capital or similar ownership of that party or the legal right to direct or arrange for direction of the general management and of the ownership and control policies of that party, and for, controls will be interpreted accordingly;Applicable Law means all applicable laws, statutes, ordinances, regulations, regulatory policies, ordinances, protocols, industry codes, road traffic rules, regulatory permits, regulatory licenses or as required by any court or judicial body or governmental, statutory, regulatory, judicial, administrative or regulatory body as from time to time in this Clause;Driver means the individual driver of a Vehicle to provide Transportation Services to You. Depending on the type of Transportation Service, the Driver may be a Transportation Provider or an employee, business partner or contractor of the Transportation Provider and provide Transportation Services on behalf of the Transportation Provider;Specific Terms means additional or alternative terms that may apply to specific parts of the System, as notified to You from time to time;",),
                      const MyListTile(title: 'Your account', content: "4.1 You acknowledge that:\n4.1.1 You have full power and authority to enter into and be legally bound by these Terms of Use and to perform Your obligations under these Terms of Use;\n4.1.2 You have reached the minimum age for You to be legally bound by these Terms of Use under the Laws Applicable in the Territory;\n4.1.3 You must comply with all Applicable Laws and Policies at all times, and will notify Halo Car if You violate any Applicable Laws or Policies;\n4.1.4 You will use the System only for lawful purposes and only for its intended use;\n4.1.5 You shall warrant that any materials and information provided by You (or a party acting on Your behalf) to Halo Car or otherwise through the System are accurate, current, complete and free from error;\n4.1.6 You may only use internet access points and data accounts that You are authorized to use;\n4.1.7 You may not engage in any fraudulent, deceptive or illegal conduct; \n4.1.8 You must not damage or interfere with the normal operation of the network on which the System operates.\n4.2 Your ordering of Transportation Services from a Transportation Provider through the System creates a direct relationship between You and the respective Transportation Provider, to which Halo Car is not a party. To the fullest extent permitted by Applicable Law, Halo Car is not responsible and has no liability for the performance and quality of the Transportation Services and for the actions or omissions of the Transportation Providers and/or Drivers in relation to You. You will be solely responsible for any obligations or liabilities to the Transportation Providers or any other third party and shall only have the right to bring claims against the Transportation Providers or any other third party arising out of Your use of the Transportation Services. Halo Car does not guarantee the availability of a Transportation Service in Your Territory.\n4.3 You agree:\n4.3.1 treat Drivers, Transportation Providers and other Users with respect, in accordance with the Policies, and will not behave or engage in any illegal, threatening or harassing behavior while using the Transportation Services or the System;\n4.3.2 does not cause damage to third party property; \n4.3.3 does not contact Drivers and Transportation Service Providers for purposes other than receiving and using Transportation Services.",),
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Divider(thickness: 0.7, color: Colors.grey),
                      ),
                      ListTile(
                        title: Text('Privacy Policy',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan[400], fontSize: 25, fontFamily: 'Outfit')
                        ),
                        leading:  Icon(Icons.policy, size: 30, color: Colors.cyan[400]),
                        onTap: (){nextScreen(context, const Policy());},

                      )
                    ]
                ),
              ),

          ],
        ),
      ),
      floatingActionButton: showScrollButton ? FloatingActionButton(onPressed: scrollOnTop, child: const Icon(Icons.arrow_upward)): null,

    );
  }
}




class MyListTile extends StatefulWidget {
  final String title ;
  final String content;
  const MyListTile({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  State<MyListTile> createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  bool visible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          onTap:  (){setState(()=> visible = !visible);},
          title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          trailing: visible ? const Icon(Icons.expand_less) : const Icon(Icons.expand_more),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Visibility(
                visible: visible,
                child: Text(widget.content,textAlign: TextAlign.justify, style: const TextStyle(fontSize: 15))),
        ),
      ],
    );
  }
}


