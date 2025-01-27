// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/// @title DynamicERC1155
/// @dev An abstract ERC1155 contract with dynamic asset creation and swapping capabilities.
/// @custom:security-contact 0x1codegod@gmail.com
abstract contract DynamicERC1155 is ERC1155 {
    // Mapping to track the existence of token IDs
    mapping(uint256 => bool) public exists;

    //Default name compatible with existing wallets
    string public name;

    //Default symbol compatible with existing wallets
    string public symbol;

    // Base URI for the metadata, must end with a forward-slash
    string private _uri;

    /// @dev Event emitted when a new asset is created
    /// @param tokenId The ID of the new token
    event AssetCreated(uint256 tokenId);

    /// @dev Event emitted when assets are swapped
    /// @param user The address of the user performing the swap
    /// @param fromTokenId The token ID being burned
    /// @param toTokenId The token ID being minted
    /// @param amountToBurn Amount of the `fromTokenId` token burned
    /// @param amountToMint Amount of the `toTokenId` token minted
    event AssetsSwapped(
        address indexed user,
        uint256 indexed fromTokenId,
        uint256 indexed toTokenId,
        uint256 amountToBurn,
        uint256 amountToMint
    );

    /// @dev Constructor to set the base URI for metadata
    /// @param uri_ The base URI, must end with a forward-slash
    constructor(string memory uri_, string memory name_, string memory symbol_) ERC1155(uri_) {
        _uri = uri_;
        name = name_;
        symbol = symbol_;
    }

    /// @notice Creates a new token dynamically
    /// @param tokenId The ID of the new token
    function _createNewAsset(
        uint256 tokenId
    ) public virtual {
        require(!exists[tokenId], "Invalid token ID");
        exists[tokenId] = true;
        emit AssetCreated(tokenId);
    }

    /// @notice Swaps one token for another
    /// @param fromTokenId The token ID to burn
    /// @param toTokenId The token ID to mint
    /// @param amountToBurn Amount of `fromTokenId` to burn
    /// @param amountToMint Amount of `toTokenId` to mint
    /// @param data Additional data passed during the minting process
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

        emit AssetsSwapped(
            msg.sender,
            fromTokenId,
            toTokenId,
            amountToBurn,
            amountToMint
        );
    }

    /// @notice Mints new tokens
    /// @param account Address receiving the tokens
    /// @param id Token ID to mint
    /// @param amount Number of tokens to mint
    /// @param data Additional data for the minting process
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        _mint(account, id, amount, data);
    }

    /// @notice Mints multiple token types in a batch
    /// @param to Address receiving the tokens
    /// @param ids Array of token IDs to mint
    /// @param amounts Array of amounts to mint for each token ID
    /// @param data Additional data for the minting process
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        _mintBatch(to, ids, amounts, data);
    }

    /// @notice Burns tokens from an account
    /// @param account Address whose tokens will be burned
    /// @param id Token ID to burn
    /// @param value Amount of tokens to burn
    function burn(address account, uint256 id, uint256 value) public virtual {
        _burn(account, id, value);
    }

    /// @notice Burns multiple token types in a batch
    /// @param from Address whose tokens will be burned
    /// @param ids Array of token IDs to burn
    /// @param values Array of amounts to burn for each token ID
    function burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        _burnBatch(from, ids, values);
    }

    /// @notice Retrieves the URI for a specific token ID
    /// @param tokenId Token ID for which the URI is requested
    /// @return The full URI of the token's metadata
    function uri(uint256 tokenId) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    _uri,
                    Strings.toString(tokenId),
                    ".json"
                )
            );
    }
}
