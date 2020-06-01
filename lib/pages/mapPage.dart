import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'dart:ui' as ui;


import 'package:dog_prototype/services/Authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:screen/screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';


/*
   TODO: FIXA SÅ DEN INTE RÄKNAR MED BREDDEN OM TELEFONEN ÄR LIGGANDE
 */


// Gör det enkelt att filtera ut från Logcat
final bool PRINT_DEBUG_INFO = true;
final String DEBUG_FILTER_STR = "DEBUG_MSG:";


double DOGPARKS_SEARCH_DISTANCE = 1000;
double DOGPARKS_MAX_SEARCH_DISTANCE = 5000;
int DOGPARKS_MAX_RESULTS = 10;


double WASTEBINS_SEARCH_DISTANCE = 2000;
double WASTEBINS_MAX_SEARCH_DISTANCE = 5000;
int WASTEBINS_MAX_RESULTS = 10;


// Kan vara GPS-positionen eller en egen kartmarkering
LatLng SELECTED_SEARCH_LOCATION;

// Telefonens GPS-position
LatLng CURRENT_LOCATION_LATLNG;

// Markeringen på kartan
Marker CURRENT_LOCATION_MARKER;

// Markering på kartan om man vill söka på annan plats än sin egen
LatLng SEARCH_LOCATION_LATLNG;
Marker SEARCH_LOCATION_MARKER;


List<DogPark> DOGPARKS = List<DogPark>();
List<WasteBin> WASTEBINS = List<WasteBin>();

BitmapDescriptor DOGPARK_MARKER_ICON;
BitmapDescriptor WASTEBIN_MARKER_ICON;
BitmapDescriptor CURRENT_LOCATION_MARKER_ICON;
BitmapDescriptor SEARCH_LOCATION_MARKER_ICON;


DogPark SELECTED_DOGPARK;


