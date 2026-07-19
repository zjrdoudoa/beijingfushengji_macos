import Foundation

public struct InventoryItem: Codable, Equatable, Hashable, Identifiable {
    public var id: String { productID }
    public var productID: String
    public var quantity: Int
    public var averageCost: Int

    public init(productID: String, quantity: Int, averageCost: Int) {
        self.productID = productID
        self.quantity = quantity
        self.averageCost = averageCost
    }
}
