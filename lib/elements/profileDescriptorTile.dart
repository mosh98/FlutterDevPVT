import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileDescriptorTile extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Race'),
      subtitle: Text('Dachshund'),
    );
  }
}