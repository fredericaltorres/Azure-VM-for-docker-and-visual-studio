///using Microsoft.Azure.Storage.Queue;
using Microsoft.WindowsAzure.Storage.Queue;
using System;
using System.Linq;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace fAzureHelper
{
    public sealed class QueueMessage
    {        
        public string Id { get; set; }
        public string PopReceipt { get; set; }
        public string AsString { get; set; }
    }

    /// <summary>
    /// https://docs.microsoft.com/en-us/azure/storage/queues/storage-dotnet-how-to-use-queues
    /// </summary>
    public class QueueManager : AzureStorageBaseClass
    {
        public string _queueName;
        CloudQueue _queue;
        private List<CloudQueueMessage> _inProcessMessages = new List<CloudQueueMessage>();

        //Error CS0029  Cannot implicitly convert type 'Microsoft.WindowsAzure.Storage.Queue.CloudQueueClient' 
        // to 'Microsoft.Azure.Storage.Queue.CloudQueueClient'  fAzureHelper 
        Microsoft.WindowsAzure.Storage.Queue.CloudQueueClient queueClient = null;

        public QueueManager(string storageAccountName, string storageAccessKey, string queueName) : base(storageAccountName, storageAccessKey)
        {
            this._queueName = queueName.ToLowerInvariant();
            queueClient = _storageAccount.CreateCloudQueueClient();

            _queue = queueClient.GetQueueReference("myqueue");
            _queue.CreateIfNotExistsAsync().GetAwaiter().GetResult();
        }

        public async Task<string> EnqueueAsync(string content)
        {
            CloudQueueMessage message = new CloudQueueMessage(content);
            await _queue.AddMessageAsync(message);
            return message.Id;
        }

        public async Task<QueueMessage> PeekAsync()
        {
            CloudQueueMessage m = await _queue.PeekMessageAsync();

            if (m == null)
                return null;

            return new QueueMessage
            {
                Id = m.Id,
                AsString = m.AsString,
                PopReceipt = m.PopReceipt
            };
        }

        public async Task<int> ApproximateMessageCountAsync()
        {
            await this._queue.FetchAttributesAsync();
            var c = this._queue.ApproximateMessageCount.HasValue ? _queue.ApproximateMessageCount.Value : -1;
            return c;
        }

        public async Task<QueueMessage> DequeueAsync()
        {
            CloudQueueMessage m = await _queue.GetMessageAsync();
            if (m == null)
                return null;

            _inProcessMessages.Add(m);

            return new QueueMessage
            {
                Id = m.Id,
                AsString = m.AsString,
                PopReceipt = m.PopReceipt
            };
        }

        public async Task DeleteAsync(string id)
        {
            var cloudMessage = this._inProcessMessages.FirstOrDefault(m => m.Id == id);
            if (cloudMessage == null)
                throw new ApplicationException($"Cannot find queue message id:{id} in the _inProcessMessages list");
            await _queue.DeleteMessageAsync(cloudMessage);
        }

        public async Task<List<QueueMessage>> ClearAsync()
        {
            var l = new List<QueueMessage>();
            while(await ApproximateMessageCountAsync() > 0)
            {
                var m = await DequeueAsync();
                l.Add(m);
                await this.DeleteAsync(m.Id);
            }
            return l;
        }
    }
}
