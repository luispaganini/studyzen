using Microsoft.AspNetCore.Mvc;
using StudyZen.Api.Dtos;
using StudyZen.Api.Services;

namespace StudyZen.Api.Controllers;

[ApiController]
[Route("api/avaliacoes")]
public class AvaliacoesController(IAvaliacaoService service) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<AvaliacaoResponse>>> Listar(CancellationToken ct) =>
        Ok(await service.ListarAsync(ct));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<AvaliacaoResponse>> Obter(int id, CancellationToken ct)
    {
        var avaliacao = await service.ObterAsync(id, ct);
        return avaliacao is null ? NotFound() : Ok(avaliacao);
    }

    [HttpGet("decompor")]
    public ActionResult<DecomposicaoResponse> Decompor([FromQuery] string tipo)
    {
        if (string.IsNullOrWhiteSpace(tipo))
        {
            return BadRequest(new { message = "O parâmetro 'tipo' é obrigatório." });
        }
        return Ok(service.Decompor(tipo));
    }

    [HttpPost]
    public async Task<ActionResult<AvaliacaoResponse>> Criar(CreateAvaliacaoRequest request, CancellationToken ct)
    {
        try
        {
            var criada = await service.CriarAsync(request, ct);
            return CreatedAtAction(nameof(Obter), new { id = criada.Id }, criada);
        }
        catch (KeyNotFoundException ex)
        {
            ModelState.AddModelError(nameof(request.DisciplinaId), ex.Message);
            return ValidationProblem(ModelState);
        }
    }
}

