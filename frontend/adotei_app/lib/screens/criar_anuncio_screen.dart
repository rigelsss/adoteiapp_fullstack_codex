import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/pet_provider.dart';

class CriarAnuncioScreen extends StatefulWidget {
  const CriarAnuncioScreen({super.key});

  @override
  State<CriarAnuncioScreen> createState() => _CriarAnuncioScreenState();
}

class _CriarAnuncioScreenState extends State<CriarAnuncioScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeCtrl = TextEditingController();
  final _racaCtrl = TextEditingController();
  final _idadeCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _fotoUrlCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _estadoCtrl = TextEditingController();

  String? _especie;
  String? _porte;

  static const _especies = ['cão', 'gato', 'coelho', 'pássaro', 'outro'];
  static const _portes = ['pequeno', 'médio', 'grande'];

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _racaCtrl.dispose();
    _idadeCtrl.dispose();
    _descricaoCtrl.dispose();
    _fotoUrlCtrl.dispose();
    _cidadeCtrl.dispose();
    _estadoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Novo anúncio',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<PetProvider>(
        builder: (_, provider, __) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Nome do pet *'),
                  _textField(
                    controller: _nomeCtrl,
                    hint: 'Ex: Rex',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 16),

                  _label('Espécie *'),
                  _dropdownField(
                    value: _especie,
                    items: _especies,
                    hint: 'Selecione a espécie',
                    onChanged: (v) => setState(() => _especie = v),
                    validator: (v) => v == null ? 'Selecione a espécie' : null,
                  ),
                  const SizedBox(height: 16),

                  _label('Raça'),
                  _textField(controller: _racaCtrl, hint: 'Ex: Labrador'),
                  const SizedBox(height: 16),

                  _label('Porte'),
                  _dropdownField(
                    value: _porte,
                    items: _portes,
                    hint: 'Selecione o porte',
                    onChanged: (v) => setState(() => _porte = v),
                  ),
                  const SizedBox(height: 16),

                  _label('Idade (em meses)'),
                  _textField(
                    controller: _idadeCtrl,
                    hint: 'Ex: 24',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),

                  _label('Descrição'),
                  _textField(
                    controller: _descricaoCtrl,
                    hint: 'Conte um pouco sobre o pet...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),

                  _label('URL da foto'),
                  _textField(
                    controller: _fotoUrlCtrl,
                    hint: 'https://...',
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),

                  _label('Cidade'),
                  _textField(controller: _cidadeCtrl, hint: 'Ex: São Paulo'),
                  const SizedBox(height: 16),

                  _label('Estado (UF)'),
                  _textField(
                    controller: _estadoCtrl,
                    hint: 'Ex: SP',
                    maxLength: 2,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                      _UpperCaseFormatter(),
                    ],
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: provider.isCriandoPet ? null : _submit,
                      child: provider.isCriandoPet
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Publicar anúncio',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final token = context.read<AuthProvider>().token!;
    final idadeRaw = _idadeCtrl.text.trim();

    try {
      final pet = await context.read<PetProvider>().cadastrarPet(
            nome: _nomeCtrl.text.trim(),
            especie: _especie!,
            raca: _racaCtrl.text.trim().isEmpty ? null : _racaCtrl.text.trim(),
            idade: idadeRaw.isEmpty ? null : int.tryParse(idadeRaw),
            porte: _porte,
            descricao: _descricaoCtrl.text.trim().isEmpty
                ? null
                : _descricaoCtrl.text.trim(),
            fotoUrl: _fotoUrlCtrl.text.trim().isEmpty
                ? null
                : _fotoUrlCtrl.text.trim(),
            cidade: _cidadeCtrl.text.trim().isEmpty
                ? null
                : _cidadeCtrl.text.trim(),
            estado: _estadoCtrl.text.trim().isEmpty
                ? null
                : _estadoCtrl.text.trim(),
            token: token,
          );

      if (!mounted) return;
      context.go('/pets/${pet.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    }
  }

  // ── Helpers de UI ────────────────────────────────────────────────────────────

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        counterText: '',
      ),
    );
  }

  Widget _dropdownField({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
      ),
      hint: Text(hint, style: const TextStyle(color: Colors.grey)),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(_capitalize(e)),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}

// ── Formatter para caixa alta no campo UF ────────────────────────────────────

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
          TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
