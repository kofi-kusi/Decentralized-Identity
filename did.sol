// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract DecentralizedIdentity {

    struct Identity {
        string name;
        string email;
        string verificationDocument;
        bool isVerified;
        bool isRevoked;
        address owner;
    }

    // Mapping from address to Identity
    mapping(address => Identity) public identities;

    // Mapping to check if an address is an authorized verifier
    mapping(address => bool) public verifiers;

    // Address of the contract owner
    address public owner;

    // Events for logging actions
    event IdentityRegistered(address indexed user, string name, string email);
    event IdentityVerified(address indexed user, address indexed verifier);
    event IdentityRevoked(address indexed user, address indexed revoker);
    event VerifierAdded(address indexed verifier);
    event VerifierRemoved(address indexed verifier);

    // Constructor to set the initial owner
    constructor() {
        owner = msg.sender;
    }

    // Modifier to check if the caller is the owner of the identity
    modifier onlyManager(address _user) {
        require(msg.sender == identities[_user].owner, "Only the identity owner can perform this action");
        _;
    }

    // Modifier to check if the caller is an authorized verifier
    modifier onlyVerifier() {
        require(verifiers[msg.sender], "Only authorized verifiers can perform this action");
        _;
    }

    // Modifier to check if the caller is the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }


    function registerIdentity(string memory _name, string memory _email, string memory _verificationDocument) public {
        require(keccak256(abi.encodePacked(identities[msg.sender].name)) == keccak256(abi.encodePacked("")), "Identity already registered");
        
        identities[msg.sender] = Identity({
            name: _name,
            email: _email,
            verificationDocument: _verificationDocument,
            isVerified: false,
            isRevoked: false,
            owner: msg.sender
        });

        emit IdentityRegistered(msg.sender, _name, _email);
    }


    function verifyIdentity(address _user) public onlyVerifier {
        require(!identities[_user].isRevoked, "Identity has been revoked");
        identities[_user].isVerified = true;
        emit IdentityVerified(_user, msg.sender);
    }

    /**
     * @dev Revoke an identity
     * @param _user The address of the user whose identity to revoke
     */
    function revokeIdentity(address _user) public onlyVerifier {
        identities[_user].isRevoked = true;
        identities[_user].isVerified = false; // Reset verification status on revocation
        emit IdentityRevoked(_user, msg.sender);
    }

    function getIdentity(address _user) public view returns (string memory name, string memory email, bool isVerified, bool isRevoked, address _owner) {
        Identity storage identity = identities[_user];
        return (identity.name, identity.email, identity.isVerified, identity.isRevoked, identity.owner);
    }

    function addVerifier(address _verifier) public onlyOwner {
        verifiers[_verifier] = true;
        emit VerifierAdded(_verifier);
    }

    function removeVerifier(address _verifier) public onlyOwner {
        verifiers[_verifier] = false;
        emit VerifierRemoved(_verifier);
    }
}