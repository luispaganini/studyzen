namespace StudyZen.Api.Models;

public class RegistroHumor
{
    public int Id { get; set; }
    public int Nivel { get; set; } // 1 a 5
    public string Emoji { get; set; } = string.Empty;
    public string? Sentimento { get; set; }
    public DateTime DataRegistro { get; set; } = DateTime.UtcNow;
}