void main() {
	runApp(MapPage());
}

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
	@override
	_MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {


	// Huvudknapparnas sida ska vara 15% av skärmens bredd
	double _buttonSideFactor = 0.15;

	// Höjden och bredden för de kvadratiska huvudknapparna
	// Sätts i Widget build hos _MainScreenState
	double _buttonSideLength;

	// Bakgrundsfärgen för huvudknapparna
	Color _buttonBackgroundColor = Colors.lightBlueAccent;

	// Används för att hitta telefonens position
	Location _locationFinder = new Location();

	// Innehåller kartans alla markeringar
	Set<Marker> _allMapMarkers = new Set<Marker>();

	// Gör det möjligt att kontrollera kartan
	Completer<GoogleMapController> _googleMapController = Completer();

	// Detta för kartan till stockholm, sen om användaren ger tillåtelse att
	// avlägsa GPS så flyttar kartan sin position till användarens GPS-position
	final CameraPosition _initCamPosition =
	CameraPosition(target: LatLng(59, 18), zoom: 10);


	bool _buttonSetSearchMarkerPressed = false;

	// Om det pågår en sökning av hundparker eller papperskorgar
	bool _isSearching = false;


	@override
	Widget build(BuildContext context) {
		_buttonSideLength = MediaQuery
			.of(context)
			.size
			.width * _buttonSideFactor;

		return Scaffold(
			appBar: AppBar(
				title: Text('Map'),
				centerTitle: true,
			),
			body: Stack(
				children: <Widget>[
					_mapWidget(),

					Center(
						child: (_isSearching == false)
							? Container()
							: CircularProgressIndicator(),
					),
					Align(
						alignment: Alignment.topRight,
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.end,
							children: <Widget>[
								Container(
									padding: EdgeInsets.all(10),
									child: _buttonSearchDogParks(),
								),
								Container(
									padding: EdgeInsets.all(10),
									child: _buttonSearchWasteBins(),
								),
								Container(
									padding: EdgeInsets.all(10),
									child: _buttonSetSearchMarker(),
								),
								Container(
									padding: EdgeInsets.all(10),
									child: _buttonFindMyLocation(),
								),


							],
						),
					),


				],
			)
		);
	}



	Widget _mapWidget() {
		return GoogleMap(
			mapType: MapType.normal,
			markers: _allMapMarkers,
			onTap: _onMapWidgetTap,
			initialCameraPosition: _initCamPosition,
			onMapCreated: (GoogleMapController controller) {
				_googleMapController.complete(controller);
			});
	}

	void _onMapWidgetTap(LatLng tapPosition) async {
		if (_buttonSetSearchMarkerPressed == true) {
			if (SEARCH_LOCATION_MARKER != null) {
				if (_allMapMarkers.contains(SEARCH_LOCATION_MARKER)) {
					_allMapMarkers.remove(SEARCH_LOCATION_MARKER);
				}
			}
			if (SEARCH_LOCATION_MARKER_ICON == null) {
				SEARCH_LOCATION_MARKER_ICON = await createTextIcon(
					"Sök härifrån!", Colors.white, Colors.blue);
			}


			SEARCH_LOCATION_LATLNG = tapPosition;
			SEARCH_LOCATION_MARKER = Marker(
				markerId: MarkerId('_buttonSetSearchMarker_id'),
				position: SEARCH_LOCATION_LATLNG,
				infoWindow: InfoWindow(title: 'Sök härifrån!'),
				icon: SEARCH_LOCATION_MARKER_ICON,
				onTap: () {
					showDialog<void>(
						context: context,
						barrierDismissible: false,
						builder: (BuildContext context) {
							return AlertDialog(

								title: Text('Sökmarkering'),
								content: Text('Vill du ta bort sökmarkeringen'),
								actions: <Widget>[
									FlatButton(
										child: Text('Ja'),
										onPressed: () {
											setState(() {
												_allMapMarkers.remove(
													SEARCH_LOCATION_MARKER);
												SEARCH_LOCATION_MARKER = null;
												SEARCH_LOCATION_LATLNG = null;
											});
											Navigator.of(context).pop();
										},
									),
									FlatButton(
										child: Text('Nej'),
										onPressed: () {
											Navigator.of(context).pop();
										},
									),
								],
							);
						},
					);
				});

			setCameraPosition(SEARCH_LOCATION_LATLNG, 15);
			setState(() {
				_buttonSetSearchMarkerPressed = false;
				_allMapMarkers.add(SEARCH_LOCATION_MARKER);
			});
			showMarkerInfo(SEARCH_LOCATION_MARKER);
		}
	}

	Widget _buttonSearchDogParks() {
		return Container(
			width: _buttonSideLength,
			height: _buttonSideLength,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(10),
				color: _buttonBackgroundColor,
				border: Border.all(color: Colors.black),
			),
			child: IconButton(
				iconSize: _buttonSideLength,
				icon: ImageIcon(AssetImage('assets/dogparkicon.png')),
				onPressed: _onPressedButtonSearchDogParks,
			));
	}

	void _onPressedButtonSearchDogParks() async {
		_searchForDogParks();
	}

	Widget _buttonSearchWasteBins() {
		return Container(
			width: _buttonSideLength,
			height: _buttonSideLength,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(10),
				color: _buttonBackgroundColor,
				border: Border.all(color: Colors.black),
			),
			child: IconButton(
				iconSize: _buttonSideLength,
				icon: ImageIcon(AssetImage('assets/wastebin_black.png')),
				onPressed: _onPressedButtonSearchWasteBins,
			));
	}

	void _onPressedButtonSearchWasteBins() async {
		_searchForWasteBins();
	}


	Widget _buttonSetSearchMarker() {
		double iconSize = _buttonSideLength * 0.7;
		return Container(
			width: _buttonSideLength,
			height: _buttonSideLength,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(10),
				color: (_buttonSetSearchMarkerPressed == false)
					? _buttonBackgroundColor
					: Colors.green,
				border: Border.all(color: Colors.black),
			),
			child: IconButton(
				iconSize: iconSize,
				icon: Icon(Icons.add_location),
				onPressed: _onPressedButtonSetSearchMarker,
			));
	}

	void _onPressedButtonSetSearchMarker() {
		setState(() {
			_buttonSetSearchMarkerPressed = !_buttonSetSearchMarkerPressed;
		});
	}

	Widget _buttonFindMyLocation() {
		double iconSize = _buttonSideLength * 0.7;

		return Container(
			width: _buttonSideLength,
			height: _buttonSideLength,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(10),
				color: _buttonBackgroundColor,
				border: Border.all(color: Colors.black),
			),
			child: IconButton(
				iconSize: iconSize,
				icon: Icon(Icons.my_location),
				onPressed: _onPressedButtonFindMyLocation,
			));
	}

	void _onPressedButtonFindMyLocation() async {
		await getCurrentLocation().then((locationData) async {
			if (locationData != null) {
				CURRENT_LOCATION_LATLNG =
					LatLng(locationData.latitude, locationData.longitude);

				// Ta bort gamla markeringen
				if (CURRENT_LOCATION_MARKER != null) {
					if (_allMapMarkers.contains(CURRENT_LOCATION_MARKER)) {
						_allMapMarkers.remove(CURRENT_LOCATION_MARKER);
					}
				}

				await createCurrentPositionMarker(CURRENT_LOCATION_LATLNG);

				setState(() {
					_allMapMarkers.add(CURRENT_LOCATION_MARKER);
				});

				await setCameraPosition(CURRENT_LOCATION_LATLNG, 15);
				await showMarkerInfo(CURRENT_LOCATION_MARKER);
			}
		});
	}

	@override
	void initState() {
		super.initState();

		// Förhindrar att GoogleMap låser sig
		Screen.keepOn(true);

		WidgetsBinding.instance.addPostFrameCallback((_) async {
			_setCurrentPos();
		});
	}

	void _setCurrentPos() async {
		if (CURRENT_LOCATION_MARKER_ICON == null) {
			await createTextIcon(
				"Här är du!", Colors.white, Colors.black87)
				.then((icon) {
				CURRENT_LOCATION_MARKER_ICON = icon;
			});
		}


		getCurrentLocation().then((locData) {
			CURRENT_LOCATION_LATLNG =
				LatLng(locData.latitude, locData.longitude);
			if (CURRENT_LOCATION_MARKER != null) {
				_allMapMarkers.remove(CURRENT_LOCATION_MARKER);
			}
			CURRENT_LOCATION_MARKER = Marker(
				markerId: MarkerId('current_loc_id'),
				position: CURRENT_LOCATION_LATLNG,
				icon: CURRENT_LOCATION_MARKER_ICON,
			);

			setState(() {
				_allMapMarkers.add(CURRENT_LOCATION_MARKER);
			});
			setCameraPosition(CURRENT_LOCATION_LATLNG, 15);
			showMarkerInfo(CURRENT_LOCATION_MARKER);
		});
	}


	void _searchForWasteBins() async {
		bool search = await showDialog<bool>(
			context: context,
			builder: (context) => SearchWasteBinsSettingsDialog(),
		);

		// Användaren tryckte på sök
		if (search == true) {
			if (WASTEBIN_MARKER_ICON == null) {
				await createBorderedIcon(
					'assets/wastebin_color.png', 100, 5, Colors.grey,
					Colors.black)
					.then((icon) {
					WASTEBIN_MARKER_ICON = icon;
				});
			}


			WASTEBINS.forEach((element) {
				_allMapMarkers.remove(element.marker);
			});
			WASTEBINS.clear();

			// Visar laddningsindikatorn mitt på kartan
			setState(() {
				_isSearching = true;
			});


			String token;
			await AuthService().getCurrentFirebaseUser().then(
					(value) =>
					value.getIdToken().then((value) => token = value.token));

			String lat = SELECTED_SEARCH_LOCATION.latitude.toString();
			String lon = SELECTED_SEARCH_LOCATION.longitude.toString();

			final http.Response response = await http.get(
				'https://dogsonfire.herokuapp.com/wastebin?latitude=$lat&longitude=$lon&distance=$WASTEBINS_SEARCH_DISTANCE',
				headers: <String, String>{
					'Content-Type': 'application/json; charset=UTF-8',
					'Authorization': "Bearer $token",
				},
			);

			if (response.statusCode == 200) {
				String jsonData = utf8.decode(response.bodyBytes);

				List allBins = jsonDecode(jsonData);

				List<WasteBin> tempBins = List<WasteBin>();

				for (int i = 0; i < allBins.length; i++) {
					WasteBin temp = WasteBin.fromJson(allBins[i]);
					temp.distance =
						getDistanceBetween(SELECTED_SEARCH_LOCATION.latitude,
							SELECTED_SEARCH_LOCATION.longitude, temp.latitude,
							temp.longitude);
					tempBins.add(temp);
				}

				tempBins.sort((WasteBin a, WasteBin b) {
					if (a.distance > b.distance)
						return 1;
					else if (a.distance < b.distance)
						return -1;
					else
						return 0;
				});

				for (int i = 0; i < tempBins.length &&
					i < WASTEBINS_MAX_RESULTS; i++) {
					if (tempBins[i].distance <= WASTEBINS_SEARCH_DISTANCE) {
						tempBins[i].marker = Marker(
							markerId: MarkerId('wastebin_id_$i'),
							infoWindow: InfoWindow(
								title: 'Papperskorg',
								snippet: tempBins[i].distance.toInt()
									.toString() +
									" m"),
							icon: WASTEBIN_MARKER_ICON,
							position: LatLng(
								tempBins[i].latitude, tempBins[i].longitude),
						);
						WASTEBINS.add(tempBins[i]);
						_allMapMarkers.add(tempBins[i].marker);
					}
				}
			} else {
				Scaffold.of(context).showSnackBar(
					SnackBar(content: Text("Oops! Något gick fel")));
			}


			Scaffold.of(context)
				.showSnackBar(
				SnackBar(content: Text(
					"Hittade " + WASTEBINS.length.toString() + " st.")));

			setCameraPosition(SELECTED_SEARCH_LOCATION, 15);
		} else {}
		setState(() {
			_isSearching = false;
		});
	}


	void _dogparkMarkerTapped(int index) async {
		Navigator.push(context, MaterialPageRoute(builder: (context) =>
			ReviewPage(selectedDogPark: DOGPARKS[index])));
	}


	Future<LocationData> getCurrentLocation() async {
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

		return await _locationFinder.getLocation();
	}

	void _searchForDogParks() async {
		bool search = await showDialog<bool>(
			context: context,
			builder: (context) => SearchDogParksSettingsDialog(),
		);


		// Användaren tryckte på sök
		if (search == true) {
			if (DOGPARK_MARKER_ICON == null) {
				DOGPARK_MARKER_ICON = await createBorderedIcon(
					'assets/dogparkicon_color.png',
					100,
					5,
					Colors.green,
					Colors.black);
			}

			DOGPARKS.forEach((element) {
				_allMapMarkers.remove(element.marker);
			});
			DOGPARKS.clear();
			setState(() {
				_isSearching = true;
			});

			String latitudeAsString = SELECTED_SEARCH_LOCATION.latitude
				.toString();
			String longitudeAsString = SELECTED_SEARCH_LOCATION.longitude
				.toString();


			String url = "https://dog-park-micro.herokuapp.com/api/v1/dog_park/find?latitude=$latitudeAsString&longitude=$longitudeAsString&distance=$DOGPARKS_SEARCH_DISTANCE";

			final http.Response response = await http.get(url);


			if (response.statusCode == 200) {
				String jsonData = utf8.decode(response.bodyBytes);

				List allparks = jsonDecode(jsonData);


				List<DogPark> allDogsParks = new List<DogPark>();
				for (int i = 0; i < allparks.length; i++) {
					DogPark temp = DogPark.fromJson(allparks[i]);
					temp.distance = getDistanceBetween(
						SELECTED_SEARCH_LOCATION.latitude,
						SELECTED_SEARCH_LOCATION.longitude,
						temp.latitude,
						temp.longitude);
					allDogsParks.add(temp);
				}

				allDogsParks.sort((DogPark a, DogPark b) {
					if (a.distance > b.distance)
						return 1;
					else if (a.distance < b.distance)
						return -1;
					else
						return 0;
				});

				for (int i = 0;
				i < allDogsParks.length && i < DOGPARKS_MAX_RESULTS;
				i++) {
					if (allDogsParks[i].distance <= DOGPARKS_SEARCH_DISTANCE) {
						allDogsParks[i].marker = Marker(
							markerId: MarkerId('dogpark_id_$i'),
							infoWindow: InfoWindow(
								title: allDogsParks[i].name +
									"\t" +
									allDogsParks[i].distance.toInt()
										.toString() +
									" m",
								snippet: allDogsParks[i].description),
							position: LatLng(allDogsParks[i].latitude,
								allDogsParks[i].longitude),
							icon: DOGPARK_MARKER_ICON,
							onTap: () {
								_dogparkMarkerTapped(i);
							},

						);

						DOGPARKS.add(allDogsParks[i]);
						_allMapMarkers.add(allDogsParks[i].marker);
					}
				}
			} else {
				Scaffold.of(context).showSnackBar(
					SnackBar(content: Text("Oops! Något gick fel")));
			}


			Scaffold.of(context)
				.showSnackBar(
				SnackBar(content: Text(
					"Hittade " + DOGPARKS.length.toString() + " st.")));

			setCameraPosition(SELECTED_SEARCH_LOCATION, 15);
		} else {}

		setState(() {
			_isSearching = false;
		});
	}

	Future<void> showMarkerInfo(Marker marker) async {
		/*
        await _googleMapController.future.then((controller) {
            if (controller != null) {
                try {
                    controller.showMarkerInfoWindow(marker.markerId);
                } catch (error) {}
            } else {}
        });

         */
	}

	Future<void> setCameraPosition(LatLng pos, double zoom) async {
		await _googleMapController.future.then((controller) {
			controller.animateCamera(CameraUpdate.newCameraPosition(
				CameraPosition(target: pos, zoom: zoom)));
		});
	}

	Future<Marker> createCurrentPositionMarker(LatLng position) async {
		if (CURRENT_LOCATION_MARKER_ICON == null) {
			CURRENT_LOCATION_MARKER_ICON =
			await createTextIcon("Här är du!", Colors.white, Colors.blue);
		}
		return Marker(
			markerId: MarkerId('gCurrentLocationMarker_id'),
			icon: CURRENT_LOCATION_MARKER_ICON,
			position: position,
			infoWindow: InfoWindow(title: 'Här är du!'),
		);
	}
}


