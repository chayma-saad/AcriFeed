using LocustMonitoring.API.Data;
using LocustMonitoring.API.DTOs;
using Microsoft.EntityFrameworkCore;

namespace LocustMonitoring.API.Services;

public class EnvironmentalService : IEnvironmentalService
{
    private readonly ApplicationDbContext _context;

    public EnvironmentalService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<EnvironmentalDataDto>> GetEnvironmentalDataAsync(DateTime? startDate, DateTime? endDate)
    {
        var query = _context.EnvironmentalData.AsQueryable();

        if (startDate.HasValue)
            query = query.Where(e => e.RecordedAt >= startDate.Value);

        if (endDate.HasValue)
            query = query.Where(e => e.RecordedAt <= endDate.Value);

        var data = await query
            .OrderBy(e => e.RecordedAt)
            .ToListAsync();

        return data.Select(e => new EnvironmentalDataDto
        {
            Temperature = e.Temperature,
            Humidity = e.Humidity,
            LightLevel = e.LightLevel,
            ActivityIndex = e.ActivityIndex,
            FeedLevel = e.FeedLevel
        }).ToList();
    }

    public async Task SaveEnvironmentalDataAsync(EnvironmentalDataDto data)
    {
        var envData = new EnvironmentalData
        {
            Temperature = data.Temperature,
            Humidity = data.Humidity,
            LightLevel = data.LightLevel ?? 75.0m, // Default value if not provided
            ActivityIndex = data.ActivityIndex ?? 0.5m, // Default value if not provided
            FeedLevel = data.FeedLevel ?? 50.0m, // Default value if not provided
            RecordedAt = DateTime.UtcNow
        };

        _context.EnvironmentalData.Add(envData);
        await _context.SaveChangesAsync();
    }

    public async Task SaveSensorDataAsync(SensorDataDto sensorData)
    {
        var sensor = new SensorData
        {
            Temperature = sensorData.Temperature,
            Humidity = sensorData.Humidity,
            FoodLevel = sensorData.FoodLevel,
            WaterLevel = sensorData.WaterLevel,
            ColonyActivity = sensorData.ColonyActivity,
            PredictedHumidity = sensorData.PredictedHumidity,
            FeedingRecommendation = sensorData.FeedingRecommendation,
            AnomalyScore = sensorData.AnomalyScore,
            ConditionStatus = sensorData.ConditionStatus,
            Timestamp = sensorData.Timestamp ?? DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow
        };

        _context.SensorData.Add(sensor);
        await _context.SaveChangesAsync();
    }

    public async Task<EnvironmentalDataDto?> GetLatestEnvironmentalDataAsync()
    {
        var data = await _context.EnvironmentalData
            .OrderByDescending(e => e.RecordedAt)
            .FirstOrDefaultAsync();

        if (data == null)
            return null;

        return new EnvironmentalDataDto
        {
            Temperature = data.Temperature,
            Humidity = data.Humidity,
            LightLevel = data.LightLevel,
            ActivityIndex = data.ActivityIndex,
            FeedLevel = data.FeedLevel
        };
    }
}

