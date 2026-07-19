import Foundation

public struct Location: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public var nameKey: String
    public var travelCost: Int
    public var marketModifiers: [String: Double]

    public init(
        id: String,
        nameKey: String,
        travelCost: Int,
        marketModifiers: [String: Double]
    ) {
        self.id = id
        self.nameKey = nameKey
        self.travelCost = travelCost
        self.marketModifiers = marketModifiers
    }
}
