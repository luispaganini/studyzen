using Microsoft.AspNetCore.Mvc;
using StudyZen.Api.Dtos;
using StudyZen.Api.Services;

namespace StudyZen.Api.Controllers;

[ApiController]
[Route("api/disciplinas")]
public class DisciplinasController(IDisciplinaService service) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<DisciplinaResponse>>> Listar(CancellationToken ct) =>
        Ok(await service.ListarAsync(ct));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<DisciplinaResponse>> Obter(int id, CancellationToken ct)
    {
        var disciplina = await service.ObterAsync(id, ct);
        return disciplina is null ? NotFound() : Ok(disciplina);
    }

    [HttpPost]
    public async Task<ActionResult<DisciplinaResponse>> Criar(CreateDisciplinaRequest request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.Nome))
        {
            ModelState.AddModelError(nameof(request.Nome), "O nome é obrigatório.");
            return ValidationProblem(ModelState);
        }

        var criada = await service.CriarAsync(request, ct);
        return CreatedAtAction(nameof(Obter), new { id = criada.Id }, criada);
    }
}
