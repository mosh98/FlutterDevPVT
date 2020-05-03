import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;


class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hundappen',
      home: TheMapScreen(),
    );
  }
}

class TheMapScreen extends StatefulWidget {
  TheMapScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TheMapScreenState createState() => _TheMapScreenState();
}

class _TheMapScreenState extends State<TheMapScreen> {
  final Location location = Location();
  Completer<GoogleMapController> _controller = Completer();

  final int _MAX_PARK_DISTANCE = 1000;
  final int _MAX_TRASH_BIN_DISTANCE = 1000;


  Set<Marker> _markers = Set();

  Set<Marker> _wasteBinMarkers = Set();
  Set<Marker> _dogParksMarkers = Set();
  Marker _searchPosMarker = null;
  Marker _homePosMarker = null;

  // Har den nuvarande positionen av mobilen
  LocationData _currentLocation = null;

  // Har positionen man markerat på kartan
  LatLng _searchLocation = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maps'),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          googleMapsWidget(),
          Container(
              alignment: Alignment.topRight,
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  findParksButton(),
                  SizedBox(height: 10.0),
                  findTrashBinsButton(),
                  SizedBox(height: 10.0), //What it do? why 2 there?
                  homeButton()
                ],
              )),
        ],
      ),
    );
  }

  Widget googleMapsWidget() {
    return GoogleMap(
        mapType: MapType.normal,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(59.339843, 18.045731),
          zoom: 10.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onTap: _onMapTap);
  }

  Widget homeButton() {
    return Material(
      shape: CircleBorder(),
      color: Colors.cyanAccent,
      child: IconButton(
          icon: Icon(Icons.home),
          iconSize: 50,
          tooltip: 'Hem',
          onPressed: () {
            _homeButtonPressed();
          }),
    );
  }

  void _onMapTap(LatLng point) {
    if (point != null) {
      if (_searchPosMarker != null) {
        _markers.remove(_searchPosMarker);
      }
      _searchLocation = LatLng(point.latitude, point.longitude);
      _searchPosMarker = new Marker(
          markerId: MarkerId('SEARCH MARKER'),
          icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position:
          LatLng(_searchLocation.latitude, _searchLocation.longitude));

      setState(() {
        _markers.add(_searchPosMarker);
      });



    }
  }

  void _homeButtonPressed() {
    _setMyCurrentLocation();
    if (_currentLocation != null) {


      if (_homePosMarker != null) {
        _markers.remove(_homePosMarker);
      }
      // För att uppdatera kartan och se nya markerna
      _homePosMarker = Marker(
          markerId: MarkerId('HOME MARKER'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueCyan),
          position: LatLng(
              _currentLocation.latitude, _currentLocation.longitude));


      setState(() {
        _markers.add(_homePosMarker);
      });

    }

    _gotoLocation(_currentLocation);
  }


  Future<void> _setMyCurrentLocation() async {
    final LocationData _locationResult = await location.getLocation();
    _currentLocation = _locationResult;
  }

  Future<void> _gotoLocation(LocationData location) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location.latitude, location.longitude), zoom: 15.0)));
  }

  Future<String> _getJSON(String url) async {
    final response = await http.get(url);
    return response.body;
  }

  Future<void> _locateParks() async {
    if (_searchLocation != null) {
      _dogParksMarkers.clear();


      String url = "https://pvt-dogpark.herokuapp.com/dogpark/find?latitude=";
      url += _searchLocation.latitude.toString() + "&longitude=";
      url += _searchLocation.longitude.toString() + "&distance=";
      url += _MAX_PARK_DISTANCE.toString();
      String data = await _getJSON(url);

      List dataAsList = jsonDecode(data);


      for (int i = 0; i < dataAsList.length; i++) {
        _dogParksMarkers.add(Marker(
            markerId: MarkerId('DOG_PARK_' + i.toString()),

            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(title: dataAsList[i]['name'], snippet: dataAsList[i]['description']),

            position:
            LatLng(dataAsList[i]['latitude'], dataAsList[i]['longitude'])));
      }

      setState(() {


        _markers.clear();
        _markers.addAll(_dogParksMarkers);

        if (_searchPosMarker != null)
          _markers.add(_searchPosMarker);
        if (_homePosMarker != null)
          _markers.add(_homePosMarker);
        if (!_wasteBinMarkers.isEmpty) {
          _markers.addAll(_wasteBinMarkers);
        }

      });
    }
  }

  Future<void> _locateTrashBins() async {

    if (_searchLocation != null) {
      //GET DATA
      String url = "https://pvt-dogpark.herokuapp.com/wastebin/find?latitude=";
      url += _searchLocation.latitude.toString() + "&longitude=";
      url += _searchLocation.longitude.toString() + "&distance=";
      url += _MAX_TRASH_BIN_DISTANCE.toString();
      String data = await _getJSON(url);

      List dataAsList = jsonDecode(data);

      _wasteBinMarkers.clear();


      for (int i = 0; i < dataAsList.length; i++) {
        _wasteBinMarkers.add(
            Marker(
            markerId: MarkerId('TRASH_BIN_' + i.toString()),
            infoWindow: InfoWindow(title: 'Papperskorg'),

            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueMagenta), //ni borde byta färgen/ikonen för trans cans, svårt att skilja vad är vad på appen
            position:
            LatLng(dataAsList[i]['latitude'], dataAsList[i]['longitude']))
        );
      }

      setState(() {
        _markers.clear();
        _markers.addAll(_wasteBinMarkers);

        if (_searchPosMarker != null)
          _markers.add(_searchPosMarker);
        if (_homePosMarker != null)
          _markers.add(_homePosMarker);
        if (!_dogParksMarkers.isEmpty) {
          _markers.addAll(_dogParksMarkers);
        }      });
    }

  }


  Widget findParksButton() {
    return Material(
      shape: CircleBorder(),
      color: Colors.green,
      child: IconButton(
        icon: Icon(Icons.collections),
        iconSize: 50,
        tooltip: 'Hitta parker',
        onPressed: _locateParks,
      ),
    );
  }

  Widget findTrashBinsButton() {
    return Material(
      shape: CircleBorder(),
      color: Colors.lightBlue,
      child: IconButton(
        icon: Icon(Icons.delete),
        iconSize: 50,
        tooltip: 'Hitta papperskorgar',
        onPressed: _locateTrashBins,
      ),
    );
  }
}
