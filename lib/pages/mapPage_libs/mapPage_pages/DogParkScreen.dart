import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'CommentScreen.dart';
import 'package:image_picker/image_picker.dart';

import '../mapPage_models/DogPark.dart';
import '../mapPage_models/Review.dart';
import '../mapPage_handlers/DataHandler.dart';

class DogParkScreen extends StatefulWidget {
    final DogPark dogPark;
    final DataHandler dataHandler;

    DogParkScreen({Key key, @required this.dogPark,  @required this.dataHandler});

    @override
    _DogParkScreenState createState() => _DogParkScreenState();
}

class _DogParkScreenState extends State<DogParkScreen> {
    bool _isInLoadingState = false;


    @override
    Widget build(BuildContext context) {

        return Scaffold(
            appBar: AppBar(
                title: Text(widget.dogPark.getName()),
                centerTitle: true,
            ),
            body: (_isInLoadingState == false)
                ? Column(

                children: <Widget>[
                    (widget.dogPark.getImageAddresses().isEmpty == false)
                        ? Flexible(
                        fit: FlexFit.tight,
                        flex: 1,
                        child: Container(child: _imageList(context)),
                    )
                        : Container(),

                    Padding
                        (
                        padding: EdgeInsets.all(widget.dataHandler.settingsHandler.defaultPaddingBetweenRows),

                        child: Container(

                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: widget.dataHandler.settingsHandler.defaultBorderWidth,
                                    color:  widget.dataHandler.settingsHandler.defaultBorderColor),
                                borderRadius: BorderRadius.circular(
                                    widget.dataHandler.settingsHandler.defaultPadding),
                            ),


                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                    widget.dataHandler.getStarRow(
                                        context,
                                        widget.dogPark.calculateRating(),
                                        widget.dataHandler.settingsHandler.defaultIconSize, widget.dataHandler
                                        .settingsHandler
                                        .reviewStarIconColor),

                                    Text(widget.dogPark
                                        .calculateRating()
                                        .toStringAsFixed(1)
                                        .toString()),
                                    Text("(" +
                                        widget.dogPark.getReviews().length
                                            .toString() +
                                        " st)"),
                                ],
                            )),
                    ),

