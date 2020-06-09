
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'Review.dart';



class DogPark {

    int _id;
    LatLng _position;

    String _name;
    String _description;
    double _distance = 0;

    Marker _marker;
    List<Review> _reviews = new List<Review>();
    List<String> _imgURLs = new List<String>();


    List<String> get imgURLs => _imgURLs;


    set imgURLs(List<String> value) {
    _imgURLs = value;
  }

  int get id => _id;

    DogPark(
        {int id, double latitude, double longitude, String name, String description}) {
        this._id = id;
        this._position = LatLng(latitude, longitude);
        this._name = name;
        this._description = description;
    }

    factory DogPark.fromJson(Map<String, dynamic> json) {
        return DogPark(
            id: json['id'],
            latitude: json['latitude'],
            longitude: json['longitude'],
            name: json['name'],
            description: json['description'],
        );
    }

    @override
    String toString() {
        return "DogPark: $_id, $_name, $_distance, $_description, " +
            _position.toString();
    }


    LatLng get position => _position;

    String get name => _name;

    String get description => _description;

    double get distance => _distance;

    Marker get marker => _marker;

    List<Review> get reviews => _reviews;

    set marker(Marker value) {
        _marker = value;
    }

    set distance(double value) {
        _distance = value;
    }


    double calulateRating() {
      double rating = 0;
      if (_reviews.isEmpty == true) {
        return 0;
      }
      _reviews.forEach((review) {
        rating += review.rating;
      });
      rating /= _reviews.length;
      return rating;
    }


}