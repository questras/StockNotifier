import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

class Stock {
  final String name;
  final double price;

  Stock({this.name, this.price});
}

Future<Map<String, Stock>> fetchStock() async {
  final url = 'https://www.bankier.pl/gielda/notowania/akcje';
  final client = http.Client();
  http.Response response = await client.get(url);

  var document = parser.parse(response.body);
  List<dom.Element> items = document.querySelectorAll('tr > td');

  Map<String, Stock> stocks = Map<String, Stock>();
  for (int i = 0; i < items.length; i++) {
    if (items[i].attributes.containsKey('class')) {
      if (items[i].attributes['class'] == 'colWalor textNowrap') {
        final name = items[i].text.trim();
        final price = items[i + 1].text.trim();
        stocks[name] = Stock(name: name, price: _formatToDouble(price));
      }
    }
  }

  return stocks;
}

double _formatToDouble(String number) {
  number = number.replaceFirst(RegExp(','), '.');
  number = number.replaceFirst(RegExp(' '), '');
  number = number.replaceFirst(RegExp('\xa0'), '');

  return double.parse(number);
}
