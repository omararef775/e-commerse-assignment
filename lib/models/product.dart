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

  static List<Product> dummyProducts = [
    Product(id: '1', name: 'Aura Noise-Cancel', category: 'Electronics', price: 149.99, oldPrice: 249.99, discount: '-40%', imageUrl: '🎧'),
    Product(id: '2', name: 'Nova Smart Watch', category: 'Electronics', price: 129.99, oldPrice: 199.99, discount: '-30%', imageUrl: '⌚'),
    Product(id: '3', name: 'Luro Leather Bag', category: 'Fashion', price: 59.99, oldPrice: 140.00, discount: '-50%', imageUrl: '👜'),
    Product(id: '4', name: 'Sport Shoes', category: 'Sports', price: 89.99, oldPrice: 120.00, discount: '-25%', imageUrl: '👟'),
    Product(id: '5', name: 'Luxury Perfume', category: 'Perfumes', price: 79.99, oldPrice: 100.00, discount: '-20%', imageUrl: '✨'),
  ];
}