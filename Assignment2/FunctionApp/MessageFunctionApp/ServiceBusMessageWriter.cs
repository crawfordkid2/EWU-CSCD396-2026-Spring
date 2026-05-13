using Azure.Identity;
using Azure.Storage.Blobs;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace MessageFunctionApp;

public class ServiceBusMessageWriter
{
    private readonly ILogger<ServiceBusMessageWriter> _logger;

    public ServiceBusMessageWriter(ILogger<ServiceBusMessageWriter> logger)
    {
        _logger = logger;
    }

    [Function(nameof(ServiceBusMessageWriter))]
    public async Task Run(
        [ServiceBusTrigger("%ServiceBusQueueName%", Connection = "ServiceBus")]
        string message)
    {
        _logger.LogInformation("Received message: {message}", message);

        string storageAccountName = Environment.GetEnvironmentVariable("StorageAccountName")!;
        string containerName = Environment.GetEnvironmentVariable("StorageContainerName")!;

        string blobUri = $"https://{storageAccountName}.blob.core.windows.net/{containerName}";

        BlobContainerClient containerClient = new BlobContainerClient(
            new Uri(blobUri),
            new DefaultAzureCredential());

        await containerClient.CreateIfNotExistsAsync();

        string fileName = $"message-{DateTime.UtcNow:yyyyMMdd-HHmmss-fff}.txt";
        BlobClient blobClient = containerClient.GetBlobClient(fileName);

        await blobClient.UploadAsync(BinaryData.FromString(message), overwrite: true);

        _logger.LogInformation("Message written to blob storage.");
    }
}
