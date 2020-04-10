import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import 'package:stocknotifier/services/stock.dart' as stock;
import 'package:stocknotifier/services/sharedPreferencesHandler.dart';
import 'package:stocknotifier/screens/stockFavoriteListScreen.dart';
import 'package:stocknotifier/components/listTiles.dart';

class StockList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StockListState();
  }
}

class StockListState extends State<StockList> {
  Future<Map<String, stock.Stock>> _futureStockList;
  Future<Set<String>> _futurePreferencesKeys;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    // Initialization required to send notifications.
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);

    // Loading stock prices and user preferences.
    _futureStockList = stock.fetchStock();
    _futurePreferencesKeys = getPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock prices'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              this._pushSavedStocks();
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              this.setState(() {
                _futureStockList = stock.fetchStock();
              });
            },
          )
        ],
      ),
      body: Center(child: this.createStockList()),
    );
  }

  FutureBuilder<Map<String, stock.Stock>> createStockList() {
    return FutureBuilder<Map<String, stock.Stock>>(
      future: _futureStockList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
//          handleNotification(snapshot.data);

          List<Widget> listTiles = new List<Widget>();

          for (var name in snapshot.data.keys) {
            final price = snapshot.data[name].price;

            listTiles.add(stockListTile(name, price, _onFavoriteTap));
            listTiles.add(Divider());
          }

          return ListView(children: listTiles);
        }
        else if (snapshot.hasError) {
          return Text('$snapshot.error');
        }
        return CircularProgressIndicator();
      },
    );
  }

  void _onFavoriteTap(bool alreadySaved, String name) {
    setState(() {
      if (alreadySaved) {
        preferencesRemove(name);
        _futurePreferencesKeys = getPreferences();
      } else {
        preferencesSave(name, 0.0);
        _futurePreferencesKeys = getPreferences();
      }
    });
  }

  void _pushSavedStocks() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => StockFavoriteList()));
  }

  void handleNotification(Map<String, stock.Stock> data) async {
    List<String> satisfyingStocks = List<String>();

    // Send notification if price is satisfying
    Set<String> prefs = await getPreferences();
    for (var key in prefs) {
      double value = await preferencesRead(key);
      if (data[key].price <= value) {
        satisfyingStocks.add(key);
      }
    }

    if (satisfyingStocks.isNotEmpty) {
      var message;
      if (satisfyingStocks.length == 1) {
        message = satisfyingStocks[0];
      } else {
        message = satisfyingStocks[0] + ', ' + satisfyingStocks[1];
        if (satisfyingStocks.length > 2) {
          message += ' and more!';
        }
      }
      showNotification(message);
    }
  }

  // When notification is selected.
  Future selectNotification(String payload) async {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: Text("Stock prices lowered."),
            ));
  }

  showNotification(String message) async {
    var android = new AndroidNotificationDetails(
        'channelId', 'channelName', 'channelDescription');
    var ios = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, ios);

    await flutterLocalNotificationsPlugin.show(
        0, 'Stock price lowered!', message, platform);
  }
}



