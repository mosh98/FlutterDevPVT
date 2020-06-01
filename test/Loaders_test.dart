import 'package:dog_prototype/loaders/CustomLoader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

//Testing custom loader
void main(){
  testWidgets('Test of custom widget', (WidgetTester tester) async{

    MaterialApp page = MaterialApp(home: Scaffold(body: CustomLoader(textWidget:Text("Test"))));

    await tester.pumpWidget(page);
    expect(find.text('Test'),findsOneWidget);
  });
}