// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./GamingAssets.sol";
import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

contract GameIntegration is AccessControl {
    GamingAssets private gamingAssets;

    mapping(address => mapping(uint256 => uint256)) public lastTransferTime; //tracks the last transfer time for each asset by each address
    
    uint256 public transferCooldown = 1 hours;

    bytes32 public constant GAME_MANAGER_ROLE = keccak256("GAME_MANAGER_ROLE");

    constructor(address gamingAssetsAddress){
         gamingAssets = GamingAssets(gamingAssetsAddress);
         _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
         _grantRole(GAME_MANAGER_ROLE, msg.sender);
    }
    
    //Function to transfer an asset with game-specific logic 
    function transferAsset(address from, address to, uint256 id, uint256 amount, bytes memory data) external onlyRole(GAME_MANAGER_ROLE){

        //check conditions
        require(block.timestamp - lastTransferTime[from][id] >= transferCooldown,"Transfer cooldown period not met"); 
        require(gamingAssets.balanceOf(from, id) >= amount, "Insufficient balance");

        //Update state (update last transfer time)
        lastTransferTime[from][id] = block.timestamp;

        //Interact with other contracts (Perform the asset Transfer)
        gamingAssets.safeTransferFrom(from, to, id, amount, data);
    }

    //Function to batch transfer assets with game-specific logic 
    function transferBatchAssets(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data )external onlyRole(GAME_MANAGER_ROLE){
        // check conditions
       for(uint256 i=0; i< ids.length ;i++){
         require(block.timestamp - lastTransferTime[from][ids[i]] >= transferCooldown, "ransfer cooldown period not met for one of the assets");
         require(gamingAssets.balanceOf(from, ids[i]) >= amounts[i], "Insufficient balance for one of the assets");
       }

        // Update state
        for (uint256 i = 0; i < ids.length; i++) {
            lastTransferTime[from][ids[i]] = block.timestamp;
        }

       // Interact with other contracts (perform the batch asset transfer) 
       gamingAssets.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    //Function to get asset information from GamingAssets contract
    function getAssetInfo(uint256 id) external view returns(string memory name, string memory description){
        return gamingAssets.assetInfo(id);
    }

    //Function to set transfer cooldown period
    function setTransferCooldown(uint256 newCooldown) external {
        transferCooldown = newCooldown;
    }
    

}