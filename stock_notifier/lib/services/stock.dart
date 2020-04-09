import 'dart:convert';

import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

class Stock {
  final String name;
  final double price;

  Stock({this.name, this.price});
}

Future<List<Stock>> fetchStock() async {
  var url = 'https://www.bankier.pl/gielda/notowania/akcje';
  var client = http.Client();
  http.Response response = await client.get(url);

  var document = parser.parse(response.body);
  List<dom.Element> items = document.querySelectorAll('tr > td');

  List<Stock> stocks = [];
  for (int i = 0; i < items.length; i++) {
    if (items[i].attributes.containsKey('class')) {
      if (items[i].attributes['class'] == 'colWalor textNowrap') {
        var name = items[i].text.trim();
        var price = items[i + 1].text.trim();
        stocks.add(Stock(name: name, price: formatToDouble(price)));
      }
    }
  }

  return stocks;
}

double formatToDouble(String number) {
  number = number.replaceFirst(RegExp(','), '.');
  number = number.replaceFirst(RegExp(' '), '');
  number = number.replaceFirst(RegExp('\xa0'), '');

  return double.parse(number);
}
