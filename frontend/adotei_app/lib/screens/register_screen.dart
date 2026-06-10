import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _perguntaSeguranca = 'Qual o nome do seu primeiro pet?';
  static const _senhaMinLength = 6;
  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  final _formKey = GlobalKey<FormState>();

  final _nomeCtrl = TextEditingController();
  final _sobrenomeCtrl = TextEditingController();
  final _respostaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();

  bool _loading = false;
  bool _obscureSenha = true;
  bool _obscureConfirmar = true;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _sobrenomeCtrl.dispose();
    _respostaCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().register(
            nome: _nomeCtrl.text.trim(),
            sobrenome: _sobrenomeCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            senha: _senhaCtrl.text,
            perguntaSeguranca: _perguntaSeguranca,
            respostaSeguranca: _respostaCtrl.text.trim(),
          );
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

  void _voltarParaLogin() {
    context.go('/login');
  }

  String? _validarObrigatorio(String? value, String mensagem) {
    if (value == null || value.trim().isEmpty) {
      return mensagem;
    }
    return null;
  }

  String? _validarEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Informe seu email';
    }
    if (!_emailRegex.hasMatch(email)) {
      return 'Informe um email válido';
    }
    return null;
  }

  String? _validarSenha(String? value) {
    final senha = value ?? '';
    if (senha.isEmpty) {
      return 'Informe uma senha';
    }
    if (senha.length < _senhaMinLength) {
      return 'A senha deve ter pelo menos $_senhaMinLength caracteres';
    }
    return null;
  }

  String? _validarConfirmarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha';
    }
    if (value != _senhaCtrl.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _voltarParaLogin();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9BC62),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final topInset = MediaQuery.of(context).padding.top;

            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _RegisterTopBar(
                    topInset: topInset,
                    onBack: _voltarParaLogin,
                  ),
                ),
                Positioned(
                  top: topInset + 36,
                  left: width * 0.05,
                  right: width * 0.05,
                  child: const _RegisterHero(),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: height * 0.72,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        width * 0.05,
                        26,
                        width * 0.05,
                        24,
                      ),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Nome'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _nomeCtrl,
                              validator: (v) => _validarObrigatorio(v, 'Informe seu nome'),
                            ),
                            const SizedBox(height: 14),
                            const _FieldLabel('Sobrenome'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _sobrenomeCtrl,
                              validator: (v) => _validarObrigatorio(v, 'Informe seu sobrenome'),
                            ),
                            const SizedBox(height: 14),
                            const _FieldLabel('Email'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validarEmail,
                            ),
                            const SizedBox(height: 14),
                            const _FieldLabel('Pergunta de segurança'),
                            const SizedBox(height: 8),
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                _perguntaSeguranca,
                                style: TextStyle(
                                  fontFamily: 'AdigianaUI',
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _InputField(
                              controller: _respostaCtrl,
                              validator: (v) =>
                                  _validarObrigatorio(v, 'Informe a resposta de segurança'),
                            ),
                            const SizedBox(height: 14),
                            const _FieldLabel('Senha'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _senhaCtrl,
                              obscureText: _obscureSenha,
                              validator: _validarSenha,
                              onChanged: (_) => _formKey.currentState?.validate(),
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
                            const SizedBox(height: 14),
                            const _FieldLabel('Confirmar senha'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _confirmarCtrl,
                              obscureText: _obscureConfirmar,
                              validator: _validarConfirmarSenha,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmar ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.blue,
                                ),
                                onPressed: () {
                                  setState(() => _obscureConfirmar = !_obscureConfirmar);
                                },
                              ),
                            ),
                            const SizedBox(height: 22),
                            _PrimaryActionButton(
                              label: 'Criar conta',
                              onPressed: _loading ? null : _cadastrar,
                              loading: _loading,
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
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

class _RegisterTopBar extends StatelessWidget {
  final double topInset;
  final VoidCallback onBack;

  const _RegisterTopBar({
    required this.topInset,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, topInset + 4, 12, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterHero extends StatelessWidget {
  const _RegisterHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 36),
              child: _OutlinedHeading(text: 'Crie sua\nconta'),
            ),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: SizedBox(
              width: 190,
              height: 210,
              child: Stack(
                children: const [
                  _PawPrint(top: 0, right: 0, size: 43, angle: 0.32),
                  _PawPrint(top: 14, right: 48, size: 43, angle: -0.32),
                  _PawPrint(top: 56, right: 22, size: 43, angle: 0.32),
                  _PawPrint(top: 70, right: 74, size: 43, angle: -0.32),
                  _PawPrint(top: 112, right: 0, size: 43, angle: 0.32),
                  _PawPrint(top: 126, right: 48, size: 43, angle: -0.32),
                ],
              ),
            ),
          ),
        ],
      ),
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
        fontSize: 16,
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
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.onChanged,
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
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
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
