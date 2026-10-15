using LocustMonitoring.API.Data;
using LocustMonitoring.API.DTOs;
using Microsoft.EntityFrameworkCore;

namespace LocustMonitoring.API.Services;

public class HistoryService : IHistoryService
{
    private readonly ApplicationDbContext _context;

    public HistoryService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<HistoryEntryDto>> GetHistoryAsync(DateTime? startDate, DateTime? endDate)
    {
        var query = _context.Predictions
            .Include(p => p.EnvironmentalData)
            .Include(p => p.User)
            .AsQueryable();

        if (startDate.HasValue)
            query = query.Where(p => p.CreatedAt >= startDate.Value);

        if (endDate.HasValue)
            query = query.Where(p => p.CreatedAt <= endDate.Value);

        var predictions = await query
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();

        var history = new List<HistoryEntryDto>();

        foreach (var prediction in predictions)
        {
            var action = await _context.ActionsTaken
                .Where(a => a.PredictionId == prediction.Id)
                .OrderByDescending(a => a.CreatedAt)
                .FirstOrDefaultAsync();

            history.Add(new HistoryEntryDto
            {
                Id = prediction.Id,
                Timestamp = prediction.CreatedAt,
                Condition = prediction.ConditionType,
                ActionTaken = action?.ActionType ?? prediction.RecommendedAction ?? "No action",
                Notes = prediction.Notes ?? "",
                EnvironmentalData = prediction.EnvironmentalData != null ? new EnvironmentalDataDto
                {
                    Temperature = prediction.EnvironmentalData.Temperature,
                    Humidity = prediction.EnvironmentalData.Humidity,
                    LightLevel = prediction.EnvironmentalData.LightLevel,
                    ActivityIndex = prediction.EnvironmentalData.ActivityIndex,
                    FeedLevel = prediction.EnvironmentalData.FeedLevel
                } : null
            });
        }

        return history;
    }
}

