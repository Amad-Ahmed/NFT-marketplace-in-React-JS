// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//INTERNAL IMPORT FOR NFT OPENZEPPELIN
// Below counter allows us to keep track of how many NFTs we have created
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;
    // unique ID identifying NFT
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;
    uint256 listingPrice = 0.0025 ether;

    address payable owner;
    // ID unique to NFT
    mapping(uint256 => MarketItem) private idMarketItem;
    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    event idMarketItemCreated(
        uint256 indexed toeknId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    constructor() ERC721("NFT Metaverse Token", "MYNFT") {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only owner of marketplace can change listing price"
        );
        _;
    }

    // To allow only owner to update price therefore we cerated a modifier
    function updateListingPrice(
        uint256 _listingPrice
    ) public payable onlyOwner {
        listingPrice = _listingPrice;
    }

    // To check how much user has to pay to create NFT
    // view is used bcoz listingPrice is state variable and to use
    // state variable we need to use view
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    // Let create "CREATE NFT TOKEN FUNCTION"
    // function to assign token to each NFT
    function createToken(
        string memory tokenURI,
        uint256 price
    ) public payable returns (uint256) {
        // first we increment the token ID then we store the
        // current token ID after increment
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();

        //mint function from openzeppelein
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        createMarketItem(newTokenId, price);

        return newTokenId;
    }

    //CREATING MARKET ITEMS
    //function to assign all the data to the NFT
    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be atleast 1");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        //creating new ID to NFT and then assigning the data
        // this in address indicates that the NFT is in the contract
        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        // transferring the NFT from the owner to the contract with the id
        _transfer(msg.sender, address(this), tokenId);
        // Assiging the Data to the NFT
        emit idMarketItemCreated(
            tokenId,
            msg.sender,
            address(this),
            price,
            false
        );
    }
}
