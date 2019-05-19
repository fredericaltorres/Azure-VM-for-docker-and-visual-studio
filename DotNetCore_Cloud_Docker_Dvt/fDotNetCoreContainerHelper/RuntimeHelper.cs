using Microsoft.Extensions.Configuration;
using System;
using System.Text;
using System.Linq;
using System.IO;
using System.Reflection;
using System.Collections.Generic;

namespace fDotNetCoreContainerHelper
{
    public class RuntimeHelper
    {
        private static string ListToString(List<string> list)
        {
            var s = new StringBuilder();
            foreach (var l in list)
                s.Append(l).Append(" ");
            return s.ToString().TrimEnd();
        }

        public static string GetContextInformation()
        {
            var s = new StringBuilder();
            s.Append($"CommandLine:{Environment.CommandLine}").AppendLine();
            s.Append($"CurrentDirectory:{Environment.CurrentDirectory}").AppendLine();
            s.Append($"GetCommandLineArgs:{ListToString(Environment.GetCommandLineArgs().ToList())}").AppendLine();
            s.Append($"Is64BitOperatingSystem:{Environment.Is64BitOperatingSystem}").AppendLine();
            s.Append($"Is64BitProcess:{Environment.Is64BitProcess}").AppendLine();
            s.Append($"MachineName:{Environment.MachineName}").AppendLine();
            s.Append($"UserDomainName:{Environment.UserDomainName}").AppendLine();
            s.Append($"UserName:{Environment.UserName}").AppendLine();
            s.Append($"Common Language Runtime Version:{Environment.Version}").AppendLine();
            s.Append($"OSVersion:{Environment.OSVersion}").AppendLine();
            s.Append($"SystemDirectory:{Environment.SystemDirectory}").AppendLine();
            s.Append($"NewLine.Length:{Environment.NewLine.Length}").AppendLine();
            s.Append($"IsRunningContainerMode:{IsRunningContainerMode()}").AppendLine();

            return s.ToString();
        }

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

        public static string GetAppFolderPath(string folder)
        {
            return Path.Combine(GetAppPath(), folder);
        }

        public static string GetMyDocumentsPath()
        {
            // /root in Linux
            return Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments); 
        }

        const string APP_SETTING_JSON_FILE_NAME = "appsettings.json";

        private static IConfigurationRoot _configurationRoot = null;

        public static IConfigurationRoot BuildAppSettingsJsonConfiguration()
        {
            if (_configurationRoot == null)
            {
                // Console.WriteLine($"Reading configuration {RuntimeHelper.GetAppSettingsJsonFile()}");
                var builder = new ConfigurationBuilder()
                                .SetBasePath(RuntimeHelper.GetAppPath())
                                .AddJsonFile(APP_SETTING_JSON_FILE_NAME, optional: true, reloadOnChange: true);
                _configurationRoot = builder.Build();
            }
            return _configurationRoot;
        }

        public static string GetAppSettings(string name)
        {
            return BuildAppSettingsJsonConfiguration()[name];
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
