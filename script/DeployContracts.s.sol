// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {GamingAssets} from "../src/GamingAssets.sol";
import {GameIntegration} from "../src/GameIntegration.sol";

contract DeployContracts is Script {
    function setUp() public {
    }

    function run() public {
        // Define the deployer
        address deployer = msg.sender;

        //start broadcasting transactions
        vm.startBroadcast(deployer);

        // Deploy Gaming Assets contract
        GamingAssets gamingAssets =  new GamingAssets("https://example.com/api/item/{id}.json");
        console.log("GamingAssets deployed at:", address(gamingAssets));

        //Grant the Minter_Role to the deployer 
        gamingAssets.grantRole(gamingAssets.MAINTER_ROLE(), deployer);
        console.log("Granted MINTER_ROLE to:", deployer);

        //Deploy GameIntegration contract
        GameIntegration gameIntegration = new GameIntegration(address(gamingAssets));
        console.log("GameIntegration deployed at:", address(gameIntegration));

        //Grant the Game_Manager_Role to the deployer
        gameIntegration.grantRole(gameIntegration.GAME_MANAGER_ROLE(), deployer);
        console.log("Granted GAME_MANAGER_ROLE to:", deployer);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
