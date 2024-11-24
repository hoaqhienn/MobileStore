// store_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class StoreService {
  static const String baseUrl =
      'https://8080-hoaqhienn-mobilestorebe-2hziaz09ts5.ws-us116.gitpod.io/api/v2';
  static const String loginUrl = '$baseUrl/users/login';
  static const String registerUrl = '$baseUrl/users/register';
  static const String userDataUrl = '$baseUrl/users/auth/me';
  static const String productsUrl = '$baseUrl/products';
  static const String searchProductsUrl = '$baseUrl/products/search';

  // Fetch user data
  Future<http.Response> fetchUserData(String token) async {
    final response = await http.get(
      Uri.parse(userDataUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  // Login user
  Future<http.Response> login(String username, String password) async {
    return await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
  }

  // Register user
  Future<http.Response> register(
      String name, String username, String password) async {
    return await http.post(
      Uri.parse(registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'username': username,
        'password': password,
      }),
    );
  }

  // Fetch products data
  Future<http.Response> fetchProducts(
      {required num currentPage, required num itemsPerPage}) async {
    return await http
        .get(Uri.parse('$productsUrl?page=$currentPage&limit=$itemsPerPage'));
  }

  // Search products
  Future<http.Response> searchProducts(
      {String? name, num? minPrice, num? maxPrice}) async {
    final Map<String, String> formData = {};

    if (name != null) {
      formData['name'] = name;
    }
    if (minPrice != null) {
      // Convert to integer if it's a whole number, otherwise use decimal
      formData['minPrice'] = minPrice == minPrice.toInt()
          ? minPrice.toInt().toString()
          : minPrice.toString();
    }
    if (maxPrice != null) {
      formData['maxPrice'] = maxPrice == maxPrice.toInt()
          ? maxPrice.toInt().toString()
          : maxPrice.toString();
    }

    final Uri uri = Uri.parse(searchProductsUrl).replace(
      queryParameters: formData,
    );

    // Note: For GET requests, typically you don't need to set Content-Type as x-www-form-urlencoded
    return await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );
  }
}
