import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../mapPage_models/SearchSettings.dart';

class SettingsHandler {



    Color _buttonBackgroundColor = Colors.lightBlueAccent;
    Color get buttonBackgroundColor => _buttonBackgroundColor;

    Color _reviewStarIconColor = Colors.orange;
    Color get reviewStarIconColor => _reviewStarIconColor;


    Color _defaultBorderColor = Colors.blue;
    double _defaultBorderRadiusValue = 10.0;
    double _defaultBorderWidth = 5.0;

    double _defaultFontSize = 40;


    double get defaultFontSize => _defaultFontSize;

    set defaultFontSize(double value) {
        _defaultFontSize = value;
    }

    double _defaultPadding = 20;
    double _defaultIconSize = 40;
    double _defaultPaddingBetweenRows = 5;


    double get defaultPadding => _defaultPadding;

    set defaultPadding(double value) {
        _defaultPadding = value;
    }

    double get defaultBorderRadiusValue => _defaultBorderRadiusValue;

    set defaultBorderRadiusValue(double value) {
        _defaultBorderRadiusValue = value;
    }

    Color get defaultBorderColor => _defaultBorderColor;

    set defaultBorderColor(Color value) {
        _defaultBorderColor = value;
    }

    final CameraPosition _initCamPosition =
    CameraPosition(target: LatLng(59, 18), zoom: 10);

    SearchSettings _searchDogParkDistance = SearchSettings(1, 5000, 1000, 100);
    SearchSettings _searchDogParkResults = SearchSettings(1, 20, 10, 20);
    SearchSettings _searchWasteBinDistance = SearchSettings(1, 2000, 1000, 100);
    SearchSettings _searchWasteBinResults = SearchSettings(1, 20, 10, 20);

    final double _defaultZoom = 15;


    double get defaultZoom => _defaultZoom;

    SearchSettings get searchDogParkDistance => _searchDogParkDistance;

    double _buttonSizeBasedOnWidth = 0.15;


    double get buttonSizeBasedOnWidth => _buttonSizeBasedOnWidth;


    double _buttonSize = 50;

    set buttonSize(double value) {
        _buttonSize = value;
    }

    double get buttonSize => _buttonSize;

    CameraPosition get initCamPosition => _initCamPosition;

    SearchSettings get searchDogParkResults => _searchDogParkResults;

    SearchSettings get searchWasteBinDistance => _searchWasteBinDistance;

    SearchSettings get searchWasteBinResults => _searchWasteBinResults;



    final String _markedLocationMarkerStringID = 'marked_pos_id';

    String get markedLocationMarkerStringID => _markedLocationMarkerStringID;

    final String _phoneLocationMarkerStringID = 'phone_pos_id';

    String get phoneLocationMarkerStringID => _phoneLocationMarkerStringID;



    double get defaultBorderWidth => _defaultBorderWidth;

    set defaultBorderWidth(double value) {
        _defaultBorderWidth = value;
    }

    double get defaultIconSize => _defaultIconSize;

    set defaultIconSize(double value) {
        _defaultIconSize = value;
    }

    double get defaultPaddingBetweenRows => _defaultPaddingBetweenRows;

    set defaultPaddingBetweenRows(double value) {
        _defaultPaddingBetweenRows = value;
    }


}