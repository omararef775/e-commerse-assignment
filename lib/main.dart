import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/product_provider.dart';
import 'screens/main_screen.dart';
import 'screens/auth_screen.dart'; // سنقوم بإنشاء هذه الشاشة في الخطوة التالية

void main() async {
  // التأكد من تهيئة الفلاتر قبل أي عملية
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الفايربيس
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.loadFavorites();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider.value(value: favoritesProvider),
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
      // التكليف الأول: توجيه المستخدم باستخدام StreamBuilder
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // أثناء التحميل
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
            );
          }
          // إذا كان المستخدم مسجلاً للدخول، وجهه للمتجر
          if (snapshot.hasData) {
            return const MainScreen();
          }
          // إذا لم يكن مسجلاً، وجهه لشاشة تسجيل الدخول
          return const AuthScreen();
        },
      ),
    );
  }
}