// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;  // Added for complex array returns

/// @title OptimizedHealthCare
/// @notice A smart contract for managing healthcare records and access control
contract OptimizedHealthCare {
    address private immutable owner;
    bool private paused;
    
    mapping(address => Doctor) private doctors;
    mapping(address => Patient) private patients;
    mapping(address => mapping(address => bool)) private patientToDoctor;
    mapping(address => Files[]) private patientFiles;
    mapping(address => Hospital) private hospitals;
    mapping(address => InsuranceComp) private insuranceCompanies;

    struct Files {
        string fileName;
        string fileType;
        string fileHash;
        uint256 timestamp;
    }
    
    struct Hospital {
        address id;
        string name;
        string location;
        bool isActive;
    }
    
    struct InsuranceComp {
        address id;
        string name;
        mapping(address => bool) regPatientsMapping;
        address[] regPatients;
    }
    
    struct Patient {
        string name;
        string dob;
        address id;
        string gender;
        string contactInfo;
        address[] doctorList;
        bool isActive;
    }
    
    struct Doctor {
        string name;
        address id;
        string contact;
        string specialization;
        address[] patientList;
        bool isActive;
    }

    // Events
    event PatientRegistered(address indexed patient, string name);
    event DoctorRegistered(address indexed doctor, string name);
    event AccessGranted(address indexed patient, address indexed doctor);
    event AccessRevoked(address indexed patient, address indexed doctor);
    event FileAdded(address indexed patient, string fileName);
    event HospitalRegistered(address indexed hospital, string name);
    event ContractPaused(address indexed owner);
    event ContractUnpaused(address indexed owner);

    // Modifiers
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyDoctor() {
        require(doctors[msg.sender].isActive, "Only active doctors can perform this action");
        _;
    }
    
    modifier onlyPatient() {
        require(patients[msg.sender].isActive, "Only active patients can perform this action");
        _;
    }

    // Added public visibility
    constructor() {
    owner = msg.sender;
}

    // Emergency pause/unpause
    function togglePause() external onlyOwner {
        paused = !paused;
        if (paused) {
            emit ContractPaused(owner);
        } else {
            emit ContractUnpaused(owner);
        }
    }

    function registerHospital(
        address _id, 
        string memory _name, 
        string memory _location
    ) external onlyOwner whenNotPaused {
        require(_id != address(0), "Invalid address");
        require(!hospitals[_id].isActive, "Hospital already registered");
        require(bytes(_name).length > 0, "Name required");
        
        hospitals[_id] = Hospital({
            id: _id,
            name: _name,
            location: _location,
            isActive: true
        });
        
        emit HospitalRegistered(_id, _name);
    }

    function registerPatient(
        string memory _name,
        string memory _dob,
        string memory _gender,
        string memory _contactInfo
    ) external whenNotPaused {
        require(bytes(_name).length > 0, "Name required");
        require(!patients[msg.sender].isActive, "Patient already registered");
        
        patients[msg.sender] = Patient({
            name: _name,
            dob: _dob,
            id: msg.sender,
            gender: _gender,
            contactInfo: _contactInfo,
            doctorList: new address[](0),
            isActive: true
        });
        
        emit PatientRegistered(msg.sender, _name);
    }

    function registerDoctor(
        string memory _name,
        string memory _contact,
        string memory _specialization
    ) external whenNotPaused {
        require(bytes(_name).length > 0, "Name required");
        require(!doctors[msg.sender].isActive, "Doctor already registered");
        
        doctors[msg.sender] = Doctor({
            name: _name,
            id: msg.sender,
            contact: _contact,
            specialization: _specialization,
            patientList: new address[](0),
            isActive: true
        });
        
        emit DoctorRegistered(msg.sender, _name);
    }

    function grantAccess(address _doctorId) external onlyPatient whenNotPaused {
        require(_doctorId != address(0), "Invalid doctor address");
        require(doctors[_doctorId].isActive, "Doctor not found or inactive");
        require(!patientToDoctor[msg.sender][_doctorId], "Access already granted");
        require(msg.sender != _doctorId, "Cannot grant access to self");

        patientToDoctor[msg.sender][_doctorId] = true;
        patients[msg.sender].doctorList.push(_doctorId);
        doctors[_doctorId].patientList.push(msg.sender);
        
        emit AccessGranted(msg.sender, _doctorId);
    }

    function revokeAccess(address _doctorId) external onlyPatient whenNotPaused {
        require(patientToDoctor[msg.sender][_doctorId], "Access not found");
        
        patientToDoctor[msg.sender][_doctorId] = false;
        
        // Remove doctor from patient's list
        address[] storage doctorList = patients[msg.sender].doctorList;
        for (uint i = 0; i < doctorList.length; i++) {
            if (doctorList[i] == _doctorId) {
                doctorList[i] = doctorList[doctorList.length - 1];
                doctorList.pop();
                break;
            }
        }
        
        // Remove patient from doctor's list
        address[] storage patientList = doctors[_doctorId].patientList;
        for (uint i = 0; i < patientList.length; i++) {
            if (patientList[i] == msg.sender) {
                patientList[i] = patientList[patientList.length - 1];
                patientList.pop();
                break;
            }
        }
        
        emit AccessRevoked(msg.sender, _doctorId);
    }

    function addFile(
        string memory _fileName,
        string memory _fileType,
        string memory _fileHash
    ) external onlyPatient whenNotPaused {
        require(bytes(_fileName).length > 0, "File name required");
        require(bytes(_fileHash).length > 0, "File hash required");
        
        patientFiles[msg.sender].push(Files({
            fileName: _fileName,
            fileType: _fileType,
            fileHash: _fileHash,
            timestamp: block.timestamp
        }));
        
        emit FileAdded(msg.sender, _fileName);
    }

    // View functions
    function getPatientFiles(address _patient) external view returns (Files[] memory) {
        require(
            msg.sender == _patient || 
            patientToDoctor[_patient][msg.sender] || 
            msg.sender == owner,
            "Unauthorized access"
        );
        return patientFiles[_patient];
    }

    function getPatientInfo(address _patient) external view returns (
        string memory name,
        string memory dob,
        string memory gender,
        string memory contactInfo,
        address[] memory doctorList
    ) {
        require(
            msg.sender == _patient || 
            patientToDoctor[_patient][msg.sender] || 
            msg.sender == owner,
            "Unauthorized access"
        );
        Patient storage p = patients[_patient];
        return (p.name, p.dob, p.gender, p.contactInfo, p.doctorList);
    }

    function getDoctorInfo(address _doctor) external view returns (
        string memory name,
        string memory contact,
        string memory specialization,
        address[] memory patientList,
        bool isActive
    ) {
        Doctor storage d = doctors[_doctor];
        require(d.isActive, "Doctor not found or inactive");
        return (d.name, d.contact, d.specialization, d.patientList, d.isActive);
    }

    function getHospitalInfo(address _hospital) external view returns (
    string memory name,
    string memory location,
    bool isActive
) {
    require(bytes(hospitals[_hospital].name).length > 0, "Hospital not found"); 
    Hospital storage h = hospitals[_hospital];
    return (h.name, h.location, h.isActive);
}


    function hasAccess(address _patient, address _doctor) external view returns (bool) {
        return patientToDoctor[_patient][_doctor];
    }
}