// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IERC1155.sol";
import "./IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract NFTMarketplace is Ownable,ReentrancyGuard,IERC721Receiver,ERC1155Holder {
    using SafeMath for uint256;

    /**
     * @dev Fallback function to receive Ether.
     */
    receive() external payable {}

    address public marketplaceToken;

    struct Auction {address seller;address tokenContract;string  tokenType;uint256 tokenId;uint256 tokenAmount;uint256 startPrice;uint256 duration;bool setAuction;bool ownerListNFT;}

    struct Bid {address bidder;uint256 amount;}

    struct MarketItem {address tokenContract;address owner;string  tokenType;uint256 tokenId;uint256 tokenAmount;uint256 price;bool listNFT;bool ownerListNFT;}

    uint256 public marketFeePercentage; // e.g., 100 means 1%
    uint256 private marketplaceBalance;

    mapping(address => mapping(uint256 =>  mapping(address => Auction))) public auctions;
    mapping(address => mapping(uint256 => mapping(address => Bid))) public highestBids;
    mapping(address => mapping(uint256 => mapping(address => MarketItem))) public listNft;


    event AuctionCreated(address indexed seller,address indexed tokenContract,uint256 indexed tokenId,uint256 startPrice,uint256 duration);

    event AuctionEnded(address indexed seller,address indexed tokenContract,uint256 indexed tokenId,address winner,uint256 totalPrice);

    event MarketItemCreated(address indexed nftContract,uint256 indexed tokenId,address seller,uint256 price,bool indexed sold,bool isMarketItem);

    /**
     * @dev initializes the marketplace token address the contract.
     * @param _marketplaceToken The address of the marketplace token.
     */

    constructor(address _marketplaceToken) Ownable(msg.sender) {
        marketplaceToken = _marketplaceToken;
    }

    /**
     * @dev ERC721Receiver callback function to signal acceptance of an ERC721 token.
    */

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }


    /**
     * @dev Creates a new market item for sale.
     * @param _tokenContract Address of the token contract.
     * @param _tokenId ID of the token being listed.
     * @param _price Price of the token.
     * @param _amount Amount of ERC1155 tokens to list (for ERC1155 tokens).
     * @param _type Type of token ("erc721" or "erc1155").
     * @param owner Owner of the token.
    */

    function createMarketItem(
         address _tokenContract,
        uint256 _tokenId,
        uint256 _price,
        uint256 _amount,
        string memory _type,
        address owner
    ) external {
        if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc1155"))) require(_amount > 0, "Amount should be greater than zero");
        require(!auctions[_tokenContract][_tokenId][owner].setAuction, "Already set auction");
        require(!listNft[_tokenContract][_tokenId][owner].listNFT,"Nft already list for sell");

        if (keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc721"))) {
            // ERC721
            IERC721 erc721Token = IERC721(_tokenContract);
            require(erc721Token.ownerOf(_tokenId) == msg.sender, "You are not the owner of this token");
            IERC721(_tokenContract).safeTransferFrom(msg.sender, address(this), _tokenId);
        } else if (keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc1155"))) {
            // ERC1155
            IERC1155 erc1155Token = IERC1155(_tokenContract);
            require(erc1155Token.balanceOf(msg.sender,_tokenId) != 0, "You are not the owner of this token");
            require(erc1155Token.balanceOf(msg.sender,_tokenId) >= _amount, "You have insufficient amount of tokens");
            IERC1155(_tokenContract).safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");
        } else {
            revert("Unsupported token type");
        }

        listNft[_tokenContract][_tokenId][owner] = MarketItem({
            tokenContract: _tokenContract,
            owner: msg.sender,
            tokenType: _type,
            tokenId: _tokenId,
            tokenAmount: _amount,
            price: _price,
            listNFT: true,
            ownerListNFT: false
        });

        emit MarketItemCreated( _tokenContract, _tokenId, msg.sender, _price, false, true);
  
    }

    /**
     * @dev Creates a new market item for sale.
     * @param _tokenContract Address of the token contract.
     * @param _tokenId ID of the token being listed.
     * @param _price Price of the token.
     * @param _amount Amount of ERC1155 tokens to list (for ERC1155 tokens).
     * @param _type Type of token ("erc721" or "erc1155").
     * @param owner Owner of the token.
    */

    function createMarketItembyAdmin(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _price,
        uint256 _amount,
        string memory _type,
        address owner
    ) external {
        if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc1155"))) require(_amount > 0, "Amount should be greater than zero");
        require(!auctions[_tokenContract][_tokenId][owner].setAuction, "Already set auction");
        require(!listNft[_tokenContract][_tokenId][owner].listNFT,"Nft already list for sell");

        if (keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc721"))) {
            // ERC721
            IERC721 erc721Token = IERC721(_tokenContract);
            require(erc721Token.ownerOf(_tokenId) == msg.sender, "You are not the owner of this token");
            IERC721(_tokenContract).safeTransferFrom(msg.sender, address(this), _tokenId);
        } else if (keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc1155"))) {
            // ERC1155
            IERC1155 erc1155Token = IERC1155(_tokenContract);
            require(erc1155Token.balanceOf(msg.sender,_tokenId) != 0, "You are not the owner of this token");
            require(erc1155Token.balanceOf(msg.sender,_tokenId) >= _amount, "You have insufficient amount of tokens");
            IERC1155(_tokenContract).safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");
        } else {
            revert("Unsupported token type");
        }

        listNft[_tokenContract][_tokenId][owner] = MarketItem({
            tokenContract: _tokenContract,
            owner: msg.sender,
            tokenType: _type,
            tokenId: _tokenId,
            tokenAmount: _amount,
            price: _price,
            listNFT: true,
            ownerListNFT: true
        });

        emit MarketItemCreated( _tokenContract, _tokenId, msg.sender, _price, false, true);
  
    }

    /**
     * @dev Purchases a market item.
     * @param _tokenContract Address of the token contract.
     * @param _tokenId ID of the token being purchased.
     * @param owner Owner of the token.
    */

    function createMarketSale(
        address _tokenContract,
        uint256 _tokenId,
        address owner
    ) external payable nonReentrant {

        MarketItem storage listNfts = listNft[_tokenContract][_tokenId][owner];
        require(listNft[_tokenContract][_tokenId][owner].listNFT,"Nft not list for sell");
        require(msg.value >= listNft[_tokenContract][_tokenId][owner].price,"Insufficient balance");
        uint256 totalPrice = listNfts.price;
        uint256 royalityFee = 0;
        address royaltyRecipient;
        address plateformRecipient;
        address founderRecipient;
        
        if(!listNfts.ownerListNFT){
            if (keccak256(abi.encodePacked(listNfts.tokenType)) == keccak256(abi.encodePacked("erc721"))) {
                // ERC721
                IERC721 erc721Token = IERC721(_tokenContract);
                royalityFee = erc721Token.royaltyFee(_tokenId);
                royaltyRecipient = erc721Token.royaltyRecipient(_tokenId);
                IERC721(_tokenContract).safeTransferFrom(address(this),msg.sender, _tokenId);
            } else if (keccak256(abi.encodePacked(listNfts.tokenType)) == keccak256(abi.encodePacked("erc1155"))) {
                // ERC1155
                IERC1155 erc1155Token = IERC1155(_tokenContract);
                royalityFee = erc1155Token.royaltyFee(_tokenId);
                royaltyRecipient = erc1155Token.royaltyRecipient(_tokenId);
                IERC1155(_tokenContract).safeTransferFrom(address(this),msg.sender, _tokenId, listNfts.tokenAmount, "");
            }

            uint256 royaltyAmount = totalPrice.mul(royalityFee).div(100); // Calculate royalty amount
            uint256 sellerAmount = totalPrice.sub(royaltyAmount);
            (bool royaltyTransferSuccess, ) = royaltyRecipient.call{value: royaltyAmount}("");
            require(royaltyTransferSuccess, "Failed to send royalty");

            (bool success, ) = listNfts.owner.call{value: sellerAmount}("");
            require(success, "Payment to seller failed");

        }else{
             if (keccak256(abi.encodePacked(listNfts.tokenType)) == keccak256(abi.encodePacked("erc721"))) {
                // ERC721
                IERC721 erc721Token = IERC721(_tokenContract);
                royalityFee = erc721Token.royaltyFee(_tokenId);
                royaltyRecipient = erc721Token.royaltyRecipient(_tokenId);
                founderRecipient = erc721Token.founderRecipient(_tokenId);
                plateformRecipient = erc721Token.plateformRecipient(_tokenId);
                IERC721(_tokenContract).safeTransferFrom(address(this),msg.sender, _tokenId);
            } else if (keccak256(abi.encodePacked(listNfts.tokenType)) == keccak256(abi.encodePacked("erc1155"))) {
                // ERC1155
                IERC1155 erc1155Token = IERC1155(_tokenContract);
                royalityFee = erc1155Token.royaltyFee(_tokenId);
                royaltyRecipient = erc1155Token.royaltyRecipient(_tokenId);
                founderRecipient = erc1155Token.founderRecipient(_tokenId);
                plateformRecipient = erc1155Token.plateformRecipient(_tokenId);

                IERC1155(_tokenContract).safeTransferFrom(address(this),msg.sender, _tokenId, listNfts.tokenAmount, "");
            }

            uint256 royaltyAmount = totalPrice.mul(royalityFee).div(100); // Calculate royalty amount
            uint256 plateformAmount = totalPrice.sub(royaltyAmount).div(2);
            uint256 founderAmount = totalPrice.sub(royaltyAmount).sub(plateformAmount);
            (bool royaltyTransferSuccess, ) = royaltyRecipient.call{value: royaltyAmount}("");
            require(royaltyTransferSuccess, "Failed to send royalty");

            (bool successPlateform, ) = plateformRecipient.call{value: plateformAmount}("");
            require(successPlateform, "Payment to plateform failed");

            (bool successFounder, ) = founderRecipient.call{value: founderAmount}("");
            require(successFounder, "Payment to founder failed");
        }

        delete listNft[_tokenContract][_tokenId][owner];   
        emit MarketItemCreated( _tokenContract, _tokenId, msg.sender, totalPrice, true, false);
  
    }

    /**
     * @dev unlist a market item from sale.
     * @param _tokenContract Address of the token contract.
     * @param _tokenId ID of the token being unlisted.
     * @param owner Owner of the token.
    */

    function unListItems(
        address _tokenContract,
        uint256 _tokenId,
        address owner
    ) external nonReentrant {

        MarketItem storage listNfts = listNft[_tokenContract][_tokenId][owner];
        require(listNft[_tokenContract][_tokenId][owner].listNFT,"Nft not list for sell");
        require(msg.sender == listNfts.owner,"Only Owner Can Unlist");
        uint256 totalPrice = listNfts.price;

        if (keccak256(abi.encodePacked(listNfts.tokenType)) == keccak256(abi.encodePacked("erc721"))) {
            // ERC721
            IERC721(_tokenContract).safeTransferFrom(address(this),listNfts.owner, _tokenId);
        } else if (keccak256(abi.encodePacked(listNfts.tokenType)) == keccak256(abi.encodePacked("erc1155"))) {
            // ERC1155
            IERC1155(_tokenContract).safeTransferFrom(address(this),listNfts.owner,_tokenId, listNfts.tokenAmount, "");
        }

        delete listNft[_tokenContract][_tokenId][owner];

        emit MarketItemCreated( _tokenContract, _tokenId, msg.sender, totalPrice, false, false);
    }

    /**
     * @dev Creates an auction for an ERC721 or ERC1155 token.
     * @param _tokenContract Address of the token contract.
     * @param _tokenId ID of the token being listed for auction.
     * @param _amount Amount of ERC1155 tokens to list (for ERC1155 tokens).
     * @param _startPrice Starting price of the auction.
     * @param _duration Duration of the auction.
     * @param _type Type of token ("erc721" or "erc1155").
     * @param owner Owner of the token.
    */

    function createAuction(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _startPrice,
        uint256 _duration,
        string memory _type,
        address owner
    ) external nonReentrant {
        require(_startPrice > 0, "Start price should be greater than zero");
        require(_duration > 0, "Auction duration should be greater than zero");
        require(!auctions[_tokenContract][_tokenId][owner].setAuction, "Already set auction");
        require(!listNft[_tokenContract][_tokenId][owner].listNFT,"Nft already list for sell");
        if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc1155"))) require(_amount > 0, "Amount should be greater than zero");

        if (keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc721"))) {
            // ERC721
            IERC721 erc721Token = IERC721(_tokenContract);
            require(erc721Token.ownerOf(_tokenId) == msg.sender, "You are not the owner of this token");
            IERC721(_tokenContract).safeTransferFrom(msg.sender, address(this), _tokenId);
        } else if (keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc1155"))) {
            // ERC1155
            IERC1155 erc1155Token = IERC1155(_tokenContract);
            require(erc1155Token.balanceOf(msg.sender,_tokenId) != 0, "You are not the owner of this token");
            require(erc1155Token.balanceOf(msg.sender,_tokenId) >= _amount, "You have insufficient amount of tokens");
            IERC1155(_tokenContract).safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");
        } else {
            revert("Unsupported token type");
        }

        auctions[_tokenContract][_tokenId][owner] = Auction({
            seller: msg.sender,
            tokenContract: _tokenContract,
            tokenType: _type,
            tokenId: _tokenId,
            tokenAmount: _amount,
            startPrice: _startPrice,
            duration: _duration,
            setAuction: true,
            ownerListNFT: false
        });

        emit AuctionCreated(msg.sender, _tokenContract, _tokenId, _startPrice, _duration);
    }

    function createAuctionbyAdmin(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _startPrice,
        uint256 _duration,
        string memory _type,
        address owner
    ) external nonReentrant {
        require(_startPrice > 0, "Start price should be greater than zero");
        require(_duration > 0, "Auction duration should be greater than zero");
        require(!auctions[_tokenContract][_tokenId][owner].setAuction, "Already set auction");
        require(!listNft[_tokenContract][_tokenId][owner].listNFT,"Nft already list for sell");
        if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc1155"))) require(_amount > 0, "Amount should be greater than zero");

        if (keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc721"))) {
            // ERC721
            IERC721 erc721Token = IERC721(_tokenContract);
            require(erc721Token.ownerOf(_tokenId) == msg.sender, "You are not the owner of this token");
            IERC721(_tokenContract).safeTransferFrom(msg.sender, address(this), _tokenId);
        } else if (keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc1155"))) {
            // ERC1155
            IERC1155 erc1155Token = IERC1155(_tokenContract);
            require(erc1155Token.balanceOf(msg.sender,_tokenId) != 0, "You are not the owner of this token");
            require(erc1155Token.balanceOf(msg.sender,_tokenId) >= _amount, "You have insufficient amount of tokens");
            IERC1155(_tokenContract).safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");
        } else {
            revert("Unsupported token type");
        }

        auctions[_tokenContract][_tokenId][owner] = Auction({
            seller: msg.sender,
            tokenContract: _tokenContract,
            tokenType: _type,
            tokenId: _tokenId,
            tokenAmount: _amount,
            startPrice: _startPrice,
            duration: _duration,
            setAuction: true,
            ownerListNFT: true
        });

        emit AuctionCreated(msg.sender, _tokenContract, _tokenId, _startPrice, _duration);
    }


    /**
     * @dev Places a bid in an ongoing auction.
     * @param _tokenContract Address of the token contract.
     * @param _tokenId ID of the token in the auction.
     * @param owner Owner of the token.
    */

    function placeBid(address _tokenContract, uint256 _tokenId, address owner) external payable nonReentrant{
        Auction storage auction = auctions[_tokenContract][_tokenId][owner];
        require(auction.duration > 0, "Auction does not exist");
        require(block.timestamp < auction.duration, "Auction has ended");
        require(msg.value > auction.startPrice, "Bid amount must be higher");
        require(msg.value > highestBids[_tokenContract][_tokenId][owner].amount, "Bid amount must be higher");

        Bid memory previousBid = highestBids[_tokenContract][_tokenId][owner];
        highestBids[_tokenContract][_tokenId][owner] = Bid({
            bidder: msg.sender,
            amount: msg.value
        });

        // Refund the previous bidder
        if (previousBid.bidder != address(0)) {
            (bool success, ) = previousBid.bidder.call{value: previousBid.amount}("");
            require(success, "Bidder refund failed");
        }
    }

    /**
     * @dev Ends an ongoing auction and transfers the token to the highest bidder.
     * @param _tokenContract Address of the token contract.
     * @param _tokenId ID of the token in the auction.
     * @param owner Owner of the token.
    */

    function endAuction(address _tokenContract, uint256 _tokenId, address owner) external payable nonReentrant {
        Auction memory auction = auctions[_tokenContract][_tokenId][owner];
        require(auction.duration > 0, "Auction does not exist");
        require(auction.tokenContract == _tokenContract, "Auction does not exist");
        require(block.timestamp >= auction.duration, "Auction has not ended yet");

        address winner = highestBids[_tokenContract][_tokenId][owner].bidder;
        if(winner == address(0)){
            if (keccak256(abi.encodePacked(auction.tokenType)) == keccak256(abi.encodePacked("erc721"))) {
                // ERC721
                IERC721(_tokenContract).safeTransferFrom(address(this), auction.seller, _tokenId);
            } else if (keccak256(abi.encodePacked(auction.tokenType)) == keccak256(abi.encodePacked("erc1155"))) {
                // ERC1155
                IERC1155(_tokenContract).safeTransferFrom(address(this),auction.seller,_tokenId,auction.tokenAmount, "");
            } else {
                revert("Unsupported token type");
            }
            delete auctions[_tokenContract][_tokenId][owner];
        }else{
        uint256 totalPrice = highestBids[_tokenContract][_tokenId][owner].amount;
        auctions[_tokenContract][_tokenId][owner].duration = 0;

        uint256 royalityFee = 0;
        address royaltyRecipient;
        address plateformRecipient;
        address founderRecipient;

        if(!auction.ownerListNFT){
              // Transfer NFT to the winner
            if (keccak256(abi.encodePacked(auction.tokenType)) == keccak256(abi.encodePacked("erc721"))) {
                // ERC721
                IERC721 erc721Token = IERC721(_tokenContract);
                royalityFee = erc721Token.royaltyFee(_tokenId);
                royaltyRecipient = erc721Token.royaltyRecipient(_tokenId);
                IERC721(_tokenContract).safeTransferFrom(address(this), winner, _tokenId);
            } else if (keccak256(abi.encodePacked(auction.tokenType)) == keccak256(abi.encodePacked("erc1155"))) {
                // ERC1155
                IERC1155 erc1155Token = IERC1155(_tokenContract);
                royalityFee = erc1155Token.royaltyFee(_tokenId);
                royaltyRecipient = erc1155Token.royaltyRecipient(_tokenId);
                IERC1155(_tokenContract).safeTransferFrom(address(this), winner,_tokenId,auction.tokenAmount, "");
            } else {
                revert("Unsupported token type");
            }

            uint256 royaltyAmount = totalPrice.mul(royalityFee).div(100); // Calculate royalty amount
            uint256 sellerAmount = totalPrice.sub(royaltyAmount);

            if (royaltyRecipient != address(0) && royaltyAmount > 0) {
                (bool royaltyTransferSuccess, ) = royaltyRecipient.call{value: royaltyAmount}("");
                require(royaltyTransferSuccess, "Failed to send royalty");
            }

            (bool success, ) = auction.seller.call{value: sellerAmount}("");
            require(success, "Payment to seller failed");
        }else{
            // Transfer NFT to the winner
            if (keccak256(abi.encodePacked(auction.tokenType)) == keccak256(abi.encodePacked("erc721"))) {
                // ERC721
                IERC721 erc721Token = IERC721(_tokenContract);
                royalityFee = erc721Token.royaltyFee(_tokenId);
                royaltyRecipient = erc721Token.royaltyRecipient(_tokenId);
                founderRecipient = erc721Token.founderRecipient(_tokenId);
                plateformRecipient = erc721Token.plateformRecipient(_tokenId);
                IERC721(_tokenContract).safeTransferFrom(address(this), winner, _tokenId);
            } else if (keccak256(abi.encodePacked(auction.tokenType)) == keccak256(abi.encodePacked("erc1155"))) {
                // ERC1155
                IERC1155 erc1155Token = IERC1155(_tokenContract);
                royalityFee = erc1155Token.royaltyFee(_tokenId);
                royaltyRecipient = erc1155Token.royaltyRecipient(_tokenId);
                founderRecipient = erc1155Token.founderRecipient(_tokenId);
                plateformRecipient = erc1155Token.plateformRecipient(_tokenId);
                IERC1155(_tokenContract).safeTransferFrom(address(this), winner,_tokenId,auction.tokenAmount, "");
            } else {
                revert("Unsupported token type");
            }

            uint256 royaltyAmount = totalPrice.mul(royalityFee).div(100); // Calculate royalty amount
            uint256 plateformAmount = totalPrice.sub(royaltyAmount).div(2);
            uint256 founderAmount = totalPrice.sub(royaltyAmount).sub(plateformAmount);
            (bool royaltyTransferSuccess, ) = royaltyRecipient.call{value: royaltyAmount}("");
            require(royaltyTransferSuccess, "Failed to send royalty");

            (bool successPlateform, ) = plateformRecipient.call{value: plateformAmount}("");
            require(successPlateform, "Payment to plateform failed");

            (bool successFounder, ) = founderRecipient.call{value: founderAmount}("");
            require(successFounder, "Payment to founder failed");
        }

        delete auctions[_tokenContract][_tokenId][owner];
        delete highestBids[_tokenContract][_tokenId][owner];
        emit AuctionEnded(auction.seller, _tokenContract, _tokenId, winner, totalPrice);
      }
    }
    
}
