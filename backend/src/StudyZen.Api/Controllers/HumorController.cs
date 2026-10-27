using Microsoft.AspNetCore.Mvc;
using StudyZen.Api.Dtos;
using StudyZen.Api.Services;

namespace StudyZen.Api.Controllers;

[ApiController]
[Route("api/humor")]
public class HumorController(IHumorService service) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<HumorResponse>>> Listar(CancellationToken ct) =>
        Ok(await service.ListarAsync(ct));

    [HttpPost]
    public async Task<ActionResult<HumorResponse>> Criar(CreateHumorRequest request, CancellationToken ct)
    {
        var criado = await service.CriarAsync(request, ct);
        return CreatedAtAction(nameof(Listar), new { id = criado.Id }, criado);
    }
}

