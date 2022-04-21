// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC165.sol";
import "./interfaces/IERC721.sol";

/*
    1. Keep track of the address who mints the NFT 
    2. Keep track of Token id 
    3. keep track of token owners to token ids
    4. keep track of how many tokens owner has 
    5. emit trnasfer logs 
*/
contract ERC721 is ERC165, IERC721 {
    constructor() {
        _registerInterface(
            bytes4(
                keccak256(("balanceOf(bytes4)")) ^
                    keccak256(("ownerOf(bytes4)")) ^
                    keccak256(("transferFrom(bytes4)"))
            )
        );
    }

    // mapping owner to token ids
    mapping(uint256 => address) private _tokenOwner;

    // mapping number of tokens held by address
    mapping(address => uint256) private _OwnedTokensCount;

    // mapping from token id to approved addresses
    mapping(uint256 => address) private _tokenApprovals;

    function balanceOf(address _owner) public view override returns (uint256) {
        require(_owner != address(0), "Wrong address");

        return _OwnedTokensCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view override returns (address) {
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

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        //1. assign the token id to to the receiver address
        //2. update balance of the address "_from"
        //3. update balance of the address "_to"
        //4. Add the safe functionality
        // safety
        // check if the receiving address is non zero
        // check if the _from address actually owns the token

        // safety checks
        require(_to != address(0), "Error: Invalid To address");
        require(_from == ownerOf(_tokenId), "Error: You down own the Token");
        require(_exists(_tokenId), "Error: Token Doesnt exists");

        // transfer token
        _tokenOwner[_tokenId] = _to;
        _OwnedTokensCount[_to] += 1;

        // update token
        _OwnedTokensCount[_from] -= 1;

        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public payable override {
        require(isApprovedOrOwner(msg.sender, _tokenId), "Error");
        _transferFrom(_from, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) public {
        // require person approving is owner
        // approving address to a token
        // reuire we cannot approve sending tokens to the owner
        // update map of the approval addresses

        address owner = ownerOf(_tokenId);
        require((_to != owner), "Error : Approval to current owner");
        require(
            (msg.sender == owner),
            "Error : Current caller is not Owner of the token"
        );
        _tokenApprovals[_tokenId] = _to;

        emit Approval(owner, _to, _tokenId);
    }

    function isApprovedOrOwner(address sender, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        require(_exists(tokenId), " Token doest exist");

        address owner = ownerOf(tokenId);

        return (sender == owner);
    }
}
