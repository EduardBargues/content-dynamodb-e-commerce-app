using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.Model;

namespace UpdateCustomerAddresses
{
    public interface IRepository
    {
        Task UpdateCustomerAddresses(string userName, Dictionary<string, Address> addresses);
    }
    public class Repository : IRepository
    {
        private const string PK_NAME = "PK";
        private const string CUSTOMER_PK_PREFIX = "CUSTOMER#";
        private const string SK_NAME = "SK";
        private const string ADDRESSES_ATTRIBUTE_NAME = "Addresses";

        private readonly IAmazonDynamoDB _client;
        private readonly string _tableName;

        public Repository(string tableName)
        {
            _client = new AmazonDynamoDBClient();
            _tableName = tableName ?? throw new ArgumentNullException(nameof(tableName));
        }

        public async Task UpdateCustomerAddresses(string userName, Dictionary<string, Address> addresses)
        {
            var key = new Dictionary<string, AttributeValue>();
            key.Add(PK_NAME, new AttributeValue($"{CUSTOMER_PK_PREFIX}{userName}"));
            key.Add(SK_NAME, new AttributeValue($"{CUSTOMER_PK_PREFIX}{userName}"));

            var attributesToUpdate = new Dictionary<string, AttributeValueUpdate>();
            var addressesAsText = JsonSerializer.Serialize(addresses);
            attributesToUpdate.Add(ADDRESSES_ATTRIBUTE_NAME,
                                   new AttributeValueUpdate(new AttributeValue(addressesAsText),
                                                            AttributeAction.PUT));
            var request = new UpdateItemRequest(_tableName, key, attributesToUpdate);
            var response = await _client.UpdateItemAsync(request);
        }
    }
}