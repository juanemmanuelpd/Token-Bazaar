// License
// SPDX-License-Identifier: MIT

// Solidity Compiler Version
pragma solidity 0.8.24;

// Libraries
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Pausable.sol";

// Contract
contract tokenBazaar is ReentrancyGuard, Ownable, Pausable{

    // Variables
    mapping(address => mapping(uint256 => Listing)) public listing;
    mapping (address => bool) public blocked;
    uint256 public percentFees = 5;
    uint256 public fees;
    uint256 public sellerAmount;
    address private bazaarOwner;
    

    // Structs
    struct Listing{
        address seller;
        address nftaddress;
        uint256 tokenId;
        uint256 price;
    }

    // Events
    event e_NFTListed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event e_NFTCancelled(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);
    event e_NFTSold(address indexed buyer, address indexed seller, address indexed nftAddress, uint256 tokenId, uint256 price);
    event e_addToBlackList(address user_, bool blocked);
    event e_removeFromBlackList(address user_, bool blocked);
    event e_newFees(uint256 fees);

    // Modifiers
    modifier notBloked(){
        require (!blocked[msg.sender],"Blocked user");
        _;    
    }

    // Constructor

    constructor() Ownable(msg.sender){
        bazaarOwner = owner();
    }

    // Functions

    function listNFT(address nftAddress_, uint256 tokenId_, uint256 price_) external notBloked whenNotPaused nonReentrant {
        require(price_ > 0, "Price can not be 0");
        address owner_ = IERC721(nftAddress_).ownerOf(tokenId_);
        require(owner_ == msg.sender, "You are not the owner of the NFT");
        Listing memory listing_ = Listing({
            seller: msg.sender,
            nftaddress: nftAddress_,
            tokenId: tokenId_,
            price: price_
        });
        listing[nftAddress_][tokenId_] = listing_;
        emit e_NFTListed(msg.sender, nftAddress_, tokenId_, price_);
    }
    
    function buyNFT(address nftAddress_, uint256 tokenId_) external payable notBloked whenNotPaused nonReentrant {
        Listing memory listing_ = listing[nftAddress_][tokenId_];
        require(listing_.price > 0, "Listing not exists");
        require(msg.value == listing_.price, "Incorrect amount");
        delete listing[nftAddress_][tokenId_];
        fees = (msg.value/100) * percentFees;
        sellerAmount = msg.value - fees;
        (bool success2, ) = listing_.seller.call{value: sellerAmount}("");
        require(success2, "Fail payment");
        (bool success, ) = bazaarOwner.call{value: fees}("");
        require(success, "Failed fee payment");
        fees = 0;
        IERC721(nftAddress_).safeTransferFrom(listing_.seller, msg.sender, listing_.tokenId);
        emit e_NFTSold(msg.sender, listing_.seller, listing_.nftaddress, listing_.tokenId, listing_.price);
    }

    function modifyFees(uint256 newPercent_) external whenNotPaused onlyOwner{
        require(newPercent_ > 0 && newPercent_ < 100, "The percent is incorrect");
        percentFees = newPercent_;
        emit e_newFees(percentFees);
    }

    function cancelList(address nftAddress_, uint256 tokenId_) external notBloked whenNotPaused nonReentrant {
        Listing memory listing_ = listing[nftAddress_][tokenId_];
        require(listing_.seller == msg.sender, "You are not the listing owner");
        delete listing[nftAddress_][tokenId_];
        emit e_NFTCancelled(msg.sender, nftAddress_, tokenId_);
    } 

    function addToBlackList (address user_) external whenNotPaused onlyOwner { 
        require(!blocked[user_],"Blacklisted");
        blocked[user_] = true;
        emit e_addToBlackList (user_, blocked[user_]);
    }
        
   function removeFromBlacklist (address user_) external whenNotPaused onlyOwner { 
        require(blocked[user_],"Off the list");
        blocked[user_] = false;
        emit e_removeFromBlackList(user_, blocked[user_]);
    }

    function pausetransactions() public onlyOwner {
        require (!paused(), "The contract is paused");
        _pause();
    }

    function unpausetransactions() public onlyOwner (){
        require (paused(), "The contract is unpaused");
        _unpause();
    }


}