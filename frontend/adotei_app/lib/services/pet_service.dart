import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/pet.dart';

class PetException implements Exception {
  final String message;
  const PetException(this.message);
  @override
  String toString() => message;
}

class PetService {
  Future<List<Pet>> listarPets({
    String? q,
    String? especie,
    String? porte,
    String? cidade,
    String? estado,
    int? donoId,
  }) async {
    final params = <String, String>{};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (especie != null) params['especie'] = especie;
    if (porte != null) params['porte'] = porte;
    if (cidade != null) params['cidade'] = cidade;
    if (estado != null) params['estado'] = estado;
    if (donoId != null) params['dono_id'] = donoId.toString();

    final uri = Uri.parse('$kApiBase/pets')
        .replace(queryParameters: params.isEmpty ? null : params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => Pet.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw PetException('Erro ao carregar pets (${response.statusCode})');
  }

  Future<PetDetail> buscarPet(int id) async {
    final response = await http.get(Uri.parse('$kApiBase/pets/$id'));
    if (response.statusCode == 200) {
      return PetDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw PetException('Pet não encontrado');
  }

  Future<void> registrarInteresse(int petId, String token) async {
    final response = await http.post(
      Uri.parse('$kApiBase/pets/$petId/interesse'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 201) return;
    throw PetException(_extrairDetalhe(response.body, 'Erro ao registrar interesse'));
  }

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
    final body = <String, dynamic>{'nome': nome, 'especie': especie};
    if (raca != null && raca.isNotEmpty) body['raca'] = raca;
    if (idade != null) body['idade'] = idade;
    if (porte != null) body['porte'] = porte;
    if (descricao != null && descricao.isNotEmpty) body['descricao'] = descricao;
    if (fotoUrl != null && fotoUrl.isNotEmpty) body['foto_url'] = fotoUrl;
    if (cidade != null && cidade.isNotEmpty) body['cidade'] = cidade;
    if (estado != null && estado.isNotEmpty) body['estado'] = estado;

    final response = await http.post(
      Uri.parse('$kApiBase/pets'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 201) {
      return Pet.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw PetException(_extrairDetalhe(response.body, 'Erro ao cadastrar pet'));
  }

  Future<void> deletarPet(int petId, String token) async {
    final response = await http.delete(
      Uri.parse('$kApiBase/pets/$petId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 204) return;
    throw PetException(_extrairDetalhe(response.body, 'Erro ao remover pet'));
  }

  Future<List<InteressadoInfo>> listarInteressados(int petId, String token) async {
    final response = await http.get(
      Uri.parse('$kApiBase/pets/$petId/interessados'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => InteressadoInfo.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw PetException('Erro ao carregar interessados');
  }

  String _extrairDetalhe(String body, String fallback) {
    try {
      return jsonDecode(body)['detail'] as String;
    } catch (_) {
      return fallback;
    }
  }
}
