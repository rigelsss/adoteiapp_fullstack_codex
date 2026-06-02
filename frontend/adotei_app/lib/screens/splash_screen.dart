import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fundo com listras verticais
          Row(
            children: [
              Expanded(child: Container(color: AppColors.orange)),
              Container(width: 18, color: Colors.white),
              Expanded(child: Container(color: AppColors.blue)),
              Container(width: 18, color: Colors.white),
              Expanded(child: Container(color: AppColors.orange)),
            ],
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Text(
                        'Adotei',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.pets, color: AppColors.orange, size: 20),
                      ),
                    ],
                  ),
                ),
                // Fotos dos pets
                Expanded(
                  child: Stack(
                    children: [
                      _PetCircle(
                        url: 'https://picsum.photos/seed/shiba/300/300',
                        top: 10, left: 20, size: 120,
                      ),
                      _PetCircle(
                        url: 'https://picsum.photos/seed/goldenretriever/300/300',
                        top: 30, right: 20, size: 100,
                      ),
                      _PetCircle(
                        url: 'https://picsum.photos/seed/persiancat/300/300',
                        bottom: 80, left: 10, size: 110,
                      ),
                      _PetCircle(
                        url: 'https://picsum.photos/seed/orangecat/300/300',
                        bottom: 60, right: 30, size: 115,
                      ),
                    ],
                  ),
                ),
                // Botões
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => context.push('/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: const StadiumBorder(),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Já tenho conta',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          context.read<AuthProvider>().entrarComoVisitante();
                          context.go('/home');
                        },
                        child: const Text(
                          'Continuar como visitante',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),   // Scaffold
    );   // PopScope
  }
}

class _PetCircle extends StatelessWidget {
  final String url;
  final double? top, bottom, left, right;
  final double size;

  const _PetCircle({
    required this.url,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
