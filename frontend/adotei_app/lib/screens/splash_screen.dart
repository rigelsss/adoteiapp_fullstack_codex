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
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final topSectionHeight = height * 0.63;
            final logoTopPadding = height * 0.075;

            return Stack(
              children: [
                const _StripedBackground(),
                Positioned.fill(
                  top: topSectionHeight,
                  child: Container(color: Colors.white),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      SizedBox(height: logoTopPadding),
                      const _BrandHeader(),
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _PetCircle(
                              imagePath: 'assets/images/splash/dog_1.jpg',
                              size: width * 0.24,
                              top: height * 0.02,
                              left: width * 0.255,
                              borderColor: AppColors.orange,
                            ),
                            _PetCircle(
                              imagePath: 'assets/images/splash/dog_2.jpg',
                              size: width * 0.24,
                              top: height * 0.11,
                              right: width * 0.005,
                              borderColor: AppColors.orange,
                            ),
                            _PetCircle(
                              imagePath: 'assets/images/splash/cat_1.jpg',
                              size: width * 0.24,
                              top: height * 0.2,
                              left: width * 0.005,
                              borderColor: AppColors.blue,
                            ),
                            _PetCircle(
                              imagePath: 'assets/images/splash/cat_2.jpg',
                              size: width * 0.24,
                              top: height * 0.28,
                              left: width * 0.505,
                              borderColor: AppColors.blue,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          width * 0.12,
                          0,
                          width * 0.12,
                          height * 0.06,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PrimarySplashButton(
                              label: 'Já tenho conta',
                              onPressed: () => context.push('/login'),
                            ),
                            const SizedBox(height: 14),
                            _PrimarySplashButton(
                              label: 'Criar conta',
                              onPressed: () => context.push('/register'),
                            ),
                            const SizedBox(height: 18),
                            GestureDetector(
                              onTap: () {
                                context.read<AuthProvider>().entrarComoVisitante();
                                context.go('/home');
                              },
                              child: const Text(
                                'Continuar como visitante',
                                style: TextStyle(
                                  color: AppColors.blue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.blue,
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
            );
          },
        ),
      ),
    );
  }
}

class _StripedBackground extends StatelessWidget {
  const _StripedBackground();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(color: const Color(0xFFF9BC62))),
        Expanded(child: Container(color: const Color(0xFF67B5D8))),
        Expanded(child: Container(color: const Color(0xFFF9BC62))),
        Expanded(child: Container(color: const Color(0xFF67B5D8))),
      ],
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _OutlinedLogoText(text: 'Adotei'),
        const SizedBox(width: 10),
        const _BrandBadge(),
      ],
    );
  }
}

class _OutlinedLogoText extends StatelessWidget {
  final String text;

  const _OutlinedLogoText({required this.text});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 54,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.5,
      color: Colors.white,
    );

    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = const Color(0xFF8E8E8E),
          ),
        ),
        Text(text, style: style),
      ],
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E4),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF8E8E8E), width: 2.5),
      ),
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF9BC62),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.home_rounded,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class _PrimarySplashButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimarySplashButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF7CC6EA),
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF9BC62),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PetCircle extends StatelessWidget {
  final String imagePath;
  final double size;
  final double? top;
  final double? left;
  final double? right;
  final Color borderColor;

  const _PetCircle({
    required this.imagePath,
    required this.size,
    required this.borderColor,
    this.top,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
