class User {
  final int id;
  final String nome;
  final String sobrenome;
  final String email;
  final String? cidade;
  final String? estado;

  const User({
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.email,
    this.cidade,
    this.estado,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        nome: json['nome'] as String,
        sobrenome: json['sobrenome'] as String,
        email: json['email'] as String,
        cidade: json['cidade'] as String?,
        estado: json['estado'] as String?,
      );

  String get nomeCompleto => '$nome $sobrenome';
}
