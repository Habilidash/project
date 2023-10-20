// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../interface/IERC4907.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract ERC4907 is ERC721URIStorage, IERC4907 {
  constructor(string memory _name, string memory _symbol) ERC721(_name,  _symbol){
  }
    struct UserInfo {
        address user; // address of user role
        uint64 expires; // unix timestamp, user expires
    }
    mapping(uint256 => UserInfo) internal _users;
    
    /// @notice set the user and expires of a NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint64 expires) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId),"ERC721: transfer caller is not owner nor approved");
        UserInfo storage info = _users[tokenId];
        info.user = user;
        info.expires = expires;
    
        emit UpdateUser(tokenId, user, expires);
    }
    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId)
    public
    view
    virtual
    override
    returns (address)
    {
    if (uint256(_users[tokenId].expires) >= block.timestamp) {
        return _users[tokenId].user;
    } else {
        return address(0);
    }
    }
    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId) public view virtual override returns(uint256){
    return _users[tokenId].expires;
    }
    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
    {
        return
            interfaceId == type(IERC4907).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);

        if (from != to && _users[tokenId].user != address(0)) {
            delete _users[tokenId];
            emit UpdateUser(tokenId, address(0), 0);
        }
    }
}































// contract Marketplace is ReentrancyGuard {
//     using Counters for Counters.Counter;
//     using EnumerableSet for EnumerableSet.AddressSet;
//     using EnumerableSet for EnumerableSet.UintSet;
//     Counters.Counter private _nftsListed;
//     address private _marketOwner;
//     uint256 private _listingFee = .001 ether;
//     // maps contract address to token id to properties of the rental listing
//     mapping(address => mapping(uint256 => Listing)) private _listingMap;
//     // maps nft contracts to set of the tokens that are listed
//     mapping(address => EnumerableSet.UintSet) private _nftContractTokensMap;
//     // tracks the nft contracts that have been listed
//     EnumerableSet.AddressSet private _nftContracts;
//     struct Listing {
//         address owner;
//         address user;
//         address nftContract;
//         uint256 tokenId;
//         uint256 pricePerDay;
//         uint256 startDateUNIX; // when the nft can start being rented
//         uint256 endDateUNIX; // when the nft can no longer be rented
//         uint256 expires; // when the user can no longer rent it
//     }
//     event NFTListed(
//         address owner,
//         address user,
//         address nftContract,
//         uint256 tokenId,
//         uint256 pricePerDay,
//         uint256 startDateUNIX,
//         uint256 endDateUNIX,
//         uint256 expires
//     );
//     event NFTRented(
//         address owner,
//         address user,
//         address nftContract,
//         uint256 tokenId,
//         uint256 startDateUNIX,
//         uint256 endDateUNIX,
//         uint64 expires,
//         uint256 rentalFee
//     );
//     event NFTUnlisted(
//         address unlistSender,
//         address nftContract,
//         uint256 tokenId,
//         uint256 refund
//     );

//     constructor() {
//         _marketOwner = msg.sender;
//     }

//     // function to list NFT for rental
//     function listNFT(
//         address nftContract,
//         uint256 tokenId,
//         uint256 pricePerDay,
//         uint256 startDateUNIX,
//         uint256 endDateUNIX
//     ) public payable nonReentrant {
//         require(isRentableNFT(nftContract), "Contract is not an ERC4907");
//         require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Not owner of nft");
//         require(msg.value == _listingFee, "Not enough ether for listing fee");
//         require(pricePerDay > 0, "Rental price should be greater than 0");
//         require(startDateUNIX >= block.timestamp, "Start date cannot be in the past");
//         require(endDateUNIX >= startDateUNIX, "End date cannot be before the start date");
//         require(_listingMap[nftContract][tokenId].nftContract == address(0), "This NFT has already been listed");

//         payable(_marketOwner).transfer(_listingFee);
//         _listingMap[nftContract][tokenId] = Listing(
//             msg.sender,
//             address(0),
//             nftContract,
//             tokenId,
//             pricePerDay,
//             startDateUNIX,
//             endDateUNIX,
//             0
//         );
//         _nftsListed.increment();
//         EnumerableSet.add(_nftContractTokensMap[nftContract], tokenId);
//         EnumerableSet.add(_nftContracts, nftContract);
//         emit NFTListed(
//             IERC721(nftContract).ownerOf(tokenId),
//             address(0),
//             nftContract,
//             tokenId,
//             pricePerDay,
//             startDateUNIX,
//             endDateUNIX,
//             0
//         );
//     }

