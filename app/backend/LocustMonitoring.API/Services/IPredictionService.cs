using LocustMonitoring.API.DTOs;

namespace LocustMonitoring.API.Services;

public interface IPredictionService
{
    Task<PredictionResponse> CreatePredictionAsync(PredictionRequest request, int? userId);
    Task<PredictionResponse?> GetLatestPredictionAsync();
    Task<List<PredictionResponse>> GetPredictionsAsync(DateTime? startDate, DateTime? endDate);
}

