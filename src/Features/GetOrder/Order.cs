using System;
using System.Collections.Generic;

namespace GetOrder
{
    public class Order
    {
        public DateTime CreatedAt { get; set; }
        public string Status { get; set; }
        public List<OrderItem> Items { get; set; }
    }
}