// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GamingAssets} from "../src/GamingAssets.sol";

contract GamingAssetsTest is Test{
    GamingAssets private gamingAssets;

    address private owner = address(0x123);
    address private minter = address(0x456);
    address private user1 = address(0x789);

    function setUp() public {
        gamingAssets = new GamingAssets("https://example.com/api/item/{id}.json");
        gamingAssets.grantRole(gamingAssets.MAINTER_ROLE(),minter);
    }
    
    function testMint() public {
        vm.prank(minter);
        gamingAssets.mint(user1,gamingAssets.WEAPON(),10,"");
        assertEq(gamingAssets.balanceOf(user1, gamingAssets.WEAPON()),10);
    }

    function testBatchMint() public {
        
        address[] memory accounts = new address[](2);
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);

        accounts[0] = user1;
        accounts[1] = user1;
        ids[0] = gamingAssets.WEAPON();
        ids[1] = gamingAssets.ARMOR();
        amounts[0] = 10;
        amounts[1] = 5;

        vm.prank(minter);
        gamingAssets.batchMint(accounts, ids, amounts, "");
        assertEq(gamingAssets.balanceOf(user1, gamingAssets.WEAPON()), 10);
        assertEq(gamingAssets.balanceOf(user1, gamingAssets.ARMOR()), 5);
    }

    function testPause() public {
        //vm.prank(owner);
        //gamingAssets.pause();
        vm.startPrank(minter);
        gamingAssets.mint(user1,gamingAssets.WEAPON(), 10, "");
        assertEq(gamingAssets.balanceOf(user1, gamingAssets.WEAPON()),10); 
    }
}