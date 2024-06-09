// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GamingAssets} from "../src/GamingAssets.sol";
import {GameIntegration} from "../src/GameIntegration.sol";

contract GameIntegrationTest is Test {
    GamingAssets private gamingAssets;
    GameIntegration private gameIntegration;

    address private owner = address(0x123);
    address private gameManager = address(0x456);
    address private user1 = address(0x789);
    address private user2 = address(0xabc);

    function setUp() public {

       gamingAssets = new GamingAssets("https://example.com/api/item/{id}.json");
       gamingAssets.grantRole(gamingAssets.MAINTER_ROLE(), owner);
       gameIntegration = new GameIntegration(address(gamingAssets));
       gameIntegration.grantRole(gameIntegration.GAME_MANAGER_ROLE(), gameManager);
    }   

    // Function to test asset transfer
    function testTransferAsset() public {
      vm.prank(owner);
      gamingAssets.mint(user1, gamingAssets.WEAPON(), 10, "");
      
      vm.prank(user1);
      gamingAssets.setApprovalForAll(address(gameIntegration), true);

      vm.startPrank(gameManager);
       vm.warp(block.timestamp + 2 hours);
       gameIntegration.transferAsset(user1, user2,gamingAssets.WEAPON(), 5, "");
       vm.stopPrank();
       assertEq(gamingAssets.balanceOf(user2, gamingAssets.WEAPON()), 5);
    }

    //Function to test batch transfer
    function testTransferBatchAssets() public {

      uint256[] memory ids = new uint256[](1);
      uint256[] memory amounts = new uint256[](1);
      ids[0] = gamingAssets.WEAPON();
      amounts[0] = 5;

      vm.prank(owner);
      gamingAssets.mint(user1, gamingAssets.WEAPON(), 10, "");
      
      vm.prank(user1);
      gamingAssets.setApprovalForAll(address(gameIntegration), true);

      vm.warp(block.timestamp + 2 hours);

      vm.prank(gameManager);
      gameIntegration.transferBatchAssets(user1, user2, ids, amounts, "");

      assertEq(gamingAssets.balanceOf(user2, gamingAssets.WEAPON()), 5);
    }
       
}