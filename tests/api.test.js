// PACKAGES
const { beforeAll } = require("@jest/globals");
const axios = require("axios");

// CONF
const appFile = require("./api.json");

// VARS
const apiBaseUrl = appFile.api_base_url.value;
const customer = {
  UserName: "user",
  Email: "user@gmail.com",
  Name: "user user",
  Addresses: {
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
  },
};

// TESTS
describe(`GIVEN api is up and running`, () => {
  describe("WHEN calling POST - /customers", () => {
    let postResponse;
    beforeAll(async () => {
      postResponse = await axios.post(`${apiBaseUrl}/customers`, customer);
    });

    it(`THEN should return CREATED-201`, async () => {
      expect(postResponse.status).toBe(201);
    });
  });
});
