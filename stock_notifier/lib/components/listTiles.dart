import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

import 'package:stocknotifier/services/sharedPreferencesHandler.dart';
import 'package:stocknotifier/components/icons.dart';

FutureBuilder<double> notificationPriceListTile(String name) {
  Future<double> value = preferencesRead(name);
  return FutureBuilder(
    future: value,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return _notificationPriceListTile(name, snapshot.data);
      }
      else if (snapshot.hasError) {
        return Text('$snapshot.error');
      }
      return CircularProgressIndicator();
    },
  );
}

ListTile _notificationPriceListTile(String name, double initialValue) {
  return ListTile(
    leading: Text("Notify me at:"),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 100.0,
          child: TextFormField(
            keyboardType: TextInputType.number,
            initialValue: initialValue.toString(),
            onChanged: (String number) {
              if (isFloat(number)) {
                preferencesSave(name, double.parse(number));
              }
            },
          ),
        ),
      ],
    ),
  );
}

FutureBuilder<Set<String>> stockListTile(
    String name, double price, Function onTileTap) {
  Future<Set<String>> _futurePreferencesKeys = getPreferences();
  return FutureBuilder<Set<String>>(
    future: _futurePreferencesKeys,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final bool alreadySaved = snapshot.data.contains(name);

        return _stockListTile(alreadySaved, name, price, onTileTap);
      }
      else if (snapshot.hasError) {
        return Text('$snapshot.error');
      }
      return CircularProgressIndicator();
    },
  );
}

ListTile _stockListTile(
    bool alreadySaved, String name, double price, Function onTileTap) {
  return ListTile(
    leading: Text(price.toString()),
    title: Text(name),
    trailing: favoriteIcon(alreadySaved),
    onTap: () {
      onTileTap(alreadySaved, name);
    },
  );
}
