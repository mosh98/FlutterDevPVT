import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:screen/screen.dart';

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
	MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {



	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('Map'),
				centerTitle: true,
			),
			body: Stack(
				children: <Widget>[
					MapWidget(key: StateHandler.mapWidgetStateKey),
					Align(
						alignment: Alignment.topRight,
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.end,
							children: <Widget>[
								Container(
									padding: EdgeInsets.all(10),
									child:
									DogparkWidget(key: StateHandler
										.dogparkWidgetStateKey),
								),
								Container(
									padding: EdgeInsets.all(10),
									child: WastebinWidget(
										key: StateHandler
											.wastebinWidgetStateKey),
								),
								Container(
									padding: EdgeInsets.all(10),
									child: SearchPosWidget(
										key: StateHandler
											.searchPosWidgetStateKey),
								),
								Container(
									padding: EdgeInsets.all(10),
									child: MyLocationWidget(
										key: StateHandler
											.myLocationWidgetStateKey),
								),
							],
						),
					)
				],
			));
	}

	@override
	void initState() {
		// Förhindrar att googlemap låser sig
		Screen.keepOn(true);

	}
}

class MapWidget extends StatefulWidget {
	MapWidget({Key key}) : super(key: key);

	@override
	MapWidgetState createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
	LatLng currentLocation;
	Location locationFinder = new Location();

	Marker currentLocationMarker;
	Marker searchLocationMarker;

	BitmapDescriptor currentLocationIcon;
	BitmapDescriptor searchLocationIcon;

	Future<LocationData> getCurrentLocation() async {
		bool _serviceEnabled;
		PermissionStatus _permissionGranted;

		_serviceEnabled = await locationFinder.serviceEnabled();
		if (!_serviceEnabled) {
			_serviceEnabled = await locationFinder.requestService();
			if (!_serviceEnabled) {
				return null;
			}
		}
		_permissionGranted = await locationFinder.hasPermission();
		if (_permissionGranted == PermissionStatus.denied) {
			_permissionGranted = await locationFinder.requestPermission();
			if (_permissionGranted != PermissionStatus.granted) {
				return null;
			}
		}

		return await locationFinder.getLocation();
	}

	Set<Marker> _markers = new Set<Marker>();
	Completer<GoogleMapController> _controller = Completer();

	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addPostFrameCallback((_) {
			getCurrentLocation().then((locData) {
				setCurrentPos();
			});
		});
	}

	void setCurrentPos() async {
		if (currentLocationIcon == null) {
			await MyFunctions.createTextIcon(
				"Här är du!", Colors.white, Colors.black87)
				.then((icon) {
				currentLocationIcon = icon;
			});
		}


		getCurrentLocation().then((locData) {
			currentLocation = LatLng(locData.latitude, locData.longitude);
			if (currentLocationMarker != null) {
				_markers.remove(currentLocationMarker);
			}
			currentLocationMarker = Marker(
				markerId: MarkerId('current_loc_id'),
				position: currentLocation,
				icon: currentLocationIcon,
			);

			setState(() {
				_markers.add(currentLocationMarker);
			});
			setCameraPosition(currentLocation, 15);
			showMarkerInfo(currentLocationMarker.markerId);
		});
	}

	static final CameraPosition initCamPos =
	CameraPosition(target: LatLng(59, 18), zoom: 10);

	Future<void> showMarkerInfo(MarkerId markerId) async {
		try {
			final GoogleMapController controller = await _controller.future;
			await controller.showMarkerInfoWindow(markerId);
		} catch (error) {}
	}

	@override
	Widget build(BuildContext context) {
		return GoogleMap(
			mapType: MapType.normal,
			markers: _markers,
			onTap: onMapTap,
			initialCameraPosition: initCamPos,
			onMapCreated: (GoogleMapController controller) {
				_controller.complete(controller);
			});
	}

	void onMapTap(LatLng position) async {
		if (searchLocationIcon == null) {
			await MyFunctions.createTextIcon(
				"Sök härifrån!", Colors.white, Colors.black)
				.then((icon) {
				searchLocationIcon = icon;
			});
		}


		if (StateHandler.searchPosWidgetStateKey.currentState.isButtonPressed ==
			true) {
			StateHandler.searchPosWidgetStateKey.currentState
				.searchPosPressed();
			if (searchLocationMarker != null) {
				_markers.remove(searchLocationMarker);
			}
			searchLocationMarker = Marker(
				markerId: MarkerId('search_loc_id'),
				icon: searchLocationIcon,
				position: position,
				onTap: () {
					showRemoveMarkerDialog();
				},
			);

			await setCameraPosition(position, 15);
			_markers.add(searchLocationMarker);

			await showMarkerInfo(searchLocationMarker.markerId);
			setState(() {});
		}
	}

	Future<void> setCameraPosition(LatLng pos, double zoom) async {
		final GoogleMapController controller = await _controller.future;
		controller.animateCamera(CameraUpdate.newCameraPosition(
			CameraPosition(target: pos, zoom: zoom)));
	}

	Future<void> showRemoveMarkerDialog() async {
		return showDialog<void>(
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
									_markers.remove(searchLocationMarker);
									searchLocationMarker = null;
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
	}
}

