import 'package:flutter/material.dart';

import 'package:stocknotifier/screens/stockListScreen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: StockList(),
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
    );
  }
}

