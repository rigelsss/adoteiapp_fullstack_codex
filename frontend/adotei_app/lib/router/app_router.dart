import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/pet_detail_screen.dart';
import '../screens/criar_anuncio_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/pets/novo',
      builder: (_, __) => const CriarAnuncioScreen(),
    ),
    GoRoute(
      path: '/pets/:id',
      builder: (_, state) => PetDetailScreen(
        petId: int.parse(state.pathParameters['id']!),
      ),
    ),
  ],
);