class DogparkWidget extends StatefulWidget {
	DogparkWidget({Key key});

	@override
	DogparkWidgetState createState() => DogparkWidgetState();
}

class DogparkWidgetState extends State<DogparkWidget> {
	bool isPressed = false;
	bool isSearching = false;
	int maxDistance = 1000;
	Set<Marker> dogparkMarkers = Set<Marker>();
	BitmapDescriptor dogparkMarkerIcon;

	@override
	void initState() {
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		if (isPressed == false) {
			return Container(
				decoration: BoxDecoration(
					borderRadius: BorderRadius.circular(10),
					color: Colors.lightBlueAccent,
					border: Border.all(color: Colors.black),
				),
				child: IconButton(
					iconSize: 40,
					icon: isSearching
						? Icon(Icons.hourglass_empty)
						: ImageIcon(AssetImage('assets/dogparkicon.png')),
					onPressed: () {
						print("watebin pressed");
						setState(() {
							isPressed = true;
						});
					}),
			);
		} else {
			return Container(
				padding: EdgeInsets.all(12.0),
				decoration: BoxDecoration(
					borderRadius: new BorderRadius.all(
						new Radius.circular(15.0)),
					color: Colors.white,
					border: Border.all(color: Colors.blue)),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						Text('Max avstånd'),
						Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: <Widget>[
								Slider(
									value: maxDistance.toDouble(),
									min: 1,
									max: 5000,
									divisions: 100,
									onChanged: (value) {
										print(value);
										setState(() {
											maxDistance = value.toInt();
										});
									},
								),
								Text("$maxDistance m")
							],
						),
						Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: <Widget>[
								Container(
									decoration: BoxDecoration(
										borderRadius:
										new BorderRadius.all(
											new Radius.circular(10.0)),
										color: Colors.white,
										border: Border.all(color: Colors.blue)),
									child: FlatButton(
										onPressed: () {
											setState(() {
												isPressed = false;
												isSearching = false;
											});
										},
										child: Text('Avbryt'),
									),
								),
								Spacer(),
								Container(
									decoration: BoxDecoration(
										borderRadius:
										new BorderRadius.all(
											new Radius.circular(10.0)),
										color: Colors.white,
										border: Border.all(color: Colors.blue)),
									child: FlatButton(
										child: Text('Sök'),
										onPressed: () {
											setState(() {
												isPressed = false;
												isSearching = true;
											});

											searchForDogsParks();
										},
									),
								),
							],
						)
					],
				));
		}
	}

	void searchForDogsParks() async {
		// Tar bort dogpark-markeringarna och uppdaterar kartan
		StateHandler.mapWidgetStateKey.currentState.setState(() {
			StateHandler.mapWidgetStateKey.currentState._markers
				.removeAll(dogparkMarkers);
		});
		dogparkMarkers.clear();

		// Om man inte satt ut en markering, använd den egna positionen
		LatLng searchPosition =
			StateHandler.mapWidgetStateKey.currentState.currentLocation;
		if (StateHandler.mapWidgetStateKey.currentState.searchLocationMarker !=
			null) {
			searchPosition = LatLng(
				StateHandler.mapWidgetStateKey.currentState.searchLocationMarker
					.position.latitude,
				StateHandler.mapWidgetStateKey.currentState.searchLocationMarker
					.position.longitude);
		}

		String latitudeAsString = searchPosition.latitude.toString();
		String longitudeAsString = searchPosition.longitude.toString();
		String url =
			'https://pvt-dogpark.herokuapp.com/dogpark/find?latitude=$latitudeAsString&longitude=$longitudeAsString&distance=$maxDistance';

		try {
			http.Response response = await http.get(url);
			// Om data är null så kan man vara utanför sökområdet
			// Om datans längd är 0 så hittades inga
			if (response.body == null || response.body.length == 0) {
				MyFunctions.showSimpleDialog(context, "Oops!",
					"Hittade inga hundparker.\n\nTesta öka sökområdet!");
			} else {
				// Annars blir åäö fel
				String jsonData = utf8.decode(response.bodyBytes);

				// Lista med hundparker, varje hundpark är en map
				List dataAsList = jsonDecode(jsonData);

				// Spara alla hundparker i en lista som kan sorteras
				List<Map<String, dynamic>> dogparks = new List<
					Map<String, dynamic>>();

				List<String> keys = [
					'longitude',
					'latitude',
					'name',
					'description'
				];
				for (int index = 0; index < dataAsList.length; index++) {
					Map<String, dynamic> oneDogPark = new Map<String,
						dynamic>();
					keys.forEach(
							(element) =>
						oneDogPark[element] = dataAsList[index][element]);
					oneDogPark['distance'] = MyFunctions.getDistanceBetween(
						oneDogPark['latitude'],
						oneDogPark['longitude'],
						searchPosition.latitude,
						searchPosition.longitude);

					dogparks.add(oneDogPark);
				}

				// Sortera listan så kortaste avståndet ligger i början
				dogparks.sort((Map a, Map b) {
					if (a['distance'] > b['distance'])
						return 1;
					else if (a['distance'] < b['distance'])
						return -1;
					else
						return 0;
				});

				// Skapa ikonen om den inte är skapad, görs bara en gång
				if (dogparkMarkerIcon == null) {
					dogparkMarkerIcon = await MyFunctions.createBorderedIcon(
						'assets/dogparkicon_color.png',
						100,
						5,
						Colors.green,
						Colors.black);
				}

				String snackText = "Hittade " + dogparks.length.toString();
				snackText += (dogparks.length == 1) ? " hundpark." : " hundparker.";

				Scaffold.of(context)
					.showSnackBar(SnackBar(content: Text(snackText)));

				for (int i = 0; i < dogparks.length; i++) {
					dogparkMarkers.add(new Marker(
						markerId: MarkerId('hundpark' + i.toString()),
						position: LatLng(
							dogparks[i]['latitude'], dogparks[i]['longitude']),
						icon: dogparkMarkerIcon,
						onTap: () {
							MyFunctions.showSimpleDialog(
								context,
								dogparks[i]['name'],
								dogparks[i]['description'] +
									"\n\n\n" +
									dogparks[i]['distance'].toInt().toString() +
									" meter från markeringen");
						},
					));

					// Uppdatera kartan
					StateHandler.mapWidgetStateKey.currentState.setState(() {
						StateHandler.mapWidgetStateKey.currentState._markers
							.addAll(dogparkMarkers);
					});
				}
			}
		} catch (error) {
			MyFunctions.showSimpleDialog(context, "Oops!",
				"Något gick fel, försök igen senare!");
		}

		setState(() {
			isSearching = false;
		});
	}
}

