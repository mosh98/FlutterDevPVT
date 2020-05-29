import 'dart:io';

import 'package:dog_prototype/models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;

import 'Authentication.dart';
class StorageProvider{

  final User user;
  StorageProvider({@required this.user});

  uploadProfileImage(File image) async{
    final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://7305ce9c-63fe-4f83-9c82-642292022b9a');
    print(_storage.storageBucket);
    print(await _storage.ref().getBucket());
    final StorageUploadTask task = _storage.ref().child(user.userId).putFile(image);
    final StorageTaskSnapshot downloadUrl = await task.onComplete;
    final String url = await downloadUrl.ref.getDownloadURL();
    print(url);
  }
}