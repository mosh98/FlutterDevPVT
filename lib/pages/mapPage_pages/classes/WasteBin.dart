import 'package:google_maps_flutter/google_maps_flutter.dart';

class WasteBin {

    double _distance;
    LatLng _position;

    Marker _marker;


    double get distance => _distance;
    LatLng get position => _position;
    Marker get marker => _marker;


    set distance(double value) {
        _distance = value;
    }

    set marker(Marker value) {
        _marker = value;
    }



    WasteBin({double latitude, double longitude}) {
        this._position = LatLng(latitude, longitude);
    }

    factory WasteBin.fromJson(Map<String, dynamic> json) {
        return WasteBin(
            latitude: json['latitude'], longitude: json['longitude']);
    }

    @override
    String toString() {
        return "WasteBin: $_distance\t" + _position.toString();
    }
}