class WastebinWidget extends StatefulWidget {
	WastebinWidget({Key key});

	@override
	WastebinWidgetState createState() => WastebinWidgetState();
}

class WastebinWidgetState extends State<WastebinWidget> {
	int maxWasteBins = 5;

	bool isPressed = false;
	bool isSearching = false;

	Set<Marker> wastebinMarkers = Set<Marker>();

	BitmapDescriptor wasteBinMarkerIcon;

	@override
	Widget build(BuildContext context) {
		if (isPressed == false) {
			return Container(
				decoration: BoxDecoration(
					borderRadius: BorderRadius.circular(10),
					color: Colors.lightBlueAccent,
					border: Border.all(color: Colors.black),
				),
				child: IconButton(
					iconSize: 40,
					icon: isSearching
						? Icon(Icons.hourglass_empty)
						: ImageIcon(AssetImage('assets/wastebin_black.png')),
					onPressed: () {
						setState(() {
							isPressed = true;
						});
					},
				),
			);
		} else {
			return Container(
				padding: EdgeInsets.all(12.0),
				decoration: BoxDecoration(
					borderRadius: new BorderRadius.all(
						new Radius.circular(15.0)),
					color: Colors.white,
					border: Border.all(color: Colors.blue)),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						Text('Max antal papperskorgar'),
						Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: <Widget>[
								Slider(
									value: maxWasteBins.toDouble(),
									min: 1,
									max: 10,
									divisions: 9,
									onChanged: (value) {
										print(value);
										setState(() {
											maxWasteBins = value.toInt();
										});
									},
								),
								Text("$maxWasteBins st")
							],
						),
						Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: <Widget>[
								Container(
									decoration: BoxDecoration(
										borderRadius:
										new BorderRadius.all(
											new Radius.circular(10.0)),
										color: Colors.white,
										border: Border.all(color: Colors.blue)),
									child: FlatButton(
										onPressed: () {
											isPressed = false;
											setState(() {
												isSearching = false;
											});
										},
										child: Text('Avbryt'),
									),
								),
								Spacer(),
								Container(
									decoration: BoxDecoration(
										borderRadius:
										new BorderRadius.all(
											new Radius.circular(10.0)),
										color: Colors.white,
										border: Border.all(color: Colors.blue)),
									child: FlatButton(
										child: Text('Sök'),
										onPressed: () {
											setState(() {
												isPressed = false;
												isSearching = true;
												searchForWasteBins();
											});
										},
									),
								),
							],
						)
					],
				));
		}
	}

	@override
	void initState() {}


	void searchForWasteBins() async {
		StateHandler.mapWidgetStateKey.currentState.setState(() {
			StateHandler.mapWidgetStateKey.currentState._markers
				.removeAll(wastebinMarkers);
		});
		wastebinMarkers.clear();

		LatLng searchPosition =
			StateHandler.mapWidgetStateKey.currentState.currentLocation;

		if (StateHandler.mapWidgetStateKey.currentState.searchLocationMarker !=
			null) {
			searchPosition = LatLng(
				StateHandler.mapWidgetStateKey.currentState.searchLocationMarker
					.position.latitude,
				StateHandler.mapWidgetStateKey.currentState.searchLocationMarker
					.position.longitude);
		}

		String latitudeAsString = searchPosition.latitude.toString();
		String longitudeAsString = searchPosition.longitude.toString();
		String url =
			'https://redesigned-backend.herokuapp.com/wastebin/find?Latitude=$latitudeAsString&Longitude=$longitudeAsString&MaxDistance=2000';

		try {

			http.Response response = await http.get(url);



			String jsonData = response.body;
			List dataAsList = jsonDecode(jsonData);
			if (dataAsList.isEmpty) {
				MyFunctions.showSimpleDialog(context, "Papperskorg",
					"Hittade inga papperskorgar :(");
			} else {
				List<Map<String, dynamic>> wastebins = new List<
					Map<String, dynamic>>();

				List<String> keys = [
					'longitude',
					'latitude',
				];


				for (int index = 0; index < dataAsList.length; index++) {
					Map<String, dynamic> oneWasteBin = new Map<String,
						dynamic>();
					keys.forEach(
							(element) =>
						oneWasteBin[element] = dataAsList[index][element]);
					oneWasteBin['distance'] =
						MyFunctions.getDistanceBetween(
							oneWasteBin['latitude'],
							oneWasteBin['longitude'],
							searchPosition.latitude,
							searchPosition.longitude);

					wastebins.add(oneWasteBin);
				}

				// Sortera listan så kortaste avståndet ligger i början
				wastebins.sort((Map a, Map b) {
					if (a['distance'] > b['distance'])
						return 1;
					else if (a['distance'] < b['distance'])
						return -1;
					else
						return 0;
				});


				// Skapa ikonen om den inte är skapad, görs bara en gång
				if (wasteBinMarkerIcon == null) {
					await MyFunctions.createBorderedIcon(
						'assets/wastebin_color.png', 100, 5, Colors.grey,
						Colors.black)
						.then((icon) {
						wasteBinMarkerIcon = icon;
					});
				}


				for (int i = 0; i < wastebins.length &&
					i < maxWasteBins; i++) {
					wastebinMarkers.add(new Marker(
						markerId: MarkerId('trashbin' + i.toString()),
						position: LatLng(
							wastebins[i]['latitude'],
							wastebins[i]['longitude']),
						icon: wasteBinMarkerIcon,
						infoWindow: InfoWindow(
							title: 'Papperskorg',
							snippet: wastebins[i]['distance']
								.toInt()
								.toString() +
								" m"),
					));
				}

				StateHandler.mapWidgetStateKey.currentState.setState(() {
					StateHandler.mapWidgetStateKey.currentState._markers
						.addAll(wastebinMarkers);
				});
			}


		} catch (error) {
			MyFunctions.showSimpleDialog(context, "Papperskorg",
				"Något gick fel, försök igen senare!");
		}
		setState(() {
			isSearching = false;
		});
	}



	void searchForWasteBins2() async {
		StateHandler.mapWidgetStateKey.currentState.setState(() {
			StateHandler.mapWidgetStateKey.currentState._markers
				.removeAll(wastebinMarkers);
		});
		wastebinMarkers.clear();

		LatLng searchPosition =
			StateHandler.mapWidgetStateKey.currentState.currentLocation;
		if (StateHandler.mapWidgetStateKey.currentState.searchLocationMarker !=
			null) {
			searchPosition = LatLng(
				StateHandler.mapWidgetStateKey.currentState.searchLocationMarker
					.position.latitude,
				StateHandler.mapWidgetStateKey.currentState.searchLocationMarker
					.position.longitude);
		}

		String lat_str = searchPosition.latitude.toString();
		String long_str = searchPosition.longitude.toString();
		String url =
			'https://redesigned-backend.herokuapp.com/wastebin/find?Latitude=$lat_str&Longitude=$long_str&MaxDistance=2000';

		if (wasteBinMarkerIcon == null) {
			await MyFunctions.createBorderedIcon(
				'assets/wastebin_color.png', 100, 5, Colors.grey, Colors.black)
				.then((icon) {
				wasteBinMarkerIcon = icon;
			});
		}
		try {
			await http.get(url).then((response) {
				setState(() {
					isSearching = false;
				});

				String jsonData = response.body;
				print(jsonData);
				List dataAsList = jsonDecode(jsonData);

				if (dataAsList.isEmpty) {
					MyFunctions.showSimpleDialog(
						context, "Papperskorg",
						"Hittade tyvärr inga papperskorgar.");
					return;
				}



				List<Map<String, double>> binData = new List<
					Map<String, double>>();
				for (int i = 0; i < dataAsList.length; i++) {
					double tempLat = dataAsList[i]['latitude'];
					double tempLong = dataAsList[i]['longitude'];
					double tempDist = MyFunctions.getDistanceBetween(
						tempLat, tempLong,
						searchPosition.latitude, searchPosition.longitude);
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

				for (int i = 0; i < binData.length && i < maxWasteBins; i++) {
					wastebinMarkers.add(new Marker(
						markerId: MarkerId('trashbin' + i.toString()),
						position: LatLng(
							binData[i]['latitude'], binData[i]['longitude']),
						icon: wasteBinMarkerIcon,
						infoWindow: InfoWindow(
							title: 'Papperskorg',
							snippet: binData[i]['distance'].toInt().toString() +
								" m"),
					));
				}

				StateHandler.mapWidgetStateKey.currentState.setState(() {
					StateHandler.mapWidgetStateKey.currentState._markers
						.addAll(wastebinMarkers);
				});
			});
		} catch (error) {
			MyFunctions.showSimpleDialog(
				context, "Hoppsan!", "Något gick fel, försök igen senare.");
			setState(() {
				isSearching = false;
			});
		}
	}
}

