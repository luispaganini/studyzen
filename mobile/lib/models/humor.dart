class RegistroHumor {
  final int id;
  final int nivel;
  final String emoji;
  final String? sentimento;
  final DateTime dataRegistro;

  const RegistroHumor({
    required this.id,
    required this.nivel,
    required this.emoji,
    this.sentimento,
    required this.dataRegistro,
  });

  factory RegistroHumor.fromJson(Map<String, dynamic> json) => RegistroHumor(
        id: json['id'] as int,
        nivel: json['nivel'] as int,
        emoji: (json['emoji'] as String?) ?? '😐',
        sentimento: json['sentimento'] as String?,
        dataRegistro: DateTime.parse(json['dataRegistro'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nivel': nivel,
        'emoji': emoji,
        'sentimento': sentimento,
        'dataRegistro': dataRegistro.toIso8601String(),
      };
}

