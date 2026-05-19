import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = true; // يبدأ بالتحميل
  String? _error;
  StreamSubscription? _subscription;

  // ── Getters ──
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  // الفايربيس يدير وضع عدم الاتصال تلقائياً، تركنا هذا المتغير فقط حتى لا نعطل شاشة الـ HomeScreen
  bool get isOffline => false; 

  List<String> get categories =>
      _products.map((p) => p.category).toSet().toList()..sort();

  List<Product> productsByCategory(String category) => _products
      .where((p) => p.category.toLowerCase() == category.toLowerCase())
      .toList();

  // ── قراءة البيانات بالتزامن اللحظي ──
  void loadProducts() {
    // التكليف الثاني: استخدام snapshots() للحصول على التحديثات اللحظية
    _subscription = FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen(
      (snapshot) {
        // تحويل وثائق السحابة إلى نموذج Product باستخدام دالة fromDoc
        _products = snapshot.docs.map((doc) => Product.fromDoc(doc)).toList();
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to fetch data from cloud.\nPlease check your connection.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel(); // إغلاق الاتصال عند تدمير المزود لتوفير الموارد
    super.dispose();
  }
}