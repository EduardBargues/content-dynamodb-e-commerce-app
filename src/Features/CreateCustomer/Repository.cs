using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.Model;

namespace CreateCustomer
{
    public interface IRepository
    {
        Task<string> CreateCustomer(Customer customer);
    }
    public class Repository : IRepository
    {
        private const string PK_NAME = "PK";
        private const string CUSTOMER_PK_PREFIX = "CUSTOMER#";
        private const string CUSTOMER_EMAIL_PK_PREFIX = "CUSTOMER_EMAIL#";
        private const string SK_NAME = "SK";
        private const string USER_NAME_ATTRIBUTE_NAME = "UserName";
        private const string EMAIL_ATTRIBUTE_NAME = "Email";
        private const string NAME_ATTRIBUTE_NAME = "Name";
        private const string ADDRESSES_ATTRIBUTE_NAME = "Addresses";

        private readonly IAmazonDynamoDB _client;
        private readonly string _tableName;

        public Repository(string tableName)
        {
            _client = new AmazonDynamoDBClient();
            _tableName = tableName ?? throw new ArgumentNullException(nameof(tableName));
        }

        public async Task<string> CreateCustomer(Customer customer)
        {
            var customerPkValue = $"{CUSTOMER_PK_PREFIX}{customer.UserName}";
            var customerRequest = new TransactWriteItem();
            customerRequest.Put = new Put();
            customerRequest.Put.TableName = _tableName;
            customerRequest.Put.ConditionExpression = $"attribute_not_exists({PK_NAME})";
            customerRequest.Put.Item = new Dictionary<string, AttributeValue>();
            customerRequest.Put.Item.Add(PK_NAME, new AttributeValue(customerPkValue));
            customerRequest.Put.Item.Add(SK_NAME, new AttributeValue(customerPkValue));
            customerRequest.Put.Item.Add(USER_NAME_ATTRIBUTE_NAME, new AttributeValue(customer.UserName));
            customerRequest.Put.Item.Add(NAME_ATTRIBUTE_NAME, new AttributeValue(customer.Name));
            customerRequest.Put.Item.Add(EMAIL_ATTRIBUTE_NAME, new AttributeValue(customer.Email));
            customerRequest.Put.Item.Add(ADDRESSES_ATTRIBUTE_NAME, new AttributeValue(JsonSerializer.Serialize(customer.Addresses)));

            var emailPkValue = $"{CUSTOMER_EMAIL_PK_PREFIX}{customer.Email}";
            var emailRequest = new TransactWriteItem();
            emailRequest.Put = new Put();
            emailRequest.Put.TableName = _tableName;
            emailRequest.Put.ConditionExpression = $"attribute_not_exists({PK_NAME})";
            emailRequest.Put.Item = new Dictionary<string, AttributeValue>();
            emailRequest.Put.Item.Add(PK_NAME, new AttributeValue(emailPkValue));
            emailRequest.Put.Item.Add(SK_NAME, new AttributeValue(emailPkValue));

            var request = new TransactWriteItemsRequest();
            request.TransactItems = new List<TransactWriteItem>() { customerRequest, emailRequest };
            try
            {
                var response = await _client.TransactWriteItemsAsync(request);
                return customer.UserName;
            }
            catch (TransactionCanceledException exc)
            {
                throw new InvalidOperationException($"A customer with the same userName or Email already exists.");
            }
        }
    }
}