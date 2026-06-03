import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _loading = false;
  bool _obscureSenha = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final senha = _senhaCtrl.text;
    if (email.isEmpty || senha.isEmpty) {
      _showError('Preencha todos os campos');
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().login(email, senha);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void _abrirRecuperarSenha() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _RecuperarSenhaSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabeçalho laranja
            Container(
              height: height * 0.42,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Patinhas decorativas
                    const Positioned(top: 16, right: 24, child: _Paw(size: 40, opacity: 0.5)),
                    const Positioned(top: 50, right: 64, child: _Paw(size: 32, opacity: 0.4)),
                    const Positioned(top: 80, right: 32, child: _Paw(size: 28, opacity: 0.3)),
                    const Positioned(top: 110, right: 70, child: _Paw(size: 24, opacity: 0.3)),
                    // Texto
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Bem-\nvindo de\nvolta!',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Card de formulário
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    _InputField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    const Text('Senha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _senhaCtrl,
                      obscureText: _obscureSenha,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureSenha ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.blue),
                        onPressed: () => setState(() => _obscureSenha = !_obscureSenha),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _abrirRecuperarSenha,
                        child: const Text(
                          'Esqueci minha senha',
                          style: TextStyle(color: AppColors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        child: _loading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Entrar',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Não tem conta? '),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: const Text(
                            'Criar conta',
                            style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recuperar senha (bottom sheet) ─────────────────────────────────────────

class _RecuperarSenhaSheet extends StatefulWidget {
  const _RecuperarSenhaSheet();

  @override
  State<_RecuperarSenhaSheet> createState() => _RecuperarSenhaSheetState();
}

class _RecuperarSenhaSheetState extends State<_RecuperarSenhaSheet> {
  final _service = AuthService();
  final _emailCtrl = TextEditingController();
  final _respostaCtrl = TextEditingController();
  final _novaSenhaCtrl = TextEditingController();

  int _step = 0; // 0: email, 1: pergunta+nova senha
  String _pergunta = '';
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _respostaCtrl.dispose();
    _novaSenhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscarPergunta() async {
    setState(() => _loading = true);
    try {
      final p = await _service.getPerguntaSeguranca(_emailCtrl.text.trim());
      setState(() { _pergunta = p; _step = 1; });
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _redefinir() async {
    setState(() => _loading = true);
    try {
      await _service.redefinirSenha(
        email: _emailCtrl.text.trim(),
        resposta: _respostaCtrl.text.trim(),
        novaSenha: _novaSenhaCtrl.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha redefinida com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
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
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24,
          MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recuperar senha',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (_step == 0) ...[
            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _InputField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _BotaoPrimario(label: 'Continuar', onTap: _buscarPergunta, loading: _loading),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_pergunta, style: const TextStyle(fontSize: 15)),
            ),
            const SizedBox(height: 16),
            const Text('Resposta', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _InputField(controller: _respostaCtrl),
            const SizedBox(height: 16),
            const Text('Nova senha', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _InputField(controller: _novaSenhaCtrl, obscureText: true),
            const SizedBox(height: 16),
            _BotaoPrimario(label: 'Redefinir senha', onTap: _redefinir, loading: _loading),
          ],
        ],
      ),
    );
  }
}

// ── Widgets compartilhados ──────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _InputField({
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.25),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

class _BotaoPrimario extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const _BotaoPrimario({required this.label, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
        ),
        child: loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _Paw extends StatelessWidget {
  final double size;
  final double opacity;
  const _Paw({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Icon(Icons.pets, size: size, color: Colors.white),
    );
  }
}
