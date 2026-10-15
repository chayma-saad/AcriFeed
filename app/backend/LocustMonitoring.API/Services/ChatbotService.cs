namespace LocustMonitoring.API.Services;

public class ChatbotService : IChatbotService
{
    public async Task<string> GetResponseAsync(string question, string? context)
    {
        // Simple rule-based chatbot (replace with actual AI chatbot in production)
        await Task.Delay(100); // Simulate async operation

        var lowerQuestion = question.ToLower();

        if (lowerQuestion.Contains("stressed") || lowerQuestion.Contains("stress"))
        {
            return "Locusts become stressed when humidity drops below 50% or temperature exceeds 30°C. " +
                   "Immediate action: Activate misting system to increase humidity and provide feed. " +
                   "Monitor temperature and ensure proper ventilation.";
        }

        if (lowerQuestion.Contains("hungry") || lowerQuestion.Contains("feed"))
        {
            return "Signs of hunger include low activity index (<0.4) or feed level below 40%. " +
                   "Action: Feed the locusts immediately with fresh vegetation. " +
                   "Monitor activity levels after feeding to ensure they return to normal.";
        }

        if (lowerQuestion.Contains("normal") || lowerQuestion.Contains("optimal"))
        {
            return "Optimal conditions for locusts: Temperature 24-28°C, Humidity 50-70%, " +
                   "Activity Index >0.5, Feed Level >50%. When all parameters are within these ranges, " +
                   "no immediate action is required. Continue regular monitoring.";
        }

        if (lowerQuestion.Contains("temperature") || lowerQuestion.Contains("temp"))
        {
            return "Ideal temperature range for locusts is 24-28°C. " +
                   "Temperatures above 30°C cause stress. Below 20°C slows activity. " +
                   "Use ventilation or cooling systems to maintain optimal temperature.";
        }

        if (lowerQuestion.Contains("humidity") || lowerQuestion.Contains("moisture"))
        {
            return "Optimal humidity for locusts is 50-70%. " +
                   "Low humidity (<50%) causes stress and dehydration. " +
                   "Use misting systems to increase humidity when needed.";
        }

        return "I'm here to help with locust monitoring. You can ask me about: " +
               "stress conditions, feeding, optimal environment, temperature, humidity, or any specific concerns. " +
               "What would you like to know?";
    }
}

