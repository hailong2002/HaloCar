import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Location Tracker',
      home: MyMapPage(),
    );
  }
}

class MyMapPage extends StatefulWidget {
  @override
  _MyMapPageState createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
  LatLng _currentPosition = LatLng(0,0);


  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    Timer.periodic(Duration(minutes: 1), (timer) {
      _getCurrentLocation();
    });
  }

  _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${_currentPosition.latitude}, ${_currentPosition.longitude}'),
      ),
      body:  FlutterMap(
        // mapController: _mapController,
        options: MapOptions(
            zoom: 15,
            center: LatLng(_currentPosition.latitude+0.2,_currentPosition.longitude+0.2)
        ),

        children: [
          // Layer that adds the map
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
          // Layer that adds points the map
          MarkerLayer(
            markers: [
              // First Marker
              Marker(
                point: LatLng(_currentPosition.latitude,_currentPosition.longitude),
                width: 80,
                height: 80,
                builder: (context) => IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.drive_eta),
                  color: Colors.orange,
                  iconSize: 45,
                ),
              ),
              // Second Marker

            ],
          ),

          // PolyLines layer

        ],
      ),
    );
  }
}
