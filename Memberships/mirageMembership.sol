// Deployed at 0x0170227514a274826685bf81aed06e4218175572
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

// SPDX-License-Identifier: MIT
// Contract authored by August Rosedale (@augustfr)
// https://miragegallery.ai

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol"; 

interface mirageContracts {
  function balanceOf(address owner) external view returns (uint256);
}

contract mirageMembership is ERC1155Supply, Ownable  {

    uint _priceIntelligent = 0.05 ether;
    uint _priceSentient = 0.5 ether;
    uint _priceDiscIntelligent = 0.0125 ether;
    uint _priceDiscSentient = 0.25 ether;
    uint256 constant _max_intelligent = 1450;
    uint256 constant _max_sentient = 50;
    uint256 sentient = 0;
    uint256 _airdrop_available = 30;
    uint256 constant intelligentID = 50;
    string intelligentURI = 'https://ipfs.io/ipfs/Qmd68aaryxxngGSXP3FqkWjG4yZG3YGbnK8Sq97ZDnMQsZ';
    string sentientURI = 'https://ipfs.io/ipfs/QmPfjJKP4YUD9ypiYZZH57DXQEvjkjv7HikthCU3sQfWnG';
    uint256 mintActive = 1;
    mirageContracts public cryptoNative;
    mirageContracts public AlejandroAndTaylor;
    mirageContracts public earlyWorks;

    constructor() ERC1155('https://ipfs.io/ipfs') {
        
        cryptoNative = mirageContracts(0x89568Fc8d04B3f833209144b77F39b71078e3CB0);
        AlejandroAndTaylor = mirageContracts(0x63400da86a6b42dac41075667cF871a5Ef93802F);
        earlyWorks = mirageContracts(0x3Cf6e4ff99D616d44Be53E90F74eAE5D150Cb726);
    }
    
    function updateURI(string memory _intelligentURI, string memory _sentientURI) public onlyOwner {
        intelligentURI = _intelligentURI;
        sentientURI = _sentientURI;
    }
    
    function updateAirdrop(uint256 airdropAvailable) public onlyOwner {
        require((totalSupply(intelligentID) + sentient) < (_max_intelligent + _max_sentient), "None available to airdrop");
        _airdrop_available = airdropAvailable;
    }
    
    function endMint() public onlyOwner {
        mintActive = 2;
    }
    
    function startMint() public onlyOwner {
        require(mintActive != 2, "Mint has been locked");
        mintActive = 0;
    }
    
    function updatePriceIntelligent(uint256 newMainPrice, uint256 newDiscPrice) public onlyOwner {
        _priceIntelligent = newMainPrice;
        _priceDiscIntelligent = newDiscPrice;
    }
    
    function updatePriceSentient(uint256 newMainPrice, uint256 newDiscPrice) public onlyOwner {
        _priceSentient = newMainPrice;
        _priceDiscSentient = newDiscPrice;
    }
    
    function mintToSender(uint numberOfTokens, uint tokenID) internal {
        require(totalSupply(intelligentID) + sentient + (numberOfTokens) <= _max_intelligent + _max_sentient, "Minting would exceed max supply");
        _mint(msg.sender, tokenID, numberOfTokens, "");
        }
    
    function mintIntelligent(uint numberOfTokens) internal virtual {
        _mint(msg.sender, intelligentID, numberOfTokens, "");
    }
    
    function mintToAddress(uint numberOfTokens, address address_to_mint, uint tokenID) internal {
        require(totalSupply(intelligentID) + sentient + numberOfTokens <= _max_intelligent + _max_sentient, "Minting would exceed max supply");
        _mint(address_to_mint, tokenID, numberOfTokens, "");
        }

    function purchaseIntelligent(uint numberOfTokens) public payable {
        require(mintActive == 0, "Mint has not opened yet or has been locked");
        require(_airdrop_available == 0, "Airdrop has not ended");
        require(totalSupply(intelligentID) + numberOfTokens <= _max_intelligent, "Purchase would exceed max supply of tokens");
        require(numberOfTokens <= 2, "Can only purchase a maximum of 2 tokens at a time");
        if (cryptoNative.balanceOf(msg.sender) > 0 || AlejandroAndTaylor.balanceOf(msg.sender) > 0 || earlyWorks.balanceOf(msg.sender) > 0) {
            require((_priceDiscIntelligent * numberOfTokens) <= msg.value, "Ether value sent is not correct");
        } else {
            require(_priceIntelligent * numberOfTokens <= msg.value, "Ether value sent is not correct");
        }
        mintIntelligent(numberOfTokens);
    }
    
    function purchaseSentient() public payable {
        require(mintActive == 0, "Mint has not opened yet or has been locked");
        require(_airdrop_available == 0, "Airdrop has not ended");
        require(sentient < _max_sentient, "Purchase would exceed max supply of tokens");
        if (cryptoNative.balanceOf(msg.sender) > 0 || AlejandroAndTaylor.balanceOf(msg.sender) > 0 || earlyWorks.balanceOf(msg.sender) > 0) {
            require(_priceDiscSentient <= msg.value, "Ether value sent is not correct");
        } else {
            require(_priceSentient <= msg.value, "Ether value sent is not correct");
        }
        mintSentient(msg.sender);
    }
    
    function mintSentient(address address_to_mint) internal virtual {
        uint tokenID = sentient;
        _mint(address_to_mint, tokenID, 1, '');
        sentient = sentient +  1; 
    }
    
    function airdrop(address addresstm, uint numberOfTokens, uint one_intelligent_two_sentient) public onlyOwner {
        require(_airdrop_available > 0, "No airdrop tokens available");
        require(numberOfTokens <= _airdrop_available);
        _airdrop_available -= numberOfTokens;
        if (one_intelligent_two_sentient == 1) {
            mintToAddress(numberOfTokens, addresstm, intelligentID);
        } else if (one_intelligent_two_sentient == 2) {
            mintSentient(addresstm);
        }
    }

    function uri(uint tokenID) public view override returns(string memory) {
        if (tokenID == intelligentID) {
            return intelligentURI;
        } else if (tokenID < 50) {
            return sentientURI;
        } else {
            return '';
        }
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}