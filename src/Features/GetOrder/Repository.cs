using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.Model;

namespace GetOrder
{
    public interface IRepository
    {
        Task<Order> GetOrder(string orderId);
    }
    public class Repository : IRepository
    {
        private const string PK_NAME = "PK";
        private const string CUSTOMER_PREFIX = "CUSTOMER#";
        private const string ORDER_PREFIX = "ORDER#";
        private const string ITEM_PREFIX = "ITEM#";
        private const string SK_NAME = "SK";
        private const string ORDER_ID_ATTRIBUTE_NAME = "OrderId";
        private const string CREATED_AT_ATTRIBUTE_NAME = "CreatedAt";
        private const string STATUS_ATTRIBUTE_NAME = "Status";
        private const string AMOUNT_ATTRIBUTE_NAME = "Amount";
        private const string NUMBER_ITEMS_ATTRIBUTE_NAME = "NumberItems";
        private const string ITEM_ID_ATTRIBUTE_NAME = "ItemId";
        private const string DESCRIPTION_ATTRIBUTE_NAME = "Description";
        private const string PRICE_ATTRIBUTE_NAME = "Price";
        private const string GSI_1_PK = "GSI_1_PK";
        private const string GSI_1_SK = "GSI_1_SK";
        private const string GSI_1_INDEX_NAME = "GSI_1";

        private readonly IAmazonDynamoDB _client;
        private readonly string _tableName;

        public Repository(string tableName)
        {
            _client = new AmazonDynamoDBClient();
            _tableName = tableName ?? throw new ArgumentNullException(nameof(tableName));
        }

        public async Task<Order> GetOrder(string orderId)
        {
            var hashGsiPk = "#gsi1pk";
            var dotsGsiPk = ":gsi1pk";
            var request = new QueryRequest(_tableName);
            request.ExpressionAttributeNames = new Dictionary<string, string>();
            request.ExpressionAttributeValues = new Dictionary<string, AttributeValue>();
            request.IndexName = GSI_1_INDEX_NAME;
            request.KeyConditionExpression = $"{hashGsiPk} = {dotsGsiPk}";
            request.ExpressionAttributeNames.Add(hashGsiPk, GSI_1_PK);
            string orderGsiPk = $"{ORDER_PREFIX}{orderId}";
            request.ExpressionAttributeValues.Add(dotsGsiPk, new AttributeValue(orderGsiPk));

            Console.WriteLine(JsonSerializer.Serialize(request));
            var response = await _client.QueryAsync(request);
            Console.WriteLine(JsonSerializer.Serialize(response));
            Console.WriteLine(orderId);

            var orderItemDb = response.Items.Single(item => item[GSI_1_SK].S == orderGsiPk);
            var order = new Order();
            order.Status = orderItemDb[STATUS_ATTRIBUTE_NAME].S;
            order.CreatedAt = DateTime.Parse(orderItemDb[CREATED_AT_ATTRIBUTE_NAME].S);
            order.Items = response.Items
                .Where(item => item[GSI_1_SK].S != orderGsiPk)
                .Select(item =>
                {
                    var orderItem = new OrderItem();
                    orderItem.Description = item[DESCRIPTION_ATTRIBUTE_NAME].S;
                    orderItem.Price = decimal.Parse(item[PRICE_ATTRIBUTE_NAME].N);
                    return orderItem;
                })
                .ToList();

            return order;
        }
    }
}