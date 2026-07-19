import Foundation

public struct MarketPrice: Codable, Equatable, Hashable, Identifiable {
    public var id: String { productID }
    public var productID: String
    public var locationID: String
    public var price: Int
    public var trendKey: String?

    public init(productID: String, locationID: String, price: Int, trendKey: String? = nil) {
        self.productID = productID
        self.locationID = locationID
        self.price = price
        self.trendKey = trendKey
    }
}
