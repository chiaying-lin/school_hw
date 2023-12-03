// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {CErc20Delegator} from "compound-protocol/contracts/CErc20Delegator.sol";
import {Unitroller} from "compound-protocol/contracts/Unitroller.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Comptroller} from "compound-protocol/contracts/Comptroller.sol";
import {SimplePriceOracle} from "compound-protocol/contracts/SimplePriceOracle.sol";
import {WhitePaperInterestRateModel} from "compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import {CErc20Delegate} from "compound-protocol/contracts/CErc20Delegate.sol";

contract UnderlyingToken is ERC20 {
    constructor() ERC20("Joy token", "JT") {}
}

contract MyScript is Script {
    ERC20 underlying_token;
    Comptroller comptroller;
    SimplePriceOracle oracle;
    WhitePaperInterestRateModel whitePaperModel;
    CErc20Delegate cERC20_impl;
    address admin;
    function setUp() public {
    }   

    function run() public {
        uint256 userPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(userPrivateKey);
        
        admin = vm.envAddress("ADMIN");
        underlying_token = new UnderlyingToken();
        comptroller = new Comptroller();
        whitePaperModel = new WhitePaperInterestRateModel(0, 0);
        cERC20_impl = new CErc20Delegate();
        oracle = new SimplePriceOracle();

        CErc20Delegator delegator = new CErc20Delegator(
                address(underlying_token),
                comptroller,
                whitePaperModel,
                1e18,
                "Compound Joy Token",
                "cJT",
                18,
                payable(admin),
                address(cERC20_impl),
                new bytes(0)
         );

        Unitroller unitroller = new Unitroller();
        unitroller._setPendingImplementation(address(comptroller));
        comptroller._become(unitroller);
        comptroller._setPriceOracle(oracle);
        unitroller._acceptImplementation();
        vm.stopBroadcast();
    }
}