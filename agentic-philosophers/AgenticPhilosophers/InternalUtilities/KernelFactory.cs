using Microsoft.SemanticKernel;
using Azure.Identity;
using dotenv.net;

internal static class KernelFactory
{
    public static Kernel CreateKernel(string deploymentName, string endpoint)
    {
        return Kernel.CreateBuilder()
            .AddAzureOpenAIChatCompletion(deploymentName, endpoint, new DefaultAzureCredential())
            .Build();
    }
}