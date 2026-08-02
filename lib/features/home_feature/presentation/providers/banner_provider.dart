import 'package:flutter/material.dart';
import 'package:supastore/features/home_feature/domain/entities/banner_entity.dart';
import 'package:supastore/features/home_feature/domain/repositories/home_repository.dart';

class BannerProvider extends ChangeNotifier {
  BannerProvider({
    required BannerRepository repository,
  }) : _repository = repository;

  final BannerRepository _repository;

  bool _isLoading = false;

  List<BannerEntity> _banners = [];

  String? _error;

  bool get isLoading => _isLoading;

  List<BannerEntity> get banners => _banners;

  String? get error => _error;

  Future<void> loadBanners() async {
    _isLoading = true;

    _error = null;

    notifyListeners();

    try {
      _banners = await _repository.getBanners();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }
}