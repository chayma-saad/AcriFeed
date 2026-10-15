namespace LocustMonitoring.API.Models;

public class EnvironmentalData
{
    public int Id { get; set; }
    public decimal? Temperature { get; set; }
    public decimal? Humidity { get; set; }
    public decimal? LightLevel { get; set; }
    public decimal? ActivityIndex { get; set; }
    public decimal? FeedLevel { get; set; }
    public DateTime RecordedAt { get; set; } = DateTime.UtcNow;
}

