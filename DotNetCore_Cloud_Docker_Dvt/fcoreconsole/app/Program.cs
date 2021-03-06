﻿using fDotNetCoreContainerHelper;
using Microsoft.Extensions.Configuration;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using fAzureHelper;
using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using DynamicSugar;
using System.Collections.Generic;
using System.Text.RegularExpressions;

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
            Console.WriteLine(RuntimeHelper.GetContextInformation());

            var aListOfStrings = new List<string>() { "a", "b" };
            Console.WriteLine($"DynamicSugarCore: List<string>.Format {aListOfStrings.Format()}");

            var alphabetDic = DS.Resources.GetTextResource(new Regex("embed.text.txt", RegexOptions.IgnoreCase), Assembly.GetExecutingAssembly());
            foreach (var e in alphabetDic)
                Console.WriteLine($"DynamicSugarCore Embed Resource: key:{e.Key} value:{e.Value} ");

            var dataTxtFile = RuntimeHelper.GetAppFilePath("data.txt");
            Console.WriteLine($"dataTxtFile:${dataTxtFile}, exists:{File.Exists(dataTxtFile)}");

            var tutuFolder = RuntimeHelper.GetAppFolderPath("tutu");
            Console.WriteLine($"tutuFolder:${tutuFolder}, exists:{Directory.Exists(tutuFolder)}");

            // Initialize Azure storage and queue
            var storageAccount = RuntimeHelper.GetAppSettings("storage:accountName");
            var storageKey = RuntimeHelper.GetAppSettings("storage:key");
            const string containerName = "public";
            const string queueName = "myQueue2";

            var qm = new QueueManager(storageAccount, storageKey, queueName);
            var bm = new BlobManager(storageAccount, storageKey, containerName);
            var tm = new TableManager(storageAccount, storageKey, "FileHistory");

            //var fileLogHistoryAzureTableRecord = new FileLogHistoryAzureTableRecord {
            //    FileName = "zizi.txt", ComputerOrigin = Environment.MachineName, CreationTime = DateTime.UtcNow 
            //};
            //fileLogHistoryAzureTableRecord.SetIdentification();
            //await tm.Insert(fileLogHistoryAzureTableRecord);
            var allRecords = await tm.GetRecords<FileLogHistoryAzureTableRecord>(Environment.MachineName);
            var ziziRecords = await tm.GetRecords<FileLogHistoryAzureTableRecord>(Environment.MachineName, "zizi.txt",
                new TableManager.WhereClauseExpression { Name = "ComputerOrigin", Value = Environment.MachineName });

            if (args.Length > 0)
            {
                switch(args[0].ToLowerInvariant())
                {
                    case "help":
                        Console.WriteLine(@"fCoreConsoleAzureStorage
clearQueue | clearStorage | dirStorage | dirQueue | getQueue | sendMessage ""text""
");
                        break;
                    case "clearqueue":
                        var deleteMessages = await qm.ClearAsync();
                        Console.WriteLine($"{deleteMessages.Count} deleted message");
                        break;
                    case "dirqueue":
                        {
                            var messageCount = await qm.ApproximateMessageCountAsync();
                            Console.WriteLine($"{messageCount} messages");
                        }
                        break;
                    case "getqueue":
                        {
                            while(true)
                            {
                                var m = await qm.DequeueAsync();
                                if (m == null) break;
                                await qm.DeleteAsync(m.Id);
                                Console.WriteLine($"Message id:{m.Id}, body:{m.AsString}");
                            }
                            
                        }
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
                            Console.WriteLine($"{blobs.Count} file(s) found in container:{bm.ContainerName}");
                            foreach(var b in blobs)
                                Console.WriteLine($"  {b}");
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
