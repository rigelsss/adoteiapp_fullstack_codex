class Pet {
  final int id;
  final String nome;
  final String especie;
  final String? raca;
  final int? idade;
  final String? porte;
  final String? descricao;
  final String? fotoUrl;
  final String? cidade;
  final String? estado;
  final String status;
  final int donoId;

  const Pet({
    required this.id,
    required this.nome,
    required this.especie,
    this.raca,
    this.idade,
    this.porte,
    this.descricao,
    this.fotoUrl,
    this.cidade,
    this.estado,
    required this.status,
    required this.donoId,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as int,
      nome: json['nome'] as String,
      especie: json['especie'] as String,
      raca: json['raca'] as String?,
      idade: json['idade'] as int?,
      porte: json['porte'] as String?,
      descricao: json['descricao'] as String?,
      fotoUrl: json['foto_url'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      status: json['status'] as String,
      donoId: json['dono_id'] as int,
    );
  }

  String get idadeFormatada {
    if (idade == null) return '';
    if (idade! < 12) return '$idade ${idade == 1 ? 'mês' : 'meses'}';
    final anos = idade! ~/ 12;
    final meses = idade! % 12;
    if (meses == 0) return '$anos ${anos == 1 ? 'ano' : 'anos'}';
    return '$anos ${anos == 1 ? 'ano' : 'anos'} e $meses ${meses == 1 ? 'mês' : 'meses'}';
  }

  String get localidade {
    if (cidade != null && estado != null) return '$cidade, $estado';
    if (cidade != null) return cidade!;
    if (estado != null) return estado!;
    return '';
  }
}

// ── Detalhe do dono ───────────────────────────────────────────────────────────

class DonoInfo {
  final int id;
  final String nome;
  final String sobrenome;
  final String? cidade;
  final String? estado;

  const DonoInfo({
    required this.id,
    required this.nome,
    required this.sobrenome,
    this.cidade,
    this.estado,
  });

  factory DonoInfo.fromJson(Map<String, dynamic> json) {
    return DonoInfo(
      id: json['id'] as int,
      nome: json['nome'] as String,
      sobrenome: json['sobrenome'] as String,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
    );
  }

  String get nomeCompleto => '$nome $sobrenome';

  String get localidade {
    if (cidade != null && estado != null) return '$cidade, $estado';
    if (cidade != null) return cidade!;
    if (estado != null) return estado!;
    return '';
  }
}

// ── Pet com detalhe do dono (GET /pets/{id}) ──────────────────────────────────

class PetDetail extends Pet {
  final DonoInfo dono;

  const PetDetail({
    required super.id,
    required super.nome,
    required super.especie,
    super.raca,
    super.idade,
    super.porte,
    super.descricao,
    super.fotoUrl,
    super.cidade,
    super.estado,
    required super.status,
    required super.donoId,
    required this.dono,
  });

  factory PetDetail.fromJson(Map<String, dynamic> json) {
    return PetDetail(
      id: json['id'] as int,
      nome: json['nome'] as String,
      especie: json['especie'] as String,
      raca: json['raca'] as String?,
      idade: json['idade'] as int?,
      porte: json['porte'] as String?,
      descricao: json['descricao'] as String?,
      fotoUrl: json['foto_url'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      status: json['status'] as String,
      donoId: json['dono_id'] as int,
      dono: DonoInfo.fromJson(json['dono'] as Map<String, dynamic>),
    );
  }
}

// ── Interessado (GET /pets/{id}/interessados) ─────────────────────────────────

class InteressadoInfo {
  final int usuarioId;
  final String nome;
  final String sobrenome;
  final String email;

  const InteressadoInfo({
    required this.usuarioId,
    required this.nome,
    required this.sobrenome,
    required this.email,
  });

  factory InteressadoInfo.fromJson(Map<String, dynamic> json) {
    return InteressadoInfo(
      usuarioId: json['usuario_id'] as int,
      nome: json['nome'] as String,
      sobrenome: json['sobrenome'] as String,
      email: json['email'] as String,
    );
  }

  String get nomeCompleto => '$nome $sobrenome';
}
