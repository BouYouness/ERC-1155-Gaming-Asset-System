// SPDX-License-Identifier:MIT

pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Pausable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

contract GamingAssets is ERC1155, Ownable, Pausable, ERC1155Burnable, AccessControl {

    bytes32 public constant MAINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public constant WEAPON = 1;
    uint256 public constant POTION = 2;
    uint256 public constant ARMOR = 3;

    struct AssetInfo{
        string  name;
        string description;
    }

    mapping(uint256 => AssetInfo) public assetInfo;

    event AssetInfoUpdated(uint256 indexed typeId, string name, string description);
    event AssetMinted(address indexed to, uint256 indexed id, uint256 amount);
    event BatchAssetMinted(address[] indexed to , uint256[] indexed ids, uint256[] amounts);

    constructor(string memory uri) ERC1155(uri) Ownable(msg.sender){
       _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
       _grantRole(MAINTER_ROLE, msg.sender); 
    }

    // Override supportsInterface to handle multiple inheritance
    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setAssetInfo(uint256 typeId, string memory name, string memory description) external onlyOwner{
        assetInfo[typeId] = AssetInfo(name, description);
        emit AssetInfoUpdated(typeId, name, description);
    }

    function mint(address account, uint256 id , uint256 amount, bytes memory data) public onlyRole(MAINTER_ROLE){
        _mint(account, id, amount, data);
        emit AssetMinted(account, id, amount);
    }

    function batchMint(address[] memory accounts, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public onlyRole(MAINTER_ROLE){
        require(accounts.length == ids.length && ids.length == amounts.length, "Arrays length mismatch");

        for(uint256 i=0; i< accounts.length; i++){
            _mint(accounts[i], ids[i], amounts[i], data);
        }
        emit BatchAssetMinted(accounts, ids, amounts);
    }
    
    //transfer assets
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data)
    public
    override
    whenNotPaused{
        super.safeTransferFrom(from, to, id, amount, data);
    }

    //batch transfer
    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    public
    override
    whenNotPaused{
    super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    // Single asset burn function
    function burn(address account, uint256 id, uint256 amount) public onlyRole(MAINTER_ROLE) override {
        _burn(account, id, amount);
    }

    //batch asset burn function
     function burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) public onlyRole(MAINTER_ROLE) override{
        _burnBatch(account, ids, amounts);
    }

    
    function pause() public /*onlyOwner*/{
        _pause();
    }

    function unpause() public onlyOwner{
        _unpause();
    }

    function setURI(string memory newuri) public onlyOwner(){
       _setURI(newuri);
    }
}