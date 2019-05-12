using System;
using System.IO;
using System.Reflection;

namespace fDotNetCoreContainerHelper
{
    public class RuntimeHelper
    {
        public static bool IsRunningContainerMode()
        {
            return Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") == "true";
        }
        public static string GetAppVersion()
        {
            return Assembly.GetEntryAssembly().GetCustomAttribute<AssemblyInformationalVersionAttribute>().InformationalVersion;
        }
        public static string GetAppPath()
        {
            return Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
        }
        public static string GetAppSettingsJsonFile()
        {
            return GetAppFilePath("appsettings.json");
        }
        public static string GetAppFilePath(string file)
        {
            return Path.Combine(GetAppPath(), file);
        }

        public static string GetMyDocumentsPath()
        {
            // /root in Linux
            return Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments); 
        }

        public static void InfiniteLoop(int max = 10000)
        {
            var loopIndex = 0;
            while (true)
            {
                Console.WriteLine($"InfiniteLoop {loopIndex++}");
                System.Threading.Tasks.Task.Delay(1000 * 10).Wait();
                if (loopIndex > max)
                    break;
            }
        }
    }
}
