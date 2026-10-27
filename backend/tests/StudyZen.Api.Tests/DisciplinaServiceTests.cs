using Microsoft.EntityFrameworkCore;
using StudyZen.Api.Data;
using StudyZen.Api.Dtos;
using StudyZen.Api.Services;

namespace StudyZen.Api.Tests;

public class DisciplinaServiceTests
{
    private static AppDbContext CriarContexto() =>
        new(new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase($"service-{Guid.NewGuid()}")
            .Options);

    [Fact]
    public async Task CriarAsync_RemoveEspacosDoNomeEPersiste()
    {
        await using var db = CriarContexto();
        var service = new DisciplinaService(db);

        var criada = await service.CriarAsync(new CreateDisciplinaRequest("  Algoritmos  ", 80));

        Assert.Equal("Algoritmos", criada.Nome);
        Assert.Equal(1, await db.Disciplinas.CountAsync());
    }

    [Fact]
    public async Task ListarAsync_RetornaOrdenadoPorNome()
    {
        await using var db = CriarContexto();
        var service = new DisciplinaService(db);
        await service.CriarAsync(new CreateDisciplinaRequest("Redes", 40));
        await service.CriarAsync(new CreateDisciplinaRequest("Banco de Dados", 60));

        var lista = await service.ListarAsync();

        Assert.Equal(["Banco de Dados", "Redes"], lista.Select(d => d.Nome));
    }

    [Fact]
    public async Task ObterAsync_Inexistente_RetornaNull()
    {
        await using var db = CriarContexto();
        var service = new DisciplinaService(db);

        Assert.Null(await service.ObterAsync(42));
    }
}
