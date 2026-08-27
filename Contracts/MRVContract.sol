// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;


contract MRVContract {

    // Roles

    address public admin;

    mapping(address => bool) public authorizedReporters;
    mapping(address => bool) public authorizedAuditors;

    
    // Facility
    

    struct Facility {
        uint256 facilityId;
        string name;
        string location;
        bool active;
    }

    mapping(uint256 => Facility) public facilities;
    uint256 public facilityCount; // also doubles as "last assigned facility ID"


    // Emissions Record
   
    struct EmissionsRecord {
        uint256 facilityId;
        bytes32 reportHash;      // keccak256 hash of the off-chain emissions report
        uint256 reportingPeriod; 
        uint256 timestamp;       // block time the record was submitted
        address submittedBy;
    }

    // facilityId => append-only list of emissions records
    mapping(uint256 => EmissionsRecord[]) private emissionsRecords;

    
    // Events
    
    event FacilityRegistered(
        uint256 indexed facilityId,
        string name,
        string location
    );

    event FacilityStatusChanged(
        uint256 indexed facilityId,
        bool active
    );

    event ReporterAuthorised(address indexed reporter);
    event ReporterRevoked(address indexed reporter);

    event AuditorAuthorised(address indexed auditor);
    event AuditorRevoked(address indexed auditor);

    event EmissionsReportSubmitted(
        uint256 indexed facilityId,
        bytes32 reportHash,
        uint256 reportingPeriod,
        address indexed submittedBy
    );

    
    // Modifiers
    

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyReporter() {
        require(authorizedReporters[msg.sender], "Only authorized reporters can perform this action");
        _;
    }

    modifier onlyAuditor() {
        require(authorizedAuditors[msg.sender], "Only authorized auditors can perform this action");
        _;
    }

    modifier facilityExists(uint256 _facilityId) {
        require(facilities[_facilityId].facilityId != 0, "Facility does not exist");
        _;
    }

    
    // Constructor
    

    constructor() {
        // The wallet that deploys the contract is the admin
        admin = msg.sender;
    }

    // User Management Functions

    function authoriseReporter(address _reporter) external onlyAdmin {
        require(_reporter != address(0), "Invalid reporter address");
        authorizedReporters[_reporter] = true;
        emit ReporterAuthorised(_reporter);
    }

    function revokeReporter(address _reporter) external onlyAdmin {
        authorizedReporters[_reporter] = false;
        emit ReporterRevoked(_reporter);
    }

    function authoriseAuditor(address _auditor) external onlyAdmin {
        require(_auditor != address(0), "Invalid auditor address");
        authorizedAuditors[_auditor] = true;
        emit AuditorAuthorised(_auditor);
    }

    function revokeAuditor(address _auditor) external onlyAdmin {
        authorizedAuditors[_auditor] = false;
        emit AuditorRevoked(_auditor);
    }

    // Facility Management Functions
    

    function registerFacility(
        string calldata _name,
        string calldata _location
    ) external onlyAdmin returns (uint256) {
        require(bytes(_name).length > 0, "Name required");
        require(bytes(_location).length > 0, "Location required");

        facilityCount++;
        facilities[facilityCount] = Facility({
            facilityId: facilityCount,
            name: _name,
            location: _location,
            active: true
        });

        emit FacilityRegistered(facilityCount, _name, _location);
        return facilityCount;
    }

    
    function setFacilityStatus(
        uint256 _facilityId,
        bool _active
    ) external onlyAdmin facilityExists(_facilityId) {
        facilities[_facilityId].active = _active;
        emit FacilityStatusChanged(_facilityId, _active);
    }

    function getFacility(
        uint256 _facilityId
    )
        external
        view
        facilityExists(_facilityId)
        returns (
            uint256 facilityId,
            string memory name,
            string memory location,
            bool active
        )
    {
        Facility memory facility = facilities[_facilityId];
        return (facility.facilityId, facility.name, facility.location, facility.active);
    }

    
    // Emissions Reporting Functions
    
    function submitEmissionsRecord(
        uint256 _facilityId,
        bytes32 _reportHash,
        uint256 _reportingPeriod
    ) external onlyReporter facilityExists(_facilityId) {
        require(facilities[_facilityId].active, "Facility is not active");
        require(_reportHash != bytes32(0), "Report hash required");
        require(_reportingPeriod > 0, "Reporting period required");

        emissionsRecords[_facilityId].push(EmissionsRecord({
            facilityId: _facilityId,
            reportHash: _reportHash,
            reportingPeriod: _reportingPeriod,
            timestamp: block.timestamp,
            submittedBy: msg.sender
        }));

        emit EmissionsReportSubmitted(_facilityId, _reportHash, _reportingPeriod, msg.sender);
    }

    function getEmissionsRecordCount(
        uint256 _facilityId
    ) external view returns (uint256) {
        return emissionsRecords[_facilityId].length;
    }


    function getEmissionsRecord(
        uint256 _facilityId,
        uint256 _recordIndex
    )
        external
        view
        onlyAuditor
        returns (
            uint256 facilityId,
            bytes32 reportHash,
            uint256 reportingPeriod,
            uint256 timestamp,
            address submittedBy
        )
    {
        require(_recordIndex < emissionsRecords[_facilityId].length, "Record does not exist");

        EmissionsRecord memory record = emissionsRecords[_facilityId][_recordIndex];
        return (
            record.facilityId,
            record.reportHash,
            record.reportingPeriod,
            record.timestamp,
            record.submittedBy
        );
    }
}
