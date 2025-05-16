// Author: Bhuvan Kanade
// Description: Stock model for Stock Profile Tracker app.
// This file defines the Stock class and its methods for CRUD operations with Back4App.

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Stock {
  String id;
  String name;
  DateTime buyDate;
  double price;
  int quantity;

  // Constructor for Stock object
  Stock({
    required this.id,
    required this.name,
    required this.buyDate,
    required this.price,
    required this.quantity,
  });

  // Convert a Stock object to a Map (for local use)
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

  // Save this stock to Back4App
  Future<void> saveToBack4App() async {
    final parseObject = ParseObject('stock')
      ..set('name', name)
      ..set('buyDate', buyDate)
      ..set('price', price)
      ..set('quantity', quantity);

    final response = await parseObject.save();
    if (!response.success) {
      throw Exception('Failed to save stock: ${response.error?.message}');
    }
  }

  // Query stocks by name from Back4App
  static Future<List<Stock>> queryByName(String name) async {
    final query = QueryBuilder(ParseObject('stock'))
      ..whereContains('name', name);

    final response = await query.query();

    if (response.success && response.results != null) {
      return response.results!.map((result) {
        return Stock(
          id: result.objectId!,
          name: result.get<String>('name') ?? '',
          buyDate: result.get<DateTime>('buyDate') ?? DateTime.now(),
          price: (result.get<num>('price') ?? 0.0).toDouble(),
          quantity: result.get<int>('quantity') ?? 0,
        );
      }).toList();
    } else {
      throw Exception('Failed to query stocks: ${response.error?.message}');
    }
  }
}
