import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/pet.dart';
import '../providers/auth_provider.dart';
import '../providers/pet_provider.dart';

// ── Filtros de espécie ────────────────────────────────────────────────────────

const _kEspecies = [
  {'label': 'Todos', 'valor': null, 'icon': Icons.menu},
  {'label': 'Cão', 'valor': 'cão', 'icon': Icons.pets},
  {'label': 'Gato', 'valor': 'gato', 'icon': Icons.catching_pokemon},
  {'label': 'Coelho', 'valor': 'coelho', 'icon': Icons.cruelty_free},
  {'label': 'Pássaro', 'valor': 'pássaro', 'icon': Icons.flutter_dash},
  {'label': 'Outro', 'valor': 'outro', 'icon': Icons.more_horiz},
];

// ── HomeScreen ────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  void _inicializar() {
    final pets = context.read<PetProvider>();
    pets.carregarPets();

    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated && auth.user != null) {
      pets.carregarProximos(
        cidade: auth.user!.cidade,
        estado: auth.user!.estado,
      );
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<PetProvider>().setBusca(value);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(auth),
        floatingActionButton: auth.isAuthenticated
            ? FloatingActionButton(
                onPressed: () => context.push('/pets/novo'),
                backgroundColor: AppColors.orange,
                tooltip: 'Anunciar pet',
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        body: RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () async {
            context.read<PetProvider>().carregarPets();
            if (auth.isAuthenticated && auth.user != null) {
              context.read<PetProvider>().carregarProximos(
                cidade: auth.user!.cidade,
                estado: auth.user!.estado,
              );
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildFiltros()),
              if (auth.isAuthenticated && auth.user?.cidade != null)
                SliverToBoxAdapter(child: _ProximosSection()),
              SliverToBoxAdapter(child: _buildTodosHeader()),
              _PetListSliver(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(AuthProvider auth) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.pets, color: AppColors.orange),
          const SizedBox(width: 8),
          const Text(
            'Adotei',
            style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        if (auth.isAuthenticated)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) async {
                if (value == 'perfil') {
                  context.push('/perfil');
                } else if (value == 'logout') {
                  final router = GoRouter.of(context);
                  await context.read<AuthProvider>().logout();
                  router.go('/');
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'perfil',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 18, color: AppColors.blue),
                      SizedBox(width: 10),
                      Text('Meu perfil'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text('Sair', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.blue,
                child: Text(
                  auth.user?.nome.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        else
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Entrar', style: TextStyle(color: AppColors.orange)),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'O que você procura?',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: AppColors.blue),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: const BorderSide(color: AppColors.blue, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Consumer<PetProvider>(
      builder: (_, pets, __) {
        return SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _kEspecies.length,
            itemBuilder: (_, i) {
              final e = _kEspecies[i];
              final selected = pets.filtroEspecie == e['valor'];
              return _EspecieChip(
                label: e['label'] as String,
                icon: e['icon'] as IconData,
                selected: selected,
                onTap: () => pets.setFiltroEspecie(e['valor'] as String?),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTodosHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        'Todos os pets',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── Chip de filtro de espécie ─────────────────────────────────────────────────

class _EspecieChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _EspecieChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: selected ? AppColors.orange : AppColors.blue,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? AppColors.orange : Colors.black87,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Seção "Próximos de mim" ───────────────────────────────────────────────────

class _ProximosSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (_, pets, __) {
        if (pets.isLoadingProximos) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Próximos de mim',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Center(child: CircularProgressIndicator(color: AppColors.blue)),
              ],
            ),
          );
        }

        if (pets.petsProximos.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Text('Próximos de mim',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: pets.petsProximos.length,
                itemBuilder: (_, i) => _PetCardHorizontal(pet: pets.petsProximos[i]),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

// ── Lista vertical de pets ────────────────────────────────────────────────────

class _PetListSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (_, pets, __) {
        if (pets.isLoading) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator(color: AppColors.orange)),
            ),
          );
        }

        if (pets.erro != null) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Não foi possível carregar os pets.\nVerifique se o servidor está rodando.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
                    onPressed: () => context.read<PetProvider>().carregarPets(),
                    child: const Text('Tentar novamente', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        if (pets.pets.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Nenhum pet encontrado', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _PetCardVertical(pet: pets.pets[i]),
            childCount: pets.pets.length,
          ),
        );
      },
    );
  }
}

// ── Card vertical (lista principal) ──────────────────────────────────────────

class _PetCardVertical extends StatelessWidget {
  final Pet pet;
  const _PetCardVertical({required this.pet});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/pets/${pet.id}'),
      child: Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _PetImage(fotoUrl: pet.fotoUrl, size: 90, radius: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Tag(text: _capitalize(pet.especie), color: AppColors.blue),
                      if (pet.porte != null) ...[
                        const SizedBox(width: 6),
                        _Tag(text: _capitalize(pet.porte!), color: AppColors.orange),
                      ],
                    ],
                  ),
                  if (pet.idadeFormatada.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(pet.idadeFormatada, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                  if (pet.localidade.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            pet.localidade,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.chevron_right, color: Colors.grey),
          ),
        ],
      ),
    ),    // Container
    );    // GestureDetector
  }
}

// ── Card horizontal (Próximos de mim) ────────────────────────────────────────

class _PetCardHorizontal extends StatelessWidget {
  final Pet pet;
  const _PetCardHorizontal({required this.pet});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/pets/${pet.id}'),
      child: Container(
        width: 130,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: _PetImage(fotoUrl: pet.fotoUrl, size: 130, radius: 0),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _capitalize(pet.especie),
                    style: const TextStyle(fontSize: 11, color: AppColors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget de imagem do pet ───────────────────────────────────────────────────

class _PetImage extends StatelessWidget {
  final String? fotoUrl;
  final double size;
  final double radius;

  const _PetImage({required this.fotoUrl, required this.size, required this.radius});

  @override
  Widget build(BuildContext context) {
    if (fotoUrl != null && fotoUrl!.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          fotoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: const Icon(Icons.pets, color: AppColors.blue, size: 36),
    );
  }
}

// ── Tag colorida ──────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
