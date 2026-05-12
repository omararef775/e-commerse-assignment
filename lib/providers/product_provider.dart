import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

/// Manages the full product list fetched from the remote API.
///
/// States:
/// - [isLoading] — network request in flight
/// - [error]     — request failed AND no cache available
/// - [products]  — data ready (may be from cache if [isOffline] is true)
/// - [isOffline] — data came from local cache (network was unavailable)
class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _isOffline = false;

  // ── Getters ───────────────────────────────────────────────────────────────

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _isOffline;

  /// Returns the distinct category names present in the loaded products.
  List<String> get categories =>
      _products.map((p) => p.category).toSet().toList()..sort();

  /// Returns products belonging to [category] (case-insensitive).
  List<Product> productsByCategory(String category) => _products
      .where((p) => p.category.toLowerCase() == category.toLowerCase())
      .toList();

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Loads products from the API (or cache on failure).
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    _isOffline = false;
    notifyListeners();

    try {
      _products = await _apiService.fetchProducts();
      _isOffline = _apiService.isFromCache;
    } catch (e) {
      _error = _friendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _friendlyMessage(Object e) {
    final raw = e.toString().toLowerCase();
    if (raw.contains('socket') ||
        raw.contains('connection') ||
        raw.contains('network') ||
        raw.contains('host')) {
      return 'No internet connection.\nPlease check your network and try again.';
    }
    if (raw.contains('timeout')) {
      return 'The request timed out.\nPlease try again.';
    }
    return 'Something went wrong.\nPlease try again later.';
  }
}
