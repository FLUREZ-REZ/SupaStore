import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supastore/features/intro_feature/presentation/providers/intro_provider.dart';

class IntroBinding {


  static List<SingleChildWidget> providers=[

    ChangeNotifierProvider(
      create: (_) => IntroProvider(),
    ),

  ];


}