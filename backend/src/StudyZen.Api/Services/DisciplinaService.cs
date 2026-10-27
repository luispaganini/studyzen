using Microsoft.EntityFrameworkCore;
using StudyZen.Api.Data;
using StudyZen.Api.Dtos;
using StudyZen.Api.Models;

namespace StudyZen.Api.Services;

public interface IDisciplinaService
{
    Task<IReadOnlyList<DisciplinaResponse>> ListarAsync(CancellationToken ct = default);
    Task<DisciplinaResponse?> ObterAsync(int id, CancellationToken ct = default);
    Task<DisciplinaResponse> CriarAsync(CreateDisciplinaRequest request, CancellationToken ct = default);
}

public class DisciplinaService(AppDbContext db) : IDisciplinaService
{
    public async Task<IReadOnlyList<DisciplinaResponse>> ListarAsync(CancellationToken ct = default) =>
        await db.Disciplinas
            .AsNoTracking()
            .OrderBy(d => d.Nome)
            .Select(d => new DisciplinaResponse(d.Id, d.Nome, d.CargaHoraria, d.CriadoEm))
            .ToListAsync(ct);

    public async Task<DisciplinaResponse?> ObterAsync(int id, CancellationToken ct = default)
    {
        var disciplina = await db.Disciplinas.AsNoTracking().FirstOrDefaultAsync(d => d.Id == id, ct);
        return disciplina is null ? null : DisciplinaResponse.From(disciplina);
    }

    public async Task<DisciplinaResponse> CriarAsync(CreateDisciplinaRequest request, CancellationToken ct = default)
    {
        var disciplina = new Disciplina
        {
            Nome = request.Nome!.Trim(),
            CargaHoraria = request.CargaHoraria
        };
        db.Disciplinas.Add(disciplina);
        await db.SaveChangesAsync(ct);
        return DisciplinaResponse.From(disciplina);
    }
}
