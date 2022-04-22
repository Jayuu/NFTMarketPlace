const { assert } = require("chai");

const stamps = artifacts.require("RareStampz");

// check chai
require("chai").use(require("chai-as-promised")).should();

contract("RareStampz", (accounts) => {
  let contract;
  // before tells the test to run before anything else
  before(async () => {
    contract = await stamps.deployed();
  });

  // testing container - deployment
  describe("deployment", async () => {
    // define tests
    it("deploys successfully", async () => {
      const address = contract.address;
      assert.notEqual(address, "");
      assert.notEqual(address, null);
      assert.notEqual(address, undefined);
      assert.notEqual(address, 0x0);
    });

    // next test
    it("Has a name", async () => {
      const name = await contract.name();
      assert.equal(name, "RareStampz");
    });

    // next test
    it("Has a Symbol", async () => {
      const symb = await contract.symbol();
      assert.equal(symb, "RSTAMPZ");
    });
  });

  // testing container - minting
  describe("minting", async () => {
    // define tests
    it("Creates a New Token", async () => {
      const result = await contract.mint("http1");
      const totalSupply = await contract.totalSupply();
      assert.equal(totalSupply, 1);

      // capture the event emmision and test the address
      const event = result.logs[0].args;
      assert.equal(
        event.from,
        "0x0000000000000000000000000000000000000000",
        "From is the contract from Zero address"
      );

      assert.equal(event.to, accounts[0], "to is message sender");

      // failure
      contract.mint("http1").should.be.rejected;
    });
  });

  // testing container - Indexing
  describe("indexing", async () => {
    it("lists RareStampz", async () => {
      await contract.mint("http2");
      await contract.mint("http3");
      await contract.mint("http4");
      const totalSupply = await contract.totalSupply();

      // get all the stamps in loop
      let result = [];
      let rareStamp;
      for (i = 1; i < totalSupply; i++) {
        rareStamp = await contract.stamps(i - 1);
        result.push(rareStamp);
      }

      // assert new array is same as minted array
      let expected = ["http1", "http2", "http3", "http4"];
      assert.equal(result.join(","), expected.join(","));
    });
  });
});
