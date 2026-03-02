// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MiningRegistry.sol";

/*
    GOVERNMENT CERTIFICATION
    - Certifies coal batches
*/

contract CertificationAuthority {

    address public factory;

    constructor(address _factory) {
        factory = _factory;
    }

    struct Certificate {
        uint256 batchId;
        string certificateHash;
        uint256 issuedAt;
        address issuedBy;
    }

    mapping(uint256 => Certificate) public certificates;
    mapping(address => bool) public authorizedOfficers;

    modifier onlyFactory() {
        require(msg.sender == factory, "Only factory");
        _;
    }

    modifier onlyOfficer() {
        require(authorizedOfficers[msg.sender], "Not officer");
        _;
    }

    function authorizeOfficer(address officer) external onlyFactory {
        authorizedOfficers[officer] = true;
    }

    function certifyBatch(
        address miningAddress,
        uint256 batchId,
        string calldata certificateHash
    ) external onlyOfficer {

        MiningRegistry mining = MiningRegistry(miningAddress);

        require(
            mining.getStatus(batchId) ==
                MiningRegistry.BatchStatus.Created,
            "Invalid state"
        );

        // prevent overwriting an existing certificate
        require(
            certificates[batchId].issuedAt == 0,
            "Already certified"
        );

        certificates[batchId] = Certificate(
            batchId,
            certificateHash,
            block.timestamp,
            msg.sender
        );

        mining.updateStatus(
            batchId,
            MiningRegistry.BatchStatus.Certified
        );
    }
}