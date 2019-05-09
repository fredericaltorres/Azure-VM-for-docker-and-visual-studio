using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace myapp
{
    public class BlobManagerAsync
    {
        private const string ConnectionStringFormat = "DefaultEndpointsProtocol=https;AccountName={0};AccountKey={1}";

        public string _storageAccountName;
        private string _storageAccessKey;
        public string _containerName;

        CloudStorageAccount _storageAccount = null;
        CloudBlobContainer _cloudBlobContainer = null;
        CloudBlobClient _cloudBlobClient = null;

        private string GetConnectString()
        {
            return string.Format(ConnectionStringFormat, this._storageAccountName, this._storageAccessKey);
        }

        public BlobManagerAsync(string storageAccountName, string storageAccessKey, string containerName)
        {
            this._storageAccountName = storageAccountName.ToLowerInvariant();
            this._storageAccessKey = storageAccessKey;
            this._containerName = containerName.ToLowerInvariant();

            if (!CloudStorageAccount.TryParse(GetConnectString(), out _storageAccount))
                throw new ApplicationException("Cannot parse connection string");

            this._cloudBlobClient = _storageAccount.CreateCloudBlobClient();
            this._cloudBlobContainer = _cloudBlobClient.GetContainerReference(containerName);

            CreatePublicContainerIfNotExistsAsync(this._cloudBlobContainer).GetAwaiter().GetResult();
        }

        private async Task<CloudBlobContainer> CreatePublicContainerIfNotExistsAsync(CloudBlobContainer container)
        {
            if (!await container.ExistsAsync())
            {
                await container.CreateIfNotExistsAsync();
                var containerPermissions = new BlobContainerPermissions();
                containerPermissions.PublicAccess = BlobContainerPublicAccessType.Blob; // Public
                await container.SetPermissionsAsync(containerPermissions);

                //// Create a container called 'quickstartblobs' and append a GUID value to it to make the name unique. 
                //cloudBlobContainer = cloudBlobClient.GetContainerReference("quickstartblobs" + Guid.NewGuid().ToString());
                //await cloudBlobContainer.CreateAsync();
                //Console.WriteLine("Created container '{0}'", cloudBlobContainer.Name);
                //Console.WriteLine();

                //// Set the permissions so the blobs are public. 
                //BlobContainerPermissions permissions = new BlobContainerPermissions
                //{
                //    PublicAccess = BlobContainerPublicAccessType.Blob
                //};
                //await cloudBlobContainer.SetPermissionsAsync(permissions);
            }
            return container;
        }

        public async Task DownloadFileAsync(string cloudFileName, string destinationFileName)
        {
            if(File.Exists(destinationFileName))
                throw new ApplicationException($"Local file {cloudFileName} already exist");

            cloudFileName = Path.GetFileName(cloudFileName);
            CloudBlockBlob cloudBlockBlob = _cloudBlobContainer.GetBlockBlobReference(cloudFileName);
            await cloudBlockBlob.DownloadToFileAsync(destinationFileName, FileMode.Create);
        }

        public async Task UploadFileAsync(string localFileName, string cloudFileName = null)
        {
            if(cloudFileName == null) // If no cloudFileName is specified use the local file name
                cloudFileName = Path.GetFileName(localFileName);

            if (await this.FileExistAsync(cloudFileName))
                throw new ApplicationException($"Cloud file {cloudFileName} already exist");

            CloudBlockBlob cloudBlockBlob = _cloudBlobContainer.GetBlockBlobReference(cloudFileName);
            await cloudBlockBlob.UploadFromFileAsync(localFileName);
        }
        public async Task DeleteContainerAsync()
        {
            await _cloudBlobContainer.DeleteIfExistsAsync();
        }
        public async Task DeleteFileAsync(string cloudFileName)
        {
            cloudFileName = Path.GetFileName(cloudFileName);
            CloudBlockBlob sourceBlob = _cloudBlobContainer.GetBlockBlobReference(cloudFileName);
            await sourceBlob.DeleteAsync();
        }
        public async Task<bool> FileExistAsync(string cloudFileName)
        {
            CloudBlockBlob blockBlob = _cloudBlobContainer.GetBlockBlobReference(cloudFileName);
            return await blockBlob.ExistsAsync();
        }
    }
}
