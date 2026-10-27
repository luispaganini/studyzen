using Microsoft.EntityFrameworkCore;
using StudyZen.Api.Data;
using StudyZen.Api.Dtos;
using StudyZen.Api.Models;

namespace StudyZen.Api.Services;

public interface IHumorService
{
    Task<IReadOnlyList<HumorResponse>> ListarAsync(CancellationToken ct = default);
    Task<HumorResponse> CriarAsync(CreateHumorRequest request, CancellationToken ct = default);
}

public class HumorService(AppDbContext db) : IHumorService
{
    private static readonly Dictionary<int, (string emoji, string sentimento)> HumoresPadrao = new()
    {
        { 1, ("😫", "Muito estressado") },
        { 2, ("🙁", "Estressado") },
        { 3, ("😐", "Neutro") },
        { 4, ("🙂", "Produtivo") },
        { 5, ("😄", "Excelente") }
    };

    public async Task<IReadOnlyList<HumorResponse>> ListarAsync(CancellationToken ct = default) =>
        await db.RegistrosHumor
            .AsNoTracking()
            .OrderByDescending(h => h.DataRegistro)
            .Select(h => HumorResponse.From(h))
            .ToListAsync(ct);

    public async Task<HumorResponse> CriarAsync(CreateHumorRequest request, CancellationToken ct = default)
    {
        var emoji = request.Emoji;
        var sentimento = request.Sentimento;

        if (string.IsNullOrWhiteSpace(emoji) && HumoresPadrao.TryGetValue(request.Nivel, out var padrao))
        {
            emoji = padrao.emoji;
            sentimento ??= padrao.sentimento;
        }

        var registro = new RegistroHumor
        {
            Nivel = request.Nivel,
            Emoji = emoji ?? "😐",
            Sentimento = sentimento ?? "Neutro",
            DataRegistro = DateTime.UtcNow
        };

        db.RegistrosHumor.Add(registro);
        await db.SaveChangesAsync(ct);
        return HumorResponse.From(registro);
    }
}

