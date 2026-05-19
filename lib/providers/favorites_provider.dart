import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class FavoritesProvider extends ChangeNotifier {
  List<Product> _favoriteItems = [];
  StreamSubscription? _authSubscription;
  StreamSubscription? _favSubscription;

  // ── Getters ──
  List<Product> get favoriteItems => List.unmodifiable(_favoriteItems);

  bool isFavorite(Product product) =>
      _favoriteItems.any((item) => item.id == product.id);

  // ── التهيئة (الاستماع لتغيرات تسجيل الدخول) ──
  FavoritesProvider() {
    // نراقب حالة المستخدم: إذا سجل دخوله نجلب مفضلته، وإذا خرج نمسحها من الشاشة
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _listenToFavorites(user.uid);
      } else {
        _favoriteItems.clear();
        _favSubscription?.cancel();
        notifyListeners();
      }
    });
  }

  // ── قراءة المفضلة بالتزامن اللحظي ──
  void _listenToFavorites(String uid) {
    _favSubscription?.cancel();
    // المسار المطلوب في التكليف: users/{userId}/favorites
    _favSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .listen((snapshot) {
      _favoriteItems = snapshot.docs.map((doc) {
        final map = doc.data();
        // نستعيد المنتج باستخدام البيانات الأساسية المحفوظة
        return Product(
          id: map['id'] as String,
          name: map['title'] as String,
          category: map['category'] as String? ?? '',
          price: (map['price'] as num).toDouble(),
          imageUrl: map['image'] as String,
        );
      }).toList();
      notifyListeners();
    });
  }

  // ── إضافة أو إزالة من المفضلة ──
  Future<void> toggleFavorite(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // يجب أن يكون مسجلاً للدخول

    // تجهيز مسار المنتج داخل مفضلة هذا المستخدم تحديداً
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(product.id);

    if (isFavorite(product)) {
      // إزالة من الفايربيس
      await docRef.delete();
    } else {
      // التكليف الثالث: استخدام set() لحفظ المنتج
      await docRef.set(product.toFavJson());
    }
  }

  // أعدنا تعريف هذه الدالة كـ (فارغة) كي لا يظهر خطأ في ملف main.dart الذي يستدعيها
  Future<void> loadFavorites() async {}

  @override
  void dispose() {
    _authSubscription?.cancel();
    _favSubscription?.cancel();
    super.dispose();
  }
}