import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/http_exception.dart';
import 'product.dart';

import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];

  // var _showFavoritesOnly = false;

  final String? authToken;
  final String? userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://flutter-shop-0001-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(
        Uri.parse(url),
      );
      final List<Product> loadedProducts = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData.isEmpty) {
        return;
      }
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'] ?? '',
          description: prodData['description'] ?? '',
          price: prodData['price'] ?? 0.0,
          imageUrl: prodData['imageUrl'] ?? '',
          isFavorite: prodData['isFavorite'] ?? false,
          userId: prodData['creatorId'] ?? '',
        ));
      });

      _items = loadedProducts;
      //print(json.decode(response.body));
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://flutter-shop-0001-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'isFavorite': product.isFavorite,
            'creatorId': product.userId,
          },
        ),
      );
      //print(json.decode(response.body));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        userId: product.userId,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-shop-0001-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken';
      await http.patch(
        Uri.parse(url),
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-shop-0001-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(Uri.parse(url));

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();

      throw const HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
