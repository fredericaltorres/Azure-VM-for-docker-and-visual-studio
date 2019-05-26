using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using fDotNetCoreContainerHelper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace fDotNetCoreWebApp.Pages
{
    public class IndexModel : PageModel
    {
        public string TheVersion { get; set; }
        public void OnGet()
        {
            this.TheVersion = RuntimeHelper.GetAppVersion();
        }
        public string GetEnvironmentInfo()
        {
            return RuntimeHelper.GetContextInformation();//.Replace(Environment.NewLine, "<br/>");

            /*
             * CommandLine:/app/fDotNetCoreWebApp.dll
            CurrentDirectory:/app
            GetCommandLineArgs:/app/fDotNetCoreWebApp.dll
            Is64BitOperatingSystem:True
            Is64BitProcess:True
            MachineName:fdotnetcorewebapp-deployment-1
            UserDomainName:fdotnetcorewebapp-deployment-1
            UserName:root
            Common Language Runtime Version:4.0.30319.42000
            OSVersion:Unix 4.15.0.1042
            SystemDirectory:
            NewLine.Length:1
            IsRunningContainerMode:True
            HOSTNAME:fdotnetcorewebapp-deployment-1.0.4-6cbbd45c94-gf5x7
            ASPNETCORE_VERSION:2.2.5
            KUBERNETES_PORT:tcp://fkubernetes9-dns-e2e935ca.hcp.eastus2.azmk8s.io:443
            KUBERNETES_PORT_443_TCP_PORT:443
            KUBERNETES_SERVICE_HOST:fkubernetes9-dns-e2e935ca.hcp.eastus2.azmk8s.io
            KUBERNETES_SERVICE_PORT_HTTPS:443
            PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
            KUBERNETES_PORT_443_TCP_ADDR:fkubernetes9-dns-e2e935ca.hcp.eastus2.azmk8s.io
            KUBERNETES_PORT_443_TCP_PROTO:tcp
            ASPNETCORE_URLS:http://+:80
            DOTNET_RUNNING_IN_CONTAINER:true
            KUBERNETES_SERVICE_PORT:443
            HOME:/root
            KUBERNETES_PORT_443_TCP:tcp://fkubernetes9-dns-e2e935ca.hcp.eastus2.azmk8s.io:443


             */

        }
    }
}
