import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';

/// Manages the user's favourite products and persists them to a local JSON file.
///
/// Only the essential fields (id, title, category, price, image) are stored
/// to minimise disk usage. The file is loaded once at startup via [loadFavorites].
class FavoritesProvider extends ChangeNotifier {
  static const String _favFileName = 'favorites.json';

  final List<Product> _favoriteItems = [];

  // ── Getters ───────────────────────────────────────────────────────────────

  List<Product> get favoriteItems => List.unmodifiable(_favoriteItems);

  bool isFavorite(Product product) =>
      _favoriteItems.any((item) => item.id == product.id);

  // ── Persistence helpers ────────────────────────────────────────────────────

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_favFileName');
  }

  /// Reads the favourites file on app startup and populates the in-memory list.
  /// Silently handles the case where the file does not yet exist (first launch).
  Future<void> loadFavorites() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return; // First launch — nothing to load.

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents) as List<dynamic>;

      _favoriteItems.clear();
      for (final item in jsonList) {
        final map = item as Map<String, dynamic>;
        _favoriteItems.add(
          Product(
            id: map['id'] as String,
            name: map['title'] as String,
            category: map['category'] as String? ?? '',
            price: (map['price'] as num).toDouble(),
            imageUrl: map['image'] as String,
          ),
        );
      }
      notifyListeners();
    } catch (_) {
      // Corrupted file or parse error — start fresh rather than crashing.
      _favoriteItems.clear();
    }
  }

  /// Persists the current favourites list to disk (best-effort).
  Future<void> _save() async {
    try {
      final file = await _getFile();
      final jsonList = _favoriteItems.map((p) => p.toFavJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (_) {
      // Never crash the app due to a write failure.
    }
  }

  // ── Public actions ─────────────────────────────────────────────────────────

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      _favoriteItems.removeWhere((item) => item.id == product.id);
    } else {
      _favoriteItems.add(product);
    }
    notifyListeners();
    _save(); // Fire-and-forget persistence.
  }
}