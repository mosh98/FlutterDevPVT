import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../singletons/DataHandler.dart';
import '../classes/SearchSettings.dart';

class SearchSettingsDialog extends StatefulWidget {
    final DataHandler dataHandler;
    final SearchSettings distanceSettings;
    final SearchSettings resultsSettings;
    final String title;


    SearchSettingsDialog(this.distanceSettings,
        this.resultsSettings,
        this.title,this.dataHandler);

    @override
    _SearchSettingsDialogState createState() =>
        _SearchSettingsDialogState();
}


class _SearchSettingsDialogState extends State<SearchSettingsDialog> {

    @override
    Widget build(BuildContext context) {
        if (widget.dataHandler.phoneLocation == null &&
            widget.dataHandler.markedLocation == null) {
            return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0))),
                title: Text(widget.title, textAlign: TextAlign.center),

                content: Container(

                    child:
                    Text(
                        'Du måste tillåta telefonen att söka från din position eller sätta ut en markering på kartan'),

                ),

                actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                            Navigator.pop(context, false);
                        },
                        child: Text('Ok'),
                    )

                ],

            );
        } else {
            return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0))),
                title: Text(widget.title, textAlign: TextAlign.center),

                content: Container(

                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            Text('Maximala avståndet'),
                            Row(
                                children: <Widget>[
                                    Slider(
                                        value: widget.distanceSettings
                                            .currentValue,
                                        min: widget.distanceSettings.minValue,
                                        max: widget.distanceSettings.maxValue,
                                        divisions: widget.distanceSettings
                                            .divisions.toInt(),
                                        onChanged: (value) {
                                            setState(() {
                                                widget.distanceSettings
                                                    .currentValue = value;
                                            });
                                        },
                                    ),
                                    Text(widget.distanceSettings.currentValue
                                        .toInt()
                                        .toString() + " m"),
                                ],
                            ),
                            Text('Max sökträffar'),
                            Row(
                                children: <Widget>[
                                    Slider(
                                        value: widget.resultsSettings
                                            .currentValue,
                                        min: widget.resultsSettings.minValue,
                                        max: widget.resultsSettings.maxValue,
                                        divisions: widget.resultsSettings
                                            .divisions.toInt(),
                                        onChanged: (value) {
                                            setState(() {
                                                widget.resultsSettings
                                                    .currentValue = value;
                                            });
                                        },
                                    ),
                                    Text(widget.resultsSettings.currentValue
                                        .toInt()
                                        .toString() + " st"),
                                ],
                            ),


                            (widget.dataHandler.phoneLocation == null)
                                ? Container()
                                : FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(32.0))),
                                color: Colors.lightBlueAccent,

                                child: Text('Sök från din position'),
                                onPressed: () {
                                    widget.dataHandler.selectedLocation =
                                        widget.dataHandler.phoneLocation;
                                    Navigator.pop(context, true);
                                },
                            ),

                            (widget.dataHandler.markedLocation == null)
                                ? Container()
                                : FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(32.0))),
                                color: Colors.lightBlueAccent,
                                child: Text('Sök från kartmarkering'),
                                onPressed: () {
                                    widget.dataHandler.selectedLocation =
                                        widget.dataHandler.markedLocation;
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
}