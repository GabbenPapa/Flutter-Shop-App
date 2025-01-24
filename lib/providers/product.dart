import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String userId;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.userId,
    this.isFavorite = false,
  });

  void toggleFavoriteStatus(String token) async {
    final oldStatus = isFavorite;

    isFavorite = !isFavorite;
    notifyListeners();

    final url =
        'https://flutter-shop-0001-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$token';
    try {
      await http.patch(
        Uri.parse(url),
        body: json.encode(
          {
            'isFavorite': isFavorite,
          },
        ),
      );
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
