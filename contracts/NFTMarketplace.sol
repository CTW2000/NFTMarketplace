


// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//npx hardhat compile

error PriceMustBeGreaterThanZero();
error NotApprovedForMarketplace();
error ItemAlreadyListed(address nftAddress, uint256 tokenId);
error NotOwner();
error ItemNotListed(address nftAddress, uint256 tokenId);
error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error NoProceeds();
error TransferFailed();


contract NftMarketplace is ReentrancyGuard {
    


event ItemListed(address indexed nftAddress, uint256 indexed tokenId, uint256 price, address indexed seller);
event ItemBought(address indexed nftAddress, uint256 indexed tokenId, uint256 price, address indexed buyer);
event ItemCanceled(address indexed nftAddress, uint256 indexed tokenId, address indexed seller);

    struct Listing {
        uint256 price;
        address seller;
    }
    
    mapping(address => mapping(uint256 => Listing)) private s_listings;
    mapping(address => uint256) private s_proceeds;



   modifier isOwner(address nftAddress, uint256 tokenId,address seller) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (owner != seller) revert NotOwner();
        _;
    }

    modifier notListed(address nftAddress, uint256 tokenId,address owner) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price > 0) revert ItemAlreadyListed(nftAddress, tokenId);
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price <= 0) revert ItemNotListed(nftAddress, tokenId);
        _;
    }



    function listItem(address nftAddress, uint256 tokenId, uint256 price)  external 
    notListed(nftAddress, tokenId, msg.sender)
    isOwner(nftAddress, tokenId, msg.sender) {
        if (price <= 0) revert PriceMustBeGreaterThanZero();
        
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) revert NotApprovedForMarketplace();
   
        s_listings[nftAddress][tokenId] = Listing(price, msg.sender);
        emit ItemListed(nftAddress, tokenId, price, msg.sender);
    }

    function buyItem(address nftAddress, uint256 tokenId) 
    external payable 
    nonReentrant
    isListed(nftAddress, tokenId) {
        Listing memory listedItem = s_listings[nftAddress][tokenId];
        if (msg.value < listedItem.price) revert PriceNotMet(nftAddress, tokenId, listedItem.price);
        s_proceeds[listedItem.seller] += msg.value;
        delete s_listings[nftAddress][tokenId];
        IERC721(nftAddress).safeTransferFrom(listedItem.seller, msg.sender, tokenId);
        emit ItemBought(nftAddress, tokenId, listedItem.price, msg.sender);
    } 

    function cancelListing(address nftAddress, uint256 tokenId) 
    external
    isListed(nftAddress, tokenId)
    isOwner(nftAddress, tokenId, msg.sender)
    {
        delete s_listings[nftAddress][tokenId];
        emit ItemCanceled(nftAddress, tokenId, msg.sender);
    }

    function updateListing(address nftAddress, uint256 tokenId, uint256 newPrice)
    external
    isListed(nftAddress, tokenId)
    isOwner(nftAddress, tokenId, msg.sender)
    { 
        s_listings[nftAddress][tokenId].price = newPrice;
        emit ItemListed(nftAddress, tokenId, newPrice, msg.sender);
    }


    function withdrawProceeds() external
    {
        uint256 proceeds = s_proceeds[msg.sender];
        if (proceeds <= 0) revert NoProceeds();
        s_proceeds[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: proceeds}("");
        if (!success) revert TransferFailed();
    }

    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
        return s_listings[nftAddress][tokenId];
    }
    function getProceeds(address seller) external view returns (uint256) {
        return s_proceeds[seller];
    } 
    


}



