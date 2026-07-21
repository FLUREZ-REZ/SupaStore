import 'package:get_it/get_it.dart';
import 'package:supastore/core/services/app_launch_service.dart';
import 'package:supastore/core/services/internet_service.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  sl.registerLazySingleton<InternetService>(
        () => InternetService(),
  );

  sl.registerLazySingleton<AppLaunchService>(
        () => AppLaunchService(),
  );
}