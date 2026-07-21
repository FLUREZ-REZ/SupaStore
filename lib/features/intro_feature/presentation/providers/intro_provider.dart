


import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroProvider extends ChangeNotifier {


  final PageController pageController =
  PageController();


  int currentPage = 0;


  void changePage(int index){

    currentPage = index;

    notifyListeners();

  }



  Future<void> completeIntro() async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      'show_intro',
      true,
    );
  }


}