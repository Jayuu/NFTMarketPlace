import React, { Component } from "react";

import Web3 from "web3";
import detectEthereumProvider from "@metamask/detect-provider";

import Stamps from "../abi/RareStampz.json";

import "./App.css";

import {
  MDBCard,
  MDBCardBody,
  MDBCardTitle,
  MDBCardText,
  MDBCardImage,
  MDBBtn,
} from "mdb-react-ui-kit";

class App extends Component {
  async componentDidMount() {
    await this.loadWeb3();
    await this.loadBlockchainData();
  }

  //  connect to ETH metamask wallet
  async loadWeb3() {
    const provider = await detectEthereumProvider();

    if (provider) {
      window.web3 = new Web3(provider);
      console.log("Ethereum wallet connected");
    } else {
      console.log("Cannot detect Ethereum wallet");
    }
  }

  // load ETH wallet data
  async loadBlockchainData() {
    const web3 = window.web3;
    const accounts = await web3.eth.getAccounts();
    console.log("Loading Accounts connected");

    // make sure there is account before you proceed
    if (Array.isArray(accounts) && accounts.length) {
      console.log("Accounts  connected");

      console.log(accounts);
      this.setState({ account: accounts[0] });

      // it will load the network data
      const netWorkId = await web3.eth.net.getId();
      const networkData = Stamps.networks[netWorkId];
      if (networkData) {
        console.log("Loading Blockchain data, Minted tokens and total supply ");

        const abi = Stamps.abi;
        const address = networkData.address;
        const contract = new web3.eth.Contract(abi, address);
        this.setState({ contract });

        const totalSupply = await contract.methods.totalSupply().call();
        console.log("Total Supply ", totalSupply);
        this.setState({ totalSupply });

        // settup an array to hold tokens

        for (var i = 0; i < totalSupply; i++) {
          const rareStamp = await contract.methods.stamps(i).call();
          this.setState({
            stamps: [...this.state.stamps, rareStamp],
          });
        }
        // console.log(this.state.stamps);
      } else {
        console.log("Error");
        window.alert("contract not deployed");
      }
    } else {
      console.log("Accounts Not connected");
      window.alert("Accounts Not connected, check metamask");
    }
    console.log("LoadBlockchainData ended");
  }

  // mint tokens
  mint = (stamp) => {
    this.state.contract.methods
      .mint(stamp)
      .send({ from: this.state.account })
      .once("receipt", (receipt) => {
        this.setState({
          stamps: [...this.state.stamps, stamp],
        });
      });
  };

  constructor(props) {
    super(props);
    this.state = {
      account: "",
      contract: null,
      totalSupply: 0,
      stamps: [],
    };
  }

  // render UI on React
  render() {
    return (
      <div className="containerFilled">
        {console.log(this.state.stamps)}
        <nav className="navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow ">
          <div
            className="navbar-brand col-sm-3 col-md-3 mr-0"
            style={{ color: "white" }}
          >
            Rare Stamps NFT Marketplace
          </div>
          <ul className="navbar-nav px-3 ">
            <li className=" nav-item text-nowrap d-none d-sm-none d-sm-block">
              <small className="text-white">{this.state.account}</small>
            </li>
          </ul>
        </nav>

        <div className="container-fluid mt-1">
          <div className="row center-row">
            <main role="main" className="col=lg-12 d-flex text-center">
              <div className="content  mr-auto ml-auto">
                <h1 style={{ color: "black" }}>RareStamps NFT Marketplace</h1>
                <form
                  onSubmit={(event) => {
                    event.preventDefault();
                    const stamp = this.stamp.value;
                    this.mint(stamp);
                  }}
                >
                  <input
                    type="text"
                    placeholder="Add a File location"
                    className="form-control mb-1"
                    ref={(input) => (this.stamp = input)}
                  />
                  <input
                    type="submit"
                    value="Mint"
                    className="btn btn-primary btn-black"
                  />
                </form>
              </div>
            </main>
          </div>

          <hr></hr>
          <div className="row textCenter">
            {this.state.stamps.map((stamp, key) => {
              console.log(stamp);
              return (
                <div>
                  <div>
                    <MDBCard
                      className="token img"
                      style={{ maxWidth: "22rem" }}
                    >
                      <MDBCardImage
                        src={stamp}
                        position="top"
                        style={{ marginRight: "4px" }}
                      />
                      <MDBCardBody>
                        <MDBCardTitle>Stamps</MDBCardTitle>
                        <MDBCardText>
                          20 Unique stamps there is only one of each stamps
                        </MDBCardText>
                        <MDBBtn href={stamp}>Download</MDBBtn>
                      </MDBCardBody>
                    </MDBCard>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    );
  }
}

export default App;
