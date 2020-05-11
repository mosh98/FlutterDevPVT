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


void main() => runApp(MapPage());


final GlobalKey<MapWidgetState> mapWidgetStateKey = GlobalKey<MapWidgetState>();
final GlobalKey<DogparkWidgetState> dogparkWidgetStateKey = GlobalKey<
	DogparkWidgetState>();
final GlobalKey<WastebinWidgetState> wastebinWidgetStateKey = GlobalKey<
	WastebinWidgetState>();
final GlobalKey<SearchPosWidgetState> searchPosWidgetStateKey = GlobalKey<
	SearchPosWidgetState>();
final GlobalKey<MyLocationWidgetState> myLocationWidgetStateKey = GlobalKey<
	MyLocationWidgetState>();


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
	MainScreenState createState() =>
		MainScreenState();

}

class MainScreenState extends State<MainScreen> {

	static SearchPosWidget searchPosWidget;


	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('Map'),
				centerTitle: true,
			),
			body: Stack(
				children: <Widget>[
					MapWidget(key: mapWidgetStateKey),
					Align(
						alignment: Alignment.topRight,
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.end,
							children: <Widget>[
								Container(
									padding: EdgeInsets.all(6),
									child: DogparkWidget(
										key: dogparkWidgetStateKey),
								),
								Container(

									padding: EdgeInsets.all(6),
									child: WastebinWidget(
										key: wastebinWidgetStateKey),
								),
								Container(
									padding: EdgeInsets.all(6),
									child: SearchPosWidget(
										key: searchPosWidgetStateKey),
								),
								Container(
									padding: EdgeInsets.all(6),
									child: MyLocationWidget(
										key: myLocationWidgetStateKey),
								),
							],
						),
					)
				],
			));
	}


}

class SearchPosWidget extends StatefulWidget {
	SearchPosWidget({Key key}) : super(key: key);

	@override
	SearchPosWidgetState createState() =>
		SearchPosWidgetState();
}

class SearchPosWidgetState extends State<SearchPosWidget> {
	bool isButtonPressed = false;


	Widget apa = new FlatButton(
		color: Colors.white,
		padding: EdgeInsets.all(4),
		child: Column(

			children: <Widget>[
				Text('Peka på'),
				Text('kartan!')
			],
		),

	);

