using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using LocustMonitoring.API.Services;

namespace LocustMonitoring.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class HistoryController : ControllerBase
{
    private readonly IHistoryService _historyService;

    public HistoryController(IHistoryService historyService)
    {
        _historyService = historyService;
    }

    [HttpGet]
    public async Task<IActionResult> GetHistory([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
    {
        var history = await _historyService.GetHistoryAsync(startDate, endDate);
        return Ok(history);
    }
}

