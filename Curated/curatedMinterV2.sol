// Deployed at 0xE4C2BF5E734A23e426022bb0b785804C87684A3d
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
 
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

interface curatedContract {
    function projectIdToArtistAddress(uint256 _projectId) external view returns (address payable);
    function projectIdToPricePerTokenInWei(uint256 _projectId) external view returns (uint256);
    function projectIdToAdditionalPayee(uint256 _projectId) external view returns (address payable);
    function projectIdToAdditionalPayeePercentage(uint256 _projectId) external view returns (uint256);
    function mirageAddress() external view returns (address payable);
    function miragePercentage() external view returns (uint256);
    function mint(address _to, uint256 _projectId, address _by) external returns (uint256 tokenId);
    function earlyMint(address _to, uint256 _projectId, address _by) external returns (uint256 _tokenId);
    function balanceOf(address owner) external view returns (uint256);
}

interface mirageContracts {
    function balanceOf(address owner, uint256 _id) external view returns (uint256);
}

contract curatedMinterV2 is Ownable {

    curatedContract public mirageContract;
    mirageContracts public membershipContract;

    uint256 public maxPubMint = 10;
    uint256 public maxPreMint = 3;

    mapping(uint256 => bool) public excluded;

    constructor(address _mirageAddress, address _membershipAddress) {
        mirageContract = curatedContract(_mirageAddress);
        membershipContract = mirageContracts(_membershipAddress);
    }
    
    function purchase(uint256 _projectId, uint256 numberOfTokens) public payable {
        require(!excluded[_projectId], "Project cannot be minted through this contract");
        require(numberOfTokens <= maxPubMint, "Can only mint 10 per transaction");
        require(msg.value >= mirageContract.projectIdToPricePerTokenInWei(_projectId) * numberOfTokens, "Must send minimum value to mint!");
        _splitFundsETH(_projectId, numberOfTokens);
        for(uint i = 0; i < numberOfTokens; i++) {
            mirageContract.mint(msg.sender, _projectId, msg.sender);  
        }
    }

    function earlyPurchase(uint256 _projectId, uint256 _membershipId, uint256 numberOfTokens) public payable {
        require(!excluded[_projectId], "Project cannot be minted through this contract");
        require(membershipContract.balanceOf(msg.sender,_membershipId) > 0, "No membership tokens in this wallet");
        require(numberOfTokens <= maxPreMint, "Can only mint 3 per transaction for presale minting");
        require(msg.value>=mirageContract.projectIdToPricePerTokenInWei(_projectId) * numberOfTokens, "Must send minimum value to mint!");
        _splitFundsETH(_projectId, numberOfTokens);
        for(uint i = 0; i < numberOfTokens; i++) {
            mirageContract.earlyMint(msg.sender, _projectId, msg.sender);
        }
    }

    function toggleProject(uint256 _projectId) public onlyOwner {
        excluded[_projectId] = !excluded[_projectId];
    }

    function updateMintLimits(uint256 _preMint, uint256 _pubMint) public onlyOwner { 
        maxPubMint = _pubMint;
        maxPreMint = _preMint;
    }

    function _splitFundsETH(uint256 _projectId, uint256 numberOfTokens) internal {
        if (msg.value > 0) {
            uint256 mintCost = mirageContract.projectIdToPricePerTokenInWei(_projectId) * numberOfTokens;
            uint256 refund = msg.value - (mirageContract.projectIdToPricePerTokenInWei(_projectId) * numberOfTokens);
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        uint256 mirageAmount = mintCost / 100 * mirageContract.miragePercentage();
        if (mirageAmount > 0) {
            payable(mirageContract.mirageAddress()).transfer(mirageAmount);
        }
        uint256 projectFunds = mintCost - mirageAmount;
        uint256 additionalPayeeAmount;
        if (mirageContract.projectIdToAdditionalPayeePercentage(_projectId) > 0) {
            additionalPayeeAmount = projectFunds / 100 * mirageContract.projectIdToAdditionalPayeePercentage(_projectId);
            if (additionalPayeeAmount > 0) {
            payable(mirageContract.projectIdToAdditionalPayee(_projectId)).transfer(additionalPayeeAmount);
            }
        }
        uint256 creatorFunds = projectFunds - additionalPayeeAmount;
        if (creatorFunds > 0) {
            payable(mirageContract.projectIdToArtistAddress(_projectId)).transfer(creatorFunds);
        }
        }
    }
}