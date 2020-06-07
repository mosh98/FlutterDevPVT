import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'SettingsHandler.dart';
import 'package:http/http.dart' as http;
import '../classes/DogPark.dart';
import '../classes/WasteBin.dart';






class DataHandler {


    SettingsHandler _settingsHandler = SettingsHandler();


    // Used to find the phones GPS-location
    Location _locationFinder = new Location();

    // Controll the map
    Completer<GoogleMapController> _googleMapController = Completer();


    // Debugging
    final bool _showLogMessages = true;
    final String _logMessageFilter = 'debug_msg: ';


    List<DogPark> _dogParks = new List<DogPark>();
    List<WasteBin> _wasteBins = new List<WasteBin>();



    // The size of the current screen
    Size _screenSize;


    LatLng _phoneLocation;
    LatLng _markedLocation;
    LatLng _selectedLocation;

    BitmapDescriptor _markedLocationMarkerIcon;
    BitmapDescriptor _phoneLocationMarkerIcon;
    BitmapDescriptor _dogParkMarkerIcon;
    BitmapDescriptor _wasteBinMarkerIcon;


    BitmapDescriptor get wasteBinMarkerIcon => _wasteBinMarkerIcon;

    set wasteBinMarkerIcon(BitmapDescriptor value) {
        _wasteBinMarkerIcon = value;
    }

    BitmapDescriptor get markedLocationMarkerIcon => _markedLocationMarkerIcon;

    set markedLocationMarkerIcon(BitmapDescriptor value) {
        _markedLocationMarkerIcon = value;
    }

    LatLng get phoneLocation => _phoneLocation;



    set screenSize(Size value) {
        _screenSize = value;
        _settingsHandler.buttonSize = _settingsHandler.buttonSizeBasedOnWidth * _screenSize.width;
    }

    Size get screenSize => _screenSize;
    SettingsHandler get settingsHandler => _settingsHandler;


    LatLng get markedLocation => _markedLocation;

    set markedLocation(LatLng value) {
        _markedLocation = value;
    }

    LatLng get selectedLocation => _selectedLocation;

    set selectedLocation(LatLng value) {
        _selectedLocation = value;
    }

    Completer<GoogleMapController> get googleMapController =>
        _googleMapController;


    void print_debug(String str) {
        if (_showLogMessages == true) {
            print(_logMessageFilter + str);
        }
    }



    Future<void> updatePhoneLocation() async {
        bool _serviceEnabled;
        PermissionStatus _permissionGranted;

        _serviceEnabled = await _locationFinder.serviceEnabled();
        if (!_serviceEnabled) {
            _serviceEnabled = await _locationFinder.requestService();
            if (!_serviceEnabled) {
                return null;
            }
        }
        _permissionGranted = await _locationFinder.hasPermission();
        if (_permissionGranted == PermissionStatus.denied) {
            _permissionGranted = await _locationFinder.requestPermission();
            if (_permissionGranted != PermissionStatus.granted) {
                return null;
            }
        }

        await _locationFinder.getLocation().then((locData) {
           _phoneLocation = LatLng(locData.latitude, locData.longitude);
        });
    }


