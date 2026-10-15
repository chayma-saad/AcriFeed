using LocustMonitoring.API.Models;

namespace LocustMonitoring.API.Services;

public interface INotificationService
{
    Task<Notification> CreateNotificationAsync(int userId, string title, string message, string type);
    Task<List<Notification>> GetUserNotificationsAsync(int userId, bool unreadOnly = false);
    Task MarkAsReadAsync(int notificationId);
}

