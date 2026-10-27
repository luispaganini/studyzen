using System.Net;
using System.Net.Http.Json;
using StudyZen.Api.Dtos;

namespace StudyZen.Api.Tests;

public class AvaliacoesEndpointTests : IClassFixture<StudyZenApiFactory>
{
    private readonly HttpClient _client;

    public AvaliacoesEndpointTests(StudyZenApiFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task Post_ComDisciplinaInexistente_RetornaValidationProblem()
    {
        var request = new CreateAvaliacaoRequest(
            DisciplinaId: 999999,
            Titulo: "Prova 1",
            Tipo: "Prova",
            DataEntrega: DateTime.UtcNow.AddDays(7),
            Subtarefas: null
        );

        var response = await _client.PostAsJsonAsync("/api/avaliacoes", request);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Post_ComDadosValidos_CriaERetornaOrdenadoPorData()
    {
        var discResp = await _client.PostAsJsonAsync("/api/disciplinas", new { nome = "Algoritmos", cargaHoraria = 80 });
        var disc = await discResp.Content.ReadFromJsonAsync<DisciplinaResponse>();
        Assert.NotNull(disc);

        var dataMaisDistante = DateTime.UtcNow.AddDays(15);
        var dataMaisProxima = DateTime.UtcNow.AddDays(3);

        await _client.PostAsJsonAsync("/api/avaliacoes", new CreateAvaliacaoRequest(
            DisciplinaId: disc.Id,
            Titulo: "Entrega Final",
            Tipo: "Trabalho",
            DataEntrega: dataMaisDistante,
            Subtarefas: null
        ));

        await _client.PostAsJsonAsync("/api/avaliacoes", new CreateAvaliacaoRequest(
            DisciplinaId: disc.Id,
            Titulo: "Quiz 1",
            Tipo: "Prova",
            DataEntrega: dataMaisProxima,
            Subtarefas: [new SubtarefaDto(null, "Revisar aula 1", false)]
        ));

        var lista = await _client.GetFromJsonAsync<List<AvaliacaoResponse>>("/api/avaliacoes");
        Assert.NotNull(lista);
        Assert.True(lista.Count >= 2);

        var indexProxima = lista.FindIndex(a => a.Titulo == "Quiz 1");
        var indexDistante = lista.FindIndex(a => a.Titulo == "Entrega Final");
        Assert.True(indexProxima < indexDistante, "A avaliação mais próxima deve vir antes na listagem.");
    }
}
