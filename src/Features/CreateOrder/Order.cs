using System.Collections.Generic;

namespace CreateOrder
{
    public class Order
    {
        public string UserName { get; set; }
        public List<OrderItem> Items { get; set; }
    }
}