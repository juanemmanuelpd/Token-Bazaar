# Token Bazaar
## Overview 🪙
A bazaar with the security and efficiency you deserve to buy/sell your NFT's.
## Features 📃
* List NFTs for easy sale.
* Cancel your NFT listing whenever you want.
* Buy NFTs using Ethereum.
* Modify the percentage of fees you will receive for each sale made in your bazaar.
* Add fraudulent users to a blacklist to prevent them from selling or buying NFTs.
* Remove fraudulent users from the blacklist when the time is right.
* In case of emergency, pause all bazaar transactions to avoid system errors or inappropriate actions by scammers and resume them when necessary.
* All smart contract functions tested.
## Technical details ⚙️
* Framework CLI -> Foundry.
* Forge version -> 1.1.0-stable.
* Solidity compiler version -> 0.8.24.
## Deploying the contract 🛠️
1. Clone the GitHub repository.
2. Open Visual Studio Code (you should already have Foundry installed).
3. Select "File" > "Open Folder", select the cloned repository folder.
4. In the project navigation bar, open the "TokenBazaar.sol" file located in the "src" folder.
5. In the toolbar above, select "Terminal" > "New Terminal".
6. Select the "Git bash" terminal (previously installed).
7. Run the `forge build` command to compile the script.
8. In the project navigation bar, open the "TokenBazaar.t.sol" file located in the "test" folder.
9. Run the command `forge test --match-test` followed by the name of a test function to test it and verify the smart contract functions are working correctly. For example, run `forge test --match-test testMintNFT -vvvv` to test the `testMintNFT` function.
10. Run `forge coverage` to generate a code coverage report, which allows you to verify which parts of the "NFTMarketplace.sol" script code (in the "src" folder) are executed by the tests. This helps identify areas outside the coverage that could be exposed to errors/vulnerabilities.
## Functions 
* `listNFT()` -> Puts an NFT up for sale using the parameters seller, nftaddress, tokenId, and price
* `cancelList()` -> Allows the owner of a listed NFT to cancel the sale of the NFT at any time.
* `buyNFT()` -> Allows any user to purchase the listed NFTs.
* `modifyFees()` -> The owner modifies the percentage of fees received for each NFT sale made in the Bazaar.
* `addToBlackList()` -> The owner can add any fraudulent user to a blacklist to prevent them from selling or buying NFTs within the bazaar.
* `removeFromBlacklist()` -> The owner can remove from the blacklist any user on it who has already been investigated and deserves to continue operating in the marketplace.
* `pausetransactions()` -> The owner can pause all transactions in the bazaar in case of emergency.
* `unpausetransactions()` -> The owner can resume all transactions in the bazaar when he considers that there are no longer risks to operate.
## Testing functions ⌨️
* `testMintNFT()` -> Verify that the NFT has been correctly minted to the user to perform the tests.
* `testShouldRevertIfPriceIsZero()` -> The test reverts if the price of the NFT to be listed is 0.
* `testShouldRevertIfNotOwner()` -> The test reverts if a user tries to list an NFT they do not own.
* `testListNFTCorrectly()` -> Verify that the user correctly lists the NFT.
* `testCancelListShouldRevertIfNotOwner()` -> The test reverts if a user tries to cancel the sale of an NFT they do not own.
* `testCancelListShouldWorkCorrectly()` -> Verifies that a user can successfully cancel a listed NFT they own.
* `testCanNotBuyUnlistedNFT()` -> The test should revert if you try to buy an NFT that is not listed by a user.
* `testCanNotBuyWithIncorrectPay()` -> The test reverts if a user attempts to purchase an NFT with an amount different from the price. It must be the exact same amount of Ether as the price of the NFT.
* `testShouldBuyNFTCorrectly()` -> Verify that any user can successfully purchase an NFT.
* `testOwnerCanModifyPercentFeesCorrectly()` -> Verify that the owner can correctly modify the fee percentage, which must be between 1 and 99%.
* `testOwnerCanAddToBlackListCorrectly()` -> Verify that the owner can add any user to the blacklist as long as that user is not already blocked.
* `testOwnerCanRemoveFromBlackListCorrectly()` -> Verify that the owner can remove any user from the blacklist while this user is there.
* `testOwnerCanPauseTheContract()` -> Verify that the owner can pause the bazaar contract as long as it is not already paused.
* `testOwnerCanUnpauseTheContract()` -> Verify that the owner can unpause the bazaar contract.
* `testUserCanNotListIfIsBlocked()` -> Verify that any blocked user cannot sell NFTs on the bazaar.
* `testUserCanNotCancelListIfIsBlocked()` -> Verify that any blocked user cannot delete NFTs for sale in the bazaar.
* `testUserCanNotBuyIfIsBlocked()` -> Ensure that any blocked user cannot purchase NFTs in the bazaar.

## Forge Coverage
![Forge Coverage](images/forgeCoverage.png)
  
CODE IS LAW!
