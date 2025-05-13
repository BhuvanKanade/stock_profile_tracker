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
    final _formKey = GlobalKey<FormState>();
    String name = '';
    DateTime buyDate = DateTime.now();
    double price = 0.0;
    int quantity = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Stock'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Stock Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a stock name';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                  onSaved: (value) => price = double.parse(value!),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                  onSaved: (value) => quantity = int.parse(value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newStock = Stock(
                    id: DateTime.now().toString(),
                    name: name,
                    buyDate: buyDate,
                    price: price,
                    quantity: quantity,
                  );

                  newStock.saveToBack4App().then((_) {
                    setState(() {
                      _stocks.add(newStock);
                    });
                    Navigator.pop(context);
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $error')),
                    );
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
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
