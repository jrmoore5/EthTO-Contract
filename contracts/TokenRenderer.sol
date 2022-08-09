// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interface/ISoulFund.sol";
import "./library/SoulFundLibrary.sol";

contract TokenRenderer is UUPSUpgradeable, OwnableUpgradeable {
    struct Attributes{
        string name;
        string color;
        address aggregator;
    }

    mapping(address => Attributes) tokenToAttributes;

    // populate with token names, colors, values
    function initialize(address[] memory _addresses, 
        string[] memory _names, 
        string[] memory _colors, 
        address[] memory _aggregators
    ) initializer public {
        require(_addresses.length == _names.length && _names.length == _colors.length && _colors.length == _aggregators.length, "Invalid param length");
        for(uint8 i=0; i<_addresses.length;i++){
            tokenToAttributes[_addresses[i]] = Attributes({name: _names[i], color: _colors[i], aggregator: _aggregators[i]});
        }
    }

    // generate svg
    // https://codepen.io/my_names_joshua/pen/PoRadQp
    // will work more on svg display in am
    function _svg(ISoulFund.Balances[] memory _balances, uint256 totalUSD, uint256[] memory percentages) internal view returns(string memory){
        string memory svg;
        
        // // get balance of native & erc20s
        // for(uint256 i=0; i<_balances.length; i++){
        //     totalUSD += _balances[i].balance / tokenToAttributes[_balances[i].token].value;

        //     // encoded to string for populating svg
        // }

        return svg;
    }

    // generate metadata
    function _meta(ISoulFund.Balances[] memory _balances) internal view returns(string memory, uint256, uint256[] memory){
        uint256 totalUSD;
        uint256[] memory usdValues = new uint[](_balances.length);
        uint256[] memory percentages = new uint[](_balances.length);
        string memory metadataString;


        // get balance of native & erc20s
        for(uint256 i=0; i<_balances.length; i++){
           usdValues[i] = _getPrice(tokenToAttributes[_balances[i].token].aggregator) * _balances[i].balance / 1 ether;
           totalUSD += _getPrice(tokenToAttributes[_balances[i].token].aggregator) * _balances[i].balance / 1 ether;
        }

        for(uint256 i=0; i<usdValues.length; i++){
            percentages[i] = SoulFundLibrary.getPercent(usdValues[i], totalUSD);
            metadataString = string(
                abi.encodePacked(
                    metadataString,
                    '{"trait_type":"',
                    tokenToAttributes[_balances[i].token].name,
                    '","value":"$',
                    SoulFundLibrary.getDecimalString(usdValues[i]),
                    '"},'
                )
            );
        }

        metadataString = string(
                abi.encodePacked(
                    metadataString,
                    '{"trait_type":"Total Value","value":"$',
                    SoulFundLibrary.getDecimalString(totalUSD),
                    '"}'
                )
        );

        return (metadataString, totalUSD, percentages);
    }

    // chainlink aggregator
    function _getPrice(address _aggregator) internal view returns(uint256){
        (
            /*uint80 roundID*/,
            int v,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = AggregatorV3Interface(_aggregator).latestRoundData();
        return uint256(v) * 10 ** 10;
    }

    // render token function
    function renderToken(address _soulfund, uint256 _tokenId) public view returns(string memory){
        ISoulFund.Balances[] memory balances = ISoulFund(_soulfund).balances(_tokenId);
        string memory metadata;
        uint256 totalUSD;
        uint256[] memory percentages;

        (metadata, totalUSD, percentages) = _meta(balances);
        string memory svg = _svg(balances, totalUSD, percentages);

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
                                    metadata,
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