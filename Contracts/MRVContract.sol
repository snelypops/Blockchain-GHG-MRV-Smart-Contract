// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title MRVContract
/// @notice On-chain Monitoring, Reporting and Verification (MRV) registry for
///         facility-level greenhouse gas emissions. Stores hashes of off-chain
///         emissions reports (not the raw data itself) to preserve commercial
///         confidentiality while giving regulators/auditors a tamper-evident
///         audit trail.
contract MRVContract {

    // ---------------------------------------------------------------------
    // Roles
    // ---------------------------------------------------------------------

    address public admin;

    mapping(address => bool) public authorizedReporters;
    mapping(address => bool) public authorizedAuditors;

    // ---------------------------------------------------------------------
    // Facility
    // ---------------------------------------------------------------------

    struct Facility {
        uint256 facilityId;
        string name;
        string location;
        bool active;
    }

    mapping(uint256 => Facility) public facilities;
    uint256 public facilityCount; // also doubles as "last assigned facility ID"

    // ---------------------------------------------------------------------
    // Emissions Record
    // ---------------------------------------------------------------------

    struct EmissionsRecord {
        uint256 facilityId;
        bytes32 reportHash;      // keccak256 hash of the off-chain emissions report
        uint256 reportingPeriod; // e.g. YYYYMM or a UNIX period marker, defined off-chain
        uint256 timestamp;       // block time the record was submitted
        address submittedBy;
    }
