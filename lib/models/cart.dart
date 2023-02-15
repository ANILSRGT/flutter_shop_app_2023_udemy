import 'dart:convert';

class Cart {
  final String productId;
  final String title;
  final int quantity;
  final double price;

  Cart({
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
  });

  Cart copyWith({
    String? productId,
    String? title,
    int? quantity,
    double? price,
  }) {
    return Cart(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'productId': productId});
    result.addAll({'title': title});
    result.addAll({'quantity': quantity});
    result.addAll({'price': price});

    return result;
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      productId: map['productId'] ?? '',
      title: map['title'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Cart.fromJson(String productId, String source) => Cart.fromMap(json.decode(source));
}
