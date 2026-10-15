using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using LocustMonitoring.API.Services;

namespace LocustMonitoring.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class EnvironmentalController : ControllerBase
{
    private readonly IEnvironmentalService _environmentalService;

    public EnvironmentalController(IEnvironmentalService environmentalService)
    {
        _environmentalService = environmentalService;
    }

    [HttpGet("latest")]
    public async Task<IActionResult> GetLatestEnvironmentalData()
    {
        var data = await _environmentalService.GetLatestEnvironmentalDataAsync();
        if (data == null)
            return NotFound(new { message = "No environmental data found" });

        return Ok(data);
    }

    [HttpPost]
    public async Task<IActionResult> SaveEnvironmentalData([FromBody] EnvironmentalDataDto data)
    {
        await _environmentalService.SaveEnvironmentalDataAsync(data);
        return Ok(new { message = "Environmental data saved successfully" });
    }

    [HttpPost("sensor")]
    public async Task<IActionResult> SaveSensorData([FromBody] SensorDataDto sensorData)
    {
        await _environmentalService.SaveSensorDataAsync(sensorData);
        return Ok(new { message = "Sensor data saved successfully" });
    }

    [HttpGet]
    public async Task<IActionResult> GetEnvironmentalData([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
    {
        var data = await _environmentalService.GetEnvironmentalDataAsync(startDate, endDate);
        return Ok(data);
    }
}

