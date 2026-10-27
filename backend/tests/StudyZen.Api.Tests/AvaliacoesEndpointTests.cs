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
        // 1. Cria disciplina
        var discResp = await _client.PostAsJsonAsync("/api/disciplinas", new { nome = "Algoritmos", cargaHoraria = 80 });
        var disc = await discResp.Content.ReadFromJsonAsync<DisciplinaResponse>();
        Assert.NotNull(disc);

        // 2. Cria duas avaliações com datas diferentes
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

        // 3. Listar avaliações
        var lista = await _client.GetFromJsonAsync<List<AvaliacaoResponse>>("/api/avaliacoes");
        Assert.NotNull(lista);
        Assert.True(lista.Count >= 2);

        var indexProxima = lista.FindIndex(a => a.Titulo == "Quiz 1");
        var indexDistante = lista.FindIndex(a => a.Titulo == "Entrega Final");
        Assert.True(indexProxima < indexDistante, "A avaliação mais próxima deve vir antes na listagem.");
    }

    [Fact]
    public async Task Decompor_TrabalhoDeConclusao_RetornaTresEtapasPadrao()
    {
        var response = await _client.GetFromJsonAsync<DecomposicaoResponse>("/api/avaliacoes/decompor?tipo=Trabalho de Conclusão");
        Assert.NotNull(response);
        Assert.Equal(3, response.SubtarefasSugeridas.Count);
        Assert.Contains("Pesquisa", response.SubtarefasSugeridas);
        Assert.Contains("Rascunho", response.SubtarefasSugeridas);
        Assert.Contains("Revisão", response.SubtarefasSugeridas);
    }

    [Fact]
    public async Task Humor_PostEGet_FuncionaComSucesso()
    {
        var request = new CreateHumorRequest(
            Nivel: 4,
            Emoji: "🙂",
            Sentimento: "Produtivo"
        );

        var postResp = await _client.PostAsJsonAsync("/api/humor", request);
        Assert.Equal(HttpStatusCode.Created, postResp.StatusCode);
        var criado = await postResp.Content.ReadFromJsonAsync<HumorResponse>();
        Assert.NotNull(criado);
        Assert.Equal(4, criado.Nivel);
        Assert.Equal("🙂", criado.Emoji);

        var lista = await _client.GetFromJsonAsync<List<HumorResponse>>("/api/humor");
        Assert.NotNull(lista);
        Assert.Contains(lista, h => h.Id == criado.Id);
    }
}

