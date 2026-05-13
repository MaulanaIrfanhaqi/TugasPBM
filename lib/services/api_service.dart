import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // ================= LOGIN =================
  Future<bool> login(String nim, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'username': nim, 'password': password}),
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String token = data['data']['token'];

        await storage.write(key: 'token', value: token);

        print('TOKEN : $token');

        return true;
      }

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // ================= GET TOKEN =================
  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  // ================= GET PRODUCTS =================
  Future<List<Product>> getProducts() async {
    try {
      String? token = await getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List products = data['data']['products'];

        print(products);

        return products.map((e) {
          print(e);

          return Product.fromJson(e);
        }).toList();
      }

      return [];
    } catch (e) {
      print('ERROR GET PRODUCTS');
      print(e);

      return [];
    }
  }

  // ================= ADD PRODUCT =================
  Future<bool> addProduct(Product product) async {
    try {
      String? token = await getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/api/products'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': product.name,
          'price': product.price,
          'description': product.description,
        }),
      );

      print(response.statusCode);
      print(response.body);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // ================= SUBMIT TUGAS =================
  Future<bool> submitTugas({
    required String name,
    required int price,
    required String description,
    required String githubUrl,
  }) async {
    try {
      String? token = await getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/api/products/submit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'price': price,
          'description': description,
          'github_url': githubUrl,
        }),
      );

      print(response.statusCode);
      print(response.body);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await storage.delete(key: 'token');
  }
}
