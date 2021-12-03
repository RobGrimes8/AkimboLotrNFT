// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "./libraries/Base64.sol";

contract MyLOTRNFT is ERC721, ERC721URIStorage, ERC721Enumerable {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  address owner;

  // We split the SVG at the part where it asks for the background color.
  string svgPartOne = '<svg preserveAspectRatio="xMinYMin meet" viewBox="0 0 125 125" xmlns="http://www.w3.org/2000/svg"><rect width="100%" height="100%" rx="25" fill="#2c3e61"/><text x="10%" y="30%" dominant-baseline="middle" fill="white">';
  string svgTextOpenTwo = '<text x="10%" y="50%" dominant-baseline="middle"  fill="white">';
  string svgTextOpenThree = '<text x="10%" y="70%" dominant-baseline="middle"  fill="white">';
  string svgTextClose = "</text>";

  string[] characters = ["Aragorn", "Frodo", "Gandalf", "Legolas", "Gimli", "Boromir", "Samwise", "Merry", "Pippin", "Gollum", "Sauron", "Saruman", "Galadriel", "Elrond", "Eomer"];
  string[] locations = ["Hobbiton", "Rohan", "Gondor", "Rivendell", "Moria", "Mordor", "Bree", "Weathertop", "Isengard", "Helm's Deep", "Fangorn", "Lorien", "Osgiliath", "Minas Morgul", "Dead Marshes"];
  string[] objects = ["The One Ring", "Sting", "Shadowfax", "Herugrim", "Morgul-Blade", "Narsil", "Glamdring", "Anduril", "Gandalf's Staff", "Saruman's Staff", "Legolas' Bow", "Gimli's Axe", "Palantir", "Evenstar", "Mithril Vest"];
  
  // CAP 
  uint256 cap = 15;
  // STORE MAPPING OF URI DATA 

  event NewAkimboNFTMinted(address sender, uint256 tokenId);

  constructor() ERC721 ("AkimboNFT", "AKMB") {
    console.log("This is my NFT contract. Woah!");
    owner = msg.sender;
    console.log(owner);
  }

  function pickRandomCharacters(uint256 tokenId) public returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("characters", Strings.toString(tokenId))));
    rand = rand % characters.length;
    string memory stringToUse = characters[rand];
    // burn selected character 
    characters[rand] = characters[characters.length-1];
    characters.pop();
    return stringToUse;
  }

  function pickRandomLocations(uint256 tokenId) public returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("locations", Strings.toString(tokenId))));
    rand = rand % locations.length;
    string memory stringToUse = locations[rand];
    // burn selected character 
    locations[rand] = locations[locations.length-1];
    locations.pop();
    return stringToUse;
  }

  function pickRandomObjects(uint256 tokenId) public returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("objects", Strings.toString(tokenId))));
    rand = rand % objects.length;
    string memory stringToUse = objects[rand];
    // burn selected character 
    objects[rand] = objects[objects.length-1];
    objects.pop();
    return stringToUse;
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function mintNFT() public {
    require(_tokenIds.current() < cap, "Mint cap is 15. Cap reached.");

    uint256 newItemId = _tokenIds.current();

    string memory firstWord = pickRandomCharacters(newItemId);
    string memory secondWord = pickRandomLocations(newItemId);
    string memory thirdWord = pickRandomObjects(newItemId);

    string memory finalSvg = string(abi.encodePacked(svgPartOne, firstWord, svgTextClose, svgTextOpenTwo, secondWord, svgTextClose, svgTextOpenThree, thirdWord, svgTextClose, "</svg>"));
    string memory idString = Strings.toString(newItemId);
    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "AkimboNFT #', idString,'", "description": "A showcase of test AkimboNFTs", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(
        string(
            abi.encodePacked(
                "https://nftpreview.0xdev.codes/?code=",
                finalTokenUri
            )
        )
    );
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
    
    // Update your URI!!!
    _setTokenURI(newItemId, finalTokenUri);

    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    emit NewAkimboNFTMinted(msg.sender, newItemId);
  }

  function getTotalNFTsMintedSoFar() public view returns (uint256) {
      return _tokenIds.current();
  }

  function getTokenIds() public view returns (uint[] memory) {
    uint[] memory _tokensOfOwner = new uint[](balanceOf(msg.sender));
    uint i;

    for (i=0;i<balanceOf(msg.sender);i++){
        _tokensOfOwner[i] = tokenOfOwnerByIndex(msg.sender, i);
    }

    return _tokensOfOwner;
  }

  function getURIData(uint256 tokenId) public view returns (string memory) {
    string memory tokenURIData = tokenURI(tokenId);
    return tokenURIData;
  }


  // OVERRIDES 
  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }
  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }
  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory){
    return super.tokenURI(tokenId);
  }
  function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}