class SearchPosWidget extends StatefulWidget {
	SearchPosWidget({Key key}) : super(key: key);

	@override
	SearchPosWidgetState createState() => SearchPosWidgetState();
}

class SearchPosWidgetState extends State<SearchPosWidget> {
	bool isButtonPressed = false;

	@override
	Widget build(BuildContext context) {
		if (isButtonPressed) {
			return Container(
				decoration: BoxDecoration(
					color: Colors.white,
					border: Border.all(
						width: 3.0, color: Colors.lightBlueAccent),
					borderRadius: BorderRadius.all(Radius.circular(5.0) //
					),
				),
				child: FlatButton(
					child: Text('Peka på kartan!'),
					onPressed: searchPosPressed,
				),
			);
		} else {
			return Container(
				decoration: BoxDecoration(
					borderRadius: BorderRadius.circular(10),
					color: Colors.lightBlueAccent,
					border: Border.all(color: Colors.black),
				),
				child: Container(
					child: IconButton(
						iconSize: 40,
						icon: Icon(Icons.navigation),
						onPressed: searchPosPressed,
					),
				));
		}
	}

	void searchPosPressed() {
		setState(() {
			if (isButtonPressed == true) {
				isButtonPressed = false;
			} else {
				isButtonPressed = true;
			}
		});
	}
}

