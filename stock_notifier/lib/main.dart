import 'package:flutter/material.dart';

import 'package:stocknotifier/screens/stockListScreen.dart';

// todo: favorite do not hide
// todo: notifications are sent only when there wasn't yet info about this status
// todo: favorite icon on favorite stocks page

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: StockList(),
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
    );
  }
}

