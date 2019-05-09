﻿using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using myapp;
using System;
using System.IO;
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
        public static void Main()
        {
            Console.WriteLine("DotNet Core Console - Containerized - Update Azure Storeage");
            Console.WriteLine();
            
            for(var i=0; i<100; i++)
            {
                CreateTextFileInStorage().GetAwaiter().GetResult();
                Console.WriteLine($"Waiting {WaitTime} seconds");
                System.Threading.Tasks.Task.Delay(1000 * 5).Wait();
            }
            Console.WriteLine("Done");
        }

        private static async Task CreateTextFileInStorage()
        {
            var bm = new BlobManagerAsync(
                "storage4containers", 
                "ZcMvvYtwUOtIFnnIU0DQw3HdbSlczN/",
                "public");

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
