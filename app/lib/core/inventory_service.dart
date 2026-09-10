import 'dart:convert';

import 'api_client.dart';

class ProductDto {
  const ProductDto(
      {required this.id,
      required this.name,
      required this.salePrice,
      required this.stock,
      required this.gstRate});

  final String id;
  final String name;
  final num salePrice;
  final num stock;
  final num gstRate;

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as String,
      name: json['name'] as String,
      salePrice: json['salePrice'] as num? ?? 0,
      stock: json['stock'] as num? ?? 0,
      gstRate: json['gstRate'] as num? ?? 0,
    );
  }
}

class InventoryService {
  const InventoryService(this._client);

  final ApiClient _client;

  Future<List<ProductDto>> fetchProducts() async {
    final response = await _client
        .get('/api/v1/products', headers: {'x-business-id': 'biz_1'});
    if (response.statusCode >= 400) {
      throw Exception(
          jsonDecode(response.body)['error'] ?? 'Failed to load products');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .map((item) => ProductDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
