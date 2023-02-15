import 'dart:convert';

import 'cart.dart';

class Order {
  final String id;
  final double amount;
  final List<Cart> products;
  final DateTime dateTime;

  Order({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });

  Order copyWith({
    String? id,
    double? amount,
    List<Cart>? products,
    DateTime? dateTime,
  }) {
    return Order(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      products: products ?? this.products,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'amount': amount});
    result.addAll({'products': products.map((x) => x.toMap()).toList()});
    result.addAll({'dateTime': dateTime.millisecondsSinceEpoch});

    return result;
  }

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    return Order(
      id: id,
      amount: map['amount']?.toDouble() ?? 0.0,
      products: List<Cart>.from(map['products']?.map((x) => Cart.fromMap(x))),
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String id, String source) => Order.fromMap(id, json.decode(source));
}
