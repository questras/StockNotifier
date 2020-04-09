import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:validators/validators.dart';

import 'package:stocknotifier/services/stock.dart' as stock;

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

class StockList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StockListState();
  }
}

class StockListState extends State<StockList> {
  Future<List<stock.Stock>> _futureStockList;
  final Map<String, stock.Stock> _savedStocks = Map<String, stock.Stock>();
  final Map<String, double> _preferences = Map<String, double>();
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

    // Loading stock prices.
    _futureStockList = stock.fetchStock();
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

  FutureBuilder<List<stock.Stock>> createStockList() {
    return FutureBuilder<List<stock.Stock>>(
      future: _futureStockList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          handleNotification(snapshot.data);

          List<Widget> listTiles = new List<Widget>();

          for (var element in snapshot.data) {
            listTiles.add(listTileFromStock(element));
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

  ListTile listTileFromStock(stock.Stock element) {
    final bool alreadySaved = _savedStocks.containsKey(element.name);
    return ListTile(
      leading: Text(element.price.toString()),
      title: Text(element.name),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _savedStocks.remove(element.name);
            _preferences.remove(element.name);
          } else {
            _savedStocks[element.name] = element;
            _preferences[element.name] = 0.0;
          }
        });
      },
    );
  }

  ListTile notificationPriceListTile(String stockName) {
    return ListTile(
      leading: Text("Notify me at:"),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 100.0,
            child: TextFormField(
              keyboardType: TextInputType.number,
              initialValue: _preferences[stockName].toString(),
              onChanged: (String number) {
                if (isFloat(number)) {
                  _preferences[stockName] = double.parse(number);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pushSavedStocks() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      List<Widget> listTiles = new List<Widget>();

      for (var key in _savedStocks.keys) {
        var element = _savedStocks[key];

        // Add tile with stock name and price.
        listTiles.add(listTileFromStock(element));

        // Add tile to change notification price.
        listTiles.add(notificationPriceListTile(element.name));
        listTiles.add(Divider());
      }

      return Scaffold(
        appBar: AppBar(
          title: Text('Saved stock'),
        ),
        body: ListView(
          children: listTiles,
        ),
      );
    }));
  }

  void handleNotification(Iterable data) {
    List<String> satisfyingStocks = List<String>();
    // Send notification if price is satisfying
    // according to preferences.
    for (var element in data) {
      if (_preferences.containsKey(element.name)) {
        if (element.price <= _preferences[element.name]) {
          satisfyingStocks.add(element.name);
        }
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
