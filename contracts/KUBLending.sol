//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./abstracts/LendingContract.sol";
import "./modules/kkub/interfaces/IKKUB.sol";
import "./modules/kap20/interfaces/IKToken.sol";
import "./modules/kap20/KAP20.sol";

contract KUBLending is LendingContract {
    constructor(ConstructorArgs memory args) LendingContract(args) {}

    /*** User Interface ***/

    function deposit(uint256 depositAmount, address sender) external payable {
        uint256 err;
        if (msg.sender == callHelper) {
            requireKYC(sender);
            (err, ) = depositInternal(
                sender,
                depositAmount,
                TransferMethod.BK_NEXT
            );
        } else {
            uint256 amountIn = msg.value == 0 ? depositAmount : msg.value;
            (err, ) = depositInternal(
                msg.sender,
                amountIn,
                TransferMethod.METAMASK
            );
        }

        requireNoError(err, "Mint failed");
    }

    function withdraw(
        uint256 withdrawTokens,
        address payable sender
    ) external returns (uint256) {
        uint256 err;
        if (msg.sender == callHelper) {
            requireKYC(sender);
            err = withdrawInternal(
                sender,
                withdrawTokens,
                TransferMethod.BK_NEXT
            );
        } else {
            err = withdrawInternal(
                payable(msg.sender),
                withdrawTokens,
                TransferMethod.METAMASK
            );
        }
        return err;
    }

    function withdrawUnderlying(
        uint256 withdrawAmount,
        address payable sender
    ) external returns (uint256) {
        uint256 err;
        if (msg.sender == callHelper) {
            requireKYC(sender);
            err = withdrawUnderlyingInternal(
                sender,
                withdrawAmount,
                TransferMethod.BK_NEXT
            );
        } else {
            err = withdrawUnderlyingInternal(
                payable(msg.sender),
                withdrawAmount,
                TransferMethod.METAMASK
            );
        }
        return err;
    }

    function borrow(
        uint256 borrowAmount,
        address payable sender
    ) external returns (uint256) {
        uint256 err;
        if (msg.sender == callHelper) {
            requireKYC(sender);
            err = borrowInternal(sender, borrowAmount, TransferMethod.BK_NEXT);
        } else {
            err = borrowInternal(
                payable(msg.sender),
                borrowAmount,
                TransferMethod.METAMASK
            );
        }
        return err;
    }

    function repayBorrow(uint256 repayAmount, address sender) external payable {
        uint256 err;
        if (msg.sender == callHelper) {
            requireKYC(sender);
            (err, ) = repayBorrowInternal(
                sender,
                repayAmount,
                TransferMethod.BK_NEXT
            );
        } else {
            uint256 amountIn = msg.value == 0 ? repayAmount : msg.value;
            (err, ) = repayBorrowInternal(
                msg.sender,
                amountIn,
                TransferMethod.METAMASK
            );
        }
        requireNoError(err, "Repay borrow fail");
    }

    function repayBorrowBehalf(
        address borrower,
        uint256 repayAmount,
        address sender
    ) external payable {
        uint256 err;
        if (msg.sender == callHelper) {
            requireKYC(sender);
            requireKYC(borrower);
            (err, ) = repayBorrowBehalfInternal(
                sender,
                borrower,
                repayAmount,
                TransferMethod.BK_NEXT
            );
        } else {
            uint256 amountIn = msg.value == 0 ? repayAmount : msg.value;
            (err, ) = repayBorrowBehalfInternal(
                msg.sender,
                borrower,
                amountIn,
                TransferMethod.METAMASK
            );
        }
        requireNoError(err, "Repay borrow behalf failed");
    }

    function liquidateBorrow(
        uint256 input,
        uint256 minReward,
        uint256 deadline,
        address borrower,
        address payable sender
    ) external payable {
        uint256 err;

        if (msg.sender == callHelper) {
            requireKYC(sender);
            (err, ) = liquidateBorrowInternal(
                sender,
                borrower,
                input,
                minReward,
                deadline,
                TransferMethod.BK_NEXT
            );
        } else {
            (err, ) = liquidateBorrowInternal(
                payable(msg.sender),
                borrower,
                input,
                minReward,
                deadline,
                TransferMethod.METAMASK
            );
        }

        requireNoError(err, "Liquidate borrow failed");
    }

    receive() external payable {
        if (
            msg.sender != _controller.yesVault() &&
            msg.sender != underlyingToken
        ) {
            (uint256 err, ) = depositInternal(
                msg.sender,
                msg.value,
                TransferMethod.METAMASK
            );
            requireNoError(err, "Deposit failed");
        }
    }

    /*** Safe Token ***/

    function getCashPrior() internal view override returns (uint256) {
        return KAP20(underlyingToken).balanceOf(address(this));
    }

    function doTransferInBKNext(
        address from,
        uint256 amount
    ) private returns (uint256) {
        KAP20 token = KAP20(underlyingToken);
        uint256 balanceBefore = token.balanceOf(address(this));

        _transferRouter.transferFrom(
            PROJECT,
            address(token),
            from,
            address(this),
            amount
        );

        uint256 balanceAfter = token.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Transfer in overflow");
        return balanceAfter - balanceBefore; // underflow already checked above, just subtract
    }

    function doTransferInMetamask(
        address from,
        uint256 amount
    ) private returns (uint256) {
        require(msg.sender == from, "Sender mismatch");

        uint256 balanceBefore = KAP20(underlyingToken).balanceOf(address(this));

        uint256 kkubInput = amount - msg.value;

        if (msg.value > 0) {
            IKKUB(underlyingToken).deposit{value: msg.value}();
        }
        if (kkubInput > 0) {
            KAP20(underlyingToken).transferFrom(from, address(this), amount);
        }

        uint256 balanceAfter = KAP20(underlyingToken).balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Transfer in overflow");
        return balanceAfter - balanceBefore; // underflow already checked above, just subtract
    }

    function doTransferIn(
        address from,
        uint256 amount,
        TransferMethod method
    ) internal override returns (uint256) {
        // Sanity checks
        if (method == TransferMethod.BK_NEXT) {
            return doTransferInBKNext(from, amount);
        } else {
            return doTransferInMetamask(from, amount);
        }
    }

    function doTransferOut(
        address payable to,
        uint256 amount,
        TransferMethod method
    ) internal override {
        method; //unused
        KAP20(underlyingToken).transfer(to, amount);
    }

    function requireNoError(
        uint256 errCode,
        string memory message
    ) internal pure {
        if (errCode == uint256(Error.NO_ERROR)) {
            return;
        }

        bytes memory fullMessage = new bytes(bytes(message).length + 5);
        uint256 i;

        for (i = 0; i < bytes(message).length; i++) {
            fullMessage[i] = bytes(message)[i];
        }

        fullMessage[i + 0] = bytes1(uint8(32));
        fullMessage[i + 1] = bytes1(uint8(40));
        fullMessage[i + 2] = bytes1(uint8(48 + (errCode / 10)));
        fullMessage[i + 3] = bytes1(uint8(48 + (errCode % 10)));
        fullMessage[i + 4] = bytes1(uint8(41));

        require(errCode == uint256(Error.NO_ERROR), string(fullMessage));
    }
}
