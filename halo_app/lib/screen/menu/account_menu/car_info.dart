import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:halo_app/services/database_service.dart';
import 'package:halo_app/shared/constants.dart';
import 'package:halo_app/shared/widget.dart';
import 'package:provider/provider.dart';

import '../../../providers/car_data.dart';

class CarInfo extends StatefulWidget {
  const CarInfo({Key? key}) : super(key: key);

  @override
  State<CarInfo> createState() => _CarInfoState();
}

class _CarInfoState extends State<CarInfo> {
  DatabaseService databaseService = DatabaseService();
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController textEditingController = TextEditingController();
  String licensePlate = '';
  String selectedBrand = 'Honda';
  String selectedModel = 'Civic';
  String selectedColor = 'Red';
  int selectedSeat = 4;

  void getCarInfo(String uid) async{
    CarData carData = CarData();
    carData.getCarInfo(user!.uid);
    bool haveCar = await carData.getCarInfo(user!.uid);
    if(haveCar){
      setState(() {
        selectedBrand = carData.brand;
        selectedModel = carData.model;
        selectedColor = carData.color;
        selectedSeat = carData.seat;
        licensePlate = carData.licensePlate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCarInfo(user!.uid);
  }

  // Brand model
  Map<String, List<String>> brandModelMap = {
    'Honda': ['Civic', 'Accord', 'CR-V', 'Fit', 'HR-V', 'Pilot', 'Odyssey','Insight','Clarity'],
    'Toyota': ['Camry', 'Corolla', 'Rav4', 'Highlander','Prius','4Runner','Sienna','Hiace'],
    'Ford': ['Mustang', 'F-150', 'Escape'],
    'Hyundai': ['Accent', 'Elantra', 'Sonata','Tucson','Santa Fe','Palisade','Kona','Venue','Ioniq','Nexo'],
    'VinFast': ['Lux A2.0', 'Lux SA2.0', 'Lux SA2.0', 'Lux SA2.0 EV','Fadil','VF e34','VF e35','VF e36'],
    'BMW' : ['3 Series', '5 Series','7 Series','X1','X3','X5','X7','Z4','i3','i8']
  };

  List<String> colors = ['Red', 'Blue', 'White', 'Black', 'Red-white', 'Blue-white', 'Grey', 'Orange', 'Gold'];
  List<int> seats = [4,5,7,15,16];


  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const  Text('Your car information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white, fontFamily: 'Roboto' )),
        leading: IconButton(
          onPressed: (){Navigator.pop(context);},
          icon: const Icon(Icons.chevron_left, size: 35, color: Colors.white),
        ),
      ),
      body: DismissKeyboard(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Form(
                    key: _key,
                    child: Column(
                        children: <Widget>[
                            Row(
                              children: [
                                const Text('Brand:  ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black,fontFamily: 'Roboto', fontSize: 16)),
                                DropdownButton<String>(
                                  value: selectedBrand,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedBrand = val!;
                                      selectedModel = brandModelMap[selectedBrand]![0];
                                    });
                                  },
                                  items: brandModelMap.keys.map((String brand) {
                                    return DropdownMenuItem<String>(
                                      value: brand,
                                      child: SizedBox(
                                        width: 65,
                                          child: Text(brand,style: const TextStyle(fontSize: 15))
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(width: 10.0),
                                const Text('Model:  ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Roboto',fontSize: 16)),
                                DropdownButton<String>(
                                  value: selectedModel,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedModel = val!;
                                    });
                                  },
                                  items: brandModelMap[selectedBrand]?.map((String model) {
                                    return DropdownMenuItem<String>(
                                      value: model,
                                      child: SizedBox(
                                          width: 67,
                                          child: Text(model, style: const TextStyle(fontSize: 15))
                                      ),
                                    );
                                  }).toList() ?? [],
                                ),
                              ],
                            ),
                            Row(
                            children: [
                              const Text('Color:  ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Roboto',fontSize: 18)),
                              DropdownButton<String>(
                                value: selectedColor,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                onChanged: (val) {
                                  setState(() {
                                    selectedColor = val!;
                                  });
                                },
                                items: colors.map((String color) {
                                  return DropdownMenuItem<String>(
                                    value: color,
                                    child: SizedBox(
                                        width: 60,
                                        child: Text(color, style: const TextStyle(fontSize: 15))
                                    ),
                                  );
                                }).toList() ,
                              ),
                              const SizedBox(width: 15),
                              const Text('Seat:  ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Roboto',fontSize: 18)),
                              DropdownButton<int>(
                                value: selectedSeat,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                onChanged: (val) {
                                  setState(() {
                                    selectedSeat = val!;
                                  });
                                },
                                items: seats.map((int seat) {
                                  return DropdownMenuItem<int>(
                                    value: seat,
                                    child: SizedBox(
                                        width: 60,
                                        child: Text('$seat', style: const TextStyle(fontSize: 15))
                                    ),
                                  );
                                }).toList() ,
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          TextFormField(
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            decoration: textEditDecoration.copyWith(
                                errorStyle: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold
                                ),
                                hintText:licensePlate.isEmpty ? 'License plate: ' : licensePlate,
                                hintStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)
                            ),
                            onChanged: (val){
                              setState(() {
                                licensePlate = val.toUpperCase();
                              });
                            },

                            validator: (val){
                              if(val!.isEmpty || val.length != 6){
                                return 'License plate cannot be empty and must be 6 character!';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                              onPressed: (){
                                if(_key.currentState!.validate()){
                                  databaseService.updateOrCreateCar(user!.uid, selectedBrand, selectedModel, selectedColor, selectedSeat,licensePlate);
                                  showToast('Successfully', Colors.cyan);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                              ),
                              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'Roboto'))
                          )
                        ],
                      ),
                    ),
                ),
          ),
        ),
      ),
        
    );
  }
}
