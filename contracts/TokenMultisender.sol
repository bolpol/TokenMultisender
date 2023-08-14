// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";

// @title TokenMultisender - Batch ERC20 token sender.
// @author Pavlo Bolhar <https://github.com/bolpol>
//
// Features:
//  - support ONLY ERC20;
//  - spam functionality;
//  - batch transfer without validation;
//  - batch transfer with validation.

contract TokenMultisender is Context {
	using SafeERC20 for IERC20;

	error ListLengthMismatch();
	error TokenIsEOA();
	error ZeroAddressSending(uint256 index);
	error ZeroAmountSending(uint256 index);

	// @dev Gas efficient batch transfer, data MUST be validate before call in fn. `validate`.
	function send(
		IERC20 _token,
		address[] calldata _accounts,
		uint256[] calldata _amounts
	) external {
		address sender = _msgSender();
		for (uint256 i; i < _accounts.length; ) {
			_token.safeTransferFrom(sender, _accounts[i], _amounts[i]);

			unchecked {
				++i;
			}
		}
	}

	// @dev Gas efficient batch transfer, amount is equal for all recipients.
	function spam(
		IERC20 _token,
		address[] calldata _accounts,
		uint256 _amount
	) external {
		require(_amount > 0, "Zero amount set");

		address sender = _msgSender();
		for (uint256 i; i < _accounts.length; ) {
			_token.safeTransferFrom(sender, _accounts[i], _amount);

			unchecked {
				++i;
			}
		}
	}

	// @dev Batch token transfer with validation on chain.
	function safeSend(
		IERC20 _token,
		address[] calldata _accounts,
		uint256[] calldata _amounts
	) external {
		_validate(address(_token), _accounts, _amounts);

		address sender = _msgSender();
		for (uint256 i; i < _accounts.length; ) {
			_token.safeTransferFrom(sender, _accounts[i], _amounts[i]);

			unchecked {
				++i;
			}
		}
	}

	// @dev Pre-validation batch tnx.
	function validate(
		address _token,
		address[] calldata _accounts,
		uint256[] calldata _amounts
	) external view returns (bool checkPassed) {
		checkPassed = _validate(_token, _accounts, _amounts);
	}

	function _validate(
		address _token,
		address[] calldata _accounts,
		uint256[] calldata _amounts
	) internal view returns (bool checkPassed) {
		if (!Address.isContract(_token)) revert TokenIsEOA();
		if (_accounts.length != _amounts.length) revert ListLengthMismatch();

		for (uint256 i; i < _accounts.length; ) {
			if (_accounts[i] == address(0)) revert ZeroAddressSending(i);
			if (_amounts[i] == uint256(0)) revert ZeroAddressSending(i);

			unchecked {
				++i;
			}
		}

		checkPassed = true;
	}
}