class SearchDogParksSettingsDialog extends StatefulWidget {
	const SearchDogParksSettingsDialog({Key key}) : super(key: key);

	@override
	SearchDogParksSettingsDialogState createState() =>
		SearchDogParksSettingsDialogState();
}

class SearchDogParksSettingsDialogState
	extends State<SearchDogParksSettingsDialog> {
	@override
	void initState() {
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		return AlertDialog(
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.all(Radius.circular(32.0))),
			title: Text('Hundparker', textAlign: TextAlign.center),

			content: Container(

				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: <Widget>[
						Text('Maximala avståndet till parken'),
						Row(
							children: <Widget>[
								Slider(
									value: DOGPARKS_SEARCH_DISTANCE,
									min: 0,
									max: DOGPARKS_MAX_SEARCH_DISTANCE,
									divisions: 100,
									onChanged: (value) {
										setState(() {
											DOGPARKS_SEARCH_DISTANCE = value;
										});
									},
								),
								Text(DOGPARKS_SEARCH_DISTANCE.toInt()
									.toString() + " m"),
							],
						),
						Text('Max sökträffar'),
						Row(
							children: <Widget>[
								Slider(
									value: DOGPARKS_MAX_RESULTS.toDouble(),
									min: 1,
									max: 20,
									divisions: 20,
									onChanged: (value) {
										setState(() {
											DOGPARKS_MAX_RESULTS =
												value.toInt();
										});
									},
								),
								Text(DOGPARKS_MAX_RESULTS.toInt()
									.toString() + " st"),
							],
						),


						(CURRENT_LOCATION_LATLNG == null)
							? Container()
							: FlatButton(
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.all(
									Radius.circular(32.0))),
							color: Colors.lightBlueAccent,

							child: Text('Sök från din position'),
							onPressed: () {
								SELECTED_SEARCH_LOCATION =
									CURRENT_LOCATION_LATLNG;
								Navigator.pop(context, true);
							},
						),

						(SEARCH_LOCATION_LATLNG == null)
							? Container()
							: FlatButton(
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.all(
									Radius.circular(32.0))),
							color: Colors.lightBlueAccent,
							child: Text('Sök från kartmarkering'),
							onPressed: () {
								SELECTED_SEARCH_LOCATION =
									SEARCH_LOCATION_LATLNG;
								Navigator.pop(context, true);
							},
						),


					],
				)

			),
			actions: <Widget>[

				FlatButton(
					onPressed: () {
						Navigator.pop(context, false);
					},
					child: Text('Avbryt'),
				)
			],
		);
	}
}


