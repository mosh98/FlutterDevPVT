import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../mapPage_dialogs/SearchSettingsDialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:screen/screen.dart';

import '../mapPage_models/DogPark.dart';
import '../mapPage_models/WasteBin.dart';
import '../mapPage_handlers/DataHandler.dart';
import 'DogParkScreen.dart';
import '../mapPage_dialogs/SearchSettingsDialog.dart';


class MainScreen extends StatefulWidget {
    @override
    _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    DataHandler _dataHandler = DataHandler();

    Set<Marker> _mapMarkers = Set<Marker>();
    Marker _phoneLocationMarker;
    Marker _markedLocationMarker;


    bool _buttonSetMarkerIsPressed = false;


    bool _isDownloadingData = false;

    @override
    Widget build(BuildContext context) {
        Size screenSize = MediaQuery
            .of(context)
            .size;

        if (screenSize != null) {
            _dataHandler
                .screenSize = screenSize;


            _dataHandler
                .settingsHandler
                .defaultPadding = screenSize.height / 40.0;
            _dataHandler
                .settingsHandler
                .defaultIconSize = screenSize.height / 15.0;
            _dataHandler
                .settingsHandler
                .defaultFontSize = screenSize.height / 40.0;
            _dataHandler
                .settingsHandler
                .defaultPaddingBetweenRows = screenSize.height / 100;
            _dataHandler
                .settingsHandler
                .defaultBorderWidth = screenSize.height / 300;
        }


        return new Scaffold(


            key: _scaffoldKey,
            appBar: new AppBar(
                title: new Text('Karta'), centerTitle: true,
            ),
            body: Stack(

                children: <Widget>[
                    _mapWidget(),
                    (_isDownloadingData == true) ? Container(child: Center(child: CircularProgressIndicator())) : Container(),
                    Column(
                        children: <Widget>[
                            Align(
                                alignment: Alignment.topRight,
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                        Container(
                                            padding: EdgeInsets.all(  _dataHandler
                                                .settingsHandler
                                                .defaultPadding/2),
                                            child: _buttonDogPark(),
                                        ),
                                        Container(
                                            padding: EdgeInsets.all(  _dataHandler
                                                .settingsHandler
                                                .defaultPadding/2),
                                            child: _buttonWasteBin(),
                                        ),
                                        Container(
                                            padding: EdgeInsets.all( _dataHandler
                                                .settingsHandler
                                                .defaultPadding/2),
                                            child: _buttonPhoneLocation(),
                                        ),
                                        Container(
                                            padding: EdgeInsets.all(  _dataHandler
                                                .settingsHandler
                                                .defaultPadding/2),
                                            child: _buttonSetMarker(),
                                        ),

                                    ],
                                ),
                            ),
                        ],
                    )

                ],


            )
        );


    }

    Widget _mapWidget() {
        return GoogleMap(
            mapType: MapType.normal,
            markers: _mapMarkers,
            onTap: _mapWidgetTapped,
            initialCameraPosition: _dataHandler
                .settingsHandler
                .initCamPosition,
            onMapCreated: (GoogleMapController controller) async {

                _dataHandler
                    .googleMapController
                    .complete(controller);
            });
    }




    void _mapWidgetTapped(LatLng tapPosition) async {



        if (_markedLocationMarker != null &&
            _buttonSetMarkerIsPressed == true) {
            _askToRemoveMarker();
        } else {
            if (_buttonSetMarkerIsPressed == true) {
                _dataHandler
                    .markedLocation = tapPosition;

                if (_markedLocationMarker != null &&
                    _mapMarkers.contains(_markedLocationMarker)) {
                    _mapMarkers.remove(_markedLocationMarker);
                }

                await _createMarkedLocationMarker().then((marker) {
                    _markedLocationMarker = marker;
                });


                await _dataHandler.setCameraPosition(
                    _dataHandler
                        .markedLocation,
                    _dataHandler
                        .settingsHandler
                        .defaultZoom);
                setState(() {
                    _mapMarkers.add(_markedLocationMarker);
                });
            }
        }
    }

    Widget _buttonDogPark() {
        return Container(
            width: _dataHandler
                .settingsHandler
                .buttonSize,
            height: _dataHandler
                .settingsHandler
                .buttonSize,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_dataHandler.settingsHandler.defaultBorderRadiusValue),
                color: _dataHandler
                    .settingsHandler
                    .buttonBackgroundColor,
                border: Border.all(color: Colors.black),
            ),
            child: IconButton(
                iconSize: _dataHandler
                    .settingsHandler
                    .buttonSize,
                icon: ImageIcon(AssetImage('assets/dogparkicon.png')),
                onPressed: _buttonDogParkPressed,
            ));
    }


    Widget _buttonWasteBin() {
        return Container(
            width: _dataHandler
                .settingsHandler
                .buttonSize,
            height: _dataHandler
                .settingsHandler
                .buttonSize,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_dataHandler.settingsHandler.defaultBorderRadiusValue),
                color: _dataHandler
                    .settingsHandler
                    .buttonBackgroundColor,
                border: Border.all(color: Colors.black),
            ),
            child: IconButton(
                iconSize: _dataHandler
                    .settingsHandler
                    .buttonSize,
                icon: ImageIcon(AssetImage('assets/wastebin_black.png')),
                onPressed: _buttonWasteBinPressed,
            ));
    }


    Widget _buttonPhoneLocation() {
        return Container(
            width: _dataHandler
                .settingsHandler
                .buttonSize,
            height: _dataHandler
                .settingsHandler
                .buttonSize,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_dataHandler.settingsHandler.defaultBorderRadiusValue),
                color: _dataHandler
                    .settingsHandler
                    .buttonBackgroundColor,
                border: Border.all(color: Colors.black),
            ),
            child: IconButton(
                iconSize: _dataHandler
                    .settingsHandler
                    .buttonSize * 0.7,
                icon: Icon(Icons.my_location),
                onPressed: _buttonPhoneLocationPressed,
            ));
    }

    Widget _buttonSetMarker() {
        Color butColor = _dataHandler
            .settingsHandler
            .buttonBackgroundColor;

        if (_buttonSetMarkerIsPressed == true) {
            if (_markedLocationMarker != null) {
                butColor = Colors.red;
            } else {
                butColor = Colors.green;
            }
        }


        return Container(
            width: _dataHandler
                .settingsHandler
                .buttonSize,
            height: _dataHandler
                .settingsHandler
                .buttonSize,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_dataHandler.settingsHandler.defaultBorderRadiusValue),
                color: butColor,
                border: Border.all(color: Colors.black),
            ),
            child: IconButton(
                iconSize: _dataHandler
                    .settingsHandler
                    .buttonSize * 0.7,
                icon: Icon(Icons.add_location),
                onPressed: _buttonSetMarkerPressed,
            ));
    }

    void _buttonDogParkPressed() async {
        bool search = await showDialog<bool>(
            context: context,
            builder: (context) =>
                SearchSettingsDialog(
                    _dataHandler
                        .settingsHandler
                        .searchDogParkDistance,
                    _dataHandler
                        .settingsHandler
                        .searchDogParkResults, 'Sök hundparker!', _dataHandler),
        );

        // If the user taps outside the dialog the result will be null,
        // if the user taps on 'Avbryt'-button the result will be false
        if (search == null || search == false) {
            return;
        } else {

            setState(() {
              _isDownloadingData = true;
            });

            // the user want to do a search for dog parks

            // remove old markers from the map
            _dataHandler
                .dogParks
                .forEach((dogpark) {
                // Maybe unnecessary to check for null
                if (dogpark.getMarker() != null &&
                    _mapMarkers.contains(dogpark.getMarker())) {
                    _mapMarkers.remove(dogpark.getMarker());
                }
            });


            // Remove old search results
            _dataHandler
                .dogParks
                .forEach((park) {
                if (_mapMarkers.contains(park.getMarker()))
                    _mapMarkers.remove(park.getMarker());
            });
            _dataHandler
                .dogParks
                .clear();


            http.Response response = await _dataHandler
                .downloadDogParks();
            if (response.statusCode == 200) {
                try {
                    String jsonData = utf8.decode(response.bodyBytes);
                    List allUnparsedParks = jsonDecode(jsonData);
                    List<DogPark> parsedParks = await _dataHandler
                        .parseDogParks(allUnparsedParks);

                    // Calulate the distance to the park based on where we searched from
                    parsedParks.forEach((park) {
                        park.setDistance(
                            _dataHandler.getDistanceBetween(
                                park.getPosition().latitude,
                                park.getPosition().longitude,
                                _dataHandler
                                    .selectedLocation
                                    .latitude,
                                _dataHandler
                                    .selectedLocation
                                    .longitude
                            )
                        );
                    });

                    // Sort the list based on distance
                    parsedParks.sort((DogPark a, DogPark b) {
                        if (a.getDistance() > b.getDistance()) {
                            return 1;
                        } else if (a.getDistance() < b.getDistance()) {
                            return -1;
                        } else {
                            return 0;
                        }
                    });

                    for (int i = 0; i < parsedParks.length && i < _dataHandler
                        .settingsHandler
                        .searchDogParkResults
                        .getCurrentValue()
                        .toInt(); i++) {
                        parsedParks[i].setMarker(await _createDogParkMarker(parsedParks[i]));
                        _dataHandler
                            .dogParks
                            .add(parsedParks[i]);
                        _mapMarkers.add(parsedParks[i].getMarker());
                    }

                    _dataHandler
                        .dogParks
                        .forEach((element) {
                        print(element.toString());
                    });



                } catch (error) {
                    // Error while parsing
                }
            } else {
                // Error while downloading
            }
        }

            setState(() {
                _isDownloadingData = false;
            });


        if (_dataHandler.dogParks.isEmpty) {
            _displaySnackBar(context, 'Hitta inga hundparker');
        } else {
            String str = ' hundpark';
            if (_dataHandler.dogParks.length> 1)
                str = ' hundparker';

            _displaySnackBar(context, 'Hittade ' + _dataHandler.dogParks.length.toString() + str);

        }


    }

    void _buttonWasteBinPressed() async {
        bool search = await showDialog<bool>(
            context: context,
            builder: (context) =>
                SearchSettingsDialog(
                    _dataHandler
                        .settingsHandler
                        .searchWasteBinDistance,
                    _dataHandler
                        .settingsHandler
                        .searchWasteBinResults, 'Sök papperskorgar!', _dataHandler),
        );


        // If the user taps outside the dialog the result will be null,
        // if the user taps on 'Avbryt'-button the result will be false

        if (search == null || search == false) {
            return;
        } else {
            setState(() {
                _isDownloadingData = true;
            });
            // the user taped on a search button
            _dataHandler
                .wasteBins
                .forEach((wastebin) {
                // Maybe unnecessary to check for null
                if (wastebin.getMarker() != null &&
                    _mapMarkers.contains(wastebin.getMarker())) {
                    _mapMarkers.remove(wastebin.getMarker());
                }
            });


            _dataHandler
                .wasteBins
                .clear();

            http.Response response = await _dataHandler
                .downloadWasteBins();


            if (response.statusCode == 200) {

                try {
                    String jsonData = utf8.decode(response.bodyBytes);

                    List allWasteBins = jsonDecode(jsonData);
                    List<WasteBin> parsedBins = await _dataHandler
                        .parseWasteBins(allWasteBins);

                    // Calulate the distance to the park based on where we searched from
                    parsedBins.forEach((wasteBin) {
                        wasteBin.setDistance(
                            _dataHandler.getDistanceBetween(
                                wasteBin.getPosition().latitude,
                                wasteBin.getPosition().longitude,
                                _dataHandler
                                    .selectedLocation
                                    .latitude,
                                _dataHandler
                                    .selectedLocation
                                    .longitude
                            )
                        );
                    });

                    // Sort the list based on distance
                    parsedBins.sort((WasteBin a, WasteBin b) {
                        if (a.getDistance() > b.getDistance()) {
                            return 1;
                        } else if (a.getDistance() < b.getDistance()) {
                            return -1;
                        } else {
                            return 0;
                        }
                    });

                    for (int i = 0; i < parsedBins.length && i < _dataHandler
                        .settingsHandler
                        .searchWasteBinResults
                        .getCurrentValue()
                        .toInt(); i++) {

                        parsedBins[i].setMarker(await _createWasteBinMarker(parsedBins[i]));
                        _dataHandler
                            .wasteBins
                            .add(parsedBins[i]);
                        _mapMarkers.add(parsedBins[i].getMarker());
                    }


                    _dataHandler
                        .wasteBins
                        .forEach((element) {
                        print(element.toString());
                    });




                } catch (error) {
                    // Error while parsing
                }

            } else {
                // Error while downloading

            }

        }

        setState(() {
        _isDownloadingData = false;
        });
        if (_dataHandler.wasteBins.isEmpty) {
            _displaySnackBar(context, 'Hitta inga papperskorgar');
        } else {
            String str = ' papperskorg';
            if (_dataHandler.wasteBins.length> 1)
                str = ' papperskorgar';

            _displaySnackBar(context, 'Hittade ' + _dataHandler.wasteBins.length.toString() + str);

        }



    }

    void _buttonPhoneLocationPressed() async {
        // Wait until the location have been found
        await _dataHandler.updatePhoneLocation();

        // Change the map to the phone's location
        await _dataHandler.setCameraPosition(_dataHandler
            .phoneLocation,
            _dataHandler
                .settingsHandler
                .defaultZoom);


        if (_phoneLocationMarker != null &&
            _mapMarkers.contains(_phoneLocationMarker)) {
            _mapMarkers.remove(_phoneLocationMarker);
        }

        await _createPhoneLocationMarker().then((marker) {
            _phoneLocationMarker = marker;
        });

        setState(() {
            _mapMarkers.add(_phoneLocationMarker);
        });
    }

    void _buttonSetMarkerPressed() {
        setState(() {
            _buttonSetMarkerIsPressed = !_buttonSetMarkerIsPressed;
        });
    }


    @override
    void initState() {
        super.initState();


        // Prevents the map for freezing
        Screen.keepOn(true);

        WidgetsBinding.instance.addPostFrameCallback((_) async {
            _buttonPhoneLocationPressed();
        });
    }


    Future<Marker> _createDogParkMarker(DogPark park) async {
        if (_dataHandler
            .dogParkMarkerIcon == null) {
            _dataHandler
                .dogParkMarkerIcon =
            await _dataHandler.createBorderedIcon(
                'assets/dogparkicon_color.png',
                100,
                5,
                Colors.green,
                Colors.black);
        }

        return Marker(
            markerId: MarkerId('dogpark_id_' + park.getID().toString()),
            icon: _dataHandler
                .dogParkMarkerIcon,
            position: park.getPosition(),
            onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DogParkScreen(dogPark: park, dataHandler: _dataHandler),
                    ),
                );
            }
        );
    }
    Future<Marker> _createWasteBinMarker(WasteBin wastebin) async {
        if (_dataHandler
            .wasteBinMarkerIcon == null) {
            _dataHandler
                .wasteBinMarkerIcon =
            await _dataHandler.createBorderedIcon(
                'assets/wastebin_color.png',
                100,
                5,
                Colors.white70,
                Colors.black);
        }

        int id =  _dataHandler.wasteBins.length+1;

        return Marker(
            markerId: MarkerId('wastebin_id_$id'),
            icon: _dataHandler
                .wasteBinMarkerIcon,
            position: wastebin.getPosition(),

        );
    }

    Future<Marker> _createMarkedLocationMarker() async {
        if (_dataHandler
            .markedLocationMarkerIcon == null) {
            await _dataHandler.createTextIcon(
                "Sök härifrån!", Colors.white, Colors.blue).then((icon) {
                _dataHandler
                    .markedLocationMarkerIcon = icon;
            });
        }

        return Marker(
            markerId: MarkerId(
                _dataHandler
                    .settingsHandler
                    .markedLocationMarkerStringID),
            icon: _dataHandler
                .markedLocationMarkerIcon,
            position: _dataHandler
                .markedLocation,
            onTap: () {
                _askToRemoveMarker();
            }
        );
    }


    Future<Marker> _createPhoneLocationMarker() async {
        if (_dataHandler
            .phoneLocationMarkerIcon == null) {
            await _dataHandler.createTextIcon(
                "Här är du!", Colors.white, Colors.blue).then((icon) {
                _dataHandler
                    .phoneLocationMarkerIcon = icon;
            });
        }

        return Marker(
            markerId: MarkerId(
                _dataHandler
                    .settingsHandler
                    .phoneLocationMarkerStringID),
            icon: _dataHandler
                .phoneLocationMarkerIcon,
            position: _dataHandler
                .phoneLocation,
        );
    }



    void _askToRemoveMarker() {
        showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
                return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0))),

                    title: Text('Sökmarkering'),
                    content: Text('Vill du ta bort sökmarkeringen'),
                    actions: <Widget>[
                        FlatButton(
                            child: Text('Ja'),
                            onPressed: () {
                                _mapMarkers.remove(_markedLocationMarker);
                                _markedLocationMarker = null;
                                _dataHandler
                                    .markedLocation = null;

                                setState(() {
                                    _buttonSetMarkerIsPressed = false;
                                });
                                Navigator.of(context).pop();
                            },
                        ),
                        FlatButton(
                            child: Text('Nej'),
                            onPressed: () {
                                setState(() {
                                    _buttonSetMarkerIsPressed = false;
                                });

                                Navigator.of(context).pop();
                            },
                        ),
                    ],
                );
            });
    }


    _displaySnackBar(BuildContext context, String str) {
        if (_scaffoldKey.currentState != null) {
            final snackBar = SnackBar(content: Text(str));
            _scaffoldKey.currentState.showSnackBar(snackBar);
        }
    }


}
