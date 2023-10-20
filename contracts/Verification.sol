// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import "./ERC4907.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DashVerification is ERC4907 {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor() ERC4907("DashVerificatio", "DV") {}
//   function _baseURI() internal pure override returns (string memory) {
//         return "";
//     }

  function mint(string memory _tokenURI) public {
    _tokenIds.increment();
    uint256 newTokenId = _tokenIds.current();
    _safeMint(msg.sender, newTokenId);
    _setTokenURI(newTokenId, _tokenURI);
  }

  function burn(uint256 tokenId) public {
    _burn(tokenId);
  }
}