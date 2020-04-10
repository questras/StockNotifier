import 'package:flutter/material.dart';

import 'package:stocknotifier/services/sharedPreferencesHandler.dart';
import 'package:stocknotifier/components/listTiles.dart';

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

    _futurePreferencesKeys = getPreferences();
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
    return FutureBuilder<Set<String>>(
      future: _futurePreferencesKeys,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Widget> listTiles = new List<Widget>();

          for (var key in snapshot.data) {
            listTiles.add(stockListTile(key, 0.0, _onFavoriteTap));
            listTiles.add(notificationPriceListTile(key));
            listTiles.add(Divider());
          }

          return ListView(children: listTiles);
        } else if (snapshot.hasError) {
          return Text('$snapshot.error');
        }
        return CircularProgressIndicator();
      },
    );
  }

  void _onFavoriteTap(bool alreadySaved, String name) async {
    await preferencesRemove(name);
     _futurePreferencesKeys = getPreferences();
    setState(() {});
  }

}
