import 'package:flutter/material.dart';

import 'package:supastore/features/home_feature/domain/entities/banner_entity.dart';
import 'package:supastore/features/home_feature/domain/repositories/home_repository.dart';

class BannerProvider extends ChangeNotifier {
  BannerProvider({
    required BannerRepository repository,
  }) : _repository = repository;

  final BannerRepository _repository;

  // ============================================================
  // HERO
  // ============================================================

  List<BannerEntity> _heroBanners = [];

  bool _isHeroLoading = false;

  String? _heroError;

  List<BannerEntity> get heroBanners =>
      _heroBanners;

  bool get isHeroLoading =>
      _isHeroLoading;

  String? get heroError =>
      _heroError;

  // ============================================================
  // PROMOTIONAL
  // ============================================================

  List<BannerEntity> _promotionalBanners = [];

  bool _isPromotionalLoading = false;

  String? _promotionalError;

  List<BannerEntity> get promotionalBanners =>
      _promotionalBanners;

  bool get isPromotionalLoading =>
      _isPromotionalLoading;

  String? get promotionalError =>
      _promotionalError;

  // ============================================================
  // SINGLE
  // ============================================================

  List<BannerEntity> _singleBanners = [];

  bool _isSingleLoading = false;

  String? _singleError;

  List<BannerEntity> get singleBanners =>
      _singleBanners;

  bool get isSingleLoading =>
      _isSingleLoading;

  String? get singleError =>
      _singleError;

  // ============================================================
  // LOAD HERO
  // ============================================================

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

  // ============================================================
  // LOAD PROMOTIONAL
  // ============================================================

  Future<void> loadPromotionalBanners() async {
    if (_isPromotionalLoading) {
      return;
    }

    _isPromotionalLoading = true;
    _promotionalError = null;

    notifyListeners();

    try {
      _promotionalBanners =
      await _repository
          .getPromotionalBanners();
    } catch (e) {
      _promotionalError = e.toString();
    } finally {
      _isPromotionalLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // LOAD SINGLE
  // ============================================================

  Future<void> loadSingleBanners() async {
    if (_isSingleLoading) {
      return;
    }

    _isSingleLoading = true;
    _singleError = null;

    notifyListeners();

    try {
      _singleBanners =
      await _repository.getSingleBanners();
    } catch (e) {
      _singleError = e.toString();
    } finally {
      _isSingleLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // LOAD ALL
  // ============================================================

  Future<void> loadAllBanners() async {
    await Future.wait([
      loadHeroBanners(),
      loadPromotionalBanners(),
      loadSingleBanners(),
    ]);
  }
}