import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'login_screen.dart';
import '../models/stock.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({Key? key}) : super(key: key);

  @override
  _StockManagementScreenState createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  final List<Stock> _stocks = [];

  @override
  void initState() {
    super.initState();
    _fetchStocks();
  }

  void _fetchStocks() async {
    final query = QueryBuilder(ParseObject('stock'));
    final response = await query.query();

    if (response.success && response.results != null) {
      setState(() {
        _stocks.clear();
        for (var result in response.results!) {
          final stock = Stock(
            id: result.objectId!,
            name: result.get<String>('name') ?? '',
            buyDate: result.get<DateTime>('buyDate') ?? DateTime.now(),
            price: (result.get<num>('price') ?? 0.0).toDouble(),
            quantity: result.get<int>('quantity') ?? 0,
          );
          _stocks.add(stock);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching stocks: ${response.error?.message}')),
      );
    }
  }

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

  void _editStock(Stock stock) {
    final _formKey = GlobalKey<FormState>();
    String name = stock.name;
    DateTime buyDate = stock.buyDate;
    double price = stock.price;
    int quantity = stock.quantity;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Stock'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
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
                  initialValue: price.toString(),
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
                  initialValue: quantity.toString(),
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
                  stock
                    ..name = name
                    ..buyDate = buyDate
                    ..price = price
                    ..quantity = quantity;

                  final parseObject = ParseObject('stock')
                    ..objectId = stock.id
                    ..set('name', name)
                    ..set('buyDate', buyDate)
                    ..set('price', price)
                    ..set('quantity', quantity);

                  parseObject.save().then((response) {
                    if (response.success) {
                      setState(() {});
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${response.error?.message}')),
                      );
                    }
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $error')),
                    );
                  });
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _signOut() async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser != null) {
      final response = await currentUser.logout();
      if (response.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.error?.message}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is currently logged in.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Buy Date')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Quantity')),
          ],
          rows: _stocks.map((stock) {
            return DataRow(cells: [
              DataCell(
                Row(
                  children: [
                    Text(stock.name),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editStock(stock),
                    ),
                  ],
                ),
              ),
              DataCell(Text(stock.buyDate.toString())),
              DataCell(Text(stock.price.toString())),
              DataCell(Text(stock.quantity.toString())),
            ]);
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStock,
        child: const Icon(Icons.add),
      ),
    );
  }
}
