using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using LocustMonitoring.API.Data;
using LocustMonitoring.API.Models;
using System.Security.Claims;

namespace LocustMonitoring.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ActionsController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public ActionsController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpPost]
    public async Task<IActionResult> RecordAction([FromBody] ActionRequest request)
    {
        var userId = GetUserId();

        var action = new ActionTaken
        {
            PredictionId = request.PredictionId,
            ActionType = request.ActionType,
            ActionDetails = request.ActionDetails,
            UserId = userId,
            CreatedAt = DateTime.UtcNow
        };

        _context.ActionsTaken.Add(action);
        await _context.SaveChangesAsync();

        return Ok(new { id = action.Id, message = "Action recorded successfully" });
    }

    private int? GetUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (int.TryParse(userIdClaim, out var userId))
            return userId;
        return null;
    }
}

public class ActionRequest
{
    public int? PredictionId { get; set; }
    public string ActionType { get; set; } = string.Empty;
    public string? ActionDetails { get; set; }
}

