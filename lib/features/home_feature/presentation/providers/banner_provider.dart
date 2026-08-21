import 'package:flutter/material.dart';

import 'package:supastore/features/home_feature/domain/entities/banner_entity.dart';
import 'package:supastore/features/home_feature/domain/repositories/home_repository.dart';

class BannerProvider extends ChangeNotifier {
  BannerProvider({
    required BannerRepository repository,
  }) : _repository = repository;

  final BannerRepository _repository;

  // ─────────────────────────────────────────────
  // Hero Banners
  // ─────────────────────────────────────────────

  List<BannerEntity> _heroBanners = [];

  bool _isHeroLoading = false;

  String? _heroError;

  List<BannerEntity> get heroBanners => _heroBanners;

  bool get isHeroLoading => _isHeroLoading;

  String? get heroError => _heroError;

  // ─────────────────────────────────────────────
  // Promotional Banners
  // ─────────────────────────────────────────────

  List<BannerEntity> _promotionalBanners = [];

  bool _isPromotionalLoading = false;

  String? _promotionalError;

  List<BannerEntity> get promotionalBanners =>
      _promotionalBanners;

  bool get isPromotionalLoading =>
      _isPromotionalLoading;

  String? get promotionalError =>
      _promotionalError;

  // ─────────────────────────────────────────────
  // Load Hero Banners
  // ─────────────────────────────────────────────

  Future<void> loadHeroBanners() async {
    if (_isHeroLoading) {
      return;
    }

    _isHeroLoading = true;
    _heroError = null;

    notifyListeners();

    try {
      _heroBanners =
      await _repository.getHeroBanners();
    } catch (e) {
      _heroError = e.toString();
    } finally {
      _isHeroLoading = false;

      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // Load Promotional Banners
  // ─────────────────────────────────────────────

  Future<void> loadPromotionalBanners() async {
    if (_isPromotionalLoading) {
      return;
    }

    _isPromotionalLoading = true;
    _promotionalError = null;

    notifyListeners();

    try {
      _promotionalBanners =
      await _repository.getPromotionalBanners();
    } catch (e) {
      _promotionalError = e.toString();
    } finally {
      _isPromotionalLoading = false;

      notifyListeners();
    }
  }
}