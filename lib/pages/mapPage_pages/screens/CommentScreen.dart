import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../classes/DogPark.dart';
import '../singletons/DataHandler.dart';

class CommentScreen extends StatefulWidget {
  final DogPark dogPark;
  final DataHandler dataHandler;

  CommentScreen({Key key, @required this.dogPark, @required this.dataHandler});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _myController = TextEditingController();


  bool _isUploadingReview = false;

  int _userRating = 4;

  @override
  Widget build(BuildContext context) {
  







    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Kommentar')),
      body: (_isUploadingReview == false) ? Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(widget.dataHandler.settingsHandler.defaultPaddingBetweenRows),
            child: Container(
              padding: EdgeInsets.all(widget.dataHandler.settingsHandler.defaultPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    width:  widget.dataHandler.settingsHandler.defaultBorderWidth,
                    color: widget.dataHandler.settingsHandler.defaultBorderColor),
                borderRadius: BorderRadius.circular(widget.dataHandler.settingsHandler.defaultBorderRadiusValue),
              ),
              child: Center(
                  child: Text(
                'Betygsätt',
                style: TextStyle(
                    fontSize: widget.dataHandler.settingsHandler.defaultFontSize,
                    letterSpacing: widget.dataHandler.settingsHandler.defaultFontSize / 7),
              )),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(widget.dataHandler.settingsHandler.defaultPaddingBetweenRows),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      width:  widget.dataHandler.settingsHandler.defaultBorderWidth,
                      color:  widget.dataHandler.settingsHandler.defaultBorderColor),
                  borderRadius: BorderRadius.circular(widget.dataHandler.settingsHandler.defaultPadding),
                ),
                child: Center(child: _starRow(context)),
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 4,
            child: Padding(
              padding: EdgeInsets.all(widget.dataHandler.settingsHandler.defaultPaddingBetweenRows),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      width:  widget.dataHandler.settingsHandler.defaultBorderWidth,
                      color:  widget.dataHandler.settingsHandler.defaultBorderColor),
                  borderRadius: BorderRadius.circular(widget.dataHandler.settingsHandler.defaultPadding),
                ),
                padding: EdgeInsets.all(widget.dataHandler.settingsHandler.defaultPadding),
                child: Column(
                  children: <Widget>[
                    Text('Kommentera',
                        style: TextStyle(
                            fontSize: widget.dataHandler.settingsHandler.defaultFontSize,
                            letterSpacing: widget.dataHandler.settingsHandler.defaultFontSize / 7)),
                    TextField(
                      controller: _myController,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(widget.dataHandler.settingsHandler.defaultPaddingBetweenRows),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    width:widget.dataHandler.settingsHandler.defaultBorderWidth,
                    color: widget.dataHandler.settingsHandler.defaultBorderColor),
                borderRadius: BorderRadius.circular(widget.dataHandler.settingsHandler.defaultPadding),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(widget.dataHandler.settingsHandler.defaultPadding),
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.deepOrangeAccent,
                          shape: StadiumBorder(),
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: Text('Tillbaka',
                              style: TextStyle(fontSize: widget.dataHandler.settingsHandler.defaultFontSize * 0.8)),
                        )),
                    Padding(
                        padding: EdgeInsets.all(widget.dataHandler.settingsHandler.defaultPadding),
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.blueAccent,
                          shape: StadiumBorder(),
                          onPressed: () {

                            _uploadComment(_myController.text.toString(),
                                _userRating+1, widget.dogPark.id);


                          },
                          child: Text('Spara',
                              style: TextStyle(fontSize: widget.dataHandler.settingsHandler.defaultFontSize * 0.8)),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ) : Center(child: CircularProgressIndicator()),
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

  Widget _starRow(BuildContext context) {
    widget.dataHandler.print_debug('_starRow userRating $_userRating');
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,

        padding: EdgeInsets.all(widget.dataHandler.settingsHandler.defaultPadding / 2),
        itemCount: 5,
        itemBuilder: (context, index) {
          return IconButton(
            icon: (_userRating >= index)
                ? Icon(Icons.star)
                : Icon(Icons.star_border),
            iconSize: widget.dataHandler.settingsHandler.defaultIconSize,
            color: Colors.orange,
            onPressed: () {
              setState(() {
                _userRating = index;
              });
            },
          );
        });
  }

  @override
  void dispose() {
    _myController.dispose();
    super.dispose();
  }
}
