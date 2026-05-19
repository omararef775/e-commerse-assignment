import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/product_provider.dart';
import 'product_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off the initial load after the first frame so the widget tree is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  // ── Offline banner ─────────────────────────────────────────────────────────

  void _showOfflineSnackBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF3A3A45),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        content: Row(
          children: const [
            Icon(Icons.wifi_off, color: Colors.orangeAccent, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Offline Mode: Showing last saved products',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    // Show offline snackbar once when data comes from cache.
    if (provider.isOffline && !provider.isLoading) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showOfflineSnackBar());
    }

    return SafeArea(
      child: _buildBody(provider),
    );
  }

  Widget _buildBody(ProductProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingState();
    }
    if (provider.error != null) {
      return _buildErrorState(provider.error!);
    }
    return _buildSuccessState(provider);
  }

  // ── Loading state ──────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.redAccent),
          SizedBox(height: 16),
          Text('Fetching products…',
              style: TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.white30, size: 64),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => context.read<ProductProvider>().loadProducts(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Success state ──────────────────────────────────────────────────────────

  Widget _buildSuccessState(ProductProvider provider) {
    final products = provider.products;

    // Split into two lists for "Today Deals" and "Trending" sections.
    final todayDeals = products.take(10).toList();
    final trending = products.reversed.take(10).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader(
          'Today\'s Deals',
          'Fresh picks curated for today only',
          'See all',
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 350,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: todayDeals.length,
            itemBuilder: (context, index) =>
                _buildProductCard(context, todayDeals[index]),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          'Trending',
          'Most loved styles and gadgets right now',
          'See all',
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 350,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trending.length,
            itemBuilder: (context, index) =>
                _buildProductCard(context, trending[index]),
          ),
        ),
      ],
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────

  Widget _buildSectionHeader(
      String title, String subtitle, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
        ),
        Text(action,
            style: const TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── Product card ───────────────────────────────────────────────────────────

  Widget _buildProductCard(BuildContext context, Product product) {
    final isFav =
        context.watch<FavoritesProvider>().isFavorite(product);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product)),
      ),
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
          // No mainAxisSize.min — the Column must fill the card's full
          // constrained height so that Spacer() has room to expand.
          children: [
            // ── Image area ────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: const Color(0xFFF5F5F5),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.redAccent),
                        );
                      },
                      errorBuilder: (context, error, trace) => const Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: Colors.white30, size: 40),
                      ),
                    ),
                  ),
                ),
                // Discount badge
                if (product.discount.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(product.discount,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                // Favourite button
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () =>
                        context.read<FavoritesProvider>().toggleFavorite(product),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24).withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ── Product info ──────────────────────────────────────────
            Text(
              product.category,
              style: const TextStyle(color: Colors.orange, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              product.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(width: 4),
                if (product.oldPrice != null)
                  Text('\$${product.oldPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white38,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 11)),
              ],
            ),
            const Spacer(),
            // ── Add to cart button ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartProvider>().addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Added to Cart ✓'),
                      duration: Duration(seconds: 1)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 34),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.zero,
                ),
                child: const Text('Add to cart',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}