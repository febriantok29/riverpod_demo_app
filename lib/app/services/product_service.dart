import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_demo_app/app/models/product.dart';

/// Service untuk mengelola Product API dari dummyjson.com
/// Menggunakan http package untuk API calls
class ProductService {
  static const String _baseUrl = 'https://dummyjson.com';

  /// Get products with pagination
  /// [limit] jumlah products per page (default: 10)
  /// [skip] jumlah products yang di-skip untuk pagination
  Future<ProductListResponse> getProducts({
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ProductListResponse.fromJson(json);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  /// Get single product by ID
  Future<Product> getProduct(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/products/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Product.fromJson(json);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }

  /// Search products by query
  Future<ProductListResponse> searchProducts({
    required String query,
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/products/search?q=$query&limit=$limit&skip=$skip',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ProductListResponse.fromJson(json);
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  /// Create new product
  /// NOTE: API ini hanya simulate, tidak benar-benar menyimpan ke database
  Future<Product> createProduct({
    required String title,
    required String description,
    required String category,
    required double price,
    required int stock,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/products/add');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': description,
          'category': category,
          'price': price,
          'stock': stock,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Product.fromJson(json);
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  /// Update product by ID
  /// NOTE: API ini hanya simulate, tidak benar-benar update database
  Future<Product> updateProduct({
    required int id,
    required String title,
    required String description,
    required String category,
    required double price,
    required int stock,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/products/$id');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': description,
          'category': category,
          'price': price,
          'stock': stock,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Product.fromJson(json);
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Delete product by ID
  /// NOTE: API ini hanya simulate, tidak benar-benar delete dari database
  Future<void> deleteProduct(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/products/$id');
      final response = await http.delete(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
}
