import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/product_provider.dart';
import 'screens/main_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialised before any async work.
  WidgetsFlutterBinding.ensureInitialized();

  // Create the FavoritesProvider and load persisted data before the app renders.
  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.loadFavorites();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // Provide the pre-loaded FavoritesProvider instance.
        ChangeNotifierProvider.value(value: favoritesProvider),
        // ProductProvider will trigger loadProducts() from HomeScreen's initState.
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E24),
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: const MainScreen(),
    );
  }
}