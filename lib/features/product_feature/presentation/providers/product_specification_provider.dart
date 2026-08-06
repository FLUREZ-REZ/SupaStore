import 'package:flutter/material.dart';

import '../../domain/entities/product_specification_entity.dart';
import '../../domain/repositories/product_specification_repository.dart';

class ProductSpecificationProvider extends ChangeNotifier {
  ProductSpecificationProvider({
    required ProductSpecificationRepository repository,
  }) : _repository = repository;

  final ProductSpecificationRepository _repository;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _error;

  String? get error => _error;

  List<ProductSpecificationEntity> _specifications = [];

  List<ProductSpecificationEntity> get specifications =>
      _specifications;

  Future<void> loadSpecifications(
      String productId,
      ) async {
    try {
      _isLoading = true;
      _error = null;

      notifyListeners();

      _specifications =
      await _repository.getProductSpecifications(
        productId,
      );

      debugPrint(
        "Specifications loaded: ${_specifications.length}",
      );

      for (var item in _specifications) {
        debugPrint(
          "${item.title} : ${item.value}",
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  void clear() {
    _specifications = [];

    _error = null;

    _isLoading = false;

    notifyListeners();
  }
}