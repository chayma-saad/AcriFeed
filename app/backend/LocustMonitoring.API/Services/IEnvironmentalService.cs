using LocustMonitoring.API.DTOs;

namespace LocustMonitoring.API.Services;

public interface IEnvironmentalService
{
    Task SaveEnvironmentalDataAsync(EnvironmentalDataDto data);
    Task SaveSensorDataAsync(SensorDataDto sensorData);
    Task<List<EnvironmentalDataDto>> GetEnvironmentalDataAsync(DateTime? startDate, DateTime? endDate);
    Task<EnvironmentalDataDto?> GetLatestEnvironmentalDataAsync();
}

