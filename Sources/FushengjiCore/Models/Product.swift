import Foundation

public struct Product: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public var nameKey: String
    public var category: String
    public var unitKey: String
    public var basePrice: Int
    public var minPrice: Int
    public var maxPrice: Int
    public var riskLevel: Int

    public init(
        id: String,
        nameKey: String,
        category: String,
        unitKey: String,
        basePrice: Int,
        minPrice: Int,
        maxPrice: Int,
        riskLevel: Int
    ) {
        self.id = id
        self.nameKey = nameKey
        self.category = category
        self.unitKey = unitKey
        self.basePrice = basePrice
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.riskLevel = riskLevel
    }
}
