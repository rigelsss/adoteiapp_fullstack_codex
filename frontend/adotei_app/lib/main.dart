import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'providers/auth_provider.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthProvider();
  await auth.tryAutoLogin();
  runApp(
    ChangeNotifierProvider.value(
      value: auth,
      child: const AdoteiApp(),
    ),
  );
}

class AdoteiApp extends StatelessWidget {
  const AdoteiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Adotei',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.orange),
        fontFamily: 'Roboto',
      ),
      routerConfig: appRouter,
    );
  }
}
