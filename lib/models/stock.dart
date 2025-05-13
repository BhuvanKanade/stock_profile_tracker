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
}
