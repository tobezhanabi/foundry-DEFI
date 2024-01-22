// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import{Test} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol"; 
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract DSCEngineTest is Test{
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    DSCEngine dsce;
    HelperConfig config;
    address ethUsdPriceFeed;
    address btcUsdPriceFeed;
    address weth;
    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;
    uint256 amountToMint =100 ether;
    uint256 amountToBurn =50 ether;
    uint256 amountCollateral =10 ether;


    function setUp()public{
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth,,  ) = config.activeNetworkConfig();
        ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE);

    }
    /**CONSTRUCTIN TEST */
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;
     function testRevertsIfTokenLengthDoesntMatchPricefeeds()public{
        tokenAddresses.push(weth);
        priceFeedAddresses.push(ethUsdPriceFeed);
        priceFeedAddresses.push(btcUsdPriceFeed);
        vm.expectRevert(DSCEngine.DSCEngine__TokenAddessesANdPriceFeedAddressMustBeSomeLength.selector);
        new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
     }
    /**PRICE Test */
    function testGetUsdValue()public{
        uint256 ethAmount = 15e18;
        uint256 expectedUsd = 30000e18;
        uint256 actualUsd = dsce.getUsdValue(weth, ethAmount);
        assertEq(expectedUsd, actualUsd);
    }
    function testGetTokenAmountFromUsd() public{
        uint256 usdAmount = 100 ether;
        uint256 expectedWeth = 0.05 ether;
        uint256 actualWeth = dsce.getTokenAmountFromUsd(weth, usdAmount);
        assertEq(expectedWeth, actualWeth);
    }
    /**DEPOSIT COLLATERAL Test */
    function testRevertIfCollateralZero() public{
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);
        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        dsce.depositCollateral(weth, 0);
        vm.stopPrank();
    }

    function testRevertsWithUnapprovedCollateral() public{
        ERC20Mock ranToken = new ERC20Mock("RAN", "RAN", USER, AMOUNT_COLLATERAL);
        vm.startPrank(USER);
        vm.expectRevert(DSCEngine.DSCEngine__NotAllowedToken.selector);
        dsce.depositCollateral(address(ranToken), AMOUNT_COLLATERAL);
        vm.stopPrank();
    }

    modifier  depositCollateral() 
    {
    vm.startPrank(USER);
    ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);
    dsce.depositCollateral(weth, AMOUNT_COLLATERAL);
    vm.stopPrank();
    _;    
    }
      modifier  depositCollateralAndMintDSC() 
    {
    vm.startPrank(USER);
    ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);
    dsce.depositCollateralAndMintDSC(weth, AMOUNT_COLLATERAL,amountToMint);
    vm.stopPrank();
    _;    
    }

    function testCanDepositedCollateralAndGetAccountInfo() public depositCollateral{
        (uint256 totalDSCMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(USER);
        uint256 expectedTotalDSCMinted = 0;
        uint256 expectedCollateralValueInUsd = dsce.getTokenAmountFromUsd(weth, collateralValueInUsd);
        assertEq(totalDSCMinted, expectedTotalDSCMinted);
        assertEq(AMOUNT_COLLATERAL, expectedCollateralValueInUsd);

    }
    function testCanMintDSC() public{
        vm.startPrank(USER);

    }
    /**BUrn */
    function testRevertIfBurnAmountIsZero () public{
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);
         dsce.depositCollateralAndMintDSC(weth, amountCollateral, amountToMint);
         vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        dsce.burnDSC(0);
        vm.stopPrank();
    }
     function testCantBurnMoreThanUserHas() public {
        vm.startPrank(USER);
        vm.expectRevert();
        dsce.burnDSC(1);
        vm.stopPrank();
     }
     function testCanBurnDsc() public depositCollateralAndMintDSC{
        vm.startPrank(USER);
        dsc.approve(address(dsce), amountToMint);
        
        dsce.burnDSC(amountToBurn);
        vm.stopPrank();
        uint256 userBalance = dsc.balanceOf(USER);
         assertEq(userBalance, amountToBurn);
     }
}