                    Flexible(
                        fit: FlexFit.tight,
                        flex: 2,
                        child: _reviewList(context),
                    ),

                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(widget.dataHandler.settingsHandler.defaultBorderRadiusValue),
                                    color: Colors.blueAccent,
                                ),
                                child: FlatButton(
                                    textColor: Colors.white,
                                    child: Text('Ladda upp en bild'),
                                    onPressed: _onUploadimagePressed,
                                ),

                            ),
                            Padding
                                (
                                padding: EdgeInsets.all(
                                    widget.dataHandler.settingsHandler.defaultPaddingBetweenRows),

                                child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(widget.dataHandler.settingsHandler.defaultBorderRadiusValue),
                                        color: Colors.blueAccent,
                                    ),
                                    child: FlatButton(
                                        textColor: Colors.white,
                                        child: Text('Betygsätt och kommentera'),
                                        onPressed: _onCommentPressed,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ],
            )
                : Center(
                child: CircularProgressIndicator(),
            ));
    }


    void _onUploadimagePressed() async {
        var tempImage = await ImagePicker.pickImage(
            source: ImageSource.gallery);

        if (tempImage != null) {
            setState(() {
                _isInLoadingState = true;
            });
            await _uploadImage(tempImage).then((response) async {
                if (response == null || response.statusCode != 200) {
                    await _showErrorDialog();
                } else {
                    await _getImages();
                }

            });
            setState(() {
                _isInLoadingState = false;
            });
        }
    }

    void _onCommentPressed() async {
        bool result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CommentScreen(dogPark: widget.dogPark, dataHandler: widget.dataHandler),
            ),
        );
        if (result != null || result == true) {
            setState(() {
                _isInLoadingState = true;
            });
            await _getReviews();
            setState(() {
                _isInLoadingState = false;
            });
        } else {
            // User pressed back or the upload failed
        }
    }

    Widget _reviewList(BuildContext context) {
        if (widget.dogPark.getReviews().isEmpty == true) {
            return Center(child: Text('Inga recensioner än'));
        } else {
            return ListView.builder(
                padding: EdgeInsets.all(widget.dataHandler.settingsHandler.defaultPaddingBetweenRows),
                itemCount: widget.dogPark.getReviews().length,
                shrinkWrap: true,

                itemBuilder: (context, index) {
                    return Card(


                        shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(widget.dataHandler.settingsHandler.defaultBorderRadiusValue),
                            side: BorderSide(color: widget.dataHandler.settingsHandler.defaultBorderColor,width: widget.dataHandler.settingsHandler.defaultBorderWidth),


                        ),
                        margin: EdgeInsets.symmetric(
                            vertical: widget.dataHandler.settingsHandler.defaultPaddingBetweenRows),
                        child:
                        Container(
                            padding: EdgeInsets.all(widget.dataHandler.settingsHandler.defaultPaddingBetweenRows),
                            child:
                            Row(

                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                    widget.dataHandler.getStarRow(
                                        context,
                                        widget.dogPark.getReviews()[index].getRating()
                                            .toDouble(), widget.dataHandler.settingsHandler.defaultIconSize / 2,
                                        widget.dataHandler
                                            .settingsHandler
                                            .reviewStarIconColor),
                                    Text(widget.dogPark.getReviews()[index].getComment()),
                                ],

                            ),
                        ),

                    );
                },
            );
        }
    }

    void _onEnter() async {

        setState(() {
            _isInLoadingState = true;
        });
        await _getReviews();

        await _getImages();

        setState(() {
            _isInLoadingState = false;
        });
    }

    @override
    void initState() {
        super.initState();
        _onEnter();
    }

    Future<void> _getReviews() async {
        widget.dogPark.getReviews().clear();

        http.Response response =
        await widget.dataHandler.downloadReviews(widget.dogPark.getID());
        if (response.statusCode == 200) {
            try {
                String jsonData = utf8.decode(response.bodyBytes);
                List decodedJson = jsonDecode(jsonData);
                for (int i = 0; i < decodedJson.length; i++) {
                    Review tempReview = Review.fromJson(decodedJson[i]);
                    widget.dogPark.getReviews().add(tempReview);
                }
            } catch (error) {}
        } else {}
    }

    Future<void> _getImages() async {
        widget.dogPark.getImageAddresses().clear();

        http.Response response =
        await widget.dataHandler.downloadImageURLs(widget.dogPark.getID());
        if (response.statusCode == 200) {
            try {
                String result = utf8.decode(response.bodyBytes);
                if (result.length > 2) {
                    // Är en lista med [url, url1, url2] osv kan inte parsa den

                    // Nu är den url, url1, url2
                    result = result.substring(1, result.length - 1);

                    List<String> urls = result.split(', ');
                    if (urls.isEmpty == false) {
                        widget.dogPark.getImageAddresses().addAll(urls);
                    }
                }
            } catch (error) {}
        } else {}
    }

    Widget _imageList(BuildContext context) {
        return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.dogPark.getImageAddresses().length,
            itemBuilder: (BuildContext context, int index) =>
                Padding
                    (
                    padding: EdgeInsets.all(widget.dataHandler.settingsHandler.defaultPaddingBetweenRows),


                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(widget.dataHandler.settingsHandler.defaultBorderRadiusValue),
                            border: Border.all(color: widget.dataHandler.settingsHandler.defaultBorderColor,width:widget.dataHandler.settingsHandler.defaultBorderWidth ),
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
                                                child: Image.network(widget
                                                    .dogPark.getImageAddresses()[index]),
                                            ),
                                            actions: <Widget>[],
                                        );
                                    },
                                );
                            },
                            child: Container(
                                padding: EdgeInsets.all(12),
                                child: Image.network(
                                    widget.dogPark.getImageAddresses()[index]),
                            ),
                        )),
                ),
        );
    }

    Future<http.StreamedResponse> _uploadImage(var image) async {
        int _dogParkID = widget.dogPark.getID();

        final String url =
            'https://dog-park-micro.herokuapp.com/image/addImage?id=$_dogParkID';


        final postUri = Uri.parse(url);
        http.MultipartRequest request = http.MultipartRequest('POST', postUri);
        http.MultipartFile multipartFile =
        await http.MultipartFile.fromPath('file', image.path);

        request.files.add(multipartFile);

        http.StreamedResponse resp;
        await request.send().then((response) async {
            resp = response;


            response.stream.transform(utf8.decoder).listen((event) {});
        }).catchError((e) {

        });

        return resp;
    }

    Future<void> _showErrorDialog() async {
        return showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text('Hoppsan!'),
                    content: SingleChildScrollView(
                        child: ListBody(
                            children: <Widget>[
                                Text('Det gick inte att ladda upp bilden'),
                            ],
                        ),
                    ),
                    actions: <Widget>[
                        FlatButton(
                            child: Text('Ok'),
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