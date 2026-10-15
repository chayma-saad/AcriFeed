namespace LocustMonitoring.API.DTOs;

public class PredictionRequest
{
    public string? FrameData { get; set; }
    public decimal? Temperature { get; set; }
    public decimal? Humidity { get; set; }
    public decimal? LightLevel { get; set; }
    public decimal? ActivityIndex { get; set; }
    public decimal? FeedLevel { get; set; }
}

