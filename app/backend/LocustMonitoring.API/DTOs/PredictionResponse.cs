namespace LocustMonitoring.API.DTOs;

public class PredictionResponse
{
    public int Id { get; set; }
    public string ConditionType { get; set; } = string.Empty;
    public decimal? Confidence { get; set; }
    public string RecommendedAction { get; set; } = string.Empty;
    public string Explanation { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public EnvironmentalDataDto? EnvironmentalData { get; set; }
}

public class EnvironmentalDataDto
{
    public decimal? Temperature { get; set; }
    public decimal? Humidity { get; set; }
    public decimal? LightLevel { get; set; }
    public decimal? ActivityIndex { get; set; }
    public decimal? FeedLevel { get; set; }
}

