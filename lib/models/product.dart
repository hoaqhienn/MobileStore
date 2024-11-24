import 'package:flutter/foundation.dart';

class Product {
  final int id;
  final String name;
  final String image;
  final double price;
  final String description;
  final String manufacturer;
  final String category;
  final String condition;
  final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    required this.manufacturer,
    required this.category,
    required this.condition,
    required this.quantity,
  });

  // From JSON constructor with robust type checking and error handling
  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      return Product(
        id: _parseId(json['id']),
        name: json['name']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
        price: _parsePrice(json['price']),
        description: json['description']?.toString() ?? '',
        manufacturer: json['manufacturer']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        condition: json['condition']?.toString() ?? '',
        quantity: _parseQuantity(json['quantity']),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing product: $json');
      }
      rethrow;
    }
  }

  // Helper method to parse ID
  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper method to parse price
  static double _parsePrice(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Helper method to parse quantity
  static int _parseQuantity(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // toJson method for converting Product to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'description': description,
      'manufacturer': manufacturer,
      'category': category,
      'condition': condition,
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: $price, quantity: $quantity}';
  }
}