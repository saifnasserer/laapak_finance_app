class Transaction {
  final String id;
  final DateTime date;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final String? description;
  final String status;
  // Income specific
  final List<InvoiceItem>? items;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.category,
    this.description,
    required this.status,
    this.items,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(),
      date: DateTime.parse(json['date']),
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      category: json['category'],
      description: json['description'],
      status: json['status'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => InvoiceItem.fromJson(i)).toList()
          : null,
    );
  }
}

class InvoiceItem {
  final int id;
  final String name;
  final double? costPrice;
  final double sellPrice;

  InvoiceItem({
    required this.id,
    required this.name,
    this.costPrice,
    required this.sellPrice,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      name: json['name'],
      costPrice: json['cost_price'] != null
          ? (json['cost_price'] as num).toDouble()
          : null,
      sellPrice: (json['sell_price'] as num).toDouble(),
    );
  }
}
