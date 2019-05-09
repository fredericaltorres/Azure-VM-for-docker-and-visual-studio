/*
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;

namespace fAzure.Blob.Api
{
    public class BlobManager
    {
        private const string ConnectionStringFormat = "DefaultEndpointsProtocol=https;AccountName={0};AccountKey={1}";

        public string _storageAccountName;
        private string _storageAccessKey;
        public string _containerName;

        public BlobManager(string storageAccountName, string storageAccessKey, string containerNamee)
        {
            this._storageAccountName = storageAccountName.ToLowerInvariant();
            this._storageAccessKey   = storageAccessKey;
            this._containerName       = containerNamee.ToLowerInvariant();
        }

        public async Task UploadAsync(string localFileName, bool overWrite = true)
        {
            var cloudFileName = Path.GetFileName(localFileName);
            if (await this.ExistAsync(cloudFileName))
            {
                if (overWrite)
                    this.DeleteAsync(cloudFileName);
                else 
                    throw new ArgumentException(string.Format("File:{0} already exist in container:{1}", cloudFileName, this._containerName));
            }
            
            CloudStorageAccount storageAccount = this.GetCloudStorageAccount();
            CloudBlobClient blobClient         = storageAccount.CreateCloudBlobClient();

            //CloudBlobContainer container       = await this.CreatePublicContainerIfNotExistsAsync(blobClient.GetContainerReference(this._containerName));
            CloudBlobContainer container =  blobClient.GetContainerReference(this._containerName);
            CloudBlockBlob blockBlob           = container.GetBlockBlobReference(cloudFileName);

            if (!File.Exists(localFileName))
                throw new ArgumentException(string.Format("file '{0}' not found", localFileName));

            using (var fileStream = System.IO.File.OpenRead(localFileName))
            {
                blockBlob.UploadFromStreamAsync(fileStream);
            }
        }

        public async Task<string> DownloadAsync(string cloudFileName, string localFolder, bool overWrite = true)
        {
            var localFileName                  = Path.Combine(localFolder, cloudFileName);
            CloudStorageAccount storageAccount = GetCloudStorageAccount();
            CloudBlobClient blobClient         = storageAccount.CreateCloudBlobClient();
            CloudBlobContainer container       = await this.CreatePublicContainerIfNotExistsAsync(blobClient.GetContainerReference(this._containerName));
            CloudBlockBlob blockBlob           = container.GetBlockBlobReference(cloudFileName);

            if (!await blockBlob.ExistsAsync())
                throw new ArgumentException(string.Format("File not found '{0}'", cloudFileName));
            
            if (!Directory.Exists(localFolder))
                Directory.CreateDirectory(localFolder);

            if (File.Exists(localFileName))
            {
                if (overWrite)
                    File.Delete(localFileName);
                else 
                    throw new ArgumentException(string.Format("File:{0} already exist in {1}", localFileName, localFolder));
            }

            using (var fileStream = System.IO.File.OpenWrite(localFileName))
            {
                blockBlob.DownloadToStreamAsync(fileStream);
            }

            return localFileName;
        }


        public async Task<bool> DeleteAsync(string cloudFileName)
        {
            CloudStorageAccount storageAccount = GetCloudStorageAccount();
            CloudBlobClient blobClient         = storageAccount.CreateCloudBlobClient();
            CloudBlobContainer container       = await this.CreatePublicContainerIfNotExistsAsync(blobClient.GetContainerReference(this._containerName));
            CloudBlockBlob sourceBlob          = container.GetBlockBlobReference(cloudFileName);
            await sourceBlob.DeleteAsync();
            return true;
        }

        public async Task<bool> ExistAsync(string cloudFileName)
        {
            CloudStorageAccount storageAccount = GetCloudStorageAccount();
            CloudBlobClient blobClient         = storageAccount.CreateCloudBlobClient();
            CloudBlobContainer container       = await this.CreatePublicContainerIfNotExistsAsync(blobClient.GetContainerReference(this._containerName));
            CloudBlockBlob blockBlob           = container.GetBlockBlobReference(cloudFileName);
            return await blockBlob.ExistsAsync();
        }

        private async Task<CloudBlobContainer> CreatePublicContainerIfNotExistsAsync(CloudBlobContainer container)
        {
            if (!await container.ExistsAsync())
            {
                await container.CreateIfNotExistsAsync();
                var containerPermissions = new BlobContainerPermissions();
                containerPermissions.PublicAccess = BlobContainerPublicAccessType.Container;
                await container.SetPermissionsAsync(containerPermissions);
            }
            return container;
        }

        private CloudStorageAccount GetCloudStorageAccount()
        {
            return CloudStorageAccount.Parse(this.GetConnectString());
        }

        private string GetConnectString()
        {
            return string.Format(ConnectionStringFormat, this._storageAccountName, this._storageAccessKey);
        }
    }
}
*/