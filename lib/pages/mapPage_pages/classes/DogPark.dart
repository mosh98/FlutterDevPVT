
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


    int getID() { return _id; }
    LatLng getPosition()  { return _position; }
    String getName() { return _name; }
    String getDescription() { return _description; }
    double getDistance() { return _distance; }
    Marker getMarker() { return _marker; }
    List<Review> getReviews() { return _reviews; }
    List<String> getImageAddresses() { return _imgURLs; }


    void setMarker(Marker marker) { _marker = marker; }
    void setDistance(double distance) { _distance = distance; }




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

    double calculateRating() {
      double rating = 0;
      if (_reviews.isEmpty == true) {
        return 0;
      }
      _reviews.forEach((review) {
        rating += review.getRating();
      });
      rating /= _reviews.length;
      return rating;
    }


}