import 'package:google_maps_flutter/google_maps_flutter.dart';

class WasteBin {

    double _distance;
    LatLng _position;

    Marker _marker;


    double getDistance() { return _distance; }
    LatLng getPosition() { return _position; }
    Marker getMarker() { return _marker; }


    void setDistance(double value) {
        _distance = value;
    }

    void setMarker(Marker marker) {
        this._marker = marker;
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