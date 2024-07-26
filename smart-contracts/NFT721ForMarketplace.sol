// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract OxBurnNFT is ERC721Enumerable,Ownable {
    using Strings for uint256;
    // Token base URI
    string private _baseTokenURI;

    // Maximum supply of tokens
    uint256 public maxSupply;

    // Total minted tokens
    uint256 public totalMint;

    // Owner Address
    address public ownerAddress;


    // Mapping to keep track of token's royalty recipient
    // mapping(uint256 => address) private _royaltyRecipients;

    event Mint(address indexed to, uint256 indexed tokenId);

    /**
     * @dev Constructor to initialize the NFT contract with initial parameters.
     * @param name The name of the NFT token.
     * @param symbol The symbol of the NFT token.
     * @param baseTokenURI The base URI for token metadata.
     * @param _maxSupply The maximum supply of tokens.
    */
    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI,
        uint256 _maxSupply,
        address _ownerAddress
    ) ERC721(name, symbol) Ownable(msg.sender) {
        _baseTokenURI = baseTokenURI;
        maxSupply = _maxSupply;
        ownerAddress = payable (_ownerAddress);
    }

    /**
     * @dev Function to set the base URI for token metadata.
     * @param baseTokenURI The new base URI for token metadata.
     */
    function setBaseURI(string memory baseTokenURI) external onlyOwner {
        _baseTokenURI = baseTokenURI;
    }


    /**
     * @dev Function to mint new NFTs.
     * @param recipient The recipient's address for the minted tokens.
     * @param _mintAmount The number of tokens to mint.
    */
    function mintNFT(address recipient, uint256 _mintAmount) external payable onlyOwner{
        require(totalSupply() + _mintAmount < maxSupply, "Max supply reached");
        // require(msg.value >= _mintAmount * _price, "insufficient balance");
        uint256 supply = totalSupply();
        // payable(ownerAddress).transfer(msg.value);
        totalMint = totalMint + _mintAmount;
        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(recipient, supply + i);
            emit Mint(recipient, supply + i);
        }
    }

    /**
     * @dev Function to retrieve the token URI for a given token ID.
     * @param tokenId The ID of the token.
     * @return The token's URI.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        string memory currentBaseURI = _baseTokenURI;
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString()
                    )
                )
                : "";
    }

    /**
     * @dev Function to retrieve the list of token IDs owned by an address.
     * @param _owner The owner's address.
     * @return An array of token IDs owned by the address.
     */
    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

     /**
     * @dev Function to return the base URI for metadata.
     * @return The base URI for metadata.
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
}
