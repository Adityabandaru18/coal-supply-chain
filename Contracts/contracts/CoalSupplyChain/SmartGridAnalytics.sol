// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    SMART GRID ANALYTICS
    - Reads blockchain events
    - Governance monitoring
*/

contract SmartGridAnalytics {

    address public factory;

    constructor(address _factory) {
        factory = _factory;
    }

    mapping(address => bool) public authorizedGrids;

    event GridAudit(address grid);

    modifier onlyFactory() {
        require(msg.sender == factory, "Only factory");
        _;
    }

    modifier onlyGrid() {
        require(authorizedGrids[msg.sender], "Not grid");
        _;
    }

    function authorizeGrid(address grid) external onlyFactory {
        authorizedGrids[grid] = true;
    }

    function recordAudit() external onlyGrid {
        emit GridAudit(msg.sender);
    }
}