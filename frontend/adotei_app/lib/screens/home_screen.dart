import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return PopScope(
      canPop: false,
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.pets, color: AppColors.orange),
            const SizedBox(width: 8),
            const Text('Adotei', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (auth.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.person_outline, color: AppColors.blue),
              onPressed: () {},
            )
          else
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Entrar', style: TextStyle(color: AppColors.orange)),
            ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: AppColors.orange),
            SizedBox(height: 16),
            Text('Home — Etapa 4', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    ),   // Scaffold
    );   // PopScope
  }
}
