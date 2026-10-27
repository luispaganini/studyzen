class Disciplina {
  final int id;
  final String nome;
  final int cargaHoraria;
  final DateTime criadoEm;

  const Disciplina({
    required this.id,
    required this.nome,
    required this.cargaHoraria,
    required this.criadoEm,
  });

  factory Disciplina.fromJson(Map<String, dynamic> json) => Disciplina(
        id: json['id'] as int,
        nome: json['nome'] as String,
        cargaHoraria: json['cargaHoraria'] as int,
        criadoEm: DateTime.parse(json['criadoEm'] as String),
      );
}
