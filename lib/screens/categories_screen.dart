import 'package:flutter/material.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  // DummyJSON category slugs (exact strings returned by the API) paired with
  // human-readable display labels and UI styling.
  static const List<Map<String, dynamic>> _apiCategories = [
    {
      'apiName': 'smartphones',
      'label': 'Smartphones',
      'icon': Icons.smartphone,
      'color': Color(0xFF4FC3F7), // light blue
    },
    {
      'apiName': 'laptops',
      'label': 'Laptops',
      'icon': Icons.laptop,
      'color': Color(0xFF80DEEA), // cyan
    },
    {
      'apiName': 'mens-shirts',
      'label': "Men's Fashion",
      'icon': Icons.checkroom,
      'color': Color(0xFF80CBC4), // teal
    },
    {
      'apiName': 'womens-dresses',
      'label': "Women's Fashion",
      'icon': Icons.dry_cleaning,
      'color': Color(0xFFF48FB1), // pink
    },
    {
      'apiName': 'beauty',
      'label': 'Beauty',
      'icon': Icons.auto_awesome,
      'color': Color(0xFFCE93D8), // purple
    },
    {
      'apiName': 'sports-accessories',
      'label': 'Sports',
      'icon': Icons.sports_basketball,
      'color': Color(0xFFA5D6A7), // green
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('Browse by category',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.15,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: _apiCategories.length,
                itemBuilder: (context, index) {
                  final cat = _apiCategories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryProductsScreen(
                            categoryName: cat['apiName'] as String,
                            displayName: cat['label'] as String,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A32),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: (cat['color'] as Color)
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(cat['icon'] as IconData,
                                size: 34, color: cat['color'] as Color),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            cat['label'] as String,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}