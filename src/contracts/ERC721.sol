// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    1. Keep track of the address who mints the NFT 
    2. Keep track of Token id 
    3. keep track of token owners to token ids
    4. keep track of how many tokens owner has 
    5. emit trnasfer logs 
*/
contract ERC721 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    // mapping owner to token ids
    mapping(uint256 => address) private _tokenOwner;

    // mapping number of tokens held by address
    mapping(address => uint256) private _OwnedTokensCount;

    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "Wrong address");

        return _OwnedTokensCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = _tokenOwner[_tokenId];
        require(owner != address(0), "no owner");
        return owner;
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        // make sure its a valid address
        require(to != address(0), "ERC721 minting to 0 address");

        // make sure the token is not minted already
        require(!_exists(tokenId), "Token already exists");

        // add a new address to tokenid to mint
        _tokenOwner[tokenId] = to;
        _OwnedTokensCount[to] += 1;

        emit Transfer(address(0), to, tokenId);
    }
}
