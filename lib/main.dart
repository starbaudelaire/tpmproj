import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'bootstrap/app_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await AppInit.initialize();
  runApp(ProviderScope(child: JogjasplorasiApp(initialLoggedIn: isLoggedIn)));
}
