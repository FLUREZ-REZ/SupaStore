import 'package:flutter/material.dart';

import 'package:supastore/features/home_feature/domain/entities/category_entity.dart';
import 'package:supastore/features/home_feature/domain/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider({
    required CategoryRepository repository,
  }) : _repository = repository;

  final CategoryRepository _repository;

  List<CategoryEntity> _categories = [];

  bool _isLoading = false;

  String? _error;

  List<CategoryEntity> get categories => _categories;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      _categories = await _repository.getCategories();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }
}