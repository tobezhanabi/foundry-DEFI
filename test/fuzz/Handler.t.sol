// use by the invariant
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";

contract Handler {
    DeployDSC deployer;
DSCEngine dsce;
DecentralizedStableCoin dsc;
HelperConfig config;
address[] memory collateralTokens = dsce.getCollateralTokens();
weth = ERC20Mock(collateralTokens[0]);
wbtc = ERC20Mock(collateralTokens[1]);

function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public{
    ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
    amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);

    vm.startPrank(msg.sender);
    collateral.mint(msg.sender, amountCollateral);
    collateral.approve(address(dsce), amountCollateral);
    dsce.depositCollateral(address(collateralSeed), amountCollateral);
    vm.stopPrank();
}

function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public{
    ERC20Mock
}


//Helper function
function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock){
    if (collateralSeed % 2 == 0) {
        return weth;

    }
    return wbtc;
}
}

