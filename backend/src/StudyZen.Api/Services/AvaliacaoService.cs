using Microsoft.EntityFrameworkCore;
using StudyZen.Api.Data;
using StudyZen.Api.Dtos;
using StudyZen.Api.Models;

namespace StudyZen.Api.Services;

public interface IAvaliacaoService
{
    Task<IReadOnlyList<AvaliacaoResponse>> ListarAsync(CancellationToken ct = default);
    Task<AvaliacaoResponse?> ObterAsync(int id, CancellationToken ct = default);
    Task<AvaliacaoResponse> CriarAsync(CreateAvaliacaoRequest request, CancellationToken ct = default);
    DecomposicaoResponse Decompor(string tipo);
}

public class AvaliacaoService(AppDbContext db) : IAvaliacaoService
{
    public async Task<IReadOnlyList<AvaliacaoResponse>> ListarAsync(CancellationToken ct = default) =>
        await db.Avaliacoes
            .AsNoTracking()
            .Include(a => a.Disciplina)
            .Include(a => a.Subtarefas)
            .OrderBy(a => a.DataEntrega)
            .Select(a => AvaliacaoResponse.From(a))
            .ToListAsync(ct);

    public async Task<AvaliacaoResponse?> ObterAsync(int id, CancellationToken ct = default)
    {
        var avaliacao = await db.Avaliacoes
            .AsNoTracking()
            .Include(a => a.Disciplina)
            .Include(a => a.Subtarefas)
            .FirstOrDefaultAsync(a => a.Id == id, ct);

        return avaliacao is null ? null : AvaliacaoResponse.From(avaliacao);
    }

    public async Task<AvaliacaoResponse> CriarAsync(CreateAvaliacaoRequest request, CancellationToken ct = default)
    {
        var disciplinaExiste = await db.Disciplinas.AnyAsync(d => d.Id == request.DisciplinaId, ct);
        if (!disciplinaExiste)
        {
            throw new KeyNotFoundException($"Disciplina com ID {request.DisciplinaId} não foi encontrada.");
        }

        var avaliacao = new Avaliacao
        {
            DisciplinaId = request.DisciplinaId,
            Titulo = request.Titulo!.Trim(),
            Tipo = request.Tipo!.Trim(),
            DataEntrega = request.DataEntrega,
            Subtarefas = request.Subtarefas?.Select(s => new Subtarefa
            {
                Titulo = s.Titulo.Trim(),
                Concluida = s.Concluida
            }).ToList() ?? []
        };

        db.Avaliacoes.Add(avaliacao);
        await db.SaveChangesAsync(ct);

        // Recarrega com disciplina para o retorno
        await db.Entry(avaliacao).Reference(a => a.Disciplina).LoadAsync(ct);

        return AvaliacaoResponse.From(avaliacao);
    }

    public DecomposicaoResponse Decompor(string tipo)
    {
        var normalizado = tipo.Trim().ToLowerInvariant();
        IReadOnlyList<string> sugestoes;

        if (normalizado.Contains("trabalho de conclusão") || normalizado.Contains("tcc"))
        {
            sugestoes = ["Pesquisa", "Rascunho", "Revisão"];
        }
        else if (normalizado.Contains("trabalho") || normalizado.Contains("projeto"))
        {
            sugestoes = ["Levantamento de requisitos", "Desenvolvimento", "Testes e Entrega"];
        }
        else if (normalizado.Contains("prova") || normalizado.Contains("exame"))
        {
            sugestoes = ["Revisão dos tópicos teóricos", "Resolução de exercícios", "Simulado"];
        }
        else
        {
            sugestoes = ["Pesquisa inicial", "Execução", "Revisão final"];
        }

        return new DecomposicaoResponse(tipo, sugestoes);
    }
}