class SearchWasteBinsSettingsDialog extends StatefulWidget {
	const SearchWasteBinsSettingsDialog({Key key}) : super(key: key);

	@override
	SearchWasteBinsSettingsDialogState createState() =>
		SearchWasteBinsSettingsDialogState();
}

class SearchWasteBinsSettingsDialogState
	extends State<SearchWasteBinsSettingsDialog> {
	@override
	void initState() {
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		return AlertDialog(
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.all(Radius.circular(32.0))),
			title: Text('Papperskorgar', textAlign: TextAlign.center),
			content: Container(
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: <Widget>[
						Text('Maximala avståndet'),
						Row(
							children: <Widget>[
								Slider(
									value: WASTEBINS_SEARCH_DISTANCE,
									min: 0,
									max: WASTEBINS_MAX_SEARCH_DISTANCE,
									divisions: 100,
									onChanged: (value) {
										setState(() {
											WASTEBINS_SEARCH_DISTANCE = value;
										});
									},
								),
								Text(WASTEBINS_SEARCH_DISTANCE.toInt()
									.toString() + " m"),
							],
						),
						Text('Max sökträffar'),
						Row(
							children: <Widget>[
								Slider(
									value: WASTEBINS_MAX_RESULTS.toDouble(),
									min: 1,
									max: 20,
									divisions: 20,
									onChanged: (value) {
										setState(() {
											WASTEBINS_MAX_RESULTS =
												value.toInt();
										});
									},
								),
								Text(WASTEBINS_MAX_RESULTS.toInt()
									.toString() + " st"),
							],
						),

						(CURRENT_LOCATION_LATLNG == null)
							? Container()
							: FlatButton(
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.all(
									Radius.circular(32.0))),
							child: Text('Sök från din position'),
							color: Colors.lightBlueAccent,
							onPressed: () {
								SELECTED_SEARCH_LOCATION =
									CURRENT_LOCATION_LATLNG;
								Navigator.pop(context, true);
							},
						),

						(SEARCH_LOCATION_LATLNG == null)
							? Container()
							: FlatButton(
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.all(
									Radius.circular(32.0))),
							color: Colors.lightBlueAccent,
							child: Text('Sök från kartmarkering'),
							onPressed: () {
								SELECTED_SEARCH_LOCATION =
									SEARCH_LOCATION_LATLNG;
								Navigator.pop(context, true);
							},
						),


					],
				)

			),
			actions: <Widget>[

				FlatButton(
					onPressed: () {
						Navigator.pop(context, false);
					},
					child: Text('Avbryt'),
				)
			],
		);
	}
}


