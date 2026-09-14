import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supastore/core/di/service_locator.dart';
import 'package:supastore/core/services/internet_service.dart';
import 'package:supastore/features/splash_feature/presentation/providers/splash_provider.dart';

class SplashBinding {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(
      create: (_) => SplashProvider(
        sl<InternetService>(),
      ),
    ),
  ];
}