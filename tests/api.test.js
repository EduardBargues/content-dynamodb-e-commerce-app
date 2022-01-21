// PACKAGES
const { beforeAll } = require("@jest/globals");
const axios = require("axios");

// CONF
const appFile = require("./api.json");

// VARS
const apiBaseUrl = appFile.api_base_url.value;
const rand = new Date().getMilliseconds();
const customer = {
  UserName: `user-${rand}`,
  Email: `user-${rand}@gmail.com`,
  Name: "user user",
  Addresses: {
    Home: {
      Street: "home street",
      City: "home City",
      State: "home State",
    },
  },
};
const newAddresses = {
  Home: {
    Street: "home street",
    City: "home City",
    State: "home State",
  },
  Business: {
    Street: "business street",
    City: "business City",
    State: "business State",
  },
};
const order = {
  UserName: customer.UserName,
  Items: [
    {
      Description: "item 1",
      Price: 1.0,
    },
    {
      Description: "item 2",
      Price: 2.0,
    },
  ],
};
// TESTS
describe(`GIVEN api is up and running`, () => {
  describe("WHEN calling POST - /customers", () => {
    let createUserResponse;
    beforeAll(async () => {
      createUserResponse = await axios.post(
        `${apiBaseUrl}/customers`,
        customer
      );
    });

    it(`THEN should return CREATED-201`, () => {
      expect(createUserResponse.status).toBe(201);
    });

    describe("WHEN calling PUT - /customers/{customerName} to change the addresses", () => {
      let updateAddressesResponse;
      beforeAll(async () => {
        updateAddressesResponse = await axios.put(
          `${apiBaseUrl}/customers/${customer.UserName}`,
          newAddresses
        );
      });

      it(`THEN should return OK-200`, () => {
        expect(updateAddressesResponse.status).toBe(200);
      });
    });

    describe("WHEN calling POST - /orders", () => {
      let createOrderResponse;
      beforeAll(async () => {
        createOrderResponse = await axios.post(`${apiBaseUrl}/orders`, order);
      });

      it(`THEN should return CREATED-201`, () => {
        expect(createOrderResponse.status).toBe(201);
      });

      it(`THEN should return orderId`, () => {
        expect(createOrderResponse.data.OrderId).toBeDefined();
      });

      describe("WHEN calling GET - /customers/{customerName} to get most recent orders", () => {
        let getCustomerResponse;
        beforeAll(async () => {
          getCustomerResponse = await axios.get(
            `${apiBaseUrl}/customers/${customer.UserName}`
          );
        });

        it(`THEN should return OK-200`, () => {
          expect(getCustomerResponse.status).toBe(200);
        });

        it(`THEN should return 1 order`, () => {
          expect(getCustomerResponse.data).toBeDefined();
          expect(getCustomerResponse.data.UserName).toBe(customer.UserName);
          expect(getCustomerResponse.data.Email).toBe(customer.Email);
          expect(getCustomerResponse.data.Orders.length).toBe(1);
          expect(getCustomerResponse.data.Orders[0].Amount).toBe(3.0);
          expect(getCustomerResponse.data.Orders[0].NumberOfItems).toBe(2);
        });
      });

      describe("WHEN calling GET - /orders/{orderId} to get the order and items", () => {
        let getOrderResponse;
        beforeAll(async () => {
          getOrderResponse = await axios.get(
            `${apiBaseUrl}/orders/${createOrderResponse.data.OrderId}`
          );
        });

        it(`THEN should return OK-200`, () => {
          expect(getOrderResponse.status).toBe(200);
        });

        it(`THEN should return the order`, () => {
          expect(getOrderResponse.data.Status).toBe("ACCEPTED");
          expect(getOrderResponse.data.Items.length).toBe(2);
        });
      });
    });
  });
});
