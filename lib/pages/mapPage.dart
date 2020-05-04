import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:location/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MapPage());

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hundappen',
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  MainScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _maxTrashBinSearchResults = 10;

  // Klass som används för att hitta ens position
  Location _location = new Location();

  // Anger den position som sökningen ska ske omkring
  LatLng _searchPosition = null;

  // Avgör om man ska visa en settingsknapp eller om man ska visa en settingsruta
  bool _settingsWidgetVisible = false;

  // Anger sökdistansen för parker och papperskorgar
  int _searchRadieDogParks = 500;
  int _searchRadieTrashbins = 500;

  // Alla synliga markeringar
  Set<Marker> _allMarkers = Set();

  // Alla papperskorgsmarkeringar
  Set<Marker> _trashBinMarkers = Set();

  // Alla hundparksmarkeringar
  Set<Marker> _dogparkMarkers = Set();

  // Hanterar kartan
  Completer<GoogleMapController> _controller = Completer();

  BitmapDescriptor _trashBinIcon;

  // callas av både settingsknappen och save-knappen för att växla
  void _onSettingsTapped() {
    _settingsWidgetVisible = _settingsWidgetVisible ? false : true;
    setState(() {});
  }

  // Tappat på kartan
  void _googleMapWidgetTapped(LatLng tapPosition) async {
    _changeMapLocation(LocationData.fromMap({
      'longitude': tapPosition.longitude,
      'latitude': tapPosition.latitude
    }));
    _setSearchPosition(tapPosition.latitude, tapPosition.longitude);
  }

  // Klickat på positionsknappen
  void _findCurrentPositionPressed() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await _location.getLocation();

    _changeMapLocation(_locationData);
    _setSearchPosition(_locationData.latitude, _locationData.longitude);
  }

  // Sätter sökpositionen och rensar markers
  void _setSearchPosition(double latitude, double longitude) {
    setState(() {
      _allMarkers.clear();

      _searchPosition = LatLng(latitude, longitude);

      _allMarkers.add(Marker(
        position: LatLng(_searchPosition.latitude, _searchPosition.longitude),
        flat: false,
        markerId: MarkerId('current_pos_marker'),
        icon: BitmapDescriptor.defaultMarkerWithHue(200),
      ));
    });
  }

  // Klickat på papperskorgsknappen
  void _findWasteBinWidgetPressed() async {
    // Finns ingen sökmarker, utgå från att man vill söka från sin plats då
    if (_searchPosition == null) {
      _findCurrentPositionPressed();
    }

    String lat = _searchPosition.latitude.toString();
    String long = _searchPosition.longitude.toString();
    String dist = _searchRadieTrashbins.toString();
    String url =
        "https://pvt-dogpark.herokuapp.com/wastebin/find?latitude=$lat&longitude=$long&distance=$dist";

    final response = await http.get(url);

    try {
      String jsonData = response.body;

      List dataAsList = jsonDecode(jsonData);

      List<Map<String, double>> binData = new List<Map<String, double>>();
      if (!dataAsList.isEmpty) {
        for (int i = 0; i < dataAsList.length; i++) {
          double tempLat = dataAsList[i]['latitude'];
          double tempLong = dataAsList[i]['longitude'];
          double tempDist = getDistanceBetween(tempLat, tempLong,
              _searchPosition.latitude, _searchPosition.longitude);
          binData.add({
            'latitude': tempLat,
            'longitude': tempLong,
            'distance': tempDist
          });
        }

        binData.sort((Map a, Map b) {
          if (a['distance'] > b['distance'])
            return 1;
          else if (a['distance'] < b['distance'])
            return -1;
          else
            return 0;
        });

        _allMarkers.removeAll(_trashBinMarkers);
        _trashBinMarkers.clear();

        for (int i = 0;
        i < binData.length && i < _maxTrashBinSearchResults;
        i++) {
          _trashBinMarkers.add(new Marker(
            markerId: MarkerId('trashbin' + i.toString()),
            position: LatLng(binData[i]['latitude'], binData[i]['longitude']),
            icon: _trashBinIcon,
            infoWindow: InfoWindow(
                title: 'Papperskorg',
                snippet: binData[i]['distance'].toInt().toString() + " m"),
          ));

          setState(() {
            _allMarkers.addAll(_trashBinMarkers);
          });
        }
      }
    } catch (e) {}
  }

  // Klickat på hundparksknappen
  void _findParksWidgetPressed() async {
    if (_searchPosition == null) {
      _findCurrentPositionPressed();
    }
    String lat = _searchPosition.latitude.toString();
    String long = _searchPosition.longitude.toString();
    String dist = _searchRadieDogParks.toString();
    String url =
        "https://pvt-dogpark.herokuapp.com/dogpark/find?latitude=$lat&longitude=$long&distance=$dist";

    final response = await http.get(url);

    try {
      String jsonData = utf8.decode(response.bodyBytes);
      List dataAsList = jsonDecode(jsonData);

      _allMarkers.removeAll(_dogparkMarkers);
      _dogparkMarkers.clear();

      if (!dataAsList.isEmpty) {
        for (int i = 0; i < dataAsList.length; i++) {
          double tempLat = dataAsList[i]['latitude'];
          double tempLong = dataAsList[i]['longitude'];
          double tempDist = getDistanceBetween(tempLat, tempLong,
              _searchPosition.latitude, _searchPosition.longitude);

          String name = dataAsList[i]['name'];
          String desc = dataAsList[i]['description'];
          _dogparkMarkers.add(new Marker(
            markerId: MarkerId('hundpark' + i.toString()),
            position: LatLng(tempLat, tempLong),
            infoWindow: InfoWindow(
                title: name + "(" + tempDist.toInt().toString() + ") m",
                snippet: desc),
          ));
        }
        setState(() {
          _allMarkers.addAll(_dogparkMarkers);
        });
      }
    } catch (e) {
      return;
    }
  }

  // Byter plats på kartan
  Future<void> _changeMapLocation(LocationData location) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location.latitude, location.longitude), zoom: 14.0)));
  }

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
        'assets/trashcanicon.png')
        .then((onValue) {
      _trashBinIcon = onValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget settingsWidget = _settingsWidgetVisible
        ? _settingsWidgetAsContainer()
        : _settingsWidgetAsButton();

    return Scaffold(
      appBar: AppBar(
        title: Text('Maps'),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          _googleMapWidget(),
          Align(
            alignment: Alignment.topRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(5),
                  child: _findParksWidget(),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: _findWasteBinWidget(),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: _findCurrentPositionWidget(),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: settingsWidget,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsWidgetAsButton() {
    return Material(
      shape: CircleBorder(),
      color: Colors.blue,
      child: IconButton(
          icon: Icon(Icons.settings),
          color: Colors.white,
          iconSize: 50,
          tooltip: 'Inställningar',
          onPressed: () {
            _settingsWidgetVisible = _settingsWidgetVisible ? false : true;
            setState(() {});
          }),
    );
  }

  Widget _settingsWidgetAsContainer() {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
          borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
          color: Colors.white,
          border: Border.all(color: Colors.blue)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Hitta hundparker inom',
                  style: new TextStyle(fontSize: 20.0)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackShape: RoundedRectSliderTrackShape(),
                  trackHeight: 2.0,
                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  valueIndicatorColor: Colors.blue,
                  valueIndicatorTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                child: Slider(
                  value: _searchRadieDogParks.toDouble(),
                  min: 0,
                  max: 2000,
                  divisions: 200,
                  label: ('$_searchRadieDogParks' + ' m'),
                  onChanged: (value) {
                    setState(
                          () {
                        _searchRadieDogParks = value.toInt();
                      },
                    );
                  },
                ),
              ),
              Text(
                '$_searchRadieDogParks m',
                style: new TextStyle(fontSize: 20.0),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Hitta papperskorgar inom',
                  style: new TextStyle(fontSize: 20.0)),
            ],
          ),
          Row(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackShape: RoundedRectSliderTrackShape(),
                  trackHeight: 2.0,
                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  valueIndicatorColor: Colors.blue,
                  valueIndicatorTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                child: Slider(
                  value: _searchRadieTrashbins.toDouble(),
                  min: 0,
                  max: 2000,
                  divisions: 200,
                  label: ('$_searchRadieTrashbins' + ' m'),
                  onChanged: (value) {
                    setState(
                          () {
                        _searchRadieTrashbins = value.toInt();
                      },
                    );
                  },
                ),
              ),
              Text(
                '$_searchRadieTrashbins m',
                style: new TextStyle(fontSize: 20.0),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                  onPressed: () {
                    _settingsWidgetVisible =
                    _settingsWidgetVisible ? false : true;
                    setState(() {});
                  },
                  child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius:
                          new BorderRadius.all(new Radius.circular(15.0)),
                          color: Colors.white,
                          border: Border.all(color: Colors.blue)),
                      child: Text(
                        'Spara',
                        style: new TextStyle(fontSize: 20.0),
                      )))
            ],
          ),
        ],
      ),
    );
  }

  Widget _googleMapWidget() {
    return GoogleMap(
        mapType: MapType.normal,
        markers: _allMarkers,
        initialCameraPosition: CameraPosition(
          target: LatLng(59.339843, 18.045731),
          zoom: 10.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onTap: _googleMapWidgetTapped);
  }

  Widget _findParksWidget() {
    return Material(
      shape: CircleBorder(),
      color: Colors.blue,
      child: IconButton(
        icon: Icon(Icons.collections),
        iconSize: 50,
        color: Colors.white,
        tooltip: 'Hitta parker',
        onPressed: _findParksWidgetPressed,
      ),
    );
  }

  Widget _findWasteBinWidget() {
    return Material(
      shape: CircleBorder(),
      color: Colors.blue,
      child: IconButton(
        icon: Icon(Icons.delete),
        color: Colors.white,
        iconSize: 50,
        tooltip: 'Hitta papperskorgar',
        onPressed: _findWasteBinWidgetPressed,
      ),
    );
  }

  Widget _findCurrentPositionWidget() {
    return Material(
      shape: CircleBorder(),
      color: Colors.blue,
      child: IconButton(
        icon: Icon(Icons.location_searching),
        iconSize: 50,
        color: Colors.white,
        tooltip: 'Hem',
        onPressed: _findCurrentPositionPressed,
      ),
    );
  }

  double getDistanceBetween(
      double lat1, double long1, double lat2, double long2) {
    const double radie = 6371e3;
    double lat1_radian = lat1 * pi / 180.0;
    double lat2_radian = lat2 * pi / 180.0;
    double delta_lat_radian = (lat2 - lat1) * pi / 180.0;
    double delta_long_radian = (long2 - long1) * pi / 180.0;
    double a = sin(delta_lat_radian / 2.0) * sin(delta_lat_radian / 2.0) +
        cos(lat1_radian) *
            cos(lat2_radian) *
            sin(delta_long_radian / 2.0) *
            sin(delta_long_radian / 2.0);
    double c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a));
    double dist = radie * c;
    return dist;
  }
}
