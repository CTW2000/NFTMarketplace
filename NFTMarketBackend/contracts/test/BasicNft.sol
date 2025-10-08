// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNft is ERC721  {
    string public constant TOKEN_URI = "https://jsonplaceholder.typicode.com/posts/1";

     uint256 private s_tokenCounter;

     event DogMinted(uint256 indexed tokenId);


    constructor() ERC721("Dogie", "DOG") {
        s_tokenCounter = 0;
    }

    function mintNft() public {
        s_tokenCounter++;   // increment the token counter
        _safeMint(msg.sender, s_tokenCounter);
        emit DogMinted(s_tokenCounter);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return TOKEN_URI;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

}