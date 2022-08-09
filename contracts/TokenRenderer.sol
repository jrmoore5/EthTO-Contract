// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interface/ISoulFund.sol";
import "./library/SoulFundLibrary.sol";

contract TokenRenderer is UUPSUpgradeable, OwnableUpgradeable {
    struct Attributes{
        string name;
        string color;
        uint256 value;
    }

    mapping(address => Attributes) tokenToAttributes;

    ISoulFund soulfund;

    error INVALID_PARAMS();

    // populate with token names, colors, values
    function initialize(
        address _soulfund,
        address[] calldata _addresses, 
        string[] calldata _names, 
        string[] calldata _colors, 
        uint256[] calldata _values
    ) initializer public {
        if(_addresses.length == _names.length && _names.length == _colors.length && _colors.length == _values.length){
            __Ownable_init();
            __UUPSUpgradeable_init();
            
            for(uint8 i=0; i<_addresses.length;i++){
                tokenToAttributes[_addresses[i]] = Attributes({name: _names[i], color: _colors[i], value: _values[i]});
            }

            soulfund = ISoulFund(_soulfund);
        }
        else{
            revert INVALID_PARAMS();
        }
    }

    // generate svg
    // https://codepen.io/my_names_joshua/pen/PoRadQp
    // will work more on svg display in am
    function _svg(ISoulFund.Balances[] memory _balances) internal view returns(string memory){
        string memory svg;
        uint256 totalUSD;
        uint256 percent = 0;
        
        // get balance of native & erc20s
        for(uint256 i=0; i<_balances.length; i++){
            totalUSD += _balances[i].balance / tokenToAttributes[_balances[i].token].value;

            // encoded to string for populating svg
        }

        return "";
    }

    // generate metadata
    function _meta(ISoulFund.Balances[] memory _balances) internal view returns(string memory){
        
        return "";
    }

    // render token function
    function renderToken(uint256 _tokenId) public view returns(string memory){
        ISoulFund.Balances[] memory balances = soulfund.balances(_tokenId);
        string memory svg = _svg(balances);
        string memory attributes = _meta(balances);

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    SoulFundLibrary.encode(
                        bytes(
                            string(
                                abi.encodePacked(
                                    '{"name": "SoulFund #',
                                    SoulFundLibrary.toString(_tokenId),
                                    '",', 
                                    '"description": "SoulFund is a Soulbound Time & Merit Based Funding Token.",',
                                    '"image": "data:image/svg+xml;base64,',
                                    svg,
                                    '","attributes": [',
                                    attributes,
                                    ']}'
                                    )
                                )
                            )
                        )
                    )
                );
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}