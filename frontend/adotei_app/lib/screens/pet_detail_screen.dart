import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/pet.dart';
import '../providers/auth_provider.dart';
import '../providers/pet_provider.dart';

class PetDetailScreen extends StatefulWidget {
  final int petId;
  const PetDetailScreen({super.key, required this.petId});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  bool _enviandoInteresse = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<PetProvider>().carregarDetalhe(widget.petId),
    );
  }

  void _voltar() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _voltar();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Consumer<PetProvider>(
          builder: (_, provider, __) {
            if (provider.isLoadingDetalhe) {
              return const Center(child: CircularProgressIndicator(color: AppColors.orange));
            }
            final pet = provider.petDetalhe;
            if (pet == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('Não foi possível carregar o pet.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _voltar,
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              );
            }
            return _buildContent(pet);
          },
        ),
      ),
    );
  }

  Widget _buildContent(PetDetail pet) {
    final auth = context.watch<AuthProvider>();
    final isOwner = auth.isAuthenticated && auth.user?.id == pet.donoId;

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(pet),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(pet),
                const SizedBox(height: 16),
                if (pet.descricao != null && pet.descricao!.isNotEmpty) ...[
                  _buildSection('Sobre', pet.descricao!),
                  const SizedBox(height: 16),
                ],
                _buildDonoCard(pet.dono),
                const SizedBox(height: 28),
                _buildActionButton(pet, isOwner, auth),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar(PetDetail pet) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: _voltar,
        style: IconButton.styleFrom(
          backgroundColor: Colors.black26,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _HeroImage(fotoUrl: pet.fotoUrl),
      ),
    );
  }

  Widget _buildHeader(PetDetail pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pet.nome,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _Tag(text: _capitalize(pet.especie), color: AppColors.blue),
            if (pet.porte != null)
              _Tag(text: _capitalize(pet.porte!), color: AppColors.orange),
            if (pet.raca != null)
              _Tag(text: pet.raca!, color: Colors.grey.shade600),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (pet.idadeFormatada.isNotEmpty) ...[
              const Icon(Icons.cake_outlined, size: 15, color: Colors.grey),
              const SizedBox(width: 4),
              Text(pet.idadeFormatada,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(width: 14),
            ],
            if (pet.localidade.isNotEmpty) ...[
              const Icon(Icons.location_on_outlined, size: 15, color: Colors.grey),
              const SizedBox(width: 4),
              Text(pet.localidade,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(content,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
      ],
    );
  }

  Widget _buildDonoCard(DonoInfo dono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.blue.withValues(alpha: 0.15),
            child: Text(
              dono.nome.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                  color: AppColors.blue, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dono.nomeCompleto,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (dono.localidade.isNotEmpty)
                  Text(dono.localidade,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Text('Responsável',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionButton(PetDetail pet, bool isOwner, AuthProvider auth) {
    if (isOwner) {
      return _VerInteressadosButton(petId: pet.id);
    }

    if (!auth.isAuthenticated) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.login, color: AppColors.orange),
          label: const Text('Entre para adotar',
              style: TextStyle(color: AppColors.orange, fontSize: 16)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: AppColors.orange, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () => context.push('/login'),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: _enviandoInteresse
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.favorite_border, color: Colors.white),
        label: Text(
          _enviandoInteresse ? 'Enviando...' : 'Quero adotar',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        onPressed: _enviandoInteresse ? null : () => _onQueroAdotar(pet.id, auth.token!),
      ),
    );
  }

  Future<void> _onQueroAdotar(int petId, String token) async {
    setState(() => _enviandoInteresse = true);
    try {
      await context.read<PetProvider>().registrarInteresse(petId, token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interesse registrado! O responsável foi notificado.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _enviandoInteresse = false);
    }
  }
}

// ── Botão "Ver interessados" (dono) ──────────────────────────────────────────

class _VerInteressadosButton extends StatelessWidget {
  final int petId;
  const _VerInteressadosButton({required this.petId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.people_outline, color: Colors.white),
        label: const Text('Ver interessados',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        onPressed: () => _mostrarInteressados(context),
      ),
    );
  }

  void _mostrarInteressados(BuildContext context) {
    final auth = context.read<AuthProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _InteressadosSheet(petId: petId, token: auth.token!),
    );
  }
}

class _InteressadosSheet extends StatefulWidget {
  final int petId;
  final String token;
  const _InteressadosSheet({required this.petId, required this.token});

  @override
  State<_InteressadosSheet> createState() => _InteressadosSheetState();
}

class _InteressadosSheetState extends State<_InteressadosSheet> {
  List<InteressadoInfo>? _lista;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final lista = await context
          .read<PetProvider>()
          .listarInteressados(widget.petId, widget.token);
      if (mounted) setState(() { _lista = lista; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _lista = []; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Interessados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: AppColors.blue))
          else if (_lista!.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Nenhum interessado ainda.',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...(_lista!.map((i) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.blue.withValues(alpha: 0.15),
                    child: Text(i.nome.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: AppColors.blue)),
                  ),
                  title: Text(i.nomeCompleto,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(i.email,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ))),
        ],
      ),
    );
  }
}

// ── Widgets compartilhados ────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  final String? fotoUrl;
  const _HeroImage({this.fotoUrl});

  @override
  Widget build(BuildContext context) {
    if (fotoUrl != null && fotoUrl!.startsWith('http')) {
      return Image.network(
        fotoUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.blue.withValues(alpha: 0.12),
      child: const Center(
        child: Icon(Icons.pets, size: 80, color: AppColors.blue),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
