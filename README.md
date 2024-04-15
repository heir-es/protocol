## Description
A contract that leverages ERC6551 (referred in contracts as Sentience Module or just Module) to transfer assets in case of death of owner.

Requires the owner of the ERC6551 NFT to approve this contract and then set module within the contract.    

Lets say the owner sets for a 1 day timer.  
Then the owner is required to log in the contract before this 1 day timer expires to reset the timer, otherwise the set beneficiary of the will can claim and receive the ERC6551 NFT.

Note: anyone can call the claim function in case of owner not reseting timer after expiry of said timer, this is to allow bots to claim on behalf of the beneficiary.

Supports cases where owner will transfer NFT to another user, which would making this will testment contract redundant, instead only resets the values.

ERC6551 is a previously created module by SophiaVerse, an example of such module can be found on this address at ethereum mainnet : 0x13038fC10B77272f17803bD37eCEc5700C2909a3

## User flow:

- User approves Sentience Module ( erc6551 with erc721 nft approveForAll = **true** )
- User sets module beneficiary and timer on respective module and token id, with *setModule* function
- User must reset timer before timer chosen in *setModule* passes by, by using *resetModule* function
- If User does not reset timer and timer passes by, Beneficiary or other users can claim for Beneficiary wallet address, by using *claimModule*
- User can choose to set a different timer on *resetModule*
- User can choose different timer and beneficiary on *setModule* if timer has not expired

## Limitations:
- Has the Module is also an ERC721, user can at any time revoke approval (approveForAll = **false**) to **heirloom.sol** making the contract innefective for *claimModule*  
- Has the Module is also an ERC721, user can at any time transfer it to anyone else, making the contract innefective, and the new owner has to *setModule* or *claimModule* to use that Module for himself with his settings  