class Review {


	int id;
	int rating;
	String comment;

	Review({this.id, this.rating, this.comment});

	factory Review.fromJson(Map<String, dynamic> json) {
		return Review(
			id: json['id'],
			rating: json['rating'],
			comment: json['comment'],
		);
	}

	@override
	String toString() {
		return "$id\t$rating\t$comment";
	}
}

class DogPark {
	int id;
	double latitude;
	double longitude;
	String name;
	String description;
	double distance;

	Marker marker;

	Marker getMarker() {
		return marker;
	}

	void setMarker(Marker m) {
		marker = m;
	}

	void setDistance(double value) {
		this.distance = value;
	}

	DogPark(
		{this.id, this.latitude, this.longitude, this.name, this.description});

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
		return "id: $id, latitude: $latitude, longitude: $longitude, name: $name, description: $description";
	}
}

class WasteBin {
	double latitude;
	double longitude;
	double distance;

	Marker marker;

	Marker getMarker() {
		return marker;
	}

	void setMarker(Marker m) {
		marker = m;
	}

	void setDistance(double value) {
		this.distance = value;
	}

	WasteBin({this.latitude, this.longitude});

	factory WasteBin.fromJson(Map<String, dynamic> json) {
		return WasteBin(
			latitude: json['latitude'], longitude: json['longitude']);
	}

