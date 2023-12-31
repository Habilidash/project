// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

interface IDashSupreme  {

    function mint(string memory _tokenURI) external;

    function burn(uint256 tokenId) external;

    function setUser(uint256 tokenId, address user, uint64 expires) external;

}
