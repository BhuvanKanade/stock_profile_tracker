import 'package:flutter/material.dart';
import '../models/stock.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({Key? key}) : super(key: key);

  @override
  _StockManagementScreenState createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  final List<Stock> _stocks = [];

  void _addStock() {
    // Placeholder for adding stock logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
      ),
      body: ListView.builder(
        itemCount: _stocks.length,
        itemBuilder: (context, index) {
          final stock = _stocks[index];
          return ListTile(
            title: Text(stock.name),
            subtitle: Text('Quantity: ${stock.quantity}, Price: ${stock.price}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStock,
        child: const Icon(Icons.add),
      ),
    );
  }
}
