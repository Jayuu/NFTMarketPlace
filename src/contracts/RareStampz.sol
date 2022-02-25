// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC721Connector.sol";

contract RareStampz is ERC721Connector {
    string[] public stamps;

    mapping(string => bool) _stampsExistence;

    function mint(string memory _stamp) public {
        require(!_stampsExistence[_stamp], "Erros - stamp Exists already");
        stamps.push(_stamp);
        uint256 id = stamps.length - 1;
        _mint(msg.sender, id);
    }

    constructor() ERC721Connector("RareStampz", "RSTAMPZ") {}
}
