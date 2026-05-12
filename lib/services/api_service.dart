import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';

/// Handles all remote API calls and local caching for products.
///
/// Offline-first strategy:
/// 1. Try to fetch fresh data from the network.
/// 2. On success → persist the JSON response to [_cacheFileName].
/// 3. On failure → silently fall back to the last saved cache file.
/// 4. If neither works → rethrow the original error.
class ApiService {
  static const String _baseUrl = 'https://dummyjson.com';
  static const String _cacheFileName = 'products_cache.json';
  static const int _productLimit = 100; // DummyJSON default is 30; fetch more.

  /// `true` if the last [fetchProducts] call returned cached data (offline mode).
  bool isFromCache = false;

  // ── Cache helpers ─────────────────────────────────────────────────────────

  Future<File> _getCacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_cacheFileName');
  }

  Future<void> _writeCache(String jsonString) async {
    try {
      final file = await _getCacheFile();
      await file.writeAsString(jsonString);
    } catch (e) {
      // Writing cache is best-effort; never crash because of it.
      debugPrint('[ApiService] Cache write failed: $e');
    }
  }

  Future<List<Product>?> _readCache() async {
    try {
      final file = await _getCacheFile();
      if (!await file.exists()) return null;
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents) as List<dynamic>;
      return jsonList
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ApiService] Cache read failed: $e');
      return null;
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetches the full product list.
  ///
  /// Sets [isFromCache] to `true` when returning cached results.
  Future<List<Product>> fetchProducts() async {
    isFromCache = false;

    try {
      debugPrint('[ApiService] Fetching products from $_baseUrl/products?limit=$_productLimit ...');
      final response = await http
          .get(Uri.parse('$_baseUrl/products?limit=$_productLimit'))
          .timeout(const Duration(seconds: 15)); // 15 s — safer for slower mobile connections

      if (response.statusCode == 200) {
        // DummyJSON wraps the list: { "products": [...], "total": N, ... }
        final Map<String, dynamic> responseMap =
            json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> jsonList =
            responseMap['products'] as List<dynamic>;

        // Cache ONLY the products array so _readCache() can still decode it
        // as a flat list without any wrapper-object handling.
        await _writeCache(json.encode(jsonList));

        return jsonList
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException(
          'Server returned status ${response.statusCode}',
          uri: Uri.parse('$_baseUrl/products'),
        );
      }
    } catch (networkError) {
      // Log the real error so it is visible in the Debug Console.
      debugPrint('[ApiService] Network error: $networkError');

      // Try the local cache before giving up.
      final cached = await _readCache();
      if (cached != null && cached.isNotEmpty) {
        debugPrint('[ApiService] Serving ${cached.length} products from cache (offline mode).');
        isFromCache = true;
        return cached;
      }

      debugPrint('[ApiService] No cache available. Rethrowing error to UI.');
      rethrow; // No cache available — propagate to the UI.
    }
  }
}
