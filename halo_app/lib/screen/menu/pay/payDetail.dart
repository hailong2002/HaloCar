import 'package:flutter/material.dart';
import 'package:halo_app/providers/pay_data.dart';
import 'package:halo_app/providers/trip_data.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_data.dart';
import '../../../shared/loading.dart';

class PayDetail extends StatefulWidget {
  const PayDetail({Key? key, required this.pid}) : super(key: key);
  final String pid;
  @override
  State<PayDetail> createState() => _PayDetailState();
}

class _PayDetailState extends State<PayDetail> {
  bool _isLoading = true;
  @override
  void initState(){
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _isLoading = false;
      });
    });

  }
  @override
  Widget build(BuildContext context) {
    PayData payData = Provider.of<PayData>(context);
    payData.getPayInfo(widget.pid);
    TripData tripData =  Provider.of<TripData>(context);
    tripData.getDetailTrip(payData.tripId);
    UserData userData = Provider.of<UserData>(context);
    userData.getUserData();
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: Colors.cyan,
        title: const  Text('Payment details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white )),
        leading: IconButton(
          onPressed: (){Navigator.pop(context);},
          icon: const Icon(Icons.chevron_left, size: 35, color: Colors.white),
        ),
      ),
      body: _isLoading ? const Loading() :
      DefaultTextStyle(
        style: const TextStyle(fontFamily: 'Roboto', color: Colors.black),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date:  ${DateFormat.EEEE().format(payData.date)}, ${DateFormat.MMMM().format(payData.date)} ${payData.date.day}, ${payData.date.year}',
                style: const TextStyle(fontSize: 18)),
              Text('At: ${payData.date.hour.toString().padLeft(2, '0')}:${payData.date.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 18)),
              Text('From ${tripData.startPoint.split(',')[0]} to ${tripData.endPoint.split(',')[0]}', style: const TextStyle(fontSize: 18)),
              userData.role != 'driver' ?
              Text('Amount: ${payData.amount} usd, pay with ${payData.service}.', style: const TextStyle(fontSize: 18)) :
              Text('You receive: ${payData.amount} usd, via ${payData.service}.', style: const TextStyle(fontSize: 18)),

            ],

          ),
        ),
      ),
    );
  }
}