class MyLocationWidget extends StatefulWidget {
	MyLocationWidget({Key key});

	@override
	MyLocationWidgetState createState() => MyLocationWidgetState();
}

class MyLocationWidgetState extends State<MyLocationWidget> {
	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(10),
				color: Colors.lightBlueAccent,
				border: Border.all(color: Colors.black),
			),
			child: Container(
				child: IconButton(
					iconSize: 40,
					icon: Icon(Icons.my_location),
					onPressed: () {
						StateHandler.mapWidgetStateKey.currentState
							.setCurrentPos();
					},
				),
			),
		);
	}
}

class MyFunctions {
	/* Räknar ut avståndet i meter mellan två positioner */
	static double getDistanceBetween(double lat1, double long1, double lat2,
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

	/* Läser in en bild från assets och scalar den med avseende på width */
	static Future<Uint8List> getBytesFromAsset(String path, int width) async {
		ByteData data = await rootBundle.load(path);
		ui.Codec codec = await ui.instantiateImageCodec(
			data.buffer.asUint8List(),
			targetWidth: width);
		ui.FrameInfo fi = await codec.getNextFrame();
		return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
			.buffer
			.asUint8List();
	}

	/* Returnerar en assetsbild i sin ursprungsform som en ui.Image */
	static Future<ui.Image> loadUiImage(String assetPath) async {
		final data = await rootBundle.load(assetPath);
		final list = Uint8List.view(data.buffer);
		final completer = Completer<ui.Image>();
		ui.decodeImageFromList(list, completer.complete);
		return completer.future;
	}

	/* Visar en enkel ruta med titel, body samt en ok-knapp */
	static showSimpleDialog(context, String title, String body) {
		showDialog(
			context: context,
			barrierDismissible: false,
			builder: (BuildContext context) =>
				AlertDialog(

					shape: RoundedRectangleBorder(

						borderRadius: BorderRadius.all(
							Radius.circular(10),

						)),
					title: Text(title),

					content: Text(body),
					actions: <Widget>[
						FlatButton(
							child: Text('Ok'),
							onPressed: () {
								Navigator.of(context).pop();
							},
						),
					],
				),
		);
	}


	/* Skapar en kvadradisk ikon med avrundade hörn och med en ram */
	static Future<BitmapDescriptor> createBorderedIcon(String path,
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

	/* Skapar markeringar med text*/
	static Future<BitmapDescriptor> createTextIcon(String textStr,
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

	static bool SHOW_DEBUG_MESSAGE = true;

	static void debugMessage(String str) {
		if (SHOW_DEBUG_MESSAGE) print("DEBUG_MESSAGE: " + str);
	}
}

class StateHandler {
	static final GlobalKey<MapWidgetState> mapWidgetStateKey =
	GlobalKey<MapWidgetState>();
	static final GlobalKey<DogparkWidgetState> dogparkWidgetStateKey =
	GlobalKey<DogparkWidgetState>();
	static final GlobalKey<WastebinWidgetState> wastebinWidgetStateKey =
	GlobalKey<WastebinWidgetState>();
	static final GlobalKey<SearchPosWidgetState> searchPosWidgetStateKey =
	GlobalKey<SearchPosWidgetState>();
	static final GlobalKey<MyLocationWidgetState> myLocationWidgetStateKey =
	GlobalKey<MyLocationWidgetState>();
}
