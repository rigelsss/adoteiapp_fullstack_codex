import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  // Step 1
  final _nomeCtrl = TextEditingController();
  final _sobrenomeCtrl = TextEditingController();
  final _perguntaCtrl = TextEditingController();
  final _respostaCtrl = TextEditingController();

  // Step 2
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();

  bool _loading = false;
  bool _obscureSenha = true;
  bool _obscureConfirmar = true;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nomeCtrl.dispose();
    _sobrenomeCtrl.dispose();
    _perguntaCtrl.dispose();
    _respostaCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  void _irParaStep2() {
    if (_nomeCtrl.text.trim().isEmpty ||
        _sobrenomeCtrl.text.trim().isEmpty ||
        _perguntaCtrl.text.trim().isEmpty ||
        _respostaCtrl.text.trim().isEmpty) {
      _showError('Preencha todos os campos');
      return;
    }
    _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _page = 1);
  }

  Future<void> _cadastrar() async {
    if (_emailCtrl.text.trim().isEmpty ||
        _senhaCtrl.text.isEmpty ||
        _confirmarCtrl.text.isEmpty) {
      _showError('Preencha todos os campos');
      return;
    }
    if (_senhaCtrl.text != _confirmarCtrl.text) {
      _showError('As senhas não coincidem');
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().register(
            nome: _nomeCtrl.text.trim(),
            sobrenome: _sobrenomeCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            senha: _senhaCtrl.text,
            perguntaSeguranca: _perguntaCtrl.text.trim(),
            respostaSeguranca: _respostaCtrl.text.trim(),
          );
      if (mounted) context.go('/home');
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _page == 1) {
          _pageCtrl.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          setState(() => _page = 0);
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Conteúdo em páginas
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildStep1(), _buildStep2()],
              ),
            ),
            // Navegação
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavButton(
                    icon: Icons.arrow_back,
                    onTap: _page == 0
                        ? () => context.go('/login')
                        : () {
                            _pageCtrl.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                            setState(() => _page = 0);
                          },
                  ),
                  // Dots
                  Row(
                    children: List.generate(2, (i) => _Dot(active: _page == i)),
                  ),
                  _page == 0
                      ? _NavButton(icon: Icons.arrow_forward, onTap: _irParaStep2)
                      : _NavButton(
                          icon: _loading ? null : Icons.check,
                          onTap: _loading ? () {} : _cadastrar,
                          loading: _loading,
                        ),
                ],
              ),
            ),
            // Logo rodapé
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Adotei',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22)),
                    SizedBox(width: 8),
                    Icon(Icons.pets, color: AppColors.orange, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),   // Scaffold
    );   // PopScope
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crie sua\nConta',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: AppColors.orange,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Você está a poucos passos de\nencontrar seu novo melhor amigo!',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 32),
          _Label('Nome'),
          _Field(controller: _nomeCtrl),
          const SizedBox(height: 20),
          _Label('Sobrenome'),
          _Field(controller: _sobrenomeCtrl),
          const SizedBox(height: 20),
          _Label('Pergunta de segurança'),
          _Field(
            controller: _perguntaCtrl,
            hint: 'Ex: Nome do seu primeiro pet?',
          ),
          const SizedBox(height: 20),
          _Label('Resposta'),
          _Field(controller: _respostaCtrl),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crie sua\nConta',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: AppColors.orange,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 32),
          _Label('Email'),
          _Field(controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 20),
          _Label('Senha'),
          _Field(
            controller: _senhaCtrl,
            obscureText: _obscureSenha,
            suffixIcon: IconButton(
              icon: Icon(_obscureSenha ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.blue),
              onPressed: () => setState(() => _obscureSenha = !_obscureSenha),
            ),
          ),
          const SizedBox(height: 20),
          _Label('Confirmar senha'),
          _Field(
            controller: _confirmarCtrl,
            obscureText: _obscureConfirmar,
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmar ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.blue),
              onPressed: () => setState(() => _obscureConfirmar = !_obscureConfirmar),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets locais ──────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? hint;

  const _Field({
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback onTap;
  final bool loading;

  const _NavButton({required this.icon, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 12 : 8,
      height: active ? 12 : 8,
      decoration: BoxDecoration(
        color: active ? AppColors.blue : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}
