namespace LocustMonitoring.API.Models;

public class Prediction
{
    public int Id { get; set; }
    public string ConditionType { get; set; } = string.Empty; // normal, hungry, stressed
    public decimal? Confidence { get; set; }
    public string? FrameData { get; set; }
    public string? RecommendedAction { get; set; }
    public string? Notes { get; set; }
    public int? UserId { get; set; }
    public int? EnvironmentalDataId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public User? User { get; set; }
    public EnvironmentalData? EnvironmentalData { get; set; }
}

