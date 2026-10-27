class Subtarefa {
  final int? id;
  final String titulo;
  final bool concluida;

  const Subtarefa({
    this.id,
    required this.titulo,
    this.concluida = false,
  });

  factory Subtarefa.fromJson(Map<String, dynamic> json) => Subtarefa(
        id: json['id'] as int?,
        titulo: (json['titulo'] as String?) ?? '',
        concluida: (json['concluida'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'titulo': titulo,
        'concluida': concluida,
      };

  Subtarefa copyWith({int? id, String? titulo, bool? concluida}) => Subtarefa(
        id: id ?? this.id,
        titulo: titulo ?? this.titulo,
        concluida: concluida ?? this.concluida,
      );
}

class Avaliacao {
  final int id;
  final int disciplinaId;
  final String? disciplinaNome;
  final String titulo;
  final String tipo;
  final DateTime dataEntrega;
  final DateTime criadoEm;
  final List<Subtarefa> subtarefas;

  const Avaliacao({
    required this.id,
    required this.disciplinaId,
    this.disciplinaNome,
    required this.titulo,
    required this.tipo,
    required this.dataEntrega,
    required this.criadoEm,
    this.subtarefas = const [],
  });

  factory Avaliacao.fromJson(Map<String, dynamic> json) => Avaliacao(
        id: json['id'] as int,
        disciplinaId: json['disciplinaId'] as int,
        disciplinaNome: json['disciplinaNome'] as String?,
        titulo: (json['titulo'] as String?) ?? '',
        tipo: (json['tipo'] as String?) ?? 'Prova',
        dataEntrega: DateTime.parse(json['dataEntrega'] as String),
        criadoEm: DateTime.parse(json['criadoEm'] as String),
        subtarefas: (json['subtarefas'] as List<dynamic>?)
                ?.map((e) => Subtarefa.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'disciplinaId': disciplinaId,
        'disciplinaNome': disciplinaNome,
        'titulo': titulo,
        'tipo': tipo,
        'dataEntrega': dataEntrega.toIso8601String(),
        'criadoEm': criadoEm.toIso8601String(),
        'subtarefas': subtarefas.map((s) => s.toJson()).toList(),
      };
}

