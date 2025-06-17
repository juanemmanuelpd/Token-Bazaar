// License
// SPDX-License-Identifier: MIT

// Solidity Compiler Version
pragma solidity 0.8.24;

// Libraries
import "forge-std/Test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../src/TokenBazaar.sol";

// Contracts
contract mockNFT is ERC721{

    // Constructor
    constructor() ERC721("MockNFT", "MNFT"){
        
    }

    // Functions
    function mint(address to_, uint256 tokenId_) external {
        _mint(to_, tokenId_);
    }

}

contract tokenBazaarTest is Test {

    tokenBazaar tokenBazaarTesting;
    mockNFT mockNFTTesting;
    address owner = vm.addr(1);
    address user = vm.addr(2);
    uint256 tokenId = 0;

    function setUp() public {
        vm.startPrank(owner);
        tokenBazaarTesting = new tokenBazaar();
        mockNFTTesting = new mockNFT();
        vm.stopPrank();
        
        vm.startPrank(user);
        mockNFTTesting.mint(user, tokenId);
        vm.stopPrank();
    }

    function testMintNFT() public view  {
        address ownerNFT = mockNFTTesting.ownerOf(tokenId);
        assert(ownerNFT == user);
    }

    function testShouldRevertIfPriceIsZero() public {
        vm.startPrank(user);
        vm.expectRevert("Price can not be 0");
        tokenBazaarTesting.listNFT(address(mockNFTTesting), tokenId, 0);
        vm.stopPrank();
    }

    function testShouldRevertIfNotOwner() public {
        vm.startPrank(user);
        address user2_ = vm.addr(3);
        uint256 tokenId_ = 1;
        mockNFTTesting.mint(user2_, tokenId_);
        vm.expectRevert("You are not the owner of the NFT");
        tokenBazaarTesting.listNFT(address(mockNFTTesting), tokenId_, 1);
        vm.stopPrank();
    }

    function testListNFTCorrectly() public{
        vm.startPrank(user);
        (address sellerBefore,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);
        tokenBazaarTesting.listNFT(address(mockNFTTesting), tokenId, 1);
        (address sellerAfter,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);
        assert(sellerBefore == address(0) && sellerAfter == user);
        vm.stopPrank();
    }
    
    function testCancelListShouldRevertIfNotOwner() public {
        vm.startPrank(user);
        (address sellerBefore,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);
        tokenBazaarTesting.listNFT(address(mockNFTTesting), tokenId, 1);
        (address sellerAfter,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);
        assert(sellerBefore == address(0) && sellerAfter == user);
        vm.stopPrank();

        address user2 = vm.addr(3);
        vm.startPrank(user2);
        vm.expectRevert("You are not the listing owner");
        tokenBazaarTesting.cancelList(address(mockNFTTesting), tokenId);
        vm.stopPrank();
    }

    function testCancelListShouldWorkCorrectly() public {
        vm.startPrank(user);
        (address sellerBefore,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);
        tokenBazaarTesting.listNFT(address(mockNFTTesting), tokenId, 1);
        (address sellerAfter,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);
        assert(sellerBefore == address(0) && sellerAfter == user);
        tokenBazaarTesting.cancelList(address(mockNFTTesting), tokenId);
        (address sellerAfter2,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);
        assert(sellerAfter2 == address(0));
        vm.stopPrank();
    }

    function testCanNotBuyUnlistedNFT() public {
        address user2 = vm.addr(3);
        vm.startPrank(user2);
        vm.expectRevert("Listing not exists");
        tokenBazaarTesting.buyNFT(address(mockNFTTesting), tokenId);
        vm.stopPrank();
    }

    function testCanNotBuyWithIncorrectPay() public {
        vm.startPrank(user);
        uint256 price = 1e18;
        (address sellerBefore,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);
        tokenBazaarTesting.listNFT(address(mockNFTTesting), tokenId, price);
        (address sellerAfter,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);
        assert(sellerBefore == address(0) && sellerAfter == user);
        vm.stopPrank();

        address user2 = vm.addr(3);
        vm.startPrank(user2);
        vm.deal(user2, price);
        vm.expectRevert("Incorrect amount");
        tokenBazaarTesting.buyNFT{value: price -1}(address(mockNFTTesting), tokenId);
        vm.stopPrank();
    }

    function testShouldBuyNFTCorrectly() public {
        vm.startPrank(user);
        uint256 price = 1e18;
        (address sellerBefore,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);
        tokenBazaarTesting.listNFT(address(mockNFTTesting), tokenId, price);
        (address sellerAfter,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);
        assert(sellerBefore == address(0) && sellerAfter == user);
        mockNFTTesting.approve(address(tokenBazaarTesting), tokenId);
        vm.stopPrank();

        address user2 = vm.addr(3);
        vm.startPrank(user2);
        vm.deal(user2, 2e18);
        uint256 balanceBefore = address(user).balance;
        address ownerBefore = mockNFTTesting.ownerOf(tokenId);
        (address sellerBefore2,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);
        tokenBazaarTesting.buyNFT{value: price}(address(mockNFTTesting), tokenId);
        (address sellerAfter2,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);   
        address ownerAfter = mockNFTTesting.ownerOf(tokenId);  
        uint256 balanceAfter = address(user).balance;
        assert(sellerBefore2 == user && sellerAfter2 == address(0));
        assert(ownerBefore == user && ownerAfter == user2);
        assert(balanceAfter == balanceBefore + tokenBazaarTesting.sellerAmount());
        vm.stopPrank();
    }

    function testOwnerCanModifyPercentFeesCorrectly() public{
       vm.startPrank(owner);
       uint256 percentBefore = tokenBazaarTesting.percentFees();
       uint256 newPercent = 30;
       tokenBazaarTesting.modifyFees(newPercent);
       uint256 percentAfter =  tokenBazaarTesting.percentFees();
       assert(percentAfter != percentBefore);
       vm.stopPrank(); 
    }

    function testOwnerCanAddToBlackListCorrectly() public{
       vm.startPrank(owner);
       tokenBazaarTesting.addToBlackList(user);
       assert(tokenBazaarTesting.blocked(user) == true);
       vm.stopPrank(); 
    }

    function testOwnerCanRemoveFromBlackListCorrectly() public{
       vm.startPrank(owner);
       tokenBazaarTesting.addToBlackList(user);
       tokenBazaarTesting.removeFromBlacklist(user);
       assert(tokenBazaarTesting.blocked(user) == false);
       vm.stopPrank(); 
    }

    function testOwnerCanPauseTheContract() public{
       vm.startPrank(owner);
       tokenBazaarTesting.pausetransactions();
       assert(tokenBazaarTesting.paused());
       vm.stopPrank(); 
    }

    function testOwnerCanUnpauseTheContract() public{
       vm.startPrank(owner);
       tokenBazaarTesting.pausetransactions();
       tokenBazaarTesting.unpausetransactions();
       assert(!tokenBazaarTesting.paused());
       vm.stopPrank(); 
    }

    function testUserCanNotListIfIsBlocked() public{
       vm.startPrank(owner);
       tokenBazaarTesting.addToBlackList(user);
       vm.stopPrank(); 

       vm.startPrank(user);
       vm.expectRevert();
       tokenBazaarTesting.listNFT(address(mockNFTTesting), tokenId, 1);
       vm.stopPrank();
    }

    function testUserCanNotCancelListIfIsBlocked() public{
       vm.startPrank(owner);
       tokenBazaarTesting.addToBlackList(user);
       vm.stopPrank(); 

       vm.startPrank(user);
       vm.expectRevert();
       tokenBazaarTesting.cancelList(address(mockNFTTesting), tokenId);
       vm.stopPrank();
    }

    function testUserCanNotBuyIfIsBlocked() public{
       address user2 = vm.addr(3);
       vm.startPrank(owner);
       tokenBazaarTesting.addToBlackList(user2);
       vm.stopPrank(); 

       vm.startPrank(user);
       uint256 price = 1e18;
       (address sellerBefore,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);
       tokenBazaarTesting.listNFT(address(mockNFTTesting), tokenId, price);
       (address sellerAfter,,,) = tokenBazaarTesting.listing(address(mockNFTTesting), tokenId);
       assert(sellerBefore == address(0) && sellerAfter == user);
       mockNFTTesting.approve(address(tokenBazaarTesting), tokenId);
       vm.stopPrank();


       vm.startPrank(user2);
       vm.deal(user2, 2e18);
       vm.expectRevert();
       tokenBazaarTesting.buyNFT{value: price}(address(mockNFTTesting), tokenId);
       vm.stopPrank();
    }
}