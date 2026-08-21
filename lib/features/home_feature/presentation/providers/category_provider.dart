import 'package:flutter/material.dart';

import 'package:supastore/features/home_feature/domain/entities/category_entity.dart';
import 'package:supastore/features/home_feature/domain/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider({
    required CategoryRepository repository,
  }) : _repository = repository;

  final CategoryRepository _repository;

  // =========================
  // Categories
  // =========================

  final List<CategoryEntity> _categories = [];

  List<CategoryEntity> get categories =>
      List.unmodifiable(_categories);

  // =========================
  // Loading
  // =========================

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // =========================
  // Error
  // =========================

  String? _error;

  String? get error => _error;

  // =========================
  // Load Categories
  // =========================

  Future<void> loadCategories() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final List<CategoryEntity> result =
      await _repository.getCategories();

      _categories
        ..clear()
        ..addAll(result);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }



}