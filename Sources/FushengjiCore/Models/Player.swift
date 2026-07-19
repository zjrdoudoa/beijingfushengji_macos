import Foundation

public struct Player: Codable, Equatable {
    public var roleID: String
    public var cash: Int
    public var debt: Int
    public var health: Int
    public var maxHealth: Int
    public var capacity: Int
    public var currentLocationID: String
    public var inventory: [InventoryItem]

    public init(
        roleID: String,
        cash: Int,
        debt: Int,
        health: Int,
        maxHealth: Int,
        capacity: Int,
        currentLocationID: String,
        inventory: [InventoryItem] = []
    ) {
        self.roleID = roleID
        self.cash = cash
        self.debt = debt
        self.health = health
        self.maxHealth = maxHealth
        self.capacity = capacity
        self.currentLocationID = currentLocationID
        self.inventory = inventory
    }

    public var usedCapacity: Int {
        inventory.reduce(0) { $0 + $1.quantity }
    }

    public var availableCapacity: Int {
        max(0, capacity - usedCapacity)
    }

    public func quantity(of productID: String) -> Int {
        inventory.first(where: { $0.productID == productID })?.quantity ?? 0
    }

    public func netWorth(market: [MarketPrice]) -> Int {
        let inventoryValue = inventory.reduce(0) { partial, item in
            let price = market.first(where: { $0.productID == item.productID })?.price ?? item.averageCost
            return partial + price * item.quantity
        }
        return cash + inventoryValue - debt
    }

    public mutating func addInventory(productID: String, quantity: Int, unitPrice: Int) {
        guard quantity > 0 else { return }

        if let index = inventory.firstIndex(where: { $0.productID == productID }) {
            let existing = inventory[index]
            let totalCost = existing.averageCost * existing.quantity + unitPrice * quantity
            let newQuantity = existing.quantity + quantity
            inventory[index].quantity = newQuantity
            inventory[index].averageCost = totalCost / newQuantity
        } else {
            inventory.append(InventoryItem(productID: productID, quantity: quantity, averageCost: unitPrice))
        }
    }

    @discardableResult
    public mutating func removeInventory(productID: String, quantity: Int) -> Bool {
        guard quantity > 0, let index = inventory.firstIndex(where: { $0.productID == productID }) else {
            return false
        }

        guard inventory[index].quantity >= quantity else {
            return false
        }

        inventory[index].quantity -= quantity
        if inventory[index].quantity == 0 {
            inventory.remove(at: index)
        }
        return true
    }
}
