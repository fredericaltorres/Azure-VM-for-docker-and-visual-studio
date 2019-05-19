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
        }
    }
}
