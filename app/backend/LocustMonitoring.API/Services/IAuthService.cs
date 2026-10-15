using LocustMonitoring.API.DTOs;

namespace LocustMonitoring.API.Services;

public interface IAuthService
{
    Task<LoginResponse?> LoginAsync(LoginRequest request);
    string GenerateJwtToken(string username, string role);
}

