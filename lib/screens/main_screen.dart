import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // قمنا بإضافة هذا السطر
import '../providers/cart_provider.dart'; // قمنا بإضافة هذا السطر
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    const CategoriesScreen(),
    const FavoritesScreen(),
    const CartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isDarkScreen = _currentIndex == 1 || _currentIndex == 3;
    
    // نستمع هنا لعدد المنتجات المختلفة في السلة
    final cartItemCount = context.watch<CartProvider>().items.length;

    return Scaffold(
      backgroundColor: isDarkScreen ? const Color(0xFF1E1E24) : Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Categories'),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
          BottomNavigationBarItem(
            // استخدمنا Badge هنا لإظهار العداد
            icon: Badge(
              isLabelVisible: cartItemCount > 0, // يختفي العداد إذا كانت السلة فارغة
              label: Text(cartItemCount.toString()), // عرض عدد المنتجات
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}