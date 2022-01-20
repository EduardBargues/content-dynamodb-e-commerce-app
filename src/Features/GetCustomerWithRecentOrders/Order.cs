using System;

namespace GetCustomerWithRecentOrders
{
    public class Order
    {
        public string OrderId { get; set; }
        public DateTime CreatedAt { get; set; }
        public string Status { get; set; }
        public decimal Amount { get; set; }
        public int NumberOfItems { get; set; }
    }
}