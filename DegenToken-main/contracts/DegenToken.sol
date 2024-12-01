// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FoodToken is ERC20, Ownable {
    struct FoodItem {
        uint256 id;
        string name;
        uint256 cost;
    }

    FoodItem[] public foodItems;
    mapping(address => FoodItem[]) private ownedFoodItems;

    event ItemRedeemed(address indexed redeemer, uint256 itemId, string itemName, uint256 itemCost);

    // Constructor with initialOwner explicitly passed
    constructor(address initialOwner) ERC20("FoodToken", "FOOD") Ownable(initialOwner) {
        // Add predefined food items
        foodItems.push(FoodItem(1, "Pizza", 10));
        foodItems.push(FoodItem(2, "Burger", 15));
        foodItems.push(FoodItem(3, "Sushi", 25));
        foodItems.push(FoodItem(4, "Steak", 50));

    }

    // Override decimals to make tokens non-fractional
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    // Mint tokens (only owner can mint)
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Burn tokens
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    // Redeem tokens for a food item
    function redeem(uint256 itemId) external {
        require(itemId > 0 && itemId <= foodItems.length, "Invalid item ID");
        FoodItem memory item = foodItems[itemId - 1];
        require(balanceOf(msg.sender) >= item.cost, "Insufficient tokens");

        // Deduct tokens and assign item to user
        _burn(msg.sender, item.cost);
        ownedFoodItems[msg.sender].push(item);

        emit ItemRedeemed(msg.sender, item.id, item.name, item.cost);
    }

    // Get all available food items
    function getFoodItems() external view returns (FoodItem[] memory) {
        return foodItems;
    }

    // Get items owned by the caller
    function getOwnedItems() external view returns (FoodItem[] memory) {
        return ownedFoodItems[msg.sender];
    }
}
