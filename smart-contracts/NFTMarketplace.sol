// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract NFTMarketplace is Ownable,ReentrancyGuard,IERC721Receiver {
    using SafeMath for uint256;

    /**
     * @dev Fallback function to receive Ether.
     */
    receive() external payable {}

    struct Auction {address seller;address tokenContract;string  tokenType;uint256 tokenId;uint256 tokenAmount;uint256 startPrice;uint256 duration;bool setAuction;bool ownerListNFT; bool is0xBurnRequired;}

    struct Bid {address bidder;uint256 amount;}

    struct MarketItem {address tokenContract;address owner;string  tokenType;uint256 tokenId;uint256 tokenAmount;uint256 price;bool listNFT; bool ownerListNFT; bool is0xBurnRequired;}

    uint256 public marketFeePercentage; // e.g., 100 means 1%

    address public Address0xBurn;

    address public teamAddress;
    address public DAOTreasury;
    address public RewardPool;
    address[] public PartnerNFTholders;


    mapping(address => mapping(uint256 =>  mapping(address => Auction))) public auctions;
    mapping(address => mapping(uint256 => mapping(address => Bid))) public highestBids;
    mapping(address => mapping(uint256 => mapping(address => MarketItem))) public listNft;


    event AuctionCreated(address indexed seller,address indexed tokenContract,uint256 indexed tokenId,uint256 startPrice,uint256 duration);

    event AuctionEnded(address indexed seller,address indexed tokenContract,uint256 indexed tokenId,address winner,uint256 totalPrice);

    event MarketItemCreated(address indexed nftContract,uint256 indexed tokenId,address seller,uint256 price,bool indexed sold,bool isMarketItem);


    constructor(address _RewardPool, address _teamAddress, address _DAOTreasury, address[] memory _PartnerNFTholders, address _Address0xBurn) Ownable(msg.sender) {
        teamAddress = _teamAddress;
        DAOTreasury = _DAOTreasury;
        PartnerNFTholders = _PartnerNFTholders;
        RewardPool = _RewardPool;
        Address0xBurn = _Address0xBurn;
    }

    function changePatnerNFTHolders(address[] memory _patnerNftsHolders) public onlyOwner {
        PartnerNFTholders = _patnerNftsHolders;
    }

    function transferHoldersby0xBurn(uint256 amount) internal  returns(bool) {
        uint individualAmount = amount.div(PartnerNFTholders.length);

        for (uint i = 0; i < PartnerNFTholders.length; i++) {
            IERC20(Address0xBurn).transferFrom(msg.sender,PartnerNFTholders[i],individualAmount);
        }

        return true;
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
     * @param _type Type of token ("erc721" or "erc1155").
     * @param owner Owner of the token.
     * @param owner 0xBurn of the token.
    */

    function createMarketItem(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _price,
        string memory _type,
        address owner,
        bool _isRequired0xBurn
    ) external {
        require(!auctions[_tokenContract][_tokenId][owner].setAuction, "Already set auction");
        require(!listNft[_tokenContract][_tokenId][owner].listNFT,"Nft already list for sell");

        if (keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc721"))) {
            // ERC721
            IERC721 erc721Token = IERC721(_tokenContract);
            require(erc721Token.ownerOf(_tokenId) == msg.sender, "You are not the owner of this token");
            IERC721(_tokenContract).safeTransferFrom(msg.sender, address(this), _tokenId);
        } else {
            revert("Unsupported token type");
        }

        listNft[_tokenContract][_tokenId][owner] = MarketItem({
            tokenContract: _tokenContract,
            owner: msg.sender,
            tokenType: _type,
            tokenId: _tokenId,
            tokenAmount: 0,
            price: _price,
            listNFT: true,
            ownerListNFT: false,
            is0xBurnRequired: _isRequired0xBurn
        });

        emit MarketItemCreated( _tokenContract, _tokenId, msg.sender, _price, false, true);
  
    }

    /**
     * @dev Creates a new market item for sale.
     * @param _tokenContract Address of the token contract.
     * @param _tokenId ID of the token being listed.
     * @param _price Price of the token.
     * @param _type Type of token ("erc721" or "erc1155").
     * @param owner Owner of the token.
     * @param _isRequired0xBurn 0xBurn of the token.
    */

    function createMarketItembyAdmin(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _price,
        string memory _type,
        address owner,
        bool _isRequired0xBurn
    ) external {
        require(!auctions[_tokenContract][_tokenId][owner].setAuction, "Already set auction");
        require(!listNft[_tokenContract][_tokenId][owner].listNFT,"Nft already list for sell");

        if (keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc721"))) {
            // ERC721
            IERC721 erc721Token = IERC721(_tokenContract);
            require(erc721Token.ownerOf(_tokenId) == msg.sender, "You are not the owner of this token");
            IERC721(_tokenContract).safeTransferFrom(msg.sender, address(this), _tokenId);
        } else {
            revert("Unsupported token type");
        }

        listNft[_tokenContract][_tokenId][owner] = MarketItem({
            tokenContract: _tokenContract,
            owner: msg.sender,
            tokenType: _type,
            tokenId: _tokenId,
            tokenAmount: 0,
            price: _price,
            listNFT: true,
            ownerListNFT: true,
            is0xBurnRequired:_isRequired0xBurn
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

        if(!listNfts.ownerListNFT){
            (bool success, ) = listNfts.owner.call{value: totalPrice}("");
            require(success, "Payment to seller failed");

        }else{
            (bool success, ) = listNfts.owner.call{value: totalPrice}("");
            require(success, "Payment to seller failed");
        }

        IERC721(_tokenContract).safeTransferFrom(address(this),msg.sender,_tokenId);
        delete listNft[_tokenContract][_tokenId][owner];   
        emit MarketItemCreated( _tokenContract, _tokenId, msg.sender, totalPrice, true, false);
  
    }

    function createMarketSaleby0xBurn(
        address _tokenContract,
        uint256 _tokenId,
        address owner
    ) external nonReentrant {

        MarketItem storage listNfts = listNft[_tokenContract][_tokenId][owner];
        require(listNft[_tokenContract][_tokenId][owner].listNFT,"Nft not list for sell");
        uint256 balanceof = IERC20(Address0xBurn).balanceOf(msg.sender);
        require(balanceof >= listNft[_tokenContract][_tokenId][owner].price,"Insufficient balance");
        uint256 totalPrice = listNfts.price;

        if(!listNfts.ownerListNFT){
            IERC20(Address0xBurn).transferFrom(msg.sender,listNfts.owner,listNfts.price);
        }else{
            uint256 DAOTreasuryAmount = totalPrice.mul(20).div(100);
            uint256 teamAmount = totalPrice.mul(20).div(100);
            uint256 RewardPoolAmount = totalPrice.mul(20).div(100);
            uint256 PartnerNFTAmount = totalPrice.mul(20).div(100);

            uint256 totalPercet = DAOTreasuryAmount.add(teamAmount).add(RewardPoolAmount).add(DAOTreasuryAmount).add(PartnerNFTAmount);
            uint256 founderAmount = totalPrice.sub(totalPercet);


            IERC20(Address0xBurn).transferFrom(msg.sender,DAOTreasury,DAOTreasuryAmount);
            IERC20(Address0xBurn).transferFrom(msg.sender,teamAddress,teamAmount);
            IERC20(Address0xBurn).transferFrom(msg.sender,RewardPool,RewardPoolAmount);

            transferHoldersby0xBurn(PartnerNFTAmount);

            IERC20(Address0xBurn).transferFrom(msg.sender,listNfts.owner,founderAmount);

        }

        IERC721(_tokenContract).safeTransferFrom(address(this),msg.sender,_tokenId);
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
        }

        delete listNft[_tokenContract][_tokenId][owner];

        emit MarketItemCreated( _tokenContract, _tokenId, msg.sender, totalPrice, false, false);
    }

    /**
     * @dev Creates an auction for an ERC721 or ERC1155 token.
     * @param _tokenContract Address of the token contract.
     * @param _tokenId ID of the token being listed for auction.
     * @param _startPrice Starting price of the auction.
     * @param _duration Duration of the auction.
     * @param _type Type of token ("erc721" or "erc1155").
     * @param owner Owner of the token.
     * @param _is0xBurnRequired 0xBurn of the token.
    */

    function createAuction(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _startPrice,
        uint256 _duration,
        string memory _type,
        address owner,
        bool _is0xBurnRequired
    ) external nonReentrant {
        require(_startPrice > 0, "Start price should be greater than zero");
        require(_duration > 0, "Auction duration should be greater than zero");
        require(!auctions[_tokenContract][_tokenId][owner].setAuction, "Already set auction");
        require(!listNft[_tokenContract][_tokenId][owner].listNFT,"Nft already list for sell");

        if (keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc721"))) {
            // ERC721
            IERC721 erc721Token = IERC721(_tokenContract);
            require(erc721Token.ownerOf(_tokenId) == msg.sender, "You are not the owner of this token");
            IERC721(_tokenContract).safeTransferFrom(msg.sender, address(this), _tokenId);
        } else {
            revert("Unsupported token type");
        }

        auctions[_tokenContract][_tokenId][owner] = Auction({
            seller: msg.sender,
            tokenContract: _tokenContract,
            tokenType: _type,
            tokenId: _tokenId,
            tokenAmount: 0,
            startPrice: _startPrice,
            duration: _duration,
            setAuction: true,
            ownerListNFT: false,
            is0xBurnRequired:_is0xBurnRequired
        });

        emit AuctionCreated(msg.sender, _tokenContract, _tokenId, _startPrice, _duration);
    }

    function createAuctionbyAdmin(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _startPrice,
        uint256 _duration,
        string memory _type,
        address owner,
        bool _is0xBurnRequired
    ) external nonReentrant {
        require(_startPrice > 0, "Start price should be greater than zero");
        require(_duration > 0, "Auction duration should be greater than zero");
        require(!auctions[_tokenContract][_tokenId][owner].setAuction, "Already set auction");
        require(!listNft[_tokenContract][_tokenId][owner].listNFT,"Nft already list for sell");
        if (keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("erc721"))) {
            // ERC721
            IERC721 erc721Token = IERC721(_tokenContract);
            require(erc721Token.ownerOf(_tokenId) == msg.sender, "You are not the owner of this token");
            IERC721(_tokenContract).safeTransferFrom(msg.sender, address(this), _tokenId);
        } else {
            revert("Unsupported token type");
        }

        auctions[_tokenContract][_tokenId][owner] = Auction({
            seller: msg.sender,
            tokenContract: _tokenContract,
            tokenType: _type,
            tokenId: _tokenId,
            tokenAmount: 0,
            startPrice: _startPrice,
            duration: _duration,
            setAuction: true,
            ownerListNFT: true,
            is0xBurnRequired:_is0xBurnRequired
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
        MarketItem storage listNfts = listNft[_tokenContract][_tokenId][owner];
        require(auction.duration > 0, "Auction does not exist");
        require(auction.tokenContract == _tokenContract, "Auction does not exist");
        require(block.timestamp >= auction.duration, "Auction has not ended yet");

        address winner = highestBids[_tokenContract][_tokenId][owner].bidder;
        if(winner == address(0)){
            if (keccak256(abi.encodePacked(auction.tokenType)) == keccak256(abi.encodePacked("erc721"))) {
                // ERC721
                IERC721(_tokenContract).safeTransferFrom(address(this), auction.seller, _tokenId);
            } else {
                revert("Unsupported token type");
            }
            delete auctions[_tokenContract][_tokenId][owner];
        }else{
            uint256 totalPrice = highestBids[_tokenContract][_tokenId][owner].amount;
            auctions[_tokenContract][_tokenId][owner].duration = 0;

            (bool success, ) = auction.seller.call{value: totalPrice}("");
            require(success, "Payment to seller failed");

            IERC721(_tokenContract).safeTransferFrom(address(this), winner, _tokenId);
            delete auctions[_tokenContract][_tokenId][owner];
            delete highestBids[_tokenContract][_tokenId][owner];
            emit AuctionEnded(auction.seller, _tokenContract, _tokenId, winner, totalPrice);
        }
    }

    function endAuctionby0xBurn(address _tokenContract, uint256 _tokenId, address owner) external nonReentrant {
        Auction memory auction = auctions[_tokenContract][_tokenId][owner];
        MarketItem storage listNfts = listNft[_tokenContract][_tokenId][owner];
        require(auction.duration > 0, "Auction does not exist");
        require(auction.tokenContract == _tokenContract, "Auction does not exist");
        require(block.timestamp >= auction.duration, "Auction has not ended yet");

        address winner = highestBids[_tokenContract][_tokenId][owner].bidder;
        if(winner == address(0)){
            if (keccak256(abi.encodePacked(auction.tokenType)) == keccak256(abi.encodePacked("erc721"))) {
                // ERC721
                IERC721(_tokenContract).safeTransferFrom(address(this), auction.seller, _tokenId);
            } else {
                revert("Unsupported token type");
            }
            delete auctions[_tokenContract][_tokenId][owner];
        }else{
        uint256 totalPrice = highestBids[_tokenContract][_tokenId][owner].amount;
        auctions[_tokenContract][_tokenId][owner].duration = 0;

        if(!auction.ownerListNFT){
            IERC20(Address0xBurn).transferFrom(msg.sender, auction.seller, totalPrice);
        }else{

            uint256 DAOTreasuryAmount = totalPrice.mul(20).div(100);
            uint256 teamAmount = totalPrice.mul(20).div(100);
            uint256 RewardPoolAmount = totalPrice.mul(20).div(100);
            uint256 PartnerNFTAmount = totalPrice.mul(20).div(100);

            uint256 totalPercet = DAOTreasuryAmount.add(teamAmount).add(RewardPoolAmount).add(DAOTreasuryAmount).add(PartnerNFTAmount);
            uint256 founderAmount = totalPrice.sub(totalPercet);


            IERC20(Address0xBurn).transferFrom(msg.sender,DAOTreasury,DAOTreasuryAmount);
            IERC20(Address0xBurn).transferFrom(msg.sender,teamAddress,teamAmount);
            IERC20(Address0xBurn).transferFrom(msg.sender,RewardPool,RewardPoolAmount);

            transferHoldersby0xBurn(PartnerNFTAmount);

            IERC20(Address0xBurn).transferFrom(msg.sender,listNfts.owner,founderAmount);
        }

        IERC721(_tokenContract).safeTransferFrom(address(this), winner, _tokenId);
        delete auctions[_tokenContract][_tokenId][owner];
        delete highestBids[_tokenContract][_tokenId][owner];
        emit AuctionEnded(auction.seller, _tokenContract, _tokenId, winner, totalPrice);
      }
    }
    
}
