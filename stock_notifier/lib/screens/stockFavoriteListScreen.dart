import 'package:flutter/material.dart';
import 'package:stocknotifier/components/icons.dart';
import 'package:validators/validators.dart';

import 'package:stocknotifier/services/sharedPreferencesHandler.dart';
import 'package:stocknotifier/services/stock.dart';

class StockFavoriteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StockFavoriteListState();
  }
}

class StockFavoriteListState extends State<StockFavoriteList> {
  Future<Set<String>> _futurePreferencesKeys;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Stocks'),
      ),
      body: Center(child: this.createFavoriteStockList()),
    );
  }

  FutureBuilder<Set<String>> createFavoriteStockList() {
    _futurePreferencesKeys = getPreferences();
    return FutureBuilder<Set<String>>(
      future: _futurePreferencesKeys,
      builder: (context, prefsSnapshot) {
        if (prefsSnapshot.hasData) {
          final _stockPrices = fetchStock();
          return FutureBuilder<Map<String, Stock>>(
            future: _stockPrices,
            builder: (context, stockSnapshot) {
              if (stockSnapshot.hasData) {
                List<Widget> listTiles = new List<Widget>();
                for (var key in prefsSnapshot.data) {
                  listTiles
                      .add(_stockListTile(key, stockSnapshot.data[key].price));
                  listTiles.add(_notificationPriceListTile(key));
                  listTiles.add(Divider());
                }

                return ListView(children: listTiles);
              }
              else if (stockSnapshot.hasError) {
                return Text('${stockSnapshot.error}');
              }
              return CircularProgressIndicator();
            },
          );
        }
        else if (prefsSnapshot.hasError) {
          return Text('$prefsSnapshot.error');
        }
        return CircularProgressIndicator();
      },
    );
  }

  ListTile _stockListTile(String name, double price) {
    return ListTile(
      leading: Text(price.toString()),
      title: Text(name),
      trailing: favoriteIcon(true),
      onTap: () {
        preferencesRemove(name);
        setState(() {});
      },
    );
  }

  FutureBuilder<double> _notificationPriceListTile(String name) {
    Future<double> value = preferencesRead(name);
    return FutureBuilder(
      future: value,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListTile(
            leading: Text('Notify me at:'),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 100.0,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    initialValue: snapshot.data.toString(),
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
        else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return CircularProgressIndicator();
      },
    );
  }

}
