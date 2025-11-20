// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Automated Grant Disburser
 * @dev A simple smart contract for managing grant requests, approvals,
 *      and automated fund disbursement to recipients.
 */
contract Project {
    address public admin;

    struct Grant {
        address recipient;
        uint256 amount;
        bool approved;
        bool disbursed;
    }

    mapping(uint256 => Grant) public grants;
    uint256 public grantCount;

    event GrantCreated(uint256 grantId, address recipient, uint256 amount);
    event GrantApproved(uint256 grantId);
    event GrantDisbursed(uint256 grantId, address recipient, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @dev Create a new grant request.
     */
    function createGrant(address _recipient, uint256 _amount) external onlyAdmin {
        grantCount++;
        grants[grantCount] = Grant(_recipient, _amount, false, false);

        emit GrantCreated(grantCount, _recipient, _amount);
    }

    /**
     * @dev Approve a pending grant.
     */
    function approveGrant(uint256 _grantId) external onlyAdmin {
        require(_grantId > 0 && _grantId <= grantCount, "Invalid grant ID");
        Grant storage grantObj = grants[_grantId];
        require(!grantObj.approved, "Grant already approved");

        grantObj.approved = true;

        emit GrantApproved(_grantId);
    }

    /**
     * @dev Disburse an approved grant to the recipient.
     */
    function disburseGrant(uint256 _grantId) external payable onlyAdmin {
        require(_grantId > 0 && _grantId <= grantCount, "Invalid grant ID");
        Grant storage grantObj = grants[_grantId];

        require(grantObj.approved, "Grant not approved");
        require(!grantObj.disbursed, "Grant already disbursed");
        require(msg.value == grantObj.amount, "Incorrect disbursement amount");

        grantObj.disbursed = true;

        payable(grantObj.recipient).transfer(msg.value);

        emit GrantDisbursed(_grantId, grantObj.recipient, msg.value);
    }
}