	@override
	String toString() {
		return "WasteBin: $distance\t$latitude\t$longitude";
	}
}


class ReviewPage extends StatefulWidget {
	final DogPark selectedDogPark;

	const ReviewPage({Key key, this.selectedDogPark}) : super(key: key);


	@override
	ReviewPageState createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewPage> {
	final double _paddingSize = 12;
	List<Review> _reviews = new List<Review>();
	List<String> _imageURLs = new List<String>();
	double _listSideLength;

	double _rating = 0;
	bool _isLoading = false;

	@override
	void initState() {
		super.initState();
		_getImageURLs();
		_getReviews();
	}

	void _getReviews() async {
		_reviews.clear();
		_rating = 0;
		setState(() {
			_isLoading = true;
		});
		try {
			final int id = widget.selectedDogPark.id;
			final http.Response response = await http.get(
				'https://dog-park-micro.herokuapp.com/api/v1/review/id/$id',

			);

			if (response.statusCode == 200) {
				String jsonData = utf8.decode(response.bodyBytes);
				List decodedJson = jsonDecode(jsonData);
				for (int i = 0; i < decodedJson.length; i++) {
					Review tempReview = Review.fromJson(decodedJson[i]);
					_reviews.add(tempReview);
					_rating += tempReview.rating;
				}
				if (_reviews.length > 0)
					_rating /= _reviews.length;
			}
		} catch (error) {

		}

		setState(() {
			_isLoading = false;
		});
	}


	void _getImageURLs() async {
		int _dogParkID = widget.selectedDogPark.id;


		String url = "https://dog-park-micro.herokuapp.com/image/getImages?id=$_dogParkID";

		await http.get(url).then((http.Response response) {
			String result = utf8.decode(response.bodyBytes);
			print("RESULT: " + result);
			if (result.length > 2) {
				// Är en lista med [url, url1, url2] osv kan inte parsa den

				// Nu är den url, url1, url2
				result = result.substring(1, result.length - 1);

				// Nu är den url url1 url2
				result = result.replaceAll(',', '');
				_imageURLs = result.split(' ');

				print(_imageURLs.toString());
				print("---------->" + _imageURLs.length.toString());
			}
		});
	}

	void _uploadImage() async {
		setState(() {
			_isLoading = true;
		});

		int _dogParkID = widget.selectedDogPark.id;

		final String url = 'https://dog-park-micro.herokuapp.com/image/addImage?id=$_dogParkID';

		ImagePicker imagePicker = ImagePicker();

		var tempImage = await imagePicker.getImage(source: ImageSource.gallery);

		final postUri = Uri.parse(url);
		http.MultipartRequest request = http.MultipartRequest('POST', postUri);

		http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
			'file', tempImage.path);

		request.files.add(multipartFile);


		await request.send().then((response) async {
			response.stream.transform(utf8.decoder).listen((value) {

			});
		}).catchError((e) {
			print(e);
		});

		await _getImageURLs();


		setState(() {
			_isLoading = false;
		});
	}