    Future<void> setCameraPosition(LatLng pos, double zoom) async {
        await _googleMapController.future.then((controller) {
            controller.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: pos, zoom: zoom)));
        });
    }


    set dogParkMarkerIcon(BitmapDescriptor value) {
        _dogParkMarkerIcon = value;
    }

    BitmapDescriptor get dogParkMarkerIcon => _dogParkMarkerIcon;

    Future<BitmapDescriptor> createTextIcon(String textStr,
        Color bgColor, Color borderColor) async {
        final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
        final Canvas canvas = Canvas(pictureRecorder);
        final Paint paint = Paint()
            ..color = Colors.white;

        TextSpan span = new TextSpan(
            style: new TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 40),
            text: textStr);
        TextPainter tp = new TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp.layout();

        double mBorderSize = tp.height / 8.0;
        double mWidth = tp.width * 1.2 + mBorderSize * 2;
        double mHeight = tp.height * 1.2 + mBorderSize * 2;

        double mTextPosX = (mWidth - tp.width) / 2;
        double mTextPosY = (mHeight - tp.height) / 2;

        canvas.drawRRect(
            ui.RRect.fromLTRBR(
                0, 0, mWidth, mHeight, Radius.circular((mWidth / 10))),
            new Paint()
                ..color = borderColor
                ..style = PaintingStyle.fill);

        canvas.drawRRect(
            ui.RRect.fromLTRBR(mBorderSize, mBorderSize, mWidth - mBorderSize,
                mHeight - mBorderSize, Radius.circular((mWidth / 10))),
            new Paint()
                ..color = bgColor
                ..style = PaintingStyle.fill);

        tp.paint(canvas, new Offset(mTextPosX, mTextPosY));

        final image = await pictureRecorder
            .endRecording()
            .toImage(mWidth.toInt(), mHeight.toInt());
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    }

    BitmapDescriptor get phoneLocationMarkerIcon => _phoneLocationMarkerIcon;

    set phoneLocationMarkerIcon(BitmapDescriptor value) {
        _phoneLocationMarkerIcon = value;
    }

    List<WasteBin> get wasteBins => _wasteBins;

    List<DogPark> get dogParks => _dogParks;

    Future<http.Response> downloadReviews(int id) async{
        final String url = "https://dog-park-micro.herokuapp.com/api/v1/review/id/$id";
        final http.Response response = await http.get(url);
        return response;
    }


    Future<http.Response> downloadImageURLs(int id) async{
        String url = "https://dog-park-micro.herokuapp.com/image/getImages?id=$id";
        final http.Response response = await http.get(url);
        return response;
    }

    Future<List<DogPark>> parseDogParks(List jsonUnparsed) async {
        List<DogPark> allParks = new List<DogPark>();
        for (int i = 0; i < jsonUnparsed.length; i++) {
            DogPark onePark = DogPark.fromJson(jsonUnparsed[i]);
            allParks.add(onePark);
        }
        return allParks;
    }


   Future<http.Response> downloadDogParks() async{
        String lat = _selectedLocation.latitude
            .toString();
        String lon = _selectedLocation.longitude
            .toString();
        String dist = _settingsHandler.searchDogParkDistance.currentValue.toInt().toString();
        String url = "https://dog-park-micro.herokuapp.com/api/v1/dog_park/find?latitude=$lat&longitude=$lon&distance=$dist";
        print(url);
        final http.Response response = await http.get(url);
        return response;
    }


    Future<http.Response> downloadWasteBins() async{
        String lat = _selectedLocation.latitude
            .toString();
        String lon = _selectedLocation.longitude
            .toString();
        String dist = _settingsHandler.searchWasteBinDistance.currentValue.toInt().toString();
        String url = 'https://dogsonfire.herokuapp.com/wastebin?latitude=$lat&longitude=$lon&distance=$dist';
        print(url);
        final http.Response response = await http.get(url);
        return response;
    }


    Future<List<WasteBin>> parseWasteBins(List jsonUnparsed) async {
        List<WasteBin> allBins = new List<WasteBin>();
        for (int i = 0; i < jsonUnparsed.length; i++) {
            WasteBin oneBin = WasteBin.fromJson(jsonUnparsed[i]);
            allBins.add(oneBin);
        }
        return allBins;
    }



    Future<http.Response> postReview(String reviewString, int rating, int dogParkID) async{
        final http.Response response = await http.post(
            'https://dog-park-micro.herokuapp.com/api/v1/review',
            headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
                "comment": "$reviewString",
                "rating": "$rating",
                "dogParkId": dogParkID,
            }),
        );
        return response;
    }


    List<Widget> _buildStarRow(BuildContext context, double rating, double iconSize, Color iconColor) {
        var starGroup = List<Widget>();
        for (var i = 1; i <= 5; i++) {
            Icon icon = Icon(Icons.star_border,
                color: iconColor, size: iconSize);
            if (rating >= i) {
                icon = Icon(Icons.star,
                    color: iconColor, size: iconSize);
            } else if (rating + 0.25 >= i - 0.5) {
                icon = Icon(Icons.star_half,
                    color: iconColor, size: iconSize);
            }
            starGroup.add(icon);
        }
        return starGroup;
    }

    Widget getStarRow(BuildContext context, double rating, double iconSize, Color iconColor) {
        return Row(
            children: _buildStarRow(context, rating, iconSize, iconColor),
        );
    }








    // Returns the distance between two positions
    double getDistanceBetween(double lat1, double long1, double lat2,
        double long2) {
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


    Future<BitmapDescriptor> createBorderedIcon(String path,
        double finalSize,
        double borderSize,
        Color bgColor,
        Color borderColor) async {
        final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
        final Canvas canvas = Canvas(pictureRecorder);

        double imageSize = finalSize - borderSize * 4;
        double imgPosX = borderSize * 2;
        double imgPosY = borderSize * 2;

        Uint8List imgBytes = await getBytesFromAsset(path, imageSize.toInt());

        ui.Image im = await decodeImageFromList(imgBytes);

        canvas.drawRRect(
            ui.RRect.fromLTRBR(
                0, 0, finalSize, finalSize, Radius.circular((finalSize / 10))),
            new Paint()
                ..color = borderColor
                ..style = PaintingStyle.fill);
        canvas.drawRRect(
            ui.RRect.fromLTRBR(borderSize, borderSize, finalSize - borderSize,
                finalSize - borderSize, Radius.circular((finalSize / 10))),
            new Paint()
                ..color = bgColor
                ..style = PaintingStyle.fill);

        canvas.drawImage(im, ui.Offset(imgPosX, imgPosY), new Paint());
        final image = await pictureRecorder
            .endRecording()
            .toImage(finalSize.toInt(), finalSize.toInt());
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    }

    Future<Uint8List> getBytesFromAsset(String path, int width) async {
        ByteData data = await rootBundle.load(path);
        ui.Codec codec = await ui.instantiateImageCodec(
            data.buffer.asUint8List(),
            targetWidth: width);
        ui.FrameInfo fi = await codec.getNextFrame();
        return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
            .buffer
            .asUint8List();
    }


}