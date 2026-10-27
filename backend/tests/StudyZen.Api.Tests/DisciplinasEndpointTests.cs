using System.Net;
using System.Net.Http.Json;
using StudyZen.Api.Dtos;

namespace StudyZen.Api.Tests;

public class DisciplinasEndpointTests : IClassFixture<StudyZenApiFactory>
{
    private readonly HttpClient _client;

    public DisciplinasEndpointTests(StudyZenApiFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task Post_ComDadosValidos_RetornaCreatedEApareceNaListagem()
    {
        var response = await _client.PostAsJsonAsync("/api/disciplinas", new { nome = "Cálculo I", cargaHoraria = 60 });

        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var criada = await response.Content.ReadFromJsonAsync<DisciplinaResponse>();
        Assert.NotNull(criada);
        Assert.True(criada.Id > 0);
        Assert.Equal("Cálculo I", criada.Nome);
        Assert.NotNull(response.Headers.Location);

        var lista = await _client.GetFromJsonAsync<List<DisciplinaResponse>>("/api/disciplinas");
        Assert.Contains(lista!, d => d.Id == criada.Id);
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("   ")]
    public async Task Post_ComNomeInvalido_RetornaBadRequest(string? nome)
    {
        var response = await _client.PostAsJsonAsync("/api/disciplinas", new { nome, cargaHoraria = 40 });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-5)]
    [InlineData(1001)]
    public async Task Post_ComCargaHorariaInvalida_RetornaBadRequest(int cargaHoraria)
    {
        var response = await _client.PostAsJsonAsync("/api/disciplinas", new { nome = "Física", cargaHoraria });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Get_PorIdInexistente_RetornaNotFound()
    {
        var response = await _client.GetAsync("/api/disciplinas/999999");

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task Health_RetornaOk()
    {
        var response = await _client.GetAsync("/health");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}