	@override
	Widget build(BuildContext context) {
		_listSideLength = MediaQuery
			.of(context)
			.size
			.height / 4;


		return Scaffold(
			appBar: AppBar(
				title: Text(widget.selectedDogPark.name),
				centerTitle: true,
			),
			body: (_isLoading == false) ?
			Container(
				padding: EdgeInsets.all(_paddingSize),
				child: Column(
					children: <Widget>[

						Expanded(

							child: _imageList(context),
							//shrinkWrap: true,

						),
						Padding(
							padding: EdgeInsets.all(_paddingSize / 2),
							child:

							Container(
								decoration: BoxDecoration(

									borderRadius: BorderRadius.circular(10),
									border: Border.all(
										color: Colors.blueAccent),

								),

								padding: EdgeInsets.all(_paddingSize),
								child: Text(widget.selectedDogPark.description),
							),
						),
						Padding(
							padding: EdgeInsets.all(_paddingSize / 2),
							child:
							Container(


								decoration: BoxDecoration(

									borderRadius: BorderRadius.circular(10),
									border: Border.all(
										color: Colors.blueAccent),

								),
								child:

								Row(

									mainAxisAlignment: MainAxisAlignment.center,

									children: <Widget>[
										(_rating >= 1)
											? Icon(
											Icons.star, color: Colors.orange)
											: Icon(
											Icons.star_border,
											color: Colors.orange),
										(_rating >= 2)
											? Icon(
											Icons.star, color: Colors.orange)
											: Icon(
											Icons.star_border,
											color: Colors.orange),
										(_rating >= 3)
											? Icon(
											Icons.star, color: Colors.orange)
											: Icon(
											Icons.star_border,
											color: Colors.orange),
										(_rating >= 4)
											? Icon(
											Icons.star, color: Colors.orange)
											: Icon(
											Icons.star_border,
											color: Colors.orange),
										(_rating >= 5)
											? Icon(
											Icons.star, color: Colors.orange)
											: Icon(
											Icons.star_border,
											color: Colors.orange),
										Text(_rating.toStringAsFixed(1)
											.toString()),
										Text(
											"(" + _reviews.length.toString() +
												")"),
									],

								),
							),
						),

						Expanded(
							child: _reviewList(context),
						),

						Row(
							mainAxisAlignment: MainAxisAlignment.spaceAround,
							children: <Widget>[
								Container(
									decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(10),
										color: Colors.blueAccent,
									),
									child: FlatButton(
										textColor: Colors.white,
										child: Text('Ladda upp en bild!'),
										onPressed: () {
											_uploadImage();
										}
									),
								),

								Container(
									decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(10),
										color: Colors.blueAccent,
									),
									child: FlatButton(
										textColor: Colors.white,
										child: Text('Betygsätt och kommentera'),
										onPressed: () async {
											await Navigator.push(context,
												MaterialPageRoute(builder: (
													context) =>
													RatingPage(
														selectedDogPark: widget
															.selectedDogPark)))
												.then((_) {
												_getReviews();
											});
										},
									),
								),

							],
						)

					],
				),


			) : Container(child: Center(child: CircularProgressIndicator())),
		);
	}

	Widget _imageList(BuildContext context) {
		return ListView.builder(

			scrollDirection: Axis.horizontal,
			itemCount: _imageURLs.length,
			itemBuilder: (BuildContext context,
				int index) =>
				Padding(
					padding: EdgeInsets.all(_paddingSize / 2),
					child:

					Container(

						decoration: BoxDecoration(

							borderRadius: BorderRadius.circular(10),
							border: Border.all(color: Colors.blueAccent),

						),
						child: GestureDetector(

							onTap: () {
								showDialog<void>(
									context: context,
									barrierDismissible: true,
									builder: (BuildContext context) {
										return AlertDialog(

											content: GestureDetector(
												onTap: () {
													Navigator.pop(context);
												},
												child: Image.network(
													_imageURLs[index]),
											),
											actions: <Widget>[
											],
										);
									},
								);
							},
							child: Container(
								width: _listSideLength,
								height: _listSideLength,
								padding: EdgeInsets.all(_paddingSize),
								child: Image.network(
									_imageURLs[index]),
							),
						)
					),
				),

		);
	}

	Widget _imageList2(BuildContext context) {
		return ListView.builder(

			scrollDirection: Axis.horizontal,
			itemCount: _imageURLs.length,
			itemBuilder: (BuildContext context,
				int index) =>
				Card(
					child: GestureDetector(
						onTap: () {
							showDialog<void>(
								context: context,
								barrierDismissible: true,
								builder: (BuildContext context) {
									return AlertDialog(

										content: GestureDetector(
											onTap: () {
												Navigator.pop(context);
											},
											child: Image.network(
												_imageURLs[index]),
										),
										actions: <Widget>[
										],
									);
								},
							);
						},
						child: Container(
							width: _listSideLength,
							height: _listSideLength,

							decoration: BoxDecoration(

								borderRadius: BorderRadius.circular(10),
								border: Border.all(color: Colors.blueAccent),

							),
							child: Image.network(
								_imageURLs[index]),
						),
					)
				),
		);
	}

	Widget _reviewList(BuildContext context) {
		return ListView.builder(
			padding: EdgeInsets.all(_paddingSize),
			itemCount: _reviews.length,
			itemBuilder: (context, index) {
				return Card(


					child:

					Row(
						children: <Widget>[
							Row(children: <Widget>[
								(_reviews[index].rating >= 1)
									? Icon(
									Icons.star, color: Colors.orange)
									: Icon(
									Icons.star_border,
									color: Colors.orange),
								(_reviews[index].rating >= 2)
									? Icon(
									Icons.star, color: Colors.orange)
									: Icon(
									Icons.star_border,
									color: Colors.orange),
								(_reviews[index].rating >= 3)
									? Icon(
									Icons.star, color: Colors.orange)
									: Icon(
									Icons.star_border,
									color: Colors.orange),
								(_reviews[index].rating >= 4)
									? Icon(
									Icons.star, color: Colors.orange)
									: Icon(
									Icons.star_border,
									color: Colors.orange),
								(_reviews[index].rating >= 5)
									? Icon(
									Icons.star, color: Colors.orange)
									: Icon(
									Icons.star_border,
									color: Colors.orange),
								Text(_reviews[index].rating.toString()),
							]),
							Expanded(
								child:

								ListTile(

									title: Text(_reviews[index].comment),
								),
							)
						],

					),
				);
			},
		);
	}
}


