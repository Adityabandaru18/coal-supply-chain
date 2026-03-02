// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MiningRegistry.sol";

/*
    INDUSTRY CONSUMER
    - Final consumption stage
*/

contract IndustryConsumer {

    address public factory;

    constructor(address _factory) {
        factory = _factory;
    }

    mapping(address => bool) public authorizedIndustry;

    event BatchConsumed(uint256 batchId, uint256 powerGenerated);

    modifier onlyFactory() {
        require(msg.sender == factory, "Only factory");
        _;
    }

    modifier onlyIndustry() {
        require(authorizedIndustry[msg.sender], "Not industry");
        _;
    }

    function authorizeIndustry(address industryAddr) external onlyFactory {
        authorizedIndustry[industryAddr] = true;
    }

    function consumeBatch(
        address miningAddress,
        uint256 batchId,
        uint256 powerGenerated
    ) external onlyIndustry {

        MiningRegistry mining = MiningRegistry(miningAddress);

        require(
            mining.getStatus(batchId) ==
                MiningRegistry.BatchStatus.Delivered,
            "Not delivered"
        );

        mining.updateStatus(
            batchId,
            MiningRegistry.BatchStatus.Consumed
        );

        emit BatchConsumed(batchId, powerGenerated);
    }
}