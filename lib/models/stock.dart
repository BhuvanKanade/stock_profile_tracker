import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Stock {
  String id;
  String name;
  DateTime buyDate;
  double price;
  int quantity;

  Stock({
    required this.id,
    required this.name,
    required this.buyDate,
    required this.price,
    required this.quantity,
  });

  // Convert a Stock object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'buyDate': buyDate.toIso8601String(),
      'price': price,
      'quantity': quantity,
    };
  }

  // Create a Stock object from a Map
  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      id: map['id'],
      name: map['name'],
      buyDate: DateTime.parse(map['buyDate']),
      price: map['price'],
      quantity: map['quantity'],
    );
  }

  Future<void> saveToBack4App() async {
    final parseObject = ParseObject('stock') // Updated class name to lowercase
      ..set('name', name)
      ..set('buyDate', buyDate)
      ..set('price', price)
      ..set('quantity', quantity);

    final response = await parseObject.save();
    if (!response.success) {
      throw Exception('Failed to save stock: ${response.error?.message}');
    }
  }
}
