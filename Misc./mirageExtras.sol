// Deployed at 0x4ae83de2753beb769ae00b99ffa403017cdca806
/*
 
           M                                                 M
         M   M                                             M   M
        M  M  M                                           M  M  M
       M  M  M  M                                       M  M  M  M
      M  M  M  M  M                                    M  M  M  M  M
     M  M M  M  M  M                                 M  M  M  M  M  M  
     M  M   M  M  M  M                              M  M     M  M  M  M
     M  M     M  M  M  M                           M  M      M  M   M  M
     M  M       M  M  M  M                        M  M       M  M   M  M         
     M  M         M  M  M  M                     M  M        M  M   M  M
     M  M           M  M  M  M                  M  M         M  M   M  M
     M  M             M  M  M  M               M  M          M  M   M  M   M  M  M  M  M  M  M
     M  M               M  M  M  M            M  M        M  M  M   M  M   M  M  M  M  M  M  M  
     M  M                 M  M  M  M         M  M      M  M  M  M   M  M                  M  M
     M  M                   M  M  M  M      M  M    M  M  M  M  M   M  M                     M
     M  M                     M  M  M  M   M  M  M  M  M  M  M  M   M  M
     M  M                       M  M  M  M  M   M  M  M  M   M  M   M  M
     M  M                         M  M  M  M   M  M  M  M    M  M   M  M
     M  M                           M  M  M   M  M  M  M     M  M   M  M
     M  M                             M  M   M  M  M  M      M  M   M  M
M  M  M  M  M  M                         M   M  M  M  M   M  M  M  M  M  M  M    
                                            M  M  M  M 
                                            M  M  M  M 
                                            M  M  M  M 
                                             M  M  M  M                        M  M  M  M  M  M
                                              M  M  M  M                          M  M  M  M 
                                               M  M  M  M                         M  M  M  M 
                                                 M  M  M  M                       M  M  M  M 
                                                   M  M  M  M                     M  M  M  M 
                                                     M  M  M  M                   M  M  M  M 
                                                        M  M  M  M                M  M  M  M 
                                                           M  M  M  M             M  M  M  M 
                                                               M  M  M  M   M  M  M  M  M  M 
                                                                   M  M  M  M  M  M  M  M  M
                                                                                                                                                        
*/

// Author: August Rosedale (https://twitter.com/augustfr)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol"; 

contract mirageExtras is ERC1155Supply, Ownable  {
 using Strings for uint256;

 struct individualID {
     string tokenURI;
 }

 mapping(uint256 => individualID) specificID;

 string baseURI = 'https://ipfs.io/ipfs/';
 constructor() ERC1155(baseURI) {
 }

 function name() external pure returns (string memory) {
     return "Mirage Gallery Extras";
 }

 function symbol() external pure returns (string memory) {
     return "MGE";
 }

 function updateURI(string memory newURI, uint256 tokenID) public onlyOwner {
     specificID[tokenID].tokenURI = newURI;
 }
 
  function mint(uint numberOfTokens, uint tokenID, string memory URI) public onlyOwner {
      require(totalSupply(tokenID) == 0, "Token has already been minted");
      require(numberOfTokens > 0, "Must be greater than 0");
      specificID[tokenID].tokenURI = URI;
     _mint(msg.sender, tokenID, numberOfTokens, "");
 }
 
  function mintToAddress(uint numberOfTokens, address address_to_mint, uint tokenID) internal {
     _mint(address_to_mint, tokenID, numberOfTokens, "");
 }
 
  function airdrop(address addresstm, uint numberOfTokens, uint tokenID, string memory URI) public onlyOwner {
     require(totalSupply(tokenID) == 0, "Token has already been minted");
     require(numberOfTokens > 0, "Must be greater than 0");
     specificID[tokenID].tokenURI = URI;
     mintToAddress(numberOfTokens, addresstm, tokenID);
 }
 
 function uri(uint256 tokenID) public view override returns(string memory) {
     require(totalSupply(tokenID) > 0, "Token does not exist");
     return specificID[tokenID].tokenURI;
 }
 
 function withdraw() public onlyOwner {
     uint balance = address(this).balance;
     payable(msg.sender).transfer(balance);
 }
}