using Azure.Identity;
using Azure.Messaging.ServiceBus;
using Microsoft.AspNetCore.Mvc;
using NetWebBasedApp.Models;
using System.Diagnostics;

namespace NetWebBasedApp.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    private readonly IConfiguration _configuration;

    public HomeController(ILogger<HomeController> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    public IActionResult Index()
    {
        return View();
    }

    [HttpPost]
    public async Task<IActionResult> SendMessage(string message)
    {
        if (string.IsNullOrWhiteSpace(message))
        {
            ViewBag.Status = "Please enter a message.";
            return View("Index");
        }

        string serviceBusNamespace = _configuration["ServiceBus:fullyQualifiedNamespace"]!;
        string queueName = _configuration["ServiceBusQueueName"]!;

        await using ServiceBusClient client = new(
            serviceBusNamespace,
            new DefaultAzureCredential());

        ServiceBusSender sender = client.CreateSender(queueName);

        await sender.SendMessageAsync(new ServiceBusMessage(message));

        ViewBag.Status = "Message sent to Service Bus!";
        return View("Index");
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel
        {
            RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier
        });
    }
}