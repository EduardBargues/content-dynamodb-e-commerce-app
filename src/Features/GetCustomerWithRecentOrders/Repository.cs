using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.Model;

namespace GetCustomerWithRecentOrders
{
    public interface IRepository
    {
        Task<CustomerWithOrders> GetCustomerWithRecentOrders(string userName);
    }
    public class Repository : IRepository
    {
        private const string PK_NAME = "PK";
        private const string CUSTOMER_PK_PREFIX = "CUSTOMER#";
        private const string USER_NAME_ATTRIBUTE_NAME = "UserName";
        private const string EMAIL_ATTRIBUTE_NAME = "Email";
        private const string ORDER_ID_ATTRIBUTE_NAME = "OrderId";
        private const string CREATED_AT_ATTRIBUTE_NAME = "CreatedAt";
        private const string STATUS_ATTRIBUTE_NAME = "Status";
        private const string AMOUNT_ATTRIBUTE_NAME = "Amount";
        private const string NUMBER_ITEMS_ATTRIBUTE_NAME = "NumberItems";

        private readonly IAmazonDynamoDB _client;
        private readonly string _tableName;

        public Repository(string tableName)
        {
            _client = new AmazonDynamoDBClient();
            _tableName = tableName ?? throw new ArgumentNullException(nameof(tableName));
        }

        public async Task<CustomerWithOrders> GetCustomerWithRecentOrders(string userName)
        {
            var hashPk = "#pk";
            var dotPk = ":pk";
            var request = new QueryRequest(_tableName);
            request.ExpressionAttributeNames = new Dictionary<string, string>();
            request.ExpressionAttributeValues = new Dictionary<string, AttributeValue>();
            request.KeyConditionExpression = $"{hashPk} = {dotPk}";
            request.ExpressionAttributeNames.Add(hashPk, PK_NAME);
            request.ExpressionAttributeValues.Add(dotPk, new AttributeValue($"{CUSTOMER_PK_PREFIX}{userName}"));
            request.ScanIndexForward = false;
            request.Limit = 11;

            var response = await _client.QueryAsync(request);
            Console.WriteLine($"{JsonSerializer.Serialize(response)}");
            var customer = new CustomerWithOrders();
            var customerItem = response.Items.First();
            customer.UserName = customerItem[USER_NAME_ATTRIBUTE_NAME].S;
            customer.Email = customerItem[EMAIL_ATTRIBUTE_NAME].S;
            customer.Orders = new List<Order>();
            for (int idx = 1; idx < response.Items.Count(); idx++)
            {
                var orderItem = response.Items[idx];
                var order = new Order();
                order.OrderId = orderItem[ORDER_ID_ATTRIBUTE_NAME].S;
                order.CreatedAt = DateTime.Parse(orderItem[CREATED_AT_ATTRIBUTE_NAME].S);
                order.Status = orderItem[STATUS_ATTRIBUTE_NAME].S;
                order.Amount = decimal.Parse(orderItem[AMOUNT_ATTRIBUTE_NAME].N);
                order.NumberOfItems = int.Parse(orderItem[NUMBER_ITEMS_ATTRIBUTE_NAME].N);
                customer.Orders.Add(order);
            }

            return customer;
        }
    }
}