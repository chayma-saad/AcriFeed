using LocustMonitoring.API.Data;
using LocustMonitoring.API.DTOs;
using LocustMonitoring.API.Models;
using Microsoft.EntityFrameworkCore;

namespace LocustMonitoring.API.Services;

public class PredictionService : IPredictionService
{
    private readonly ApplicationDbContext _context;

    public PredictionService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<PredictionResponse> CreatePredictionAsync(PredictionRequest request, int? userId)
    {
        // Save environmental data first
        var envData = new EnvironmentalData
        {
            Temperature = request.Temperature,
            Humidity = request.Humidity,
            LightLevel = request.LightLevel,
            ActivityIndex = request.ActivityIndex,
            FeedLevel = request.FeedLevel,
            RecordedAt = DateTime.UtcNow
        };

        _context.EnvironmentalData.Add(envData);
        await _context.SaveChangesAsync();

        // AI Prediction Logic (simplified - in production, call actual AI model)
        var (conditionType, confidence, recommendedAction, explanation) = PredictCondition(
            request.Temperature ?? 25,
            request.Humidity ?? 60,
            request.ActivityIndex ?? 0.5m,
            request.FeedLevel ?? 50
        );

        var prediction = new Prediction
        {
            ConditionType = conditionType,
            Confidence = confidence,
            FrameData = request.FrameData,
            RecommendedAction = recommendedAction,
            Notes = explanation,
            UserId = userId,
            EnvironmentalDataId = envData.Id,
            CreatedAt = DateTime.UtcNow
        };

        _context.Predictions.Add(prediction);
        await _context.SaveChangesAsync();

        return new PredictionResponse
        {
            Id = prediction.Id,
            ConditionType = conditionType,
            Confidence = confidence,
            RecommendedAction = recommendedAction,
            Explanation = explanation,
            CreatedAt = prediction.CreatedAt,
            EnvironmentalData = new EnvironmentalDataDto
            {
                Temperature = envData.Temperature,
                Humidity = envData.Humidity,
                LightLevel = envData.LightLevel,
                ActivityIndex = envData.ActivityIndex,
                FeedLevel = envData.FeedLevel
            }
        };
    }

    public async Task<PredictionResponse?> GetLatestPredictionAsync()
    {
        var prediction = await _context.Predictions
            .Include(p => p.EnvironmentalData)
            .OrderByDescending(p => p.CreatedAt)
            .FirstOrDefaultAsync();

        if (prediction == null)
            return null;

        return new PredictionResponse
        {
            Id = prediction.Id,
            ConditionType = prediction.ConditionType,
            Confidence = prediction.Confidence,
            RecommendedAction = prediction.RecommendedAction ?? "",
            Explanation = prediction.Notes ?? "",
            CreatedAt = prediction.CreatedAt,
            EnvironmentalData = prediction.EnvironmentalData != null ? new EnvironmentalDataDto
            {
                Temperature = prediction.EnvironmentalData.Temperature,
                Humidity = prediction.EnvironmentalData.Humidity,
                LightLevel = prediction.EnvironmentalData.LightLevel,
                ActivityIndex = prediction.EnvironmentalData.ActivityIndex,
                FeedLevel = prediction.EnvironmentalData.FeedLevel
            } : null
        };
    }

    public async Task<List<PredictionResponse>> GetPredictionsAsync(DateTime? startDate, DateTime? endDate)
    {
        var query = _context.Predictions
            .Include(p => p.EnvironmentalData)
            .AsQueryable();

        if (startDate.HasValue)
            query = query.Where(p => p.CreatedAt >= startDate.Value);

        if (endDate.HasValue)
            query = query.Where(p => p.CreatedAt <= endDate.Value);

        var predictions = await query
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();

        return predictions.Select(p => new PredictionResponse
        {
            Id = p.Id,
            ConditionType = p.ConditionType,
            Confidence = p.Confidence,
            RecommendedAction = p.RecommendedAction ?? "",
            Explanation = p.Notes ?? "",
            CreatedAt = p.CreatedAt,
            EnvironmentalData = p.EnvironmentalData != null ? new EnvironmentalDataDto
            {
                Temperature = p.EnvironmentalData.Temperature,
                Humidity = p.EnvironmentalData.Humidity,
                LightLevel = p.EnvironmentalData.LightLevel,
                ActivityIndex = p.EnvironmentalData.ActivityIndex,
                FeedLevel = p.EnvironmentalData.FeedLevel
            } : null
        }).ToList();
    }

    // Simplified AI prediction logic (replace with actual ML model in production)
    private (string conditionType, decimal confidence, string action, string explanation) PredictCondition(
        decimal temperature, decimal humidity, decimal activityIndex, decimal feedLevel)
    {
        // Simple rule-based prediction (replace with actual AI model)
        if (humidity < 50 || temperature > 30)
        {
            return ("stressed", 0.85m, "Activate misting / feed now",
                "Locusts are stressed due to low humidity or high temperature. Activate misting and feed now to prevent population loss.");
        }
        else if (feedLevel < 40 || activityIndex < 0.4m)
        {
            return ("hungry", 0.75m, "Feed now",
                "Locusts show signs of hunger. Feed now to maintain optimal health.");
        }
        else
        {
            return ("normal", 0.90m, "No action",
                "Locusts are in optimal condition. No immediate action required.");
        }
    }
}

