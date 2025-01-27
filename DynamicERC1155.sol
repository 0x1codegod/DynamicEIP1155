// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";


/// @custom:security-contact 0x1codegod@gmail.com
abstract contract DynamicERC1155 is  ERC1155 {

    mapping ( uint256 => bool ) exists;
    mapping ( uint256 => string ) name;
    mapping ( uint256 => string ) public symbol;
    
    //@notice: dynamic _uri should end with a forward-slash 
    string private _uri;

    event AssetCreated(
        string indexed name, 
        string indexed symbol,
        uint256 tokenId
    );

    event AssetsSwapped( 
        address indexed user, 
        uint256 indexed fromTokenId, 
        uint256 indexed toTokenId,
        uint256 amountToBurn, 
        uint256 amountToMint
    );

    constructor( string memory uri_)
        ERC1155( uri_)
    {
        _uri = uri_;
    }
    
    // Function to create a new asset dynamically
    function _createNewAsset(string memory _name, string memory _symbol, uint256 tokenId) public virtual {
        
        require(!exists[tokenId], "Invalid token ID");
        exists[tokenId] = true;
        name[tokenId] = _name;
        symbol[tokenId] = _symbol;
       
        emit AssetCreated(_name, _symbol, tokenId );
    }

     // Function to swap one asset for another
    function _exchange(
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 amountToBurn,
        uint256 amountToMint,
        bytes memory data
    ) public virtual {
        require(
            exists[fromTokenId] && exists[toTokenId],
            "Invalid token IDs"
        );

        burn(msg.sender, fromTokenId, amountToBurn);
        mint(msg.sender, toTokenId, amountToMint, data);

        emit AssetsSwapped(msg.sender, fromTokenId, toTokenId, amountToBurn, amountToMint);
    }
    
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual  {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        _mintBatch(to, ids, amounts, data);
    }

    function burn(address account, uint256 id, uint256 value) public virtual  {
       _burn( account, id, value);
    }

    
    function burnBatch(address from, uint256[] memory ids, uint256[] memory values) public virtual  {
       _burnBatch(from, ids, values);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return (
            string(
                abi.encodePacked(
                    _uri,
                    Strings.toString(tokenId),
                    ".json"
                )
            )
        );
    }
}