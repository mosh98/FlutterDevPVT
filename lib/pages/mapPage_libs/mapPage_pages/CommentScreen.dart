import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../mapPage_models/DogPark.dart';
import '../mapPage_handlers/DataHandler.dart';

class CommentScreen extends StatefulWidget {
    final DogPark dogPark;
    final DataHandler dataHandler;

    CommentScreen(
        {Key key, @required this.dogPark, @required this.dataHandler});

    @override
    _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {


    final _myController = TextEditingController();

    bool _isUploadingReview = false;

    int _userRating = 5;

    @override
    Widget build(BuildContext context) {
        Widget theWidget = Container(child: Center(child: CircularProgressIndicator()));
        if (_isUploadingReview == false) {
            theWidget = Container(


                child: Column(

                    children: <Widget>[

                        Padding(padding: EdgeInsets.all(
                            widget.dataHandler.settingsHandler
                                .defaultPaddingBetweenRows
                        ),
                            child:


                            Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: widget.dataHandler
                                            .settingsHandler
                                            .defaultBorderWidth,
                                        color: widget.dataHandler
                                            .settingsHandler
                                            .defaultBorderColor),
                                    borderRadius: BorderRadius.circular(
                                        widget.dataHandler.settingsHandler
                                            .defaultBorderRadiusValue),
                                ),
                                child: Center(
                                    child: Text(
                                        'Betygsätt',
                                        style: TextStyle(
                                            fontSize: widget.dataHandler
                                                .settingsHandler
                                                .defaultFontSize,
                                            letterSpacing: widget.dataHandler
                                                .settingsHandler
                                                .defaultFontSize /
                                                7),
                                    )
                                ),
                            ),
                        ),


                        Padding(padding: EdgeInsets.all(
                            widget.dataHandler.settingsHandler
                                .defaultPaddingBetweenRows
                        ),
                            child:
                            Container(
                                padding: EdgeInsets.all(
                                    widget.dataHandler.settingsHandler
                                        .defaultPadding / 2),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: widget.dataHandler
                                            .settingsHandler
                                            .defaultBorderWidth,
                                        color: widget.dataHandler
                                            .settingsHandler
                                            .defaultBorderColor),
                                    borderRadius: BorderRadius.circular(
                                        widget.dataHandler.settingsHandler
                                            .defaultPadding),
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: _buildEditableStarRow(
                                        context,
                                        widget.dataHandler.settingsHandler
                                            .defaultIconSize,
                                        widget.dataHandler.settingsHandler
                                            .reviewStarIconColor),
                                ),
                            ),
                        ),

                        Expanded(child:

                        Padding(padding: EdgeInsets.all(
                            widget.dataHandler.settingsHandler
                                .defaultPaddingBetweenRows
                        ),
                            child: Container(

                                padding: EdgeInsets.all(
                                    widget.dataHandler.settingsHandler
                                        .defaultPadding / 2),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: widget.dataHandler
                                            .settingsHandler
                                            .defaultBorderWidth,
                                        color: widget.dataHandler
                                            .settingsHandler
                                            .defaultBorderColor),
                                    borderRadius: BorderRadius.circular(
                                        widget.dataHandler.settingsHandler
                                            .defaultPadding),
                                ),

                                child: Column(
                                    children: <Widget>[
                                        Text('Kommentera',
                                            style: TextStyle(
                                                fontSize: widget.dataHandler
                                                    .settingsHandler
                                                    .defaultFontSize,
                                                letterSpacing: widget
                                                    .dataHandler.settingsHandler
                                                    .defaultFontSize / 7)),

                                        TextField(

                                            controller: _myController,
                                        ),

                                    ],
                                )
                            )
                        ),
                        ),

                        Padding(padding: EdgeInsets.all(
                            widget.dataHandler.settingsHandler
                                .defaultPaddingBetweenRows
                        ), child:

                        Container(


                            padding: EdgeInsets.all(
                                widget.dataHandler.settingsHandler
                                    .defaultPadding / 2),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: widget.dataHandler
                                        .settingsHandler
                                        .defaultBorderWidth,
                                    color: widget.dataHandler
                                        .settingsHandler
                                        .defaultBorderColor),
                                borderRadius: BorderRadius.circular(
                                    widget.dataHandler.settingsHandler
                                        .defaultPadding),
                            ),

                            child: Row(

                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,

                                children: <Widget>[

                                    RaisedButton(
                                        textColor: Colors.white,
                                        color: Colors.deepOrangeAccent,
                                        shape: StadiumBorder(),
                                        onPressed: () {
                                            Navigator.pop(
                                                context, false);
                                        },
                                        child: Text('Tillbaka'),
                                    ),


                                    RaisedButton(
                                        textColor: Colors.white,
                                        color: Colors.blueAccent,
                                        shape: StadiumBorder(),
                                        onPressed: () {
                                            _uploadComment(
                                                _myController.text
                                                    .toString(),
                                                _userRating,
                                                widget.dogPark.getID());
                                        },

                                        child: Text('Spara'),
                                    ),


                                ],
                            ),
                        ),
                        ),

                    ],
                )
            );
        }


        return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(title: Text('Kommentar')),
            body: theWidget,
        );

    }

    void _uploadComment(String comment, int rating, int dogparkID) async {
        setState(() {
            _isUploadingReview = true;
        });

        http.Response response =
        await widget.dataHandler.postReview(comment, rating, dogparkID);

        if (response.statusCode == 200) {
            _isUploadingReview = false;

            Navigator.pop(context, true);
        } else {
            // something went wrong
        }
        _isUploadingReview = false;
        Navigator.pop(context, false);
    }


    List<Widget> _buildEditableStarRow(BuildContext context,
        double iconSize, Color iconColor) {
        var starGroup = List<Widget>();

        for (var i = 1; i <= 5; i++) {
            Icon icon = Icon(Icons.star_border,
                color: iconColor, size: iconSize);
            if (_userRating >= i) {
                icon = Icon(Icons.star,
                    color: iconColor, size: iconSize);
            }

            IconButton button = IconButton(
                icon: icon,
                onPressed: () {
                    setState(() {
                        if (_userRating == i) {
                            _userRating = i - 1;
                        } else {
                            _userRating = i;
                        }
                    });
                },
            );

            starGroup.add(button);
        }
        return starGroup;
    }


    @override
    void initState() {
        super.initState();

    }

    @override
    void dispose() {
        _myController.dispose();

        super.dispose();
    }
}
