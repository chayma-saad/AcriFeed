namespace LocustMonitoring.API.Services;

public interface IChatbotService
{
    Task<string> GetResponseAsync(string question, string? context);
}

