import 'package:flutter/material.dart';

import '../../domain/entities/product_image_entity.dart';
import '../../domain/repositories/product_image_repository.dart';

class ProductImageProvider extends ChangeNotifier {
  ProductImageProvider({
    required ProductImageRepository repository,
  }) : _repository = repository;

  final ProductImageRepository _repository;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _error;

  String? get error => _error;

  List<ProductImageEntity> _images = [];

  List<ProductImageEntity> get images => _images;


  Future<void> loadImages(
      String productId,
      ) async {

    try {

      debugPrint("🔥 loadImages called: $productId");


      _isLoading = true;
      _error = null;

      notifyListeners();


      _images = await _repository.getProductImages(
        productId,
      );


      debugPrint(
        "✅ Images count: ${_images.length}",
      );


      for (final image in _images) {

        debugPrint(
          "🖼 Image URL: ${image.imageUrl}",
        );

      }


    } catch (e) {

      debugPrint(
        "❌ Error loading images: $e",
      );

      _error = e.toString();


    } finally {

      _isLoading = false;

      notifyListeners();

    }
  }


  void clear() {

    _images = [];

    _error = null;

    _isLoading = false;

    notifyListeners();

  }
}