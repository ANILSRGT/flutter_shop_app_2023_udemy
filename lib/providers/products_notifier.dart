import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/http_exception.dart';
import '../../models/product.dart';
import '../core/init/dotenv/dotenv_manager.dart';

class ProductsNotifier with ChangeNotifier {
  final String? authToken;
  final String? userId;
  ProductsNotifier(this.authToken, this.userId, this._items);

  final List<Product> _items;

  List<Product> get items {
    return _items;
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  String get _firebaseDBUrl => DotEnvManager.instance.firebaseDBUrl;

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts(bool filterByUser) async {
    try {
      final filterString = filterByUser ? 'orderBy="createdUserId"&equalTo="$userId"' : '';
      final url = '$_firebaseDBUrl/products.json?auth=$authToken&$filterString';
      final res = await http.get(Uri.parse(url));
      final extractedData = json.decode(res.body) as Map<String, dynamic>?;
      final List<Product> loadedProducts = <Product>[];
      final favUrl = '$_firebaseDBUrl/userFavorites/$userId.json?auth=$authToken';
      final favoriteRes = await http.get(Uri.parse(favUrl));
      final favoriteData = json.decode(favoriteRes.body);
      if (extractedData == null) return;
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product.fromMap(prodId, prodData).copyWith(
          isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      _items.clear();
      _items.addAll(loadedProducts);
      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> addProduct(Product newProduct) async {
    try {
      final url = '$_firebaseDBUrl/products.json?auth=$authToken';
      newProduct = newProduct.copyWith(createdUserId: userId);
      final res = await http.post(Uri.parse(url), body: newProduct.toJson());
      await HttpException.checkForError(res.statusCode, 'Could not add product.');
      final resProdId = json.decode(res.body)['name'];
      final prod = newProduct.copyWith(id: resProdId);
      _items.add(prod);
      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product editedProduct) async {
    try {
      final prodIndex = _items.indexWhere((element) => element.id == id);
      if (prodIndex >= 0) {
        final prod = _items[prodIndex];
        final url = '$_firebaseDBUrl/products/${prod.id}.json?auth=$authToken';
        final res = await http.patch(Uri.parse(url), body: editedProduct.toJson());
        await HttpException.checkForError(res.statusCode, 'Could not update product.');
        _items[prodIndex] = editedProduct;
        notifyListeners();
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> toggleFavoriteStatus(String prodId) async {
    if (userId == null) return Future.error('User not found!');
    try {
      final url = '$_firebaseDBUrl/userFavorites/$userId/$prodId.json?auth=$authToken';
      final prodIndex = _items.indexWhere((element) => element.id == prodId);
      final prodToToggle = _items[prodIndex];
      final isCurrentlyFavorite = prodToToggle.isFavorite;
      final newFavoriteStatus = !isCurrentlyFavorite;
      final res = await http.put(Uri.parse(url), body: json.encode(newFavoriteStatus));
      await HttpException.checkForError(res.statusCode, 'Could not update product.');
      _items[prodIndex].isFavorite = newFavoriteStatus;
      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = '$_firebaseDBUrl/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final res = await http.delete(Uri.parse(url));
    try {
      await HttpException.checkForError(res.statusCode, 'Could not delete product.', () {
        _items.insert(existingProductIndex, existingProduct!);
        notifyListeners();
      });
    } catch (e) {
      print(e);
      rethrow;
    }
    existingProduct = null;
  }
}
