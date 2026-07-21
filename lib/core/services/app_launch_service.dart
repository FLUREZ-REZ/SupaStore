import 'package:shared_preferences/shared_preferences.dart';

class AppLaunchService {

  Future<bool> hasSeenIntro() async {

    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool('show_intro') ?? false;
  }
}