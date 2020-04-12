import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:stocknotifier/services/stock.dart' as stock;
import 'package:stocknotifier/services/sharedPreferencesHandler.dart';
import 'package:stocknotifier/screens/stockFavoriteListScreen.dart';
import 'package:stocknotifier/screens/settingsScreen.dart';
import 'package:stocknotifier/components/listTiles.dart';

class StockList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StockListState();
  }
}

class _StockListState extends State<StockList> {
  Future<Map<String, stock.Stock>> _futureStockList;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  Timer _notificationTimer;
  int _currentNotificationThreshold;

  @override
  void initState() {
    super.initState();

    // Initialization required to send notifications.
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(android, ios);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _selectNotification);

    _currentNotificationThreshold = 0;
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setNotificationTimer();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            this._pushSettings();
          },
        ),
        title: Text('Stock prices'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              this._pushSavedStocks();
            },
          ),
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  this.setState(() {});
                  _showSnackBar(context);
                },
              );
            },
          )
        ],
      ),
      body: Center(child: this._createStockList()),
    );
  }

  void _showSnackBar(BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Stock refreshed.'),
    ));
  }

  FutureBuilder<Map<String, stock.Stock>> _createStockList() {
    _futureStockList = stock.fetchStock();
    return FutureBuilder<Map<String, stock.Stock>>(
      future: _futureStockList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Widget> listTiles = new List<Widget>();

          for (var name in snapshot.data.keys) {
            final price = snapshot.data[name].price;

            listTiles.add(stockListTile(name, price, _onFavoriteTap));
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

  void _onFavoriteTap(bool alreadySaved, String name) {
    setState(() {
      if (alreadySaved) {
        preferencesRemove(name);
      } else {
        preferencesSave(name, 0.0);
      }
    });
  }

  void _pushSavedStocks() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => StockFavoriteList()));
  }

  void _pushSettings() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsScreen()));
  }

  void _handleNotification() async {
    List<String> satisfyingStocks = List<String>();
    Map<String, stock.Stock> stockPrices = await stock.fetchStock();

    // Send notification if price is satisfying
    Set<String> prefs = await getPreferences();
    for (var key in prefs) {
      double value = await preferencesRead(key);
      if (stockPrices[key].price <= value) {
        satisfyingStocks.add(key);
      }
    }

    if (satisfyingStocks.isNotEmpty) {
      var message = stockPrices[satisfyingStocks[0]].toString();

      if (satisfyingStocks.length > 1) {
        message += ', ' + stockPrices[satisfyingStocks[1]].toString();
      }

      if (satisfyingStocks.length > 2) {
        message += ' and more';
      }

      message += '!';
      showNotification(message);
    }
  }

  /// Set notification timer to time specified in shared preference
  /// or update it if notification threshold time was changed.
  void setNotificationTimer() async {
    final notificationThreshold = await notificationThresholdRead();

    if (notificationThreshold != _currentNotificationThreshold) {
      this._notificationTimer?.cancel();
      this._notificationTimer = Timer.periodic(
          Duration(minutes: notificationThreshold),
          (Timer t) => _handleNotification());

      _currentNotificationThreshold = notificationThreshold;
    }
  }

  // When notification is selected.
  Future _selectNotification(String payload) async {
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

    await _flutterLocalNotificationsPlugin.show(
        0, 'Stock price lowered!', message, platform);
  }
}
