import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:halo_app/providers/user_data.dart';
import 'package:provider/provider.dart';

import '../../services/database_service.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({Key? key}) : super(key: key);

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  DatabaseService databaseService = DatabaseService();
  User? user = FirebaseAuth.instance.currentUser;
  int finishedTrip = 0;
  double totalAmount = 0;
  void getTrip() async{
    QuerySnapshot snapshot = await databaseService.tripCollection.where('driverId', isEqualTo: user!.uid).get();
    for(var doc in snapshot.docs){
      if(doc['isFinished']){
        setState(() {
          finishedTrip += 1;
        });
      }
    }
  }

  void getPay() async{
    QuerySnapshot snapshot = await databaseService.payCollection.where('uid', isEqualTo: user!.uid).get();
    for(var doc in snapshot.docs){
      setState(() {
        totalAmount += doc['amount'].toDouble();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getTrip();
    getPay();
  }

  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    userData.getUserData();
    return Scaffold(
        backgroundColor: Colors.cyan,
        body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
          child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  const Text('Dashboard', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'Outfit', color: Colors.white)),
                  const SizedBox(height: 30),
                  Text('Trip has complete: $finishedTrip' ,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit',color: Colors.white)),
                  const SizedBox(height: 10),
                  Text('Income: $totalAmount usd',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit',color: Colors.white)),
                  const SizedBox(height: 10),
                  Text('Average rating: ${userData.totalRating.toStringAsFixed(1)} / 5',style:const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit',color: Colors.white)),
                  // Center(
                  //   child: CustomPaint(
                  //     size: Size(300, 200),
                  //     painter:  DriverPerformancePainter(),
                  //   ),
                  // ),
                ],


        ),
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ biểu đồ cột tại đây
    // Sử dụng các hàm vẽ như drawRect, drawLine, ...
    // Vẽ các cột dựa trên dữ liệu của bạn
    // Ví dụ:
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final barWidth = 40.0;
    final spacing = 20.0;
    final data = [5.0, 7.0, 2.0];

    for (int i = 0; i < data.length; i++) {
      canvas.drawRect(
        Rect.fromPoints(
          Offset((barWidth + spacing) * i, size.height),
          Offset((barWidth + spacing) * i + barWidth, size.height - data[i] * 20),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class DriverPerformancePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ đường chỉ số trục x (ngang)
    Paint xLinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), xLinePaint);

    // Vẽ đường chỉ số trục y (dọc)
    Paint yLinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(Offset(0, 0), Offset(0, size.height), yLinePaint);

    // Dữ liệu của từng tháng
    final monthsData = [1, 5, 6, 9, 4, 12, 10];
    final incomeData =[1, 5, 6, 9, 4, 12, 10];
    final maxValue = 12.0;

    Paint dataPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;


    Path dataPath = Path();
    for (int i = 0; i < monthsData.length; i++) {
      final x = size.width / (monthsData.length - 1) * i;
      final y = size.height - (monthsData[i] / maxValue) * size.height;
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }

    canvas.drawPath(dataPath, dataPaint);
    Paint tickPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'] ;

    for (int i = 0; i < months.length; i++) {
      final x = size.width / (months.length - 1) * i;
      final y1 = size.height;
      final y2 = size.height + 10;

      canvas.drawLine(Offset(x, y1), Offset(x, y2), tickPaint);

      textPainter.text = TextSpan(
        text: months[i],
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height + 15));
    }

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}