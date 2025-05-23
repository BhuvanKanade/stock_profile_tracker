import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'login_screen.dart';
import '../models/stock.dart';

// Main screen for managing stocks
class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({Key? key}) : super(key: key);

  @override
  _StockManagementScreenState createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  // List to hold all stocks
  final List<Stock> _stocks = [];

  @override
  void initState() {
    super.initState();
    _fetchStocks(); // Fetch stocks when screen initializes
  }

  // Fetch all stocks from Back4App
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
      // Show error if fetch fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching stocks: ${response.error?.message}')),
      );
    }
  }

  // Show dialog to add a new stock
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
                // Stock name input
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Stock Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a stock name';
                    }
                    if (!RegExp(r'^[a-zA-Z]+(\s[a-zA-Z]+)*$').hasMatch(value)) {
                      return 'Stock name can only contain letters';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value!,
                ),
                // Buy date input (date picker)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Buy Date'),
                  readOnly: true,
                  controller: TextEditingController(text: buyDate.toLocal().toString().split(' ')[0]),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: buyDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        buyDate = selectedDate;
                      });
                    }
                  },
                ),
                // Price input
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
                // Quantity input
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
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            // Add button
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

                  // Save new stock to Back4App
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

  // Show dialog to edit an existing stock
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
                // Stock name input
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Stock Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a stock name';
                    }
                    if (!RegExp(r'^[a-zA-Z]+(\s[a-zA-Z]+)*$').hasMatch(value)) {
                      return 'Stock name can only contain letters';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value!,
                ),
                // Buy date input (date picker)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Buy Date'),
                  readOnly: true,
                  controller: TextEditingController(text: buyDate.toLocal().toString().split(' ')[0]),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: buyDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        buyDate = selectedDate;
                      });
                    }
                  },
                ),
                // Price input
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
                // Quantity input
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
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            // Update button
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

                  // Save updated stock to Back4App
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

  // Show dialog to confirm and delete a stock
  void _deleteStock(Stock stock) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Stock'),
          content: const Text('Are you sure you want to delete this stock?'),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            // Delete button
            ElevatedButton(
              onPressed: () {
                final parseObject = ParseObject('stock')..objectId = stock.id;
                parseObject.delete().then((response) {
                  if (response.success) {
                    setState(() {
                      _stocks.remove(stock);
                    });
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
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Sign out the current user
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

  // Query stocks by name using Back4App
  void _queryStocksByName(String name) async {
    try {
      final results = await Stock.queryByName(name);
      setState(() {
        _stocks.clear();
        _stocks.addAll(results);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error querying stocks: $error')),
      );
    }
  }

  // Show dialog to enter stock name for querying
  void _showQueryDialog() {
    final _formKey = GlobalKey<FormState>();
    String queryName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Query Stocks by Name'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Stock Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a stock name';
                }
                return null;
              },
              onSaved: (value) => queryName = value!,
            ),
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            // Query button
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.pop(context);
                  _queryStocksByName(queryName);
                }
              },
              child: const Text('Query'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Main UI for stock management
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
        actions: [
          // Search, refresh, and logout buttons
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showQueryDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStocks,
          ),
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
          // Display each stock as a row in the table
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
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteStock(stock),
                    ),
                  ],
                ),
              ),
              DataCell(Text(stock.buyDate.toLocal().toString().split(' ')[0])),
              DataCell(Text(stock.price.toString())),
              DataCell(Text(stock.quantity.toString())),
            ]);
          }).toList(),
        ),
      ),
      // Floating button to add a new stock
      floatingActionButton: FloatingActionButton(
        onPressed: _addStock,
        child: const Icon(Icons.add),
      ),
    );
  }
}
