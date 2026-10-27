using System.ComponentModel.DataAnnotations;
using StudyZen.Api.Models;

namespace StudyZen.Api.Dtos;

public record SubtarefaDto(int? Id, string Titulo, bool Concluida);

public record CreateAvaliacaoRequest(
    [Required(ErrorMessage = "A disciplina é obrigatória.")]
    int DisciplinaId,
    [Required(AllowEmptyStrings = false, ErrorMessage = "O título é obrigatório.")]
    [StringLength(120, MinimumLength = 1, ErrorMessage = "O título deve ter entre 1 e 120 caracteres.")]
    string? Titulo,
    [Required(AllowEmptyStrings = false, ErrorMessage = "O tipo é obrigatório.")]
    string? Tipo,
    [Required(ErrorMessage = "A data de entrega é obrigatória.")]
    DateTime DataEntrega,
    List<SubtarefaDto>? Subtarefas);

public record DecomposicaoResponse(string Tipo, IReadOnlyList<string> SubtarefasSugeridas);

public record AvaliacaoResponse(
    int Id,
    int DisciplinaId,
    string? DisciplinaNome,
    string Titulo,
    string Tipo,
    DateTime DataEntrega,
    DateTime CriadoEm,
    IReadOnlyList<SubtarefaDto> Subtarefas)
{
    public static AvaliacaoResponse From(Avaliacao a) =>
        new(
            a.Id,
            a.DisciplinaId,
            a.Disciplina?.Nome,
            a.Titulo,
            a.Tipo,
            a.DataEntrega,
            a.CriadoEm,
            a.Subtarefas.Select(s => new SubtarefaDto(s.Id, s.Titulo, s.Concluida)).ToList()
        );
}

