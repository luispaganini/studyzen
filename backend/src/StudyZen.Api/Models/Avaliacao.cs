namespace StudyZen.Api.Models;

public class Subtarefa
{
    public int Id { get; set; }
    public int AvaliacaoId { get; set; }
    public Avaliacao? Avaliacao { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public bool Concluida { get; set; }
}

public class Avaliacao
{
    public int Id { get; set; }
    public int DisciplinaId { get; set; }
    public Disciplina? Disciplina { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string Tipo { get; set; } = "Prova";
    public DateTime DataEntrega { get; set; }
    public DateTime CriadoEm { get; set; } = DateTime.UtcNow;
    public List<Subtarefa> Subtarefas { get; set; } = [];
}

