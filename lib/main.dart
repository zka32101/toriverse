import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/router.dart';
import 'config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();

  runApp(
    const ProviderScope(
      child: ToriverseApp(),
    ),
  );
}

class ToriverseApp extends ConsumerWidget {
  const ToriverseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'トリバース',
      theme: ToriverseTheme.lightTheme(),
      darkTheme: ToriverseTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
