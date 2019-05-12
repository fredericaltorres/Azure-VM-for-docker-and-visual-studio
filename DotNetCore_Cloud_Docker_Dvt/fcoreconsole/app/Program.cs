using Microsoft.Extensions.Configuration;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using myapp;
using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Threading.Tasks;

namespace DotNetCoreConsole_Container_UpdatingAzureStorage
{
    /// <summary>
    /// Documentation References: 
    /// - Azure Storage client library for .NET - https://docs.microsoft.com/dotnet/api/overview/azure/storage?view=azure-dotnet
    /// - Asynchronous Programming with Async and Await - http://msdn.microsoft.com/library/hh191443.aspx
    /// </summary>

    public static class Program
    {
        public const int WaitTime = 5;
        public static string GetVersion()
        {
            return Assembly.GetEntryAssembly().GetCustomAttribute<AssemblyInformationalVersionAttribute>().InformationalVersion;
        }

        public static void Main()
        {
            IConfigurationRoot configuration = BuildConfiguration();

            var storageAccount = configuration["storage:accountName"];
            var storageKey = configuration["storage:key"];
            const string containerName = "public";

            Console.WriteLine($"DotNet Core Console - Containerized - Update Azure Storeage - v{GetVersion()}");
            Console.WriteLine($"Storage:{storageAccount}, container:{containerName}");

            for (var i = 0; i < 100; i++)
            {
                Console.WriteLine($"");
                Console.WriteLine($"{i} execution(s).");
                CreateTextFileInStorage(storageAccount, storageKey, containerName).GetAwaiter().GetResult();
                Console.WriteLine($"Waiting {WaitTime} seconds");
                System.Threading.Tasks.Task.Delay(1000 * WaitTime).Wait();
            }
            Console.WriteLine("Done");
        }

        private static IConfigurationRoot BuildConfiguration()
        {
            var builder = new ConfigurationBuilder()
                            .SetBasePath(Directory.GetCurrentDirectory())
                            .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);
            IConfigurationRoot configuration = builder.Build();
            return configuration;
        }

        private static async Task CreateTextFileInStorage(string storageAccountName, string storageKey, string containerName)
        {
            var bm = new BlobManagerAsync(
                storageAccountName,
                storageKey,
                containerName);

            string localPath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
            string localFileName = "QS_" + Guid.NewGuid().ToString() + ".txt";
            var fullPathFileName = Path.Combine(localPath, localFileName);

            Console.WriteLine($"About to create localfile:{fullPathFileName}");
            File.WriteAllText(fullPathFileName, "Hello, World!");

            Console.WriteLine($"About to upload localfile:{fullPathFileName}");
            await bm.UploadFileAsync(fullPathFileName);
            //await bm.DownloadFileAsync(fullPathFileName, fullPathFileName+".txt");
            //await bm.DeleteFileAsync(fullPathFileName);
        }
    }
}
