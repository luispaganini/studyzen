namespace StudyZen.Api.Models;

public class Disciplina
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public int CargaHoraria { get; set; }
    public DateTime CriadoEm { get; set; } = DateTime.UtcNow;
}
