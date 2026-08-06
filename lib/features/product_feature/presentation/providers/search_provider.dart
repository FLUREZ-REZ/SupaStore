import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/search_repository.dart';


class SearchProvider extends ChangeNotifier {

  SearchProvider({
    required SearchRepository repository,
  }) : _repository = repository {
    loadHistory();
  }


  final SearchRepository _repository;



  List<ProductEntity> _products = [];

  List<ProductEntity> get products => _products;



  bool _isLoading = false;

  bool get isLoading => _isLoading;



  String? _error;

  String? get error => _error;



  List<String> _history = [];

  List<String> get history => _history;



  Future<void> search(String value) async {


    if(value.trim().isEmpty){

      _products = [];

      notifyListeners();

      return;

    }



    try {


      _isLoading = true;

      _error = null;

      notifyListeners();



      final result =
      await _repository.searchProducts(
        value,
      );


      _products = result;



    }catch(e){


      _error = e.toString();


    }



    _isLoading = false;

    notifyListeners();


  }




  // ==========================
  // Load Search History
  // ==========================

  Future<void> loadHistory() async {


    final prefs =
    await SharedPreferences.getInstance();



    _history =
        prefs.getStringList(
          'search_history',
        ) ?? [];



    notifyListeners();


  }




  // ==========================
  // Add Search History
  // ==========================

  Future<void> addSearchHistory(
      String value,
      ) async {


    value = value.trim();



    if(value.isEmpty) return;



    // تکراری حذف شود

    _history.remove(value);



    // جدید اول لیست

    _history.insert(
      0,
      value,
    );



    // فقط 10 تای آخر

    if(_history.length > 10){

      _history =
          _history.sublist(
            0,
            10,
          );

    }



    final prefs =
    await SharedPreferences.getInstance();



    await prefs.setStringList(
      'search_history',
      _history,
    );



    notifyListeners();


  }




  // ==========================
  // Clear History
  // ==========================

  Future<void> clearHistory() async {


    _history.clear();



    final prefs =
    await SharedPreferences.getInstance();



    await prefs.remove(
      'search_history',
    );



    notifyListeners();


  }


}