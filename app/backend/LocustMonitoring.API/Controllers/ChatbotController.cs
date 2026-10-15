using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using LocustMonitoring.API.Services;

namespace LocustMonitoring.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ChatbotController : ControllerBase
{
    private readonly IChatbotService _chatbotService;

    public ChatbotController(IChatbotService chatbotService)
    {
        _chatbotService = chatbotService;
    }

    [HttpPost("ask")]
    public async Task<IActionResult> AskQuestion([FromBody] ChatbotRequest request)
    {
        if (string.IsNullOrEmpty(request.Question))
        {
            return BadRequest(new { message = "Question is required" });
        }

        var response = await _chatbotService.GetResponseAsync(request.Question, request.Context);
        return Ok(new { response });
    }
}

public class ChatbotRequest
{
    public string Question { get; set; } = string.Empty;
    public string? Context { get; set; }
}

