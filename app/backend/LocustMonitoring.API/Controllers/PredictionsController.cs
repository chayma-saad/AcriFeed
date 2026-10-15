using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using LocustMonitoring.API.DTOs;
using LocustMonitoring.API.Services;
using System.Security.Claims;

namespace LocustMonitoring.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PredictionsController : ControllerBase
{
    private readonly IPredictionService _predictionService;
    private readonly INotificationService _notificationService;

    public PredictionsController(IPredictionService predictionService, INotificationService notificationService)
    {
        _predictionService = predictionService;
        _notificationService = notificationService;
    }

    [HttpPost]
    public async Task<IActionResult> CreatePrediction([FromBody] PredictionRequest request)
    {
        var userId = GetUserId();
        var prediction = await _predictionService.CreatePredictionAsync(request, userId);

        // Create notification for critical conditions
        if (prediction.ConditionType == "stressed" && userId.HasValue)
        {
            await _notificationService.CreateNotificationAsync(
                userId.Value,
                "⚠ Locusts are stressed",
                "Activate misting & feed now!",
                "alert"
            );
        }

        return Ok(prediction);
    }

    [HttpGet("latest")]
    public async Task<IActionResult> GetLatestPrediction()
    {
        var prediction = await _predictionService.GetLatestPredictionAsync();
        if (prediction == null)
            return NotFound(new { message = "No predictions found" });

        return Ok(prediction);
    }

    [HttpGet]
    public async Task<IActionResult> GetPredictions([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
    {
        var predictions = await _predictionService.GetPredictionsAsync(startDate, endDate);
        return Ok(predictions);
    }

    private int? GetUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (int.TryParse(userIdClaim, out var userId))
            return userId;
        return null;
    }
}

