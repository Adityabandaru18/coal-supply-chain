// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MiningRegistry.sol";
import "./CertificationAuthority.sol";
import "./TransportRegistry.sol";
import "./IndustryConsumer.sol";
import "./SmartGridAnalytics.sol";

/*
    CENTRAL GOVERNANCE FACTORY
    - Deploys all system contracts
    - Authorizes all actors
*/

contract CoalSupplyChainFactory {

    address public owner;

    MiningRegistry public mining;
    CertificationAuthority public certification;
    TransportRegistry public transport;
    IndustryConsumer public industry;
    SmartGridAnalytics public smartgrid;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deployAll() external onlyOwner {
        require(
            address(mining) == address(0) &&
                address(certification) == address(0) &&
                address(transport) == address(0) &&
                address(industry) == address(0) &&
                address(smartgrid) == address(0),
            "Already deployed"
        );

        mining = new MiningRegistry(address(this));
        certification = new CertificationAuthority(address(this));
        transport = new TransportRegistry(address(this));
        industry = new IndustryConsumer(address(this));
        smartgrid = new SmartGridAnalytics(address(this));

        // allow the domain contracts (and factory itself) to update mining status
        mining.authorizeUpdater(address(certification));
        mining.authorizeUpdater(address(transport));
        mining.authorizeUpdater(address(industry));
    }

    /* Role Authorization */

    function authorizeMiner(address minerAddr) external onlyOwner {
        mining.authorizeMiner(minerAddr);
    }

    function authorizeOfficer(address officer) external onlyOwner {
        certification.authorizeOfficer(officer);
    }

    function authorizeTransporter(address transporter) external onlyOwner {
        transport.authorizeTransporter(transporter);
    }

    function authorizeIndustry(address industryAddr) external onlyOwner {
        industry.authorizeIndustry(industryAddr);
    }

    function authorizeGrid(address grid) external onlyOwner {
        smartgrid.authorizeGrid(grid);
    }
}