	@override
	Widget build(BuildContext context) {
		if (isButtonPressed) {
			return
				Container(
					decoration: BoxDecoration(
						color: Colors.white,
						border: Border.all(
							width: 3.0,
							color: Colors.lightBlueAccent
						),
						borderRadius: BorderRadius.all(
							Radius.circular(5.0) //
						),
					),
					child: FlatButton(
						child: Text('Peka på kartan!'),
						onPressed: searchPosPressed,
					),
				);
		} else {
			return ClipOval(
				child:
				Container(
					color: Colors.lightBlueAccent,
					child: IconButton(
						iconSize: 40,
						icon: Icon(Icons.navigation),
						onPressed: searchPosPressed,
					),
				)

			);
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


	void setCurrentPos() {
		getCurrentLocation().then((locData) {
			currentLocation = LatLng(locData.latitude, locData.longitude);
			if (currentLocationMarker != null) {
				_markers.remove(currentLocationMarker);
			}
			currentLocationMarker = Marker(
				markerId: MarkerId('current_loc_id'),
				position: currentLocation,
				infoWindow: InfoWindow(title: 'Här är du!')
			);
			setState(() {
				_markers.add(currentLocationMarker);
			});
			setCameraPosition(currentLocation, 15);
			showMarkerInfo(currentLocationMarker.markerId);
		});
	}

	static final CameraPosition initCamPos = CameraPosition(
		target: LatLng(59, 18),
		zoom: 10);

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
		if (searchPosWidgetStateKey.currentState.isButtonPressed == true) {
			searchPosWidgetStateKey.currentState.searchPosPressed();
			if (searchLocationMarker != null) {
				_markers.remove(searchLocationMarker);
			}
			searchLocationMarker = Marker(
				markerId: MarkerId('search_loc_id'),
				icon: BitmapDescriptor.defaultMarkerWithHue(
					BitmapDescriptor.hueAzure),
				position: position,
				infoWindow: InfoWindow(title: 'Sök häromkring!'),
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
			CameraPosition(target: pos, zoom: zoom)
		));
	}

	Future<void> showRemoveMarkerDialog() async {
		return showDialog<void>(
			context: context,
			barrierDismissible: false,
			builder: (BuildContext context) {
				return AlertDialog(
					title: Text('Sökmarkering'),
					content:
					Text('Vill du ta bort sökmarkeringen'),
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
	DogparkWidgetState createState() =>
		DogparkWidgetState();
}

class DogparkWidgetState extends State<DogparkWidget> {

	bool isPressed = false;
	bool isSearching = false;
	int maxDistance = 1000;
	Set<Marker> dogparkMarkers = Set<Marker>();
	Uint8List dogparkMarkerIcon;

	@override
	Widget build(BuildContext context) {
		if (isPressed == false) {
			return ClipOval(
				child: Container(
					color: Colors.lightBlueAccent,
					child: IconButton(
						iconSize: 40,
						icon: isSearching ? Icon(Icons.hourglass_empty) :
						ImageIcon(
							AssetImage('assets/dogparkicon_white.png')),
						onPressed: () {
							print("watebin pressed");
							setState(() {
								isPressed = true;
							});
						}


					),
				),
			);
		}
		else {
			return Container(
				padding: EdgeInsets.all(12.0),
				decoration: BoxDecoration(
					borderRadius: new BorderRadius.all(
						new Radius.circular(15.0)),
					color: Colors.white,
					border: Border.all(color: Colors.blue)
				),
				child:

				Column(
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
										borderRadius: new BorderRadius.all(
											new Radius.circular(10.0)),
										color: Colors.white,
										border: Border.all(color: Colors.blue)
									),
									child:
									FlatButton(
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
										borderRadius: new BorderRadius.all(
											new Radius.circular(10.0)),
										color: Colors.white,
										border: Border.all(color: Colors.blue)
									),
									child:
									FlatButton(

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
				)
			);
		}
	}


	void searchForDogsParks() async {
		mapWidgetStateKey.currentState.setState(() {
			mapWidgetStateKey.currentState._markers.removeAll(dogparkMarkers);
		});
		dogparkMarkers.clear();


		dogparkMarkerIcon =
		await getBytesFromAsset('assets/dogparkmarker.png', 100);


		LatLng searchPosition = mapWidgetStateKey.currentState.currentLocation;
		if (mapWidgetStateKey.currentState.searchLocationMarker != null) {
			searchPosition = LatLng(
				mapWidgetStateKey.currentState.searchLocationMarker.position
					.latitude,
				mapWidgetStateKey.currentState.searchLocationMarker.position
					.longitude);
		}


		String lat_str = searchPosition.latitude.toString();
		String long_str = searchPosition.longitude.toString();
		String url = 'https://pvt-dogpark.herokuapp.com/dogpark/find?latitude=$lat_str&longitude=$long_str&distance=$maxDistance';

		try {
			await http.get(url).then((response) {
				setState(() {
					isSearching = false;
				});


				String jsonData = utf8.decode(response.bodyBytes);
				List dataAsList = jsonDecode(jsonData);

				if (dataAsList.isEmpty) {
					showSimpleDialog(context, "Hundparker",
						"Hittade tyvärr inga hundparker.");
					return;
				}
				List<Map<String, double>> binData = new List<
					Map<String, double>>();
				for (int i = 0; i < dataAsList.length; i++) {
					double tempLat = dataAsList[i]['latitude'];
					double tempLong = dataAsList[i]['longitude'];
					double tempDist = getDistanceBetween(tempLat, tempLong,
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


				for (int i = 0; i < dataAsList.length; i++) {
					double tempLat = dataAsList[i]['latitude'];
					double tempLong = dataAsList[i]['longitude'];
					double tempDist = getDistanceBetween(tempLat, tempLong,
						searchPosition.latitude, searchPosition.longitude);

					String name = dataAsList[i]['name'];
					String desc = dataAsList[i]['description'];
					dogparkMarkers.add(new Marker(
						markerId: MarkerId('hundpark' + i.toString()),
						position: LatLng(tempLat, tempLong),
						icon: BitmapDescriptor.fromBytes(dogparkMarkerIcon),
						infoWindow: InfoWindow(
							title: name + "(" + tempDist.toInt().toString() +
								") m",
							snippet: desc),
					));
				}

				mapWidgetStateKey.currentState.setState(() {
					mapWidgetStateKey.currentState._markers.addAll(
						dogparkMarkers);
				});
			});
		} catch (error) {
			showSimpleDialog(
				context, "Hoppsan!", "Något gick fel, försök igen senare.");
			setState(() {
				isSearching = false;
			});
		}
	}

}

class WastebinWidget extends StatefulWidget {
	WastebinWidget({Key key});

	@override
	WastebinWidgetState createState() =>
		WastebinWidgetState();
}

class WastebinWidgetState extends State<WastebinWidget> {

	int maxWasteBins = 5;

	bool isPressed = false;
	bool isSearching = false;


	Uint8List trashbinIcon;

	Set<Marker> trashbinMarkes = Set<Marker>();

	@override
	Widget build(BuildContext context) {
		if (isPressed == false) {
			return ClipOval(
				child: Container(
					color: Colors.lightBlueAccent,
					child: IconButton(
						iconSize: 40,
						icon: isSearching
							? Icon(Icons.hourglass_empty)
							: ImageIcon(
							AssetImage('assets/wastebin_black.png')),
						onPressed: () {
							setState(() {
								isPressed = true;
							});
						},
					),
				),
			);
		} else {
			return Container(
				padding: EdgeInsets.all(12.0),
				decoration: BoxDecoration(
					borderRadius: new BorderRadius.all(
						new Radius.circular(15.0)),
					color: Colors.white,
					border: Border.all(color: Colors.blue)
				),
				child:

				Column(
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
										borderRadius: new BorderRadius.all(
											new Radius.circular(10.0)),
										color: Colors.white,
										border: Border.all(color: Colors.blue)
									),
									child:
									FlatButton(
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
										borderRadius: new BorderRadius.all(
											new Radius.circular(10.0)),
										color: Colors.white,
										border: Border.all(color: Colors.blue)
									),
									child:
									FlatButton(

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
				)


			);
		}
	}

	@override
	void initState() {


	}


	void searchForWasteBins() async {
		mapWidgetStateKey.currentState.setState(() {
			mapWidgetStateKey.currentState._markers.removeAll(trashbinMarkes);
		});
		trashbinMarkes.clear();


		trashbinIcon =
		await getBytesFromAsset('assets/trashbin_icon_black.png', 100);


		LatLng searchPosition = mapWidgetStateKey.currentState.currentLocation;
		if (mapWidgetStateKey.currentState.searchLocationMarker != null) {
			searchPosition = LatLng(
				mapWidgetStateKey.currentState.searchLocationMarker.position
					.latitude,
				mapWidgetStateKey.currentState.searchLocationMarker.position
					.longitude);
		}


		String lat_str = searchPosition.latitude.toString();
		String long_str = searchPosition.longitude.toString();
		String url = 'https://redesigned-backend.herokuapp.com/wastebin/find?Latitude=$lat_str&Longitude=$long_str&MaxDistance=2000';

		try {
			await http.get(url).then((response) {
				setState(() {
					isSearching = false;
				});


				String jsonData = response.body;
				print(jsonData);
				List dataAsList = jsonDecode(jsonData);

				if (dataAsList.isEmpty) {
					showSimpleDialog(context, "Papperskorg",
						"Hittade tyvärr inga papperskorgar.");
					return;
				}
				List<Map<String, double>> binData = new List<
					Map<String, double>>();
				for (int i = 0; i < dataAsList.length; i++) {
					double tempLat = dataAsList[i]['latitude'];
					double tempLong = dataAsList[i]['longitude'];
					double tempDist = getDistanceBetween(tempLat, tempLong,
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


				for (int i = 0;
				i < binData.length && i < maxWasteBins;
				i++) {
					trashbinMarkes.add(new Marker(
						markerId: MarkerId('trashbin' + i.toString()),
						position: LatLng(
							binData[i]['latitude'], binData[i]['longitude']),
						icon: BitmapDescriptor.fromBytes(trashbinIcon),
						infoWindow: InfoWindow(
							title: 'Papperskorg',
							snippet: binData[i]['distance'].toInt().toString() +
								" m"),
					));
				}

				mapWidgetStateKey.currentState.setState(() {
					mapWidgetStateKey.currentState._markers.addAll(
						trashbinMarkes);
				});
			});
		} catch (error) {
			showSimpleDialog(
				context, "Hoppsan!", "Något gick fel, försök igen senare.");
			setState(() {
				isSearching = false;
			});
		}
	}


}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
	ByteData data = await rootBundle.load(path);
	ui.Codec codec = await ui.instantiateImageCodec(
		data.buffer.asUint8List(), targetWidth: width);
	ui.FrameInfo fi = await codec.getNextFrame();
	return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer
		.asUint8List();
}


void showSimpleDialog(context, String title, String body) {
	showDialog(
		context: context,
		barrierDismissible: false,
		child: AlertDialog(
			title: Text(title),
			content:
			Text(body),
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

class MyLocationWidget extends StatefulWidget {
	MyLocationWidget({Key key});

	@override
	MyLocationWidgetState createState() => MyLocationWidgetState();
}

class MyLocationWidgetState extends State<MyLocationWidget> {
	@override
	Widget build(BuildContext context) {
		return ClipOval(
			child: Container(
				color: Colors.lightBlueAccent,
				child: IconButton(
					iconSize: 40,
					icon: Icon(Icons.my_location),
					onPressed: () {
						mapWidgetStateKey.currentState.setCurrentPos();
					},
				),
			),
		);
	}
}


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