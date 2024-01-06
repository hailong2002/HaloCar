import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:halo_app/shared/widget.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapRouting extends StatefulWidget {
  const MapRouting({super.key, required this.customerPosition, required this.destination, required this.driverPosition});
  final LatLng customerPosition ;
  final LatLng destination;
  final LatLng driverPosition;
  @override
  State<MapRouting> createState() => _MapRoutingState();
}

class _MapRoutingState extends State<MapRouting> {

  // Raw coordinates got from  OpenRouteService
  List listOfPoints = [];

  // Conversion of listOfPoints into LatLng(Latitude, Longitude) list of points
  List<LatLng> points = [];

  String baseUrl = 'https://api.openrouteservice.org/v2/directions/driving-car';
  String apiKey = '5b3ce3597851110001cf6248fed30e4c25284c5095d74a16290a1ed2';
  bool customerToLocation = true;
  getRouteUrl(String startPoint, String endPoint){
    return Uri.parse('$baseUrl?api_key=$apiKey&start=$startPoint&end=$endPoint');
  }

  // Method to consume the OpenRouteService API
  getCoordinates() async {
    var response;
    if(customerToLocation){
      response = await http.get(getRouteUrl("${widget.customerPosition.longitude},${widget.customerPosition.latitude}",
          "${widget.destination.longitude},${widget.destination.latitude}"));
    }else{
      response = await http.get(getRouteUrl("${widget.driverPosition.longitude},${widget.driverPosition.latitude}",
          '${widget.customerPosition.longitude},${widget.customerPosition.latitude}'));
    }
    setState(() {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        listOfPoints = data['features'][0]['geometry']['coordinates'];
        points = listOfPoints
            .map((p) => LatLng(p[1].toDouble(), p[0].toDouble()))
            .toList();
      }
    });
  }
  LatLng _currentPosition = LatLng(0,0);

  @override
  void initState() {
    super.initState();
    updateDriverPosition();
    Timer.periodic(Duration(seconds: 5), (timer) {
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

  void updateDriverPosition(){
    setState(() {
      _currentPosition = widget.driverPosition;
    });
  }


  final MapController mapController = MapController();
  double currentZoom = 10.0;

  void _zoomIn() {
    mapController.move(mapController.center, currentZoom + 1.0);
    currentZoom += 1.0;
  }

  void _zoomOut() {
    mapController.move(mapController.center, currentZoom - 1.0);
    currentZoom -= 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.cyan,
          title: const  Text('Customer position', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white )),
          leading: IconButton(
            onPressed: (){Navigator.pop(context);},
            icon: const Icon(Icons.chevron_left, size: 35, color: Colors.white),
          ),

      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
            zoom: 10,
            center: LatLng(widget.customerPosition.latitude+0.002,widget.customerPosition.longitude+0.002)
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
                point: LatLng(widget.customerPosition.latitude,widget.customerPosition.longitude),
                width: 80,
                height: 80,
                builder: (context) => IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.person_pin_circle),
                  color: Colors.orange,
                  iconSize: 45,
                ),
              ),
              // Second Marker
              Marker(
                point: LatLng(widget.destination.latitude,widget.destination.longitude),
                width: 80,
                height: 80,
                builder: (context) => IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.location_on),
                  color: Colors.red,
                  iconSize: 45,
                ),
              ),
              // Marker(
              //   point: LatLng(widget.driverPosition.latitude,widget.driverPosition.longitude),
              //   width: 80,
              //   height: 80,
              //   builder: (context) => IconButton(
              //     onPressed: () {},
              //     icon: const Icon(Icons.drive_eta),
              //     color: Colors.cyan,
              //     iconSize: 30,
              //   ),
              // ),
              Marker(
                point: LatLng(_currentPosition.latitude,_currentPosition.longitude),
                width: 80,
                height: 80,
                builder: (context) => IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.drive_eta_rounded),
                  color: Colors.cyan,
                  iconSize: 30,
                ),
              ),
            ],
          ),

          // PolyLines layer
          PolylineLayer(
            polylineCulling: false,
            polylines: [
              Polyline(
                  points: points, color: Colors.blue, strokeWidth: 5),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            onPressed: () {
              setState(() {
                customerToLocation = true;
              });
              getCoordinates();
            } ,
            mini: true,
            child: const Icon( Icons.route,
              color: Colors.white,
            ),
          ),
          FloatingActionButton(
            onPressed: (){
              setState(() {
                customerToLocation = false;
              });
              getCoordinates();
            },
            mini: true,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.man),
          ),
          FloatingActionButton(
              onPressed: (){
                _zoomIn();
              },
              mini: true,
              backgroundColor: Colors.teal,
              child: const Icon(Icons.zoom_in),
          ),
          FloatingActionButton(
              onPressed: (){
                _zoomOut();
              },
              mini: true,
              backgroundColor: Colors.teal,
              child: const Icon(Icons.zoom_out),
          ),

        ],
      ),
    );
  }
}