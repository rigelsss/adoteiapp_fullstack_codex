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
      backgroundColor: Colors.transparent,
      builder: (_) => const _RecuperarSenhaSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9BC62),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    width * 0.05,
                    height * 0.09,
                    width * 0.05,
                    0,
                  ),
                  child: const _LoginHero(),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: height * 0.63,
                    padding: EdgeInsets.fromLTRB(
                      width * 0.05,
                      32,
                      width * 0.05,
                      24,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Email'),
                          const SizedBox(height: 10),
                          _InputField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 26),
                          const _FieldLabel('Senha'),
                          const SizedBox(height: 10),
                          _InputField(
                            controller: _senhaCtrl,
                            obscureText: _obscureSenha,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureSenha ? Icons.visibility_off : Icons.visibility,
                                color: AppColors.blue,
                              ),
                              onPressed: () {
                                setState(() => _obscureSenha = !_obscureSenha);
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _abrirRecuperarSenha,
                              child: const Text(
                                'Esqueci minha senha',
                                style: TextStyle(
                                  fontFamily: 'AdigianaUI',
                                  color: AppColors.blue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.blue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _PrimaryActionButton(
                            label: 'Entrar',
                            onPressed: _loading ? null : _login,
                            loading: _loading,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Não tem conta? ',
                                style: TextStyle(
                                  fontFamily: 'AdigianaUI',
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.push('/register'),
                                child: const Text(
                                  'Criar conta',
                                  style: TextStyle(
                                    fontFamily: 'AdigianaUI',
                                    color: AppColors.blue,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(top: 38),
            child: _OutlinedHeading(text: 'Bem vindo\nde volta!'),
          ),
        ),
        Positioned(
          top: -2,
          right: -4,
          child: SizedBox(
            width: 190,
            height: 230,
            child: Stack(
              children: const [
                _PawPrint(top: 0, right: 0, size: 43, angle: 0.32),
                _PawPrint(top: 14, right: 48, size: 43, angle: -0.32),
                _PawPrint(top: 56, right: 22, size: 43, angle: 0.32),
                _PawPrint(top: 70, right: 74, size: 43, angle: -0.32),
                _PawPrint(top: 112, right: 0, size: 43, angle: 0.32),
                _PawPrint(top: 126, right: 48, size: 43, angle: -0.32),
                _PawPrint(top: 168, right: 22, size: 43, angle: 0.32),
                _PawPrint(top: 182, right: 74, size: 43, angle: -0.32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OutlinedHeading extends StatelessWidget {
  final String text;

  const _OutlinedHeading({required this.text});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: 'AdigianaUI',
      fontSize: 52,
      fontWeight: FontWeight.w400,
      height: 1.0,
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

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'AdigianaUI',
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF6BC7F4), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF8ED5F4),
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: 'AdigianaUI',
          fontSize: 16,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const _PrimaryActionButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
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
          disabledBackgroundColor: const Color(0xFFF9BC62),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontFamily: 'AdigianaUI',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _PawPrint extends StatelessWidget {
  final double top;
  final double right;
  final double size;
  final double angle;

  const _PawPrint({
    required this.top,
    required this.right,
    required this.size,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      child: Transform.rotate(
        angle: angle,
        child: Stack(
          children: [
            Icon(
              Icons.pets,
              size: size,
              color: const Color(0xFF6BC7F4),
            ),
            Icon(
              Icons.pets,
              size: size - 4,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

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

  int _step = 0;
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
      final pergunta = await _service.getPerguntaSeguranca(_emailCtrl.text.trim());
      setState(() {
        _pergunta = pergunta;
        _step = 1;
      });
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
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
          const SnackBar(
            content: Text('Senha redefinida com sucesso!'),
            backgroundColor: Colors.green,
          ),
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recuperar senha',
              style: TextStyle(
                fontFamily: 'AdigianaUI',
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            if (_step == 0) ...[
              const _FieldLabel('Email'),
              const SizedBox(height: 10),
              _InputField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              _PrimaryActionButton(
                label: 'Continuar',
                onPressed: _loading ? null : _buscarPergunta,
                loading: _loading,
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _pergunta,
                  style: const TextStyle(
                    fontFamily: 'AdigianaUI',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Resposta'),
              const SizedBox(height: 10),
              _InputField(controller: _respostaCtrl),
              const SizedBox(height: 18),
              const _FieldLabel('Nova senha'),
              const SizedBox(height: 10),
              _InputField(controller: _novaSenhaCtrl, obscureText: true),
              const SizedBox(height: 18),
              _PrimaryActionButton(
                label: 'Redefinir senha',
                onPressed: _loading ? null : _redefinir,
                loading: _loading,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
