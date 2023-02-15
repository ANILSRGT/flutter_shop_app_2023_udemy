import 'dart:convert';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String createdUserId;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.createdUserId,
    this.isFavorite = false,
  });

  static Product emptyValue() {
    return Product(
      id: '',
      title: '',
      description: '',
      price: 0,
      imageUrl: '',
      createdUserId: '',
    );
  }

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? createdUserId,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      createdUserId: createdUserId ?? this.createdUserId,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'title': title});
    result.addAll({'description': description});
    result.addAll({'price': price});
    result.addAll({'imageUrl': imageUrl});
    result.addAll({'createdUserId': createdUserId});

    return result;
  }

  String toJson() => json.encode(toMap());

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      title: map['title'],
      description: map['description'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      createdUserId: map['createdUserId'],
    );
  }

  factory Product.fromJson(String id, String source) => Product.fromMap(id, json.decode(source));
}
