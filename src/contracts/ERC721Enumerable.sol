// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./interfaces/IERC721Enumerable.sol";

/// @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x780e9d63.
/* is ERC721 */
contract ERC721Enumerable is ERC721, IERC721Enumerable {
    constructor() {
        _registerInterface(
            bytes4(
                keccak256(("totalSupply(bytes4)")) ^
                    keccak256(("tokenByIndex(bytes4)")) ^
                    keccak256(("tokenOfOwnerByIndex(bytes4)"))
            )
        );
    }

    uint256[] private _allTokens;

    // mapping from tokenId to all token position
    mapping(uint256 => uint256) private _allTokensIndex;

    // mapping of owner to list all owner token ids
    mapping(address => uint256[]) private _ownedTokens;

    // mapping from token ID to index of owner token list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    function _mint(address to, uint256 tokenId) internal override(ERC721) {
        super._mint(to, tokenId);

        // 1 add tokens to the owner
        // 2 add tokens to our token supply

        _addTokensToAllEnumeration(tokenId);
        _addTokensToOwnerEnumeration(to, tokenId);
    }

    // add tokens to all tokens array and set the position of the tokens indexes
    function _addTokensToAllEnumeration(uint256 tokenID) private {
        _allTokensIndex[tokenID] = _allTokens.length;
        _allTokens.push(tokenID);
    }

    function _addTokensToOwnerEnumeration(address to, uint256 tokenId) private {
        // 1. add address and token id to _ownedTokens
        // 2. _ownedTokensIndex tokenid set to the address of owned tokens position
        // we want to execute for minitng
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    // returns token by index
    function tokenByIndex(uint256 index)
        public
        view
        override
        returns (uint256)
    {
        // make sure index is within in the range of existance
        require(index < totalSupply(), "Global index is out of bounds");

        return _allTokens[index];
    }

    // returns token owner by index
    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        override
        returns (uint256)
    {
        require(index < balanceOf(owner), "Owner index is out of bounds");

        return _ownedTokens[owner][index];
    }

    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() public view override returns (uint256) {
        return _allTokens.length;
    }
}
