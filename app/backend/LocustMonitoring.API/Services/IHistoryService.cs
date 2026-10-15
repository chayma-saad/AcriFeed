using LocustMonitoring.API.DTOs;

namespace LocustMonitoring.API.Services;

public interface IHistoryService
{
    Task<List<HistoryEntryDto>> GetHistoryAsync(DateTime? startDate, DateTime? endDate);
}

public class HistoryEntryDto
{
    public int Id { get; set; }
    public DateTime Timestamp { get; set; }
    public string Condition { get; set; } = string.Empty;
    public string ActionTaken { get; set; } = string.Empty;
    public string Notes { get; set; } = string.Empty;
    public EnvironmentalDataDto? EnvironmentalData { get; set; }
}

