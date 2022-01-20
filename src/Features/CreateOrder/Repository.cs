using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.Model;

namespace CreateOrder
{
    public interface IRepository
    {
        Task<string> CreateOrder(Order order);
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

        private readonly IAmazonDynamoDB _client;
        private readonly string _tableName;

        public Repository(string tableName)
        {
            _client = new AmazonDynamoDBClient();
            _tableName = tableName ?? throw new ArgumentNullException(nameof(tableName));
        }

        public async Task<string> CreateOrder(Order order)
        {
            var nowAsText = DateTime.UtcNow.ToString("s");
            var orderId = $"{order.UserName}<>{nowAsText}";

            var requests = order.Items
                .Select((orderItem, index) => GetOrderItemWriteRequest(index, orderItem, orderId))
                .ToList();
            requests.Add(GetOrderWriteRequest(orderId, nowAsText, order));
            var tableRequest = new Dictionary<string, List<WriteRequest>>();
            tableRequest.Add(_tableName, requests);
            var request = new BatchWriteItemRequest(tableRequest);
            var response = await _client.BatchWriteItemAsync(request);

            return orderId;
        }

        private WriteRequest GetOrderWriteRequest(string orderId, string nowAsText, Order order)
        {
            var item2Put = new Dictionary<string, AttributeValue>();
            item2Put.Add(PK_NAME, new AttributeValue($"{CUSTOMER_PREFIX}{order.UserName}"));
            item2Put.Add(SK_NAME, new AttributeValue($"#{ORDER_PREFIX}{orderId}"));

            item2Put.Add(ORDER_ID_ATTRIBUTE_NAME, new AttributeValue(orderId));
            item2Put.Add(CREATED_AT_ATTRIBUTE_NAME, new AttributeValue(nowAsText));
            item2Put.Add(STATUS_ATTRIBUTE_NAME, new AttributeValue("ACCEPTED"));
            item2Put.Add(AMOUNT_ATTRIBUTE_NAME, new AttributeValue() { N = $"{order.Items.Sum(item => item.Price)}" });
            item2Put.Add(NUMBER_ITEMS_ATTRIBUTE_NAME, new AttributeValue() { N = $"{order.Items.Count()}" });

            item2Put.Add(GSI_1_PK, new AttributeValue($"{ORDER_PREFIX}{orderId}"));
            item2Put.Add(GSI_1_SK, new AttributeValue($"{ORDER_PREFIX}{orderId}"));

            var putRequest = new PutRequest(item2Put);
            var request = new WriteRequest(putRequest);

            return request;
        }

        private WriteRequest GetOrderItemWriteRequest(int itemId, OrderItem orderItem, string orderId)
        {
            var item2Put = new Dictionary<string, AttributeValue>();
            item2Put.Add(PK_NAME, new AttributeValue($"{ORDER_PREFIX}{orderId}#{ITEM_PREFIX}{itemId}"));
            item2Put.Add(SK_NAME, new AttributeValue($"{ORDER_PREFIX}{orderId}#{ITEM_PREFIX}{itemId}"));

            item2Put.Add(ORDER_ID_ATTRIBUTE_NAME, new AttributeValue(orderId));
            item2Put.Add(ITEM_ID_ATTRIBUTE_NAME, new AttributeValue($"{itemId}"));
            item2Put.Add(DESCRIPTION_ATTRIBUTE_NAME, new AttributeValue(orderItem.Description));
            item2Put.Add(PRICE_ATTRIBUTE_NAME, new AttributeValue() { N = $"{orderItem.Price}" });

            item2Put.Add(GSI_1_PK, new AttributeValue($"{ORDER_PREFIX}{orderId}"));
            item2Put.Add(GSI_1_SK, new AttributeValue($"{ITEM_PREFIX}{itemId}"));

            var putRequest = new PutRequest(item2Put);
            var request = new WriteRequest(putRequest);

            return request;
        }
    }
}