// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SoulFund is ERC721, Pausable, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant GRANTER_ROLE = keccak256("GRANTER_ROLE");
    bytes32 public constant BENEFICIARY_ROLE = keccak256("BENEFICIARY_ROLE");
    Counters.Counter private _tokenIdCounter;

    constructor(
        address _admin,
        address _pauser,
        address _beneficiary
    ) ERC721("SoulFund", "SLF") {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(PAUSER_ROLE, _pauser);
        _grantRole(GRANTER_ROLE, _msgSender());
        _grantRole(BENEFICIARY_ROLE, _beneficiary);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(address _to) public onlyRole(GRANTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);
    }

    //revert on all transfers excpet inital mint
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal override(ERC721) whenNotPaused {
        require(
            _from == address(0),
            "SoulFund: soul bound token cannot be transferred"
        );
        super._beforeTokenTransfer(_from, _to, _tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }
}
