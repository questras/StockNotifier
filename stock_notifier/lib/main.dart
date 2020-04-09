import 'package:flutter/material.dart';
import 'package:stocknotifier/services/stock.dart' as stock;

//void main(List<String> arguments) async {
//  await stock.fetchStock();
//}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StockList();
  }
}

class StockListState extends State<StockList> {
  Future<List<stock.Stock>> _futureStockList;
  final Map<String, stock.Stock> _savedStocks = Map<String, stock.Stock>();

  @override
  void initState() {
    super.initState();
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
            onPressed: () {this._pushSaved();},
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
      body: Center(
        child: this.createList(),
      ),
    );
  }

  FutureBuilder<List<stock.Stock>> createList() {
    return FutureBuilder<List<stock.Stock>>(
      future: _futureStockList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Widget> listTiles = new List<Widget>();

          for (var element in snapshot.data) {
            listTiles.add(createListTile(element, favorite: true));
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

  ListTile createListTile(stock.Stock element, {favorite=false}) {
    final bool alreadySaved = _savedStocks.containsKey(element.name);
    return ListTile(
      leading: Text(element.price),
      title: Text(element.name),
      trailing: favorite ?  Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ) : null,
      onTap: () {
        setState(() {
          if (favorite) {
            if (alreadySaved) {
              _savedStocks.remove(element.name);
            } else {
              _savedStocks[element.name] = element;
            }
          }
        });
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          List<Widget> listTiles = new List<Widget>();

          for (var element in _savedStocks.keys) {
            listTiles.add(createListTile(_savedStocks[element]));
            listTiles.add(
              ListTile(
                leading: Text("Notify me at:"),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 100.0,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        initialValue: null,
                      ),
                    )
                  ],
                ),
              )
            );
            listTiles.add(Divider());
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved stock'),
            ),
            body: ListView(children: listTiles,),
          );
        }
      )
    );
  }
}

class StockList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StockListState();
  }
}
