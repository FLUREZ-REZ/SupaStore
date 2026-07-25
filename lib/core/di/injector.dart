import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

final getIt = GetIt.instance;

Future<void> setupInjector() async {
  getIt.registerLazySingleton<SupabaseClient>(
        () => SupabaseService.client,
  );
}