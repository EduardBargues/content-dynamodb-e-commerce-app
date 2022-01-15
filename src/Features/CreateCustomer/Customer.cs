using System.Collections.Generic;

namespace CreateCustomer
{
    public class Customer
    {
        public string UserName { get; set; }
        public string Email { get; set; }
        public string Name { get; set; }
        public Dictionary<string, Address> Addresses { get; set; }
    }
}