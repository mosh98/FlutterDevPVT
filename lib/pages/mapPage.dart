
import 'package:flutter/material.dart';
import 'mapPage_libs/mapPage_pages/MainScreen.dart';


class MapPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Hundappen',
            home: MainScreen(),
        );
    }
}
