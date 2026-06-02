import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/user.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  Future<String> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$kApiBase/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['access_token'] as String;
    }
    throw AuthException(_detail(response, 'Email ou senha incorretos'));
  }

  Future<User> register({
    required String nome,
    required String sobrenome,
    required String email,
    required String senha,
    required String perguntaSeguranca,
    required String respostaSeguranca,
  }) async {
    final response = await http.post(
      Uri.parse('$kApiBase/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'sobrenome': sobrenome,
        'email': email,
        'senha': senha,
        'pergunta_seguranca': perguntaSeguranca,
        'resposta_seguranca': respostaSeguranca,
      }),
    );
    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw AuthException(_detail(response, 'Erro ao criar conta'));
  }

  Future<User> getMe(String token) async {
    final response = await http.get(
      Uri.parse('$kApiBase/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw AuthException('Sessão expirada');
  }

  Future<String> getPerguntaSeguranca(String email) async {
    final response = await http.post(
      Uri.parse('$kApiBase/auth/recuperar-senha/pergunta'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['pergunta'] as String;
    }
    throw AuthException(_detail(response, 'Email não encontrado'));
  }

  Future<void> redefinirSenha({
    required String email,
    required String resposta,
    required String novaSenha,
  }) async {
    final response = await http.post(
      Uri.parse('$kApiBase/auth/recuperar-senha/redefinir'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'resposta': resposta, 'nova_senha': novaSenha}),
    );
    if (response.statusCode != 200) {
      throw AuthException(_detail(response, 'Resposta incorreta'));
    }
  }

  String _detail(http.Response r, String fallback) {
    try {
      return (jsonDecode(r.body) as Map<String, dynamic>)['detail'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}
