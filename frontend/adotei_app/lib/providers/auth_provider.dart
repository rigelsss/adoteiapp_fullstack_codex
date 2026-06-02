import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  User? _user;
  String? _token;
  bool _isGuest = false;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isGuest => _isGuest;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('auth_token');
    if (saved == null) return;
    try {
      final user = await _service.getMe(saved);
      _token = saved;
      _user = user;
      notifyListeners();
    } catch (_) {
      await prefs.remove('auth_token');
    }
  }

  Future<void> login(String email, String senha) async {
    final token = await _service.login(email, senha);
    final user = await _service.getMe(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
    _user = user;
    _isGuest = false;
    notifyListeners();
  }

  Future<void> register({
    required String nome,
    required String sobrenome,
    required String email,
    required String senha,
    required String perguntaSeguranca,
    required String respostaSeguranca,
  }) async {
    await _service.register(
      nome: nome,
      sobrenome: sobrenome,
      email: email,
      senha: senha,
      perguntaSeguranca: perguntaSeguranca,
      respostaSeguranca: respostaSeguranca,
    );
    await login(email, senha);
  }

  void entrarComoVisitante() {
    _isGuest = true;
    _token = null;
    _user = null;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    _user = null;
    _isGuest = false;
    notifyListeners();
  }
}
