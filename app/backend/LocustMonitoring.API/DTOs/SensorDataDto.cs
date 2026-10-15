namespace LocustMonitoring.API.DTOs;

public class SensorDataDto
{
    public decimal? Temperature { get; set; }
    public decimal? Humidity { get; set; }
    public decimal? FoodLevel { get; set; }
    public decimal? WaterLevel { get; set; }
    public int? ColonyActivity { get; set; }
    public decimal? PredictedHumidity { get; set; }
    public decimal? FeedingRecommendation { get; set; }
    public decimal? AnomalyScore { get; set; }
    public string? ConditionStatus { get; set; }
    public DateTime? Timestamp { get; set; }
}



