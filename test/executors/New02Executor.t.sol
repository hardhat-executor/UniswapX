// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {SwapRouter02Executor} from "../../src/sample-executors/SwapRouter02Executor.sol";
import {MockERC20} from "../util/mock/MockERC20.sol";
import {MockSwapRouter} from "../util/mock/MockSwapRouter.sol";
import {DutchOrderReactor} from "../../src/sample-reactors/DutchOrderReactor.sol";
import {Test} from "../../lib/forge-std/src/Test.sol";

contract SwapRouter02ExecutorReactorCallbackTest is Test {
    SwapRouter02Executor public executor;
    MockERC20 public token0;
    MockERC20 public token1;
    MockSwapRouter public swapRouter;
    address public user;

    function setUp() public {
        user = address(this);
        token0 = new MockERC20("Token0", "TK0", 18);
        token1 = new MockERC20("Token1", "TK1", 18);
        swapRouter = new MockSwapRouter();
        executor = new SwapRouter02Executor(address(swapRouter));
    }

    function testReactorCallback() public {
        uint256 amountIn = 100 ether;
        token0.mint(address(reactor), amountIn);
        token0.approve(address(executor), amountIn);

        vm.prank(address(reactor));
        executor.reactorCallback(address(token0), amountIn, user);

        assertEq(
            token0.balanceOf(user),
            amountIn,
            "User should receive the swapped amount"
        );
    }

    function testMsgSenderNotReactor() public {
        uint256 amountIn = 100 ether;
        token0.mint(user, amountIn);
        token0.approve(address(executor), amountIn);

        vm.expectRevert("Only reactor can call");
        executor.reactorCallback(address(token0), amountIn, user);
    }
}
