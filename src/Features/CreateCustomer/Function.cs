using System;
using System.Net;

using Amazon.Lambda.Core;
using Amazon.Lambda.APIGatewayEvents;
using System.Text.Json;
using System.Threading.Tasks;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace CreateCustomer
{
    public class Function
    {
        private static string DynamoDbTableName
            => Environment.GetEnvironmentVariable("DYNAMODB_TABLE_NAME");
        private readonly IRepository _db;

        public Function() : this(new Repository(DynamoDbTableName))
        { }
        public Function(IRepository db)
        {
            _db = db ?? throw new ArgumentNullException(nameof(db));
        }

        public async Task<APIGatewayProxyResponse> Handler(APIGatewayProxyRequest request, ILambdaContext context)
        {
            var customer = JsonSerializer.Deserialize<Customer>(request.Body);
            try
            {
                var token = await _db.CreateCustomer(customer);
                return new APIGatewayProxyResponse
                {
                    StatusCode = (int)HttpStatusCode.Created,
                    Body = JsonSerializer.Serialize(new { Token = token })
                };
            }
            catch (InvalidOperationException exc)
            {
                return new APIGatewayProxyResponse()
                {
                    StatusCode = (int)HttpStatusCode.BadRequest,
                    Body = exc.Message
                };
            }
        }
    }
}