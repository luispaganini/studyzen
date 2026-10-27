using System.ComponentModel.DataAnnotations;
using StudyZen.Api.Models;

namespace StudyZen.Api.Dtos;

public record CreateDisciplinaRequest(
    [Required(AllowEmptyStrings = false, ErrorMessage = "O nome é obrigatório.")]
    [StringLength(120, MinimumLength = 1, ErrorMessage = "O nome deve ter entre 1 e 120 caracteres.")]
    string? Nome,
    [Range(1, 1000, ErrorMessage = "A carga horária deve estar entre 1 e 1000 horas.")]
    int CargaHoraria);

public record DisciplinaResponse(int Id, string Nome, int CargaHoraria, DateTime CriadoEm)
{
    public static DisciplinaResponse From(Disciplina d) => new(d.Id, d.Nome, d.CargaHoraria, d.CriadoEm);
}
