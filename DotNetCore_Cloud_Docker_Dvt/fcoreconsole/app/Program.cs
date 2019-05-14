using fDotNetCoreContainerHelper;
using Microsoft.Extensions.Configuration;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using fAzureHelper;
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

        public static async Task Main(string [] args)
        {
            Console.WriteLine($"DotNet Core Console - Containerized - Update Azure Storeage - v{RuntimeHelper.GetAppVersion()} - IsRunningContainerMode:{RuntimeHelper.IsRunningContainerMode()}");
            Console.WriteLine($"Env Fred={Environment.GetEnvironmentVariable("Fred")}");

            var dataTxtFile = RuntimeHelper.GetAppFilePath("data.txt");
            Console.WriteLine($"dataTxtFile:${dataTxtFile}, exists:{File.Exists(dataTxtFile)}");

            var tutuFolder = RuntimeHelper.GetAppFilePath("tutu");
            Console.WriteLine($"tutuFolder:${tutuFolder}, exists:{Directory.Exists(tutuFolder)}");

            var storageAccount = RuntimeHelper.GetAppSettings("storage:accountName");
            var storageKey = RuntimeHelper.GetAppSettings("storage:key");
            const string containerName = "public";
            const string queueName = "myQueue2";

            var qm = new QueueManager(storageAccount, storageKey, queueName);
            var bm = new BlobManager(storageAccount, storageKey, containerName);

            if(args.Length > 0)
            {
                switch(args[0].ToLowerInvariant())
                {
                    case "help":
                        Console.WriteLine(@"fCoreConsoleAzureStorage
clearQueue | clearStorage | dirStorage | SendMessage ""text""

with no parameter, default mode uploading a blob file to storage and logging a message to queue
");
                        break;
                    case "clearqueue":
                        var deleteMessages = await qm.ClearAsync();
                        Console.WriteLine($"{deleteMessages.Count} deleted message");
                        break;
                    case "clearstorage":
                        {
                            var blobs = await bm.DirAsync();
                            Console.WriteLine($"About to delete {blobs.Count} cloud file from storage container:{bm.ContainerName}");
                            await bm.DeleteFileAsync(blobs);
                        }
                        break;
                    case "dirstorage":
                        {
                            var blobs = await bm.DirAsync();
                            Console.WriteLine($"Dir {blobs.Count} cloud file from storage container:{bm.ContainerName}");
                            foreach (var b in blobs)
                                Console.WriteLine(b);
                        }
                        break;

                    case "sendmessage":
                        Console.WriteLine($"Sending Message:{args[1]}");
                        var messageId = await qm.EnqueueAsync(args[1]);
                        Console.WriteLine($"MessageId:${messageId}");
                        break;
                    default:
                        Console.WriteLine($"Command not supported:{args[0]}");
                        break;
                }
                Environment.Exit(0);
            }

            Console.WriteLine($"Storage:{storageAccount}, container:{containerName}");

            for (var i = 0; i < 100; i++)
            {
                Console.WriteLine($"");
                Console.WriteLine($"{i} execution(s).");
                CreateTextFileInStorage(bm, qm).GetAwaiter().GetResult();
                Console.WriteLine($"Waiting {WaitTime} seconds");
                System.Threading.Tasks.Task.Delay(1000 * WaitTime).Wait();
            }
            Console.WriteLine("Done");
        }


        private static async Task CreateTextFileInStorage(BlobManager blobManager, QueueManager queueManager)
        {
            Console.WriteLine($"{await queueManager.ApproximateMessageCountAsync()} message in the queue");
            
            string localPath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
            string localFileName = "QS_" + Guid.NewGuid().ToString() + ".txt";
            var fullPathFileName = Path.Combine(localPath, localFileName);

            await queueManager.EnqueueAsync($"CreatingFile {localFileName}");

            Console.WriteLine($"About to create localfile:{fullPathFileName}");
            File.WriteAllText(fullPathFileName, "Hello, World!");

            Console.WriteLine($"About to upload localfile:{fullPathFileName}");
            await blobManager.UploadFileAsync(fullPathFileName);

            Console.WriteLine($"");

            //await bm.DownloadFileAsync(fullPathFileName, fullPathFileName+".txt");
            //await bm.DeleteFileAsync(fullPathFileName);
        }
    }
}
