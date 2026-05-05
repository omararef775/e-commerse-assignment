import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Product> products = Product.dummyProducts;

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Today Deals', 'Fresh picks curated for today only', 'See all'),
          const SizedBox(height: 15),
          SizedBox(
            // قمنا بزيادة الارتفاع هنا بشكل كافٍ جداً لمنع أي خطأ
            height: 340, 
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) => _buildProductCard(context, products[index]),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Trending', 'Most loved styles and gadgets right now', 'See all'),
          const SizedBox(height: 15),
          SizedBox(
            // قمنا بزيادة الارتفاع هنا أيضاً
            height: 340, 
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.reversed.toList().length,
              itemBuilder: (context, index) => _buildProductCard(context, products.reversed.toList()[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
        ),
        Text(action, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final isFav = context.watch<FavoritesProvider>().isFavorite(product);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)));
      },
      child: Container(
        width: 170, 
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A32),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // يمنع التمدد غير الضروري
          children: [
            Stack(
              children: [
                Container(
                  height: 140, // زيادة ارتفاع الصورة قليلاً
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E24),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(child: Text(product.imageUrl, style: const TextStyle(fontSize: 60))),
                ),
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(10)),
                    child: Text(product.discount, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  top: 5, right: 5,
                  child: IconButton(
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.grey),
                    onPressed: () => context.read<FavoritesProvider>().toggleFavorite(product),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(product.category, style: const TextStyle(color: Colors.orange, fontSize: 12)),
            // أضفنا Expanded لضمان عدم حدوث طفح في النص
            Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Row(
              children: [
                Text('\$${product.price}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 5),
                if (product.oldPrice != null)
                  Text('\$${product.oldPrice}', style: const TextStyle(color: Colors.white54, decoration: TextDecoration.lineThrough, fontSize: 12)),
              ],
            ),
            const Spacer(), // يقوم بدفع الزر للأسفل للحفاظ على ترتيب البطاقات
            ElevatedButton(
              onPressed: () {
                 context.read<CartProvider>().addToCart(product);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة للسلة'), duration: Duration(seconds: 1)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                minimumSize: const Size(double.infinity, 35), // زر أطول قليلاً
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: const Text('Add to cart', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}