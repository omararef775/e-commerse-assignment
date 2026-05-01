class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final String discount;
  final String imageUrl; // سنستخدم أيقونات أو روابط وهمية مؤقتاً

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.oldPrice,
    this.discount = '',
    required this.imageUrl,
  });
}