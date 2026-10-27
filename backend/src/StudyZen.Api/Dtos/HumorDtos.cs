using System.ComponentModel.DataAnnotations;
using StudyZen.Api.Models;

namespace StudyZen.Api.Dtos;

public record CreateHumorRequest(
    [Range(1, 5, ErrorMessage = "O nível de humor deve estar entre 1 e 5.")]
    int Nivel,
    string? Emoji,
    string? Sentimento);

public record HumorResponse(int Id, int Nivel, string Emoji, string? Sentimento, DateTime DataRegistro)
{
    public static HumorResponse From(RegistroHumor h) =>
        new(h.Id, h.Nivel, h.Emoji, h.Sentimento, h.DataRegistro);
}

