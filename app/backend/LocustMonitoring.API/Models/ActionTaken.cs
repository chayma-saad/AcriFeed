namespace LocustMonitoring.API.Models;

public class ActionTaken
{
    public int Id { get; set; }
    public int? PredictionId { get; set; }
    public string ActionType { get; set; } = string.Empty;
    public string? ActionDetails { get; set; }
    public int? UserId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public Prediction? Prediction { get; set; }
    public User? User { get; set; }
}

