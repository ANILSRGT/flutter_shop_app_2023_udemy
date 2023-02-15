import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/cart.dart';
import '../../models/order.dart';
import '../core/init/dotenv/dotenv_manager.dart';

class OrdersNotifier with ChangeNotifier {
  final String? authToken;
  final String? userId;
  OrdersNotifier(this.authToken, this.userId, this._orders);

  final List<Order> _orders;

  List<Order> get orders {
    return _orders;
  }

  String get _firebaseDBUrl => DotEnvManager.instance.firebaseDBUrl;

  Future<void> fetchAndSetOrders() async {
    try {
      final url = '$_firebaseDBUrl/orders/$userId.json?auth=$authToken';
      final res = await http.get(Uri.parse(url));
      final List<Order> loadedOrders = <Order>[];
      final extractedData = json.decode(res.body) as Map<String, dynamic>?;
      if (extractedData == null) return;
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(Order.fromMap(orderId, orderData));
      });
      _orders.clear();
      loadedOrders.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      _orders.addAll(loadedOrders);
      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> addOrder(List<Cart> cartProducts, double total) async {
    try {
      final url = '$_firebaseDBUrl/orders/$userId.json?auth=$authToken';
      final order = Order(
        id: DateTime.now().toString(),
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now(),
      );
      final res = await http.post(
        Uri.parse(url),
        body: order.toJson(),
      );
      _orders.insert(0, order.copyWith(id: json.decode(res.body)['name']));
      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