class RatingPage extends StatefulWidget {
	final DogPark selectedDogPark;

	const RatingPage({Key key, this.selectedDogPark}) : super(key: key);


	@override
	RatingPageState createState() => RatingPageState();
}

class RatingPageState extends State<RatingPage> {
	int _rating = 0;
	final _myController = TextEditingController();


	bool _isSaving = false;

	void _updateRating(int rating) {
		setState(() {
			_rating = rating;
		});
	}

	@override
	void dispose() {
		_myController.dispose();
		super.dispose();
	}


	@override
	Widget build(BuildContext context) {
		final double paddingSize = 12;
		final double _iconSize = 40;
		return Scaffold(

			resizeToAvoidBottomInset: false,
			appBar: AppBar(title: Text('Kommentar')),

			body:


			(_isSaving == false) ? Column(

				children: <Widget>[


					Container(
						padding: EdgeInsets.all(20),
						child: Column(

							children: <Widget>[

								Text('Betyg'),


								Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: <Widget>[
										IconButton(
											icon: (_rating >= 1)
												? Icon(Icons.star)
												: Icon(Icons.star_border),
											iconSize: _iconSize,
											color: Colors.orange,
											onPressed: () {
												_updateRating(1);
											}
										),
										IconButton(
											icon: (_rating >= 2)
												? Icon(Icons.star)
												: Icon(Icons.star_border),
											iconSize: _iconSize,
											color: Colors.orange,
											onPressed: () {
												_updateRating(2);
											}
										),
										IconButton(
											icon: (_rating >= 3)
												? Icon(Icons.star)
												: Icon(Icons.star_border),
											iconSize: _iconSize,
											color: Colors.orange,
											onPressed: () {
												_updateRating(3);
											}
										),
										IconButton(
											icon: (_rating >= 4)
												? Icon(Icons.star)
												: Icon(Icons.star_border),
											iconSize: _iconSize,
											color: Colors.orange,
											onPressed: () {
												_updateRating(4);
											}
										),
										IconButton(
											icon: (_rating >= 5)
												? Icon(Icons.star)
												: Icon(Icons.star_border),
											iconSize: _iconSize,
											color: Colors.orange,
											onPressed: () {
												_updateRating(5);
											}
										),
									],
								),
							],
						),
					),

					Container(
						padding: EdgeInsets.all(20),

						child: Column(

							children: <Widget>[
								Text('Kommentera'),


								TextField(
									controller: _myController,
								),

							],
						),
					),

					Expanded(

						child: Align(
							alignment: Alignment.bottomCenter,

							child: Row(

								mainAxisAlignment: MainAxisAlignment
									.spaceBetween,
								children: <Widget>[
									Padding(
										padding: EdgeInsets.all(20),
										child:

										RaisedButton(
											textColor: Colors.white,
											color: Colors.blueAccent,
											shape: StadiumBorder(),
											onPressed: () {
												Navigator.pop(context, true);
											},
											child: Text("Tillbaka"),
										)
									),
									Padding(
										padding: EdgeInsets.all(20),
										child:

										RaisedButton(
											textColor: Colors.white,
											color: Colors.blueAccent,
											shape: StadiumBorder(),
											onPressed: () {
												_saveComment(_myController.text,
													_rating);
											},
											child: Text("Spara"),
										)
									),


								],
							),
						),
					),

				],
			) : Container(child: Center(child: CircularProgressIndicator(),)),


		);
	}

	void _saveComment(String str, int rating) async {
		setState(() {
			_isSaving = true;
		});

		final http.Response response = await http.post(
			'https://dog-park-micro.herokuapp.com/api/v1/review',
			headers: <String, String>{
				'Content-Type': 'application/json; charset=UTF-8',
			},
			body: jsonEncode(<String, dynamic>{
				"comment": "$str",
				"rating": "$rating",
				"dogParkId": widget.selectedDogPark.id,
			}),

		);


		Navigator.pop(context, true);
	}


}

/* Räknar ut avståndet i meter mellan två positioner */
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


/* Skapar en kvadradisk ikon med avrundade hörn och med en ram */
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
/* Skapar markeringar med text*/
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