//     // function to rent NFT
//     function rentNFT(
//         address nftContract,
//         uint256 tokenId,
//         uint64 expires
//     ) public payable nonReentrant {
//         Listing storage listing = _listingMap[nftContract][tokenId];
//         require(listing.user == address(0) || block.timestamp > listing.expires, "NFT already rented");
//         require(expires <= listing.endDateUNIX, "Rental period exceeds max date rentable");
//         // Transfer rental fee
//         uint256 numDays = (expires - block.timestamp)/60/60/24 + 1;
//         uint256 rentalFee = listing.pricePerDay * numDays;
//         require(msg.value >= rentalFee, "Not enough ether to cover rental period");
//         payable(listing.owner).transfer(rentalFee);
//         // Update listing
//         IERC4907(nftContract).setUser(tokenId, msg.sender, expires);
//         listing.user = msg.sender;
//         listing.expires = expires;

//         emit NFTRented(
//             IERC721(nftContract).ownerOf(tokenId),
//             msg.sender,
//             nftContract,
//             tokenId,
//             listing.startDateUNIX,
//             listing.endDateUNIX,
//             expires,
//             rentalFee
//         );
//     }

//     // function to unlist your rental, refunding the user for any lost time
//     function unlistNFT(address nftContract, uint256 tokenId) public payable nonReentrant {
//         Listing storage listing = _listingMap[nftContract][tokenId];
//         require(listing.owner != address(0), "This NFT is not listed");
//         require(listing.owner == msg.sender || _marketOwner == msg.sender , "Not approved to unlist NFT");
//         // fee to be returned to user if unlisted before rental period is up
//         // nothing to refund if no renter
//         uint256 refund = 0;
//         if (listing.user != address(0)) {
//             refund = ((listing.expires - block.timestamp) / 60 / 60 / 24 + 1) * listing.pricePerDay;
//             require(msg.value >= refund, "Not enough ether to cover refund");
//             payable(listing.user).transfer(refund);
//         }
//         // clean up data
//         IERC4907(nftContract).setUser(tokenId, address(0), 0);
//         EnumerableSet.remove(_nftContractTokensMap[nftContract], tokenId);
//         delete _listingMap[nftContract][tokenId];
//         if (EnumerableSet.length(_nftContractTokensMap[nftContract]) == 0) {
//             EnumerableSet.remove(_nftContracts, nftContract);
//         }
//         _nftsListed.decrement();

//         emit NFTUnlisted(
//             msg.sender,
//             nftContract,
//             tokenId,
//             refund
//         );
//     }

//     /* 
//      * function to get all listings
//      *
//      * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
//      * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
//      * this function has an unbounded cost, and using it as part of a state-changing function may render the function
//      * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
//      */
//     function getAllListings() public view returns (Listing[] memory) {
//         Listing[] memory listings = new Listing[](_nftsListed.current());
//         uint256 listingsIndex = 0;
//         address[] memory nftContracts = EnumerableSet.values(_nftContracts);
//         for (uint i = 0; i < nftContracts.length; i++) {
//             address nftAddress = nftContracts[i];
//             uint256[] memory tokens = EnumerableSet.values(_nftContractTokensMap[nftAddress]);
//             for (uint j = 0; j < tokens.length; j++) {
//                 listings[listingsIndex] = _listingMap[nftAddress][tokens[j]];
//                 listingsIndex++;
//             }
//         }
//         return listings;
//     }

//     function getListingFee() public view returns (uint256) {
//         return _listingFee;
//     }

//     function isRentableNFT(address nftContract) public view returns (bool) {
//         bool _isRentable = false;
//         bool _isNFT = false;
//         try IERC165(nftContract).supportsInterface(type(IERC4907).interfaceId) returns (bool rentable) {
//             _isRentable = rentable;
//         } catch {
//             return false;
//         }
//         try IERC165(nftContract).supportsInterface(type(IERC721).interfaceId) returns (bool nft) {
//             _isNFT = nft;
//         } catch {
//             return false;
//         }
//         return _isRentable && _isNFT;
//     }
// }