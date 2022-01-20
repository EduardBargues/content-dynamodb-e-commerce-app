using System.Collections.Generic;

namespace GetCustomerWithRecentOrders
{
    public class CustomerWithOrders
    {
        public string UserName { get; set; }
        public string Email { get; set; }
        public List<Order> Orders { get; set; }
    }
}