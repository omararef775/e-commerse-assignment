import 'package:cloud_firestore/cloud_firestore.dart';
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final String discount;
  final String imageUrl;
  final double rating;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.oldPrice,
    this.discount = '',
    required this.imageUrl,
    this.rating = 0.0,
    this.description = '',
  });

  /// Creates a [Product] from a DummyJSON API response object.
  ///
  /// DummyJSON field mapping:
  ///   title             → name
  ///   category          → category  (slug e.g. "beauty", "smartphones")
  ///   price             → price
  ///   discountPercentage→ discount  (e.g. 10.48 → "-10%")
  ///   thumbnail         → imageUrl  (always present and reliable)
  ///   rating            → rating
  ///   description       → description
  factory Product.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num).toDouble();
    final discountPct = (json['discountPercentage'] as num? ?? 0).round();

    // Reverse-compute the original price before the discount was applied.
    // oldPrice = price / (1 - discountPct / 100)
    final double? oldPrice = discountPct > 0
        ? double.parse(
            (price / (1 - discountPct / 100)).toStringAsFixed(2))
        : null;

    return Product(
      id: json['id'].toString(),
      name: json['title'] as String,
      category: json['category'] as String,
      price: price,
      oldPrice: oldPrice,
      discount: discountPct > 0 ? '-$discountPct%' : '',
      // thumbnail is always present; fall back to first image if somehow missing.
      imageUrl: (json['thumbnail'] as String?) ??
          ((json['images'] as List?)?.first as String? ?? ''),
      rating: (json['rating'] as num? ?? 0).toDouble(),
      description: json['description'] as String? ?? '',
    );
  }

  /// Serialises this product back to a DummyJSON-compatible map.
  /// Used to re-read cached products with the same [fromJson] factory.
  Map<String, dynamic> toJson() => {
        'id': int.tryParse(id) ?? id,
        'title': name,
        'category': category,
        'price': price,
        'discountPercentage':
            oldPrice != null && oldPrice! > 0
                ? double.parse(
                    (((oldPrice! - price) / oldPrice!) * 100)
                        .toStringAsFixed(2))
                : 0.0,
        'thumbnail': imageUrl,
        'rating': rating,
        'description': description,
      };

  /// Lightweight map for the favourites file — only the essential fields.
  Map<String, dynamic> toFavJson() => {
        'id': id,
        'title': name,
        'category': category,
        'price': price,
        'image': imageUrl,
      };
      /// Creates a [Product] from a Firestore Document Snapshot.
  factory Product.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Product(
      id: doc.id, // نأخذ المعرف مباشرة من وثيقة الفايربيس
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (data['oldPrice'] as num?)?.toDouble(),
      discount: data['discount'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] as String? ?? '',
    );
  }

  /// Serialises this product to a Map to be saved in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'oldPrice': oldPrice,
      'discount': discount,
      'imageUrl': imageUrl,
      'rating': rating,
      'description': description,
    };
  }
}