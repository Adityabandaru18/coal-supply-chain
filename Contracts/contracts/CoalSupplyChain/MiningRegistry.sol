// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    MINING REGISTRY
    - Creates coal batches
    - Maintains lifecycle status
*/

contract MiningRegistry {

    address public factory;

    // contracts (or factory) that are allowed to update batch status
    mapping(address => bool) public authorizedUpdaters;

    constructor(address _factory) {
        factory = _factory;
        authorizedUpdaters[_factory] = true;
    }

    enum BatchStatus {
        Created,
        Certified,
        InTransit,
        Delivered,
        Consumed
    }

    struct CoalBatch {
        uint256 id;
        address miner;
        string location;
        string grade;
        uint256 quantity;
        uint256 timestamp;
        BatchStatus status;
    }

    uint256 public batchCounter;

    mapping(uint256 => CoalBatch) public batches;
    mapping(address => bool) public authorizedMiners;

    event BatchCreated(uint256 id);
    event StatusUpdated(uint256 id, BatchStatus status);

    modifier onlyFactory() {
        require(msg.sender == factory, "Only factory");
        _;
    }

    modifier onlyMiner() {
        require(authorizedMiners[msg.sender], "Not miner");
        _;
    }

    modifier onlyAuthorizedUpdater() {
        require(authorizedUpdaters[msg.sender], "Not authorized updater");
        _;
    }

    function authorizeMiner(address minerAddr) external onlyFactory {
        authorizedMiners[minerAddr] = true;
    }

    function authorizeUpdater(address updater) external onlyFactory {
        authorizedUpdaters[updater] = true;
    }

    function createCoalBatch(
        string calldata location,
        string calldata grade,
        uint256 quantity
    ) external onlyMiner {

        require(quantity > 0, "Quantity must be > 0");

        batchCounter++;

        batches[batchCounter] = CoalBatch(
            batchCounter,
            msg.sender,
            location,
            grade,
            quantity,
            block.timestamp,
            BatchStatus.Created
        );

        emit BatchCreated(batchCounter);
    }

    function updateStatus(uint256 batchId, BatchStatus newStatus)
        external
        onlyAuthorizedUpdater
    {
        require(
            batchId != 0 && batchId <= batchCounter,
            "Invalid batchId"
        );
        batches[batchId].status = newStatus;
        emit StatusUpdated(batchId, newStatus);
    }

    function getStatus(uint256 batchId)
        external
        view
        returns (BatchStatus)
    {
        return batches[batchId].status;
    }
}