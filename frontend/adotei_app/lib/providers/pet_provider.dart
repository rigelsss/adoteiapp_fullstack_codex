import 'package:flutter/foundation.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';

class PetProvider extends ChangeNotifier {
  final PetService _service = PetService();

  // ── Lista principal (home) ───────────────────────────────────────────────────
  List<Pet> _pets = [];
  List<Pet> _petsProximos = [];
  String? _filtroEspecie;
  String _busca = '';
  bool _loading = false;
  bool _loadingProximos = false;
  String? _erro;

  List<Pet> get pets => _pets;
  List<Pet> get petsProximos => _petsProximos;
  String? get filtroEspecie => _filtroEspecie;
  bool get isLoading => _loading;
  bool get isLoadingProximos => _loadingProximos;
  String? get erro => _erro;

  Future<void> carregarPets() async {
    _loading = true;
    _erro = null;
    notifyListeners();
    try {
      _pets = await _service.listarPets(
        q: _busca.isEmpty ? null : _busca,
        especie: _filtroEspecie,
      );
    } catch (e) {
      _erro = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> carregarProximos({String? cidade, String? estado}) async {
    if (cidade == null && estado == null) return;
    _loadingProximos = true;
    notifyListeners();
    try {
      _petsProximos = await _service.listarPets(cidade: cidade, estado: estado);
    } catch (_) {
      _petsProximos = [];
    } finally {
      _loadingProximos = false;
      notifyListeners();
    }
  }

  void setFiltroEspecie(String? especie) {
    _filtroEspecie = especie;
    carregarPets();
  }

  void setBusca(String busca) {
    _busca = busca;
    carregarPets();
  }

  // ── Detalhe do pet ───────────────────────────────────────────────────────────
  PetDetail? _petDetalhe;
  bool _loadingDetalhe = false;

  PetDetail? get petDetalhe => _petDetalhe;
  bool get isLoadingDetalhe => _loadingDetalhe;

  Future<void> carregarDetalhe(int id) async {
    _petDetalhe = null;
    _loadingDetalhe = true;
    notifyListeners();
    try {
      _petDetalhe = await _service.buscarPet(id);
    } finally {
      _loadingDetalhe = false;
      notifyListeners();
    }
  }

  // ── Perfil do usuário ────────────────────────────────────────────────────────
  List<Pet> _meusPets = [];
  bool _loadingMeusPets = false;

  List<Pet> get meusPets => _meusPets;
  bool get isLoadingMeusPets => _loadingMeusPets;

  Future<void> carregarMeusPets(int donoId) async {
    _loadingMeusPets = true;
    notifyListeners();
    try {
      _meusPets = await _service.listarPets(donoId: donoId);
    } catch (_) {
      _meusPets = [];
    } finally {
      _loadingMeusPets = false;
      notifyListeners();
    }
  }

  // Throws PetException on failure.
  Future<void> deletarPet(int petId, String token) async {
    await _service.deletarPet(petId, token);
    _meusPets.removeWhere((p) => p.id == petId);
    _pets.removeWhere((p) => p.id == petId);
    notifyListeners();
  }

  // ── Ações ────────────────────────────────────────────────────────────────────

  // Throws PetException on failure — caller shows SnackBar with message.
  Future<void> registrarInteresse(int petId, String token) =>
      _service.registrarInteresse(petId, token);

  Future<List<InteressadoInfo>> listarInteressados(int petId, String token) =>
      _service.listarInteressados(petId, token);

  bool _criandoPet = false;
  bool get isCriandoPet => _criandoPet;

  // Returns the created Pet or rethrows PetException on failure.
  Future<Pet> cadastrarPet({
    required String nome,
    required String especie,
    String? raca,
    int? idade,
    String? porte,
    String? descricao,
    String? fotoUrl,
    String? cidade,
    String? estado,
    required String token,
  }) async {
    _criandoPet = true;
    notifyListeners();
    try {
      final pet = await _service.cadastrarPet(
        nome: nome,
        especie: especie,
        raca: raca,
        idade: idade,
        porte: porte,
        descricao: descricao,
        fotoUrl: fotoUrl,
        cidade: cidade,
        estado: estado,
        token: token,
      );
      carregarPets(); // refresh list in background
      return pet;
    } catch (e) {
      rethrow;
    } finally {
      _criandoPet = false;
      notifyListeners();
    }
